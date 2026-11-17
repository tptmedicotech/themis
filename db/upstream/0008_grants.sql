-- Privileges for tpt_app (runtime) and staff roles. Roles themselves are created by
-- infrastructure bootstrap; this migration is idempotent if a role is missing (PGlite tests
-- create them first).

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'tpt_app') then
    create role tpt_app nobypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'tpt_staff_readonly') then
    create role tpt_staff_readonly nologin nobypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'tpt_staff_support') then
    create role tpt_staff_support nologin nobypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'tpt_staff_billing') then
    create role tpt_staff_billing nologin nobypassrls;
  end if;
end
$$;

grant usage on schema util, iam, billing, clinical, knowledge, ai, audit, admin to tpt_app;
grant usage on schema util, iam, billing, audit, admin to tpt_staff_readonly;
grant usage on schema admin to tpt_staff_support, tpt_staff_billing;

grant select, insert, update on all tables in schema iam to tpt_app;
grant select, insert, update on all tables in schema clinical to tpt_app;
grant select, insert, update on all tables in schema knowledge to tpt_app;
grant select, insert, update, delete on all tables in schema ai to tpt_app;

grant select on billing.plans, billing.platform_settings, billing.billing_settings,
  billing.subscriptions, billing.payment_attempts, billing.payfast_notifications,
  billing.quota_periods, billing.report_slots, billing.entitlement_overrides to tpt_app;
grant insert, update on billing.billing_settings, billing.subscriptions,
  billing.payment_attempts, billing.payfast_notifications to tpt_app;

grant select, insert on audit.audit_log, audit.export_audit, audit.ingest_audit, audit.usage_events to tpt_app;

grant usage, select on all sequences in schema iam, billing, clinical, knowledge, ai, audit to tpt_app;

grant execute on all functions in schema util, iam, billing to tpt_app;
grant execute on function util.current_org_id() to tpt_app;
grant execute on function util.current_user_id() to tpt_app;
grant execute on function util.current_role() to tpt_app;

-- Runtime must not write slots/periods directly.
revoke insert, update, delete on billing.quota_periods, billing.report_slots from tpt_app;
revoke update, delete on audit.audit_log from tpt_app;

-- Staff: no access to clinical, knowledge, ai (denied by default: no grants, no policies).
grant select on iam.organisations, iam.memberships, iam.invitations, iam.org_settings, iam.org_ai_policy
  to tpt_staff_readonly;
grant select on iam.profiles to tpt_staff_readonly;
grant select on billing.plans, billing.platform_settings, billing.billing_settings,
  billing.subscriptions, billing.payment_attempts, billing.payfast_notifications,
  billing.quota_periods, billing.report_slots, billing.entitlement_overrides
  to tpt_staff_readonly;
grant select on audit.audit_log, audit.usage_events to tpt_staff_readonly;

-- Staff policies: they have no app.org_id, so tenant policies would hide everything.
-- Add a separate permissive policy that allows staff roles to read iam/billing/audit only.
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
    'iam.profiles',
    'billing.plans',
    'billing.platform_settings',
    'billing.billing_settings',
    'billing.subscriptions',
    'billing.payment_attempts',
    'billing.payfast_notifications',
    'billing.quota_periods',
    'billing.report_slots',
    'billing.entitlement_overrides',
    'audit.audit_log',
    'audit.usage_events'
  ]
  loop
    execute format(
      'create policy staff_read on %s for select to tpt_staff_readonly using (true)',
      t
    );
  end loop;
end
$$;
