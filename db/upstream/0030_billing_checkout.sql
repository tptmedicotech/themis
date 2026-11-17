-- Checkout payment attempts, subscription checkout state, and attempt-aware Payfast ITN.

alter table billing.payment_attempts
  add column if not exists owner_user_id uuid references iam.profiles (id),
  add column if not exists plan_key text references billing.plans (key),
  add column if not exists recurring_amount_cents integer,
  add column if not exists kind text,
  add column if not exists previous_plan_key text references billing.plans (key),
  add column if not exists updated_at timestamptz not null default now();

alter table billing.payment_attempts
  drop constraint if exists payment_attempts_status_check;
alter table billing.payment_attempts
  add constraint payment_attempts_status_check
  check (status in ('pending', 'complete', 'failed', 'cancelled'));

alter table billing.payment_attempts
  drop constraint if exists payment_attempts_kind_check;
alter table billing.payment_attempts
  add constraint payment_attempts_kind_check
  check (kind is null or kind in ('initial', 'upgrade'));

create unique index if not exists payment_attempts_payfast_payment_id_uidx
  on billing.payment_attempts (payfast_payment_id)
  where payfast_payment_id is not null;

alter table billing.subscriptions
  add column if not exists checkout_attempt_id uuid references billing.payment_attempts (id),
  add column if not exists last_payment_outcome text,
  add column if not exists previous_payfast_token text,
  add column if not exists previous_subscription_cancellation text;

create trigger payment_attempts_updated_at before update on billing.payment_attempts
  for each row execute function util.set_updated_at();

create or replace function billing.apply_payfast_itn_effects(
  p_pf_payment_id text,
  p_payment_attempt_id uuid,
  p_payload jsonb,
  p_source_ip text,
  p_outcome text,
  p_reason text,
  p_payfast_token text,
  p_period_start timestamptz,
  p_period_end timestamptz
) returns jsonb
language plpgsql
security definer
set search_path = billing, iam, pg_temp
as $$
declare
  v_existing text;
  v_attempt billing.payment_attempts%rowtype;
  v_sub billing.subscriptions%rowtype;
  v_period_end timestamptz;
begin
  select outcome into v_existing
    from billing.payfast_notifications
   where pf_payment_id = p_pf_payment_id;
  if found then
    return jsonb_build_object('outcome', 'already_processed');
  end if;

  if p_payment_attempt_id is null then
    insert into billing.payfast_notifications (
      pf_payment_id, organization_id, payload, source_ip, outcome, reason
    ) values (
      p_pf_payment_id, null, p_payload, p_source_ip, 'rejected', 'missing_payment_attempt'
    );
    return jsonb_build_object('outcome', 'rejected', 'reason', 'missing_payment_attempt');
  end if;

  select * into v_attempt
    from billing.payment_attempts
   where id = p_payment_attempt_id
   for update;

  if not found then
    insert into billing.payfast_notifications (
      pf_payment_id, organization_id, payload, source_ip, outcome, reason
    ) values (
      p_pf_payment_id, null, p_payload, p_source_ip, 'rejected', 'unknown_attempt'
    );
    return jsonb_build_object('outcome', 'rejected', 'reason', 'unknown_attempt');
  end if;

  insert into billing.payfast_notifications (
    pf_payment_id, organization_id, payload, source_ip, outcome, reason
  ) values (
    p_pf_payment_id, v_attempt.organization_id, p_payload, p_source_ip, p_outcome, p_reason
  );

  if p_outcome <> 'applied' then
    if p_outcome = 'ignored' and v_attempt.status = 'pending' then
      update billing.payment_attempts
         set status = 'cancelled', updated_at = now()
       where id = v_attempt.id;
    elsif p_outcome = 'ignored' and p_reason like 'status_%' and v_attempt.status = 'pending' then
      update billing.payment_attempts
         set status = case when p_reason = 'status_CANCELLED' then 'cancelled' else 'failed' end,
             updated_at = now()
       where id = v_attempt.id;
      update billing.subscriptions
         set checkout_attempt_id = null,
             last_payment_outcome = case when p_reason = 'status_CANCELLED' then 'cancelled' else 'failed' end,
             status = case when status in ('processing') then 'prepayment' else status end,
             updated_at = now()
       where organization_id = v_attempt.organization_id
         and checkout_attempt_id = v_attempt.id;
    end if;
    if p_reason is not null and p_reason <> '' then
      return jsonb_build_object('outcome', p_outcome, 'reason', p_reason);
    end if;
    return jsonb_build_object('outcome', p_outcome);
  end if;

  select * into v_sub
    from billing.subscriptions
   where organization_id = v_attempt.organization_id
   for update;

  if v_sub.checkout_attempt_id is distinct from v_attempt.id then
    update billing.payment_attempts
       set status = 'cancelled', updated_at = now()
     where id = v_attempt.id and status = 'pending';
    return jsonb_build_object('outcome', 'ignored', 'reason', 'superseded_checkout');
  end if;

  if v_attempt.status <> 'pending' then
    return jsonb_build_object('outcome', 'rejected', 'reason', 'attempt_not_pending');
  end if;

  if exists (
    select 1 from billing.payment_attempts
     where payfast_payment_id = p_pf_payment_id and id <> v_attempt.id
  ) then
    return jsonb_build_object('outcome', 'rejected', 'reason', 'payment_id_conflict');
  end if;

  v_period_end := case
    when v_attempt.kind = 'upgrade' and v_sub.current_period_end is not null then v_sub.current_period_end
    else p_period_end
  end;

  update billing.payment_attempts
     set status = 'complete',
         payfast_payment_id = p_pf_payment_id,
         updated_at = now()
   where id = v_attempt.id;

  update billing.subscriptions
     set plan_key = v_attempt.plan_key,
         status = 'active',
         payfast_token = coalesce(nullif(p_payfast_token, ''), payfast_token),
         current_period_start = p_period_start,
         current_period_end = v_period_end,
         checkout_attempt_id = null,
         last_payment_outcome = null,
         pending_plan_key = null,
         scheduled_effective_at = null,
         previous_payfast_token = case
           when v_attempt.kind = 'upgrade' and payfast_token is not null then payfast_token
           else previous_payfast_token
         end,
         previous_subscription_cancellation = case
           when v_attempt.kind = 'upgrade' and payfast_token is not null then 'pending_configuration'
           else coalesce(previous_subscription_cancellation, 'not_required')
         end,
         updated_at = now()
   where organization_id = v_attempt.organization_id;

  update iam.organisations
     set org_type = case when v_attempt.plan_key = 'institutional_team' then 'institutional' else org_type end,
         updated_at = now()
   where id = v_attempt.organization_id;

  insert into billing.quota_periods (organization_id, capability, period_start, period_end, limit_value)
  select v_attempt.organization_id, 'reports', p_period_start, v_period_end, p.report_limit_monthly
    from billing.plans p
   where p.key = v_attempt.plan_key
  on conflict (organization_id, capability, period_start) do nothing;

  return jsonb_build_object('outcome', 'applied');
end;
$$;

revoke all on function billing.apply_payfast_itn_effects(
  text, uuid, jsonb, text, text, text, text, timestamptz, timestamptz
) from public;
grant execute on function billing.apply_payfast_itn_effects(
  text, uuid, jsonb, text, text, text, text, timestamptz, timestamptz
) to tpt_app;

-- Drop legacy signature (org/plan params) after replacement.
drop function if exists billing.apply_payfast_itn_effects(
  text, uuid, jsonb, text, text, text, text, text, timestamptz, timestamptz
);
