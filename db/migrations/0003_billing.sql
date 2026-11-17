-- SQLite stand-in for db/upstream/0003_billing.sql
-- billing.report_slots is created in 0004_clinical.sql.
-- SQLite cannot add a foreign key to an existing column.
-- The report foreign key needs clinical_reports, and that table does not exist yet.
-- status values on payment attempts are the final check from upstream 0030.
-- SQLite cannot add that table check later.

create table billing_plans (
  key text primary key,
  name text not null,
  price_cents integer not null default 0 check (price_cents >= 0),
  currency text not null default 'ZAR',
  billing_interval text not null default 'monthly',
  report_limit_monthly integer check (report_limit_monthly is null or report_limit_monthly >= 0),
  seat_limit integer not null default 1 check (seat_limit >= 1),
  features text not null default '[]' check (json_valid(features)),
  "public" integer not null default 0 check ("public" in (0, 1)),
  active integer not null default 1 check (active in (0, 1)),
  placeholder integer not null default 1 check (placeholder in (0, 1)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table billing_billing_settings (
  organization_id text primary key references iam_organisations (id),
  grace_days integer not null default 7 check (grace_days >= 0 and grace_days <= 90),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table billing_platform_settings (
  id integer primary key check (id = 1),
  grace_days integer not null default 7 check (grace_days >= 0 and grace_days <= 90),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

insert into billing_platform_settings (id, grace_days) values (1, 7);

create table billing_subscriptions (
  id text primary key,
  organization_id text not null unique references iam_organisations (id),
  plan_key text not null references billing_plans (key),
  status text not null check (
    status in ('prepayment', 'processing', 'active', 'past_due', 'unpaid', 'cancelled')
  ),
  payfast_token text,
  current_period_start text,
  current_period_end text,
  pending_plan_key text references billing_plans (key),
  scheduled_effective_at text,
  cancelled_at text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table billing_payment_attempts (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  subscription_id text references billing_subscriptions (id),
  amount_cents integer not null,
  currency text not null default 'ZAR',
  status text not null check (status in ('pending', 'complete', 'failed', 'cancelled')),
  payfast_payment_id text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table billing_payfast_notifications (
  id text primary key,
  pf_payment_id text not null unique,
  organization_id text references iam_organisations (id),
  payload text not null check (json_valid(payload)),
  source_ip text,
  outcome text not null,
  reason text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table billing_quota_periods (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  capability text not null default 'reports',
  period_start text not null,
  period_end text not null,
  limit_value integer,
  consumed integer not null default 0 check (consumed >= 0),
  reserved integer not null default 0 check (reserved >= 0),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  unique (organization_id, capability, period_start)
);

create table billing_entitlement_overrides (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  capability text not null,
  enabled integer not null check (enabled in (0, 1)),
  reason text,
  created_by text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create trigger billing_plans_updated_at
after update on billing_plans
for each row
begin
  update billing_plans
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where key = old.key
     and updated_at = old.updated_at;
end;

create trigger billing_billing_settings_updated_at
after update on billing_billing_settings
for each row
begin
  update billing_billing_settings
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where organization_id = old.organization_id
     and updated_at = old.updated_at;
end;

create trigger billing_platform_settings_updated_at
after update on billing_platform_settings
for each row
begin
  update billing_platform_settings
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger billing_subscriptions_updated_at
after update on billing_subscriptions
for each row
begin
  update billing_subscriptions
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger billing_quota_periods_updated_at
after update on billing_quota_periods
for each row
begin
  update billing_quota_periods
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;
