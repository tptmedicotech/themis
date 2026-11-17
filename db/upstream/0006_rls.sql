-- Enable and FORCE row-level security on every tenant table.
-- The runtime role is not the owner and not BYPASSRLS. FORCE also covers table owners
-- (needed in PGlite tests, where the migrating user owns the tables).

do $$
declare
  t text;
begin
  foreach t in array array[
    'iam.organisations',
    'iam.memberships',
    'iam.invitations',
    'iam.org_settings',
    'iam.org_ai_policy',
    'billing.billing_settings',
    'billing.subscriptions',
    'billing.payment_attempts',
    'billing.payfast_notifications',
    'billing.quota_periods',
    'billing.report_slots',
    'billing.entitlement_overrides',
    'clinical.reports',
    'clinical.report_versions',
    'clinical.attachments',
    'clinical.export_files',
    'clinical.scan_compositions',
    'clinical.dictation_sessions',
    'clinical.dictation_segments',
    'knowledge.documents',
    'knowledge.chunks',
    'knowledge.ingestion_jobs',
    'ai.agent_runs',
    'ai.run_events',
    'ai.run_steps',
    'ai.tool_calls',
    'ai.citations',
    'ai.validations',
    'ai.model_usage',
    'audit.export_audit',
    'audit.ingest_audit',
    'audit.usage_events'
  ]
  loop
    execute format('alter table %s enable row level security', t);
    execute format('alter table %s force row level security', t);
  end loop;
end
$$;

-- Organisations: a user sees orgs they belong to. During create, app.org_id is unset so
-- the insert policy allows the first row; membership is written in the same transaction.
create policy organisations_select on iam.organisations
  for select using (
    id = util.current_org_id()
    or exists (
      select 1 from iam.memberships m
      where m.organization_id = iam.organisations.id
        and m.user_id = util.current_user_id()
        and m.status = 'active'
    )
  );
create policy organisations_insert on iam.organisations
  for insert with check (true);
create policy organisations_update on iam.organisations
  for update using (id = util.current_org_id());

create policy memberships_all on iam.memberships
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());

-- Allow the creator to insert their owner membership before app.org_id is set,
-- as long as they are writing their own user_id.
create policy memberships_self_insert on iam.memberships
  for insert
  with check (user_id = util.current_user_id());

create policy invitations_all on iam.invitations
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());
create policy org_settings_all on iam.org_settings
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());
create policy org_ai_policy_all on iam.org_ai_policy
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());

create policy billing_settings_all on billing.billing_settings
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());
create policy subscriptions_all on billing.subscriptions
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());
create policy payment_attempts_all on billing.payment_attempts
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());
create policy payfast_notifications_all on billing.payfast_notifications
  using (organization_id = util.current_org_id())
  with check (organization_id = util.current_org_id());
create policy quota_periods_select on billing.quota_periods
  for select using (organization_id = util.current_org_id());
create policy report_slots_select on billing.report_slots
  for select using (organization_id = util.current_org_id());
create policy entitlement_overrides_select on billing.entitlement_overrides
  for select using (organization_id = util.current_org_id());

-- Tenant isolation for the rest: organization_id = app.org_id.
do $$
declare
  t text;
begin
  foreach t in array array[
    'clinical.reports',
    'clinical.report_versions',
    'clinical.attachments',
    'clinical.export_files',
    'clinical.scan_compositions',
    'clinical.dictation_sessions',
    'clinical.dictation_segments',
    'knowledge.documents',
    'knowledge.chunks',
    'knowledge.ingestion_jobs',
    'ai.agent_runs',
    'ai.run_events',
    'ai.run_steps',
    'ai.tool_calls',
    'ai.citations',
    'ai.validations',
    'ai.model_usage',
    'audit.export_audit',
    'audit.ingest_audit',
    'audit.usage_events'
  ]
  loop
    execute format(
      'create policy tenant_all on %s for all to tpt_app using (organization_id = util.current_org_id()) with check (organization_id = util.current_org_id())',
      t
    );
  end loop;
end
$$;

-- audit_log is append-only. No UPDATE/DELETE grants for the runtime role (see 0008).
-- Staff and the runtime may insert; select is org-scoped when org_id is set.
alter table audit.audit_log enable row level security;
alter table audit.audit_log force row level security;
create policy audit_log_select on audit.audit_log
  for select using (organization_id is null or organization_id = util.current_org_id());
create policy audit_log_insert on audit.audit_log
  for insert with check (organization_id is null or organization_id = util.current_org_id());

-- profiles: a user can read their own row; members of the current org can read each other.
alter table iam.profiles enable row level security;
alter table iam.profiles force row level security;
create policy profiles_self on iam.profiles
  using (
    id = util.current_user_id()
    or exists (
      select 1 from iam.memberships m
      where m.user_id = iam.profiles.id
        and m.organization_id = util.current_org_id()
        and m.status = 'active'
    )
  );
create policy profiles_insert_self on iam.profiles
  for insert with check (id = util.current_user_id() or firebase_uid is not null);

-- plans and platform_settings are readable by anyone authenticated (no org column).
alter table billing.plans enable row level security;
alter table billing.plans force row level security;
create policy plans_select on billing.plans for select using (true);

alter table billing.platform_settings enable row level security;
alter table billing.platform_settings force row level security;
create policy platform_settings_select on billing.platform_settings for select using (true);

alter table ai.prompt_versions enable row level security;
alter table ai.prompt_versions force row level security;
create policy prompt_versions_select on ai.prompt_versions for select using (true);
