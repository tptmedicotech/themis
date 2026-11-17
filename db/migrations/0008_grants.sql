-- Postgres-only body. Read db/upstream/0008_grants.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0008_grants.sql',
  'Postgres grants are not created. The reader role in themis_access_policy is the read rule.'
);
