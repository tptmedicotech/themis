-- Postgres-only body. Read db/upstream/0009_admin.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0009_admin.sql',
  'admin security-definer functions are not created.'
);
