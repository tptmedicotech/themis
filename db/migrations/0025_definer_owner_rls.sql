-- Postgres-only body. Read db/upstream/0025_definer_owner_rls.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0025_definer_owner_rls.sql',
  'Definer-owner row level security is not created.'
);
