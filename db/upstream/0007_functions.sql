-- SECURITY DEFINER helpers. The runtime role may EXECUTE these and nothing more
-- on quota/slot tables (grants in 0008).

create or replace function iam.upsert_profile(
  p_firebase_uid text,
  p_email text,
  p_display_name text
) returns iam.profiles
language plpgsql
security definer
set search_path = iam, pg_temp
as $$
declare
  rec iam.profiles;
begin
  insert into iam.profiles (firebase_uid, email, display_name)
  values (p_firebase_uid, p_email, p_display_name)
  on conflict (firebase_uid) do update
    set email = coalesce(excluded.email, iam.profiles.email),
        display_name = coalesce(excluded.display_name, iam.profiles.display_name)
  returning * into rec;
  return rec;
end;
$$;

create or replace function iam.memberships_for_user(p_user_id uuid)
returns table(organization_id uuid, role text)
language sql
stable
security definer
set search_path = iam, pg_temp
as $$
  select m.organization_id, m.role
    from iam.memberships m
   where m.user_id = p_user_id
     and m.status = 'active';
$$;

create or replace function billing.grace_days_for(p_org uuid)
returns integer
language sql
stable
security definer
set search_path = billing, pg_temp
as $$
  select coalesce(
    (select grace_days from billing.billing_settings where organization_id = p_org),
    (select grace_days from billing.platform_settings where id)
  );
$$;

create or replace function billing.subscription_allows_new_slots(p_org uuid, p_now timestamptz)
returns boolean
language plpgsql
stable
security definer
set search_path = billing, pg_temp
as $$
declare
  rec billing.subscriptions%rowtype;
begin
  select * into rec from billing.subscriptions where organization_id = p_org;
  if not found then
    return false;
  end if;
  if rec.status = 'active' then
    return true;
  end if;
  if rec.status = 'past_due' then
    return rec.current_period_end is not null
      and p_now <= rec.current_period_end + make_interval(days => billing.grace_days_for(p_org));
  end if;
  if rec.status = 'cancelled' then
    return rec.current_period_end is not null and p_now <= rec.current_period_end;
  end if;
  return false;
end;
$$;

create or replace function billing.current_quota_period(p_org uuid, p_now timestamptz)
returns billing.quota_periods
language plpgsql
security definer
set search_path = billing, pg_temp
as $$
declare
  rec billing.quota_periods%rowtype;
  sub billing.subscriptions%rowtype;
  lim integer;
begin
  select * into rec
  from billing.quota_periods
  where organization_id = p_org
    and capability = 'reports'
    and period_start <= p_now
    and period_end > p_now
  order by period_start desc
  limit 1;
  if found then
    return rec;
  end if;

  select * into sub from billing.subscriptions where organization_id = p_org;
  if not found or sub.current_period_start is null or sub.current_period_end is null then
    return rec;
  end if;

  select report_limit_monthly into lim from billing.plans where key = sub.plan_key;

  insert into billing.quota_periods (
    organization_id, capability, period_start, period_end, limit_value
  ) values (
    p_org, 'reports', sub.current_period_start, sub.current_period_end, lim
  )
  on conflict (organization_id, capability, period_start) do update
    set period_end = excluded.period_end
  returning * into rec;
  return rec;
end;
$$;

create or replace function billing.assert_can_create_report(p_org uuid, p_now timestamptz)
returns void
language plpgsql
security definer
set search_path = billing, pg_temp
as $$
declare
  period billing.quota_periods;
begin
  if p_org is distinct from util.current_org_id() then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  if not billing.subscription_allows_new_slots(p_org, p_now) then
    raise exception 'SUBSCRIPTION_INACTIVE' using errcode = '55P03';
  end if;
  period := billing.current_quota_period(p_org, p_now);
  if period.id is null then
    raise exception 'SUBSCRIPTION_INACTIVE' using errcode = '55P03';
  end if;
  if period.limit_value is not null
     and (period.consumed + period.reserved) >= period.limit_value then
    raise exception 'REPORT_LIMIT_REACHED' using errcode = 'P0001';
  end if;
end;
$$;

create or replace function billing.reserve_report_slot(p_report_id uuid, p_now timestamptz default now())
returns jsonb
language plpgsql
security definer
set search_path = billing, clinical, iam, util, pg_temp
as $$
declare
  v_org uuid;
  v_locked timestamptz;
  v_slot billing.report_slots%rowtype;
  v_period billing.quota_periods;
