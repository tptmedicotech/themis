-- Postgres-only body. Read db/upstream/0023_org_hard_purge_clinical.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0023_org_hard_purge_clinical.sql',
  'The clinical purge change is not created.'
);
