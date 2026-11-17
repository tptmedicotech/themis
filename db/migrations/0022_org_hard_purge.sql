-- Postgres-only body. Read db/upstream/0022_org_hard_purge.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0022_org_hard_purge.sql',
  'iam.hard_purge_organisation is not created.'
);