begin
  select organization_id, generation_locked_at
    into v_org, v_locked
  from clinical.reports
  where id = p_report_id;

  if v_org is null then
    raise exception 'REPORT_NOT_FOUND' using errcode = 'P0002';
  end if;
  if v_org is distinct from util.current_org_id() then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  if v_locked is not null then
    raise exception 'REPORT_FINALISED' using errcode = 'P0001';
  end if;

  select * into v_slot from billing.report_slots where report_id = p_report_id;
  if found and v_slot.state in ('reserved', 'consumed') then
    return jsonb_build_object('slotId', v_slot.id, 'state', v_slot.state, 'created', false);
  end if;

  if not billing.subscription_allows_new_slots(v_org, p_now) then
    raise exception 'SUBSCRIPTION_INACTIVE' using errcode = '55P03';
  end if;

  v_period := billing.current_quota_period(v_org, p_now);
  if v_period.id is null then
    raise exception 'SUBSCRIPTION_INACTIVE' using errcode = '55P03';
  end if;
  if v_period.limit_value is not null
     and (v_period.consumed + v_period.reserved) >= v_period.limit_value then
    raise exception 'REPORT_LIMIT_REACHED' using errcode = 'P0001';
  end if;

  if found and v_slot.state = 'released' then
    update billing.report_slots
      set state = 'reserved', period_id = v_period.id, reserved_at = p_now, released_at = null
      where id = v_slot.id
      returning * into v_slot;
  else
    insert into billing.report_slots (organization_id, report_id, state, period_id, reserved_at)
    values (v_org, p_report_id, 'reserved', v_period.id, p_now)
    returning * into v_slot;
  end if;

  update billing.quota_periods
    set reserved = reserved + 1
    where id = v_period.id;

  return jsonb_build_object('slotId', v_slot.id, 'state', v_slot.state, 'created', true);
end;
$$;

create or replace function billing.finalise_report(
  p_report_id uuid,
  p_reason text,
  p_now timestamptz default now()
) returns jsonb
language plpgsql
security definer
set search_path = billing, clinical, audit, util, pg_temp
as $$
declare
  v_org uuid;
  v_locked timestamptz;
  v_slot billing.report_slots%rowtype;
begin
  if p_reason not in ('export', 'download', 'complete', 'copy') then
    raise exception 'VALIDATION_FAILED' using errcode = '22023';
  end if;

  select organization_id, generation_locked_at
    into v_org, v_locked
  from clinical.reports
  where id = p_report_id;

  if v_org is null then
    raise exception 'REPORT_NOT_FOUND' using errcode = 'P0002';
  end if;
  if v_org is distinct from util.current_org_id() then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  if v_locked is not null then
    return jsonb_build_object(
      'reportId', p_report_id,
      'finalised', true,
      'alreadyFinalised', true,
      'generationLockedAt', v_locked
    );
  end if;

  update clinical.reports
    set generation_locked_at = p_now,
        finalised_reason = p_reason,
        status = case when p_reason = 'complete' then 'complete' else status end
    where id = p_report_id;

  select * into v_slot from billing.report_slots where report_id = p_report_id;
  if found and v_slot.state = 'reserved' then
    update billing.report_slots
      set state = 'consumed', consumed_at = p_now
      where id = v_slot.id;
    update billing.quota_periods
      set reserved = reserved - 1, consumed = consumed + 1
      where id = v_slot.period_id;
  end if;

  insert into audit.export_audit (organization_id, report_id, user_id, reason)
  values (v_org, p_report_id, util.current_user_id(), p_reason);

  return jsonb_build_object(
    'reportId', p_report_id,
    'finalised', true,
    'alreadyFinalised', false,
    'generationLockedAt', p_now
  );
end;
$$;

create or replace function billing.release_report_slot(p_report_id uuid, p_now timestamptz default now())
returns jsonb
language plpgsql
security definer
set search_path = billing, util, pg_temp
as $$
declare
  v_slot billing.report_slots%rowtype;
begin
  select * into v_slot from billing.report_slots where report_id = p_report_id;
  if not found then
    raise exception 'REPORT_NOT_FOUND' using errcode = 'P0002';
  end if;
  if v_slot.organization_id is distinct from util.current_org_id() then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  if v_slot.state <> 'reserved' then
    return jsonb_build_object('slotId', v_slot.id, 'state', v_slot.state, 'released', false);
  end if;

  update billing.report_slots
    set state = 'released', released_at = p_now
    where id = v_slot.id;
  update billing.quota_periods
    set reserved = reserved - 1
    where id = v_slot.period_id;

  return jsonb_build_object('slotId', v_slot.id, 'state', 'released', 'released', true);
end;
$$;
