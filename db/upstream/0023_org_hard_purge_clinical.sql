-- Explicit clinical + knowledge tenant deletes before org row (safe cascade; see org-purge spike).

create or replace function iam.hard_purge_organisation(p_organization_id uuid)
returns void
language plpgsql
security definer
set search_path = iam, billing, clinical, knowledge, ai, audit, pg_temp
as $$
begin
  if not exists (
    select 1
      from iam.organisations o
     where o.id = p_organization_id
       and o.status = 'deleted'
       and o.purge_eligible_at is not null
       and o.purge_eligible_at <= now()
  ) then
    raise exception 'NOT_ELIGIBLE' using errcode = 'P0001';
  end if;

  delete from ai.model_usage where organization_id = p_organization_id;
  delete from ai.agent_runs where organization_id = p_organization_id;
  delete from knowledge.ingestion_jobs where organization_id = p_organization_id;
  delete from knowledge.chunks where organization_id = p_organization_id;
  delete from knowledge.documents where organization_id = p_organization_id;
  delete from billing.report_slots where organization_id = p_organization_id;
  delete from clinical.dictation_segments where organization_id = p_organization_id;
  delete from clinical.dictation_sessions where organization_id = p_organization_id;
  delete from clinical.scan_compositions where organization_id = p_organization_id;
  delete from clinical.export_files where organization_id = p_organization_id;
  delete from clinical.attachments where organization_id = p_organization_id;
  delete from clinical.report_versions where organization_id = p_organization_id;
  delete from clinical.reports where organization_id = p_organization_id;
  delete from billing.payment_attempts where organization_id = p_organization_id;
  delete from billing.quota_periods where organization_id = p_organization_id;
  delete from billing.entitlement_overrides where organization_id = p_organization_id;
  delete from billing.subscriptions where organization_id = p_organization_id;
  delete from billing.billing_settings where organization_id = p_organization_id;
  update billing.payfast_notifications
     set organization_id = null
   where organization_id = p_organization_id;
  delete from audit.export_audit where organization_id = p_organization_id;
  delete from audit.ingest_audit where organization_id = p_organization_id;
  delete from audit.usage_events where organization_id = p_organization_id;
  delete from iam.memberships where organization_id = p_organization_id;
  delete from iam.invitations where organization_id = p_organization_id;
  delete from iam.org_settings where organization_id = p_organization_id;
  delete from iam.org_ai_policy where organization_id = p_organization_id;
  delete from iam.organisations where id = p_organization_id;

  insert into audit.audit_log (action, target_type, target_id, after)
  values (
    'iam.organisation_hard_purge',
    'organisation',
    p_organization_id,
    jsonb_build_object('purged_at', now())
  );
end;
$$;

comment on function iam.hard_purge_organisation(uuid) is
  'Hard-delete one soft-deleted org and tenant rows after purge_eligible_at. Job/migrator only.';
