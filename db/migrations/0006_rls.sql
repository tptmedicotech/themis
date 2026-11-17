-- Postgres-only body. Read db/upstream/0006_rls.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0006_rls.sql',
  'Row level security policies are not created. A Themis reader may read every mirror row.'
);
