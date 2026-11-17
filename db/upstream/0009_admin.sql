-- Staff writes go through admin.* SECURITY DEFINER functions only.

create or replace function admin.write_audit(
  p_action text,
  p_target_type text,
  p_target_id uuid,
  p_before jsonb,
  p_after jsonb
) returns void
language plpgsql
security definer
set search_path = audit, pg_temp
as $$
begin
  insert into audit.audit_log (action, target_type, target_id, before, after, db_session_user, actor_role)
  values (
    p_action,
    p_target_type,
    p_target_id,
    p_before,
    p_after,
    session_user::text,
    current_setting('app.acting_user', true)
  );
end;
$$;

create or replace function admin.set_plan_limit(
  p_plan_key text,
  p_report_limit_monthly integer,
  p_apply_now boolean default false
) returns billing.plans
language plpgsql
security definer
set search_path = billing, admin, pg_temp
as $$
declare
  before_row billing.plans;
  after_row billing.plans;
begin
  if not pg_has_role(session_user, 'tpt_staff_billing', 'member') and session_user <> 'tpt_staff_billing' then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  select * into before_row from billing.plans where key = p_plan_key;
  if not found then
    raise exception 'NOT_FOUND' using errcode = 'P0002';
  end if;

  update billing.plans
    set report_limit_monthly = p_report_limit_monthly
    where key = p_plan_key
    returning * into after_row;

  if p_apply_now then
    update billing.quota_periods qp
      set limit_value = p_report_limit_monthly
    from billing.subscriptions s
    where s.organization_id = qp.organization_id
      and s.plan_key = p_plan_key
      and qp.capability = 'reports'
      and qp.period_end > now();
  end if;

  perform admin.write_audit(
    'plan.limit_change',
    'plan',
    null,
    to_jsonb(before_row),
    to_jsonb(after_row) || jsonb_build_object('apply_now', p_apply_now)
  );
  return after_row;
end;
$$;

create or replace function admin.set_grace_days(
  p_organization_id uuid,
  p_grace_days integer
) returns billing.billing_settings
language plpgsql
security definer
set search_path = billing, admin, pg_temp
as $$
declare
  before_row billing.billing_settings;
  after_row billing.billing_settings;
begin
  if not pg_has_role(session_user, 'tpt_staff_billing', 'member') and session_user <> 'tpt_staff_billing' then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  select * into before_row from billing.billing_settings where organization_id = p_organization_id;
  insert into billing.billing_settings (organization_id, grace_days)
  values (p_organization_id, p_grace_days)
  on conflict (organization_id) do update set grace_days = excluded.grace_days
  returning * into after_row;
  perform admin.write_audit('billing.grace_days', 'organisation', p_organization_id, to_jsonb(before_row), to_jsonb(after_row));
  return after_row;
end;
$$;

create or replace function admin.set_entitlement_override(
  p_organization_id uuid,
  p_capability text,
  p_enabled boolean,
  p_reason text
) returns billing.entitlement_overrides
language plpgsql
security definer
set search_path = billing, admin, pg_temp
as $$
declare
  rec billing.entitlement_overrides;
begin
  if not pg_has_role(session_user, 'tpt_staff_billing', 'member') and session_user <> 'tpt_staff_billing' then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  insert into billing.entitlement_overrides (organization_id, capability, enabled, reason, created_by)
  values (p_organization_id, p_capability, p_enabled, p_reason, session_user)
  returning * into rec;
  perform admin.write_audit('billing.entitlement_override', 'organisation', p_organization_id, null, to_jsonb(rec));
  return rec;
end;
$$;

create or replace function admin.suspend_membership(p_membership_id uuid)
returns iam.memberships
language plpgsql
security definer
set search_path = iam, admin, pg_temp
as $$
declare
  before_row iam.memberships;
  after_row iam.memberships;
begin
  if not pg_has_role(session_user, 'tpt_staff_support', 'member') and session_user <> 'tpt_staff_support' then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;
  select * into before_row from iam.memberships where id = p_membership_id;
  if not found then
    raise exception 'NOT_FOUND' using errcode = 'P0002';
  end if;
  update iam.memberships set status = 'suspended' where id = p_membership_id returning * into after_row;
  perform admin.write_audit('iam.membership_suspend', 'membership', p_membership_id, to_jsonb(before_row), to_jsonb(after_row));
  return after_row;
end;
$$;

revoke all on function admin.set_plan_limit(text, integer, boolean) from public;
revoke all on function admin.set_grace_days(uuid, integer) from public;
revoke all on function admin.set_entitlement_override(uuid, text, boolean, text) from public;
revoke all on function admin.suspend_membership(uuid) from public;
revoke all on function admin.write_audit(text, text, uuid, jsonb, jsonb) from public;

grant execute on function admin.set_plan_limit(text, integer, boolean) to tpt_staff_billing;
grant execute on function admin.set_grace_days(uuid, integer) to tpt_staff_billing;
grant execute on function admin.set_entitlement_override(uuid, text, boolean, text) to tpt_staff_billing;
grant execute on function admin.suspend_membership(uuid) to tpt_staff_support;
grant execute on function admin.write_audit(text, text, uuid, jsonb, jsonb) to tpt_staff_billing, tpt_staff_support;
