-- Org-scoped product activity feed (richer than audit.usage_events metering).

create table audit.activity_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  user_id uuid not null references iam.profiles (id),
  kind text not null,
  entity_type text,
  entity_id text,
  report_id uuid references clinical.reports (id) on delete set null,
  report_family text,
  metadata jsonb not null default '{}'::jsonb,
  client_ip inet,
  user_agent text,
  idempotency_key text,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint activity_events_kind_len check (char_length(kind) <= 128),
  constraint activity_events_entity_type_len check (entity_type is null or char_length(entity_type) <= 64),
  constraint activity_events_entity_id_len check (entity_id is null or char_length(entity_id) <= 256)
);

create index activity_events_org_occurred_idx
  on audit.activity_events (organization_id, occurred_at desc, id desc);

create unique index activity_events_idempotency
  on audit.activity_events (organization_id, idempotency_key)
  where idempotency_key is not null;

alter table audit.activity_events enable row level security;
alter table audit.activity_events force row level security;

create policy tenant_all on audit.activity_events
  for all to tpt_app
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());

do $$
declare
  owner_name name;
begin
  select r.rolname into owner_name
    from pg_class c
    join pg_roles r on r.oid = c.relowner
   where c.oid = 'audit.activity_events'::regclass;
  execute format(
    'create policy definer_owner_all on audit.activity_events as permissive for all to %I using (true) with check (true)',
    owner_name
  );
end
$$;

grant select, insert on audit.activity_events to tpt_app;
grant select on audit.activity_events to tpt_staff_readonly;

create policy staff_read on audit.activity_events
  for select to tpt_staff_readonly using (true);

-- Keep org hard purge in sync (0024 baseline + activity_events).
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
  delete from ai.run_events where organization_id = p_organization_id;
  delete from ai.run_steps where organization_id = p_organization_id;
  delete from ai.tool_calls where organization_id = p_organization_id;
  delete from ai.citations where organization_id = p_organization_id;
  delete from ai.validations where organization_id = p_organization_id;
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
  delete from audit.activity_events where organization_id = p_organization_id;
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
