-- Postgres-only body. Read db/upstream/0018_invitation_preview_return_next.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0018_invitation_preview_return_next.sql',
  'The invitation preview change is not created.'
);
