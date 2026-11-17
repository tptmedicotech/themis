-- Themis usage store. This table set is not in the main database.
-- themis_webapp_usage holds usage rows that come from tpt-webapp.
-- themis_usage_daily holds one total per organisation, source, day, and metric.
-- audit_usage_events and ai_model_usage remain the raw tpt-api rows.

create table themis_webapp_usage (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  user_id text references iam_profiles (id),
  route text not null,
  event_name text not null,
  metadata text not null default '{}' check (json_valid(metadata)),
  occurred_at text not null
);

create index themis_webapp_usage_org_occurred
  on themis_webapp_usage (organization_id, occurred_at);

create table themis_usage_daily (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  source text not null check (source in ('tpt-api', 'tpt-webapp')),
  day text not null,
  metric text not null,
  quantity integer not null check (quantity >= 0),
  unique (organization_id, source, day, metric)
);
