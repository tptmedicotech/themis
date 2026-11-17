-- Postgres-only body. Read db/upstream/0015_accept_invitation.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0015_accept_invitation.sql',
  'iam.accept_invitation is not created.'
);
