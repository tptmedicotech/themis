-- Postgres-only body. Read db/upstream/0016_invitation_preview.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0016_invitation_preview.sql',
  'The invitation preview function is not created.'
);
