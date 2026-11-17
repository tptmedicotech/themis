-- Persist Payfast ITN outcomes under RLS (tpt_app cannot insert quota_periods directly).
create or replace function billing.apply_payfast_itn_effects(
  p_pf_payment_id text,
  p_org_id uuid,
  p_payload jsonb,
  p_source_ip text,
  p_outcome text,
  p_reason text,
  p_plan_key text,
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
begin
  select outcome into v_existing
    from billing.payfast_notifications
   where pf_payment_id = p_pf_payment_id;
  if found then
    return jsonb_build_object('outcome', 'already_processed');
  end if;

  insert into billing.payfast_notifications (
    pf_payment_id, organization_id, payload, source_ip, outcome, reason
  ) values (
    p_pf_payment_id, p_org_id, p_payload, p_source_ip, p_outcome, p_reason
  );

  if p_outcome = 'applied' and p_org_id is not null then
    insert into billing.subscriptions (
      organization_id, plan_key, status, payfast_token, current_period_start, current_period_end
    ) values (
      p_org_id, coalesce(nullif(p_plan_key, ''), 'solo_basic'), 'active',
      nullif(p_payfast_token, ''), p_period_start, p_period_end
    )
    on conflict (organization_id) do update set
      plan_key = excluded.plan_key,
      status = 'active',
      payfast_token = coalesce(excluded.payfast_token, billing.subscriptions.payfast_token),
      current_period_start = excluded.current_period_start,
      current_period_end = excluded.current_period_end;

    insert into billing.quota_periods (organization_id, capability, period_start, period_end, limit_value)
    select p_org_id, 'reports', p_period_start, p_period_end, p.report_limit_monthly
      from billing.plans p
     where p.key = coalesce(nullif(p_plan_key, ''), 'solo_basic')
    on conflict (organization_id, capability, period_start) do nothing;
  end if;

  if p_reason is not null and p_reason <> '' then
    return jsonb_build_object('outcome', p_outcome, 'reason', p_reason);
  end if;
  return jsonb_build_object('outcome', p_outcome);
end;
$$;

revoke all on function billing.apply_payfast_itn_effects(
  text, uuid, jsonb, text, text, text, text, text, timestamptz, timestamptz
) from public;
grant execute on function billing.apply_payfast_itn_effects(
  text, uuid, jsonb, text, text, text, text, text, timestamptz, timestamptz
) to tpt_app;
