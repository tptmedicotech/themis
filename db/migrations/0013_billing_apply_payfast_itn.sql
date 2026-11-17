-- Postgres-only body. Read db/upstream/0013_billing_apply_payfast_itn.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0013_billing_apply_payfast_itn.sql',
  'The first PayFast ITN function is not created. Upstream 0030 replaces that function. Themis stores the rows only.'
);
