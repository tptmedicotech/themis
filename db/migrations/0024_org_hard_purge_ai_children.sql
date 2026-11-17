-- Postgres-only body. Read db/upstream/0024_org_hard_purge_ai_children.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0024_org_hard_purge_ai_children.sql',
  'The AI purge change is not created.'
);
