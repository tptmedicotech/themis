-- Postgres-only body. Read db/upstream/0017_invitation_preview_ambiguous.sql.
-- Themis records the gap. Themis does not run the Postgres statements.

insert into themis_upstream_gaps (id, reason) values (
  '0017_invitation_preview_ambiguous.sql',
  'The invitation preview change is not created.'
);
