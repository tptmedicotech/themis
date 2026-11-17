-- Postgres-only body. Read db/upstream/0011_resume_stale_runs.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0011_resume_stale_runs.sql',
  'The stale-run function is not created.'
);
