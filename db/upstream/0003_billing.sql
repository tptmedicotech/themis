create table billing.plans (
  key text primary key,
  name text not null,
  price_cents integer not null default 0 check (price_cents >= 0),
  currency text not null default 'ZAR',
  billing_interval text not null default 'monthly',
  report_limit_monthly integer check (report_limit_monthly is null or report_limit_monthly >= 0),
  seat_limit integer not null default 1 check (seat_limit >= 1),
  features text[] not null default '{}',
  public boolean not null default false,
  active boolean not null default true,
  -- Placeholder rows are seeded for local/dev. They must not be treated as production prices.
  placeholder boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table billing.billing_settings (
  organization_id uuid primary key references iam.organisations (id),
  grace_days integer not null default 7 check (grace_days >= 0 and grace_days <= 90),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table billing.platform_settings (
  id boolean primary key default true check (id),
  grace_days integer not null default 7 check (grace_days >= 0 and grace_days <= 90),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into billing.platform_settings (id, grace_days) values (true, 7) on conflict do nothing;

create table billing.subscriptions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null unique references iam.organisations (id),
  plan_key text not null references billing.plans (key),
  status text not null check (
    status in ('prepayment', 'processing', 'active', 'past_due', 'unpaid', 'cancelled')
  ),
  payfast_token text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  pending_plan_key text references billing.plans (key),
  scheduled_effective_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table billing.payment_attempts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  subscription_id uuid references billing.subscriptions (id),
  amount_cents integer not null,
  currency text not null default 'ZAR',
  status text not null,
  payfast_payment_id text,
  created_at timestamptz not null default now()
);

create table billing.payfast_notifications (
  id uuid primary key default gen_random_uuid(),
  pf_payment_id text not null unique,
  organization_id uuid references iam.organisations (id),
  payload jsonb not null,
  source_ip text,
  outcome text not null,
  reason text,
  created_at timestamptz not null default now()
);

create table billing.quota_periods (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  capability text not null default 'reports',
  period_start timestamptz not null,
  period_end timestamptz not null,
  limit_value integer,
  consumed integer not null default 0 check (consumed >= 0),
  reserved integer not null default 0 check (reserved >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, capability, period_start)
);

create table billing.report_slots (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid not null unique,
  state text not null check (state in ('reserved', 'consumed', 'released')),
  period_id uuid references billing.quota_periods (id),
  reserved_at timestamptz not null default now(),
  consumed_at timestamptz,
  released_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table billing.entitlement_overrides (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  capability text not null,
  enabled boolean not null,
  reason text,
  created_by text,
  created_at timestamptz not null default now()
);

create trigger plans_updated_at before update on billing.plans
  for each row execute function util.set_updated_at();
create trigger billing_settings_updated_at before update on billing.billing_settings
  for each row execute function util.set_updated_at();
create trigger subscriptions_updated_at before update on billing.subscriptions
  for each row execute function util.set_updated_at();
create trigger quota_periods_updated_at before update on billing.quota_periods
  for each row execute function util.set_updated_at();
create trigger report_slots_updated_at before update on billing.report_slots
  for each row execute function util.set_updated_at();
