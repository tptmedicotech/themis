-- Postgres-only body. Read db/upstream/0007_functions.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0007_functions.sql',
  'Postgres functions in this file are not created.'
);
