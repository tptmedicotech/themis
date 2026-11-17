-- Postgres-only body. Read db/upstream/0012_claim_stale_run_options.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0012_claim_stale_run_options.sql',
  'The claim-stale-run function is not created.'
);
