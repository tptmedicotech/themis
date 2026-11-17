-- SQLite stand-in for db/upstream/0001_schemas.sql
-- SQLite has no CREATE SCHEMA and no CREATE ROLE.
-- A mirror table name is the Postgres schema, one underscore, and the Postgres table name.
-- Example: iam.organisations is iam_organisations.

create table if not exists schema_migrations (
  id text primary key,
  applied_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table themis_upstream_gaps (
  id text primary key,
  reason text not null
);

insert into themis_upstream_gaps (id, reason) values
  (
    '0001_schemas.sql:roles',
    'Postgres roles tpt_app, tpt_staff_readonly, tpt_staff_support, and tpt_staff_billing are not created.'
  ),
  (
    '0001_schemas.sql:util',
    'util.set_updated_at and the util.current_* functions are not created. Mirror tables set updated_at with an AFTER UPDATE trigger.'
  );
