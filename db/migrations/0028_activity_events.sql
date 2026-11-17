-- SQLite stand-in for db/upstream/0028_activity_events.sql
-- Row level security and the hard-purge function are not created.

create table audit_activity_events (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  user_id text not null references iam_profiles (id),
  kind text not null check (length(kind) <= 128),
  entity_type text check (entity_type is null or length(entity_type) <= 64),
  entity_id text check (entity_id is null or length(entity_id) <= 256),
  report_id text references clinical_reports (id) on delete set null,
  report_family text,
  metadata text not null default '{}' check (json_valid(metadata)),
  client_ip text,
  user_agent text,
  idempotency_key text,
  occurred_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create index audit_activity_events_org_occurred
  on audit_activity_events (organization_id, occurred_at desc, id desc);

create unique index audit_activity_events_idempotency
  on audit_activity_events (organization_id, idempotency_key)
  where idempotency_key is not null;

insert into themis_upstream_gaps (id, reason) values (
  '0028_activity_events.sql:rls',
  'Row level security and the hard-purge function body are not created.'
);
