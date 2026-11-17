-- Postgres-only body. Read db/upstream/0014_claim_queued_runs.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0014_claim_queued_runs.sql',
  'The claim-queued-runs function is not created.'
);
