-- Postgres-only body. Read db/upstream/0015_knowledge_delete_grant.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0015_knowledge_delete_grant.sql',
  'The knowledge delete grant is not created.'
);
