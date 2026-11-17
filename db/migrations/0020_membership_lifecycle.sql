-- SQLite stand-in for db/upstream/0020_membership_lifecycle.sql
-- The profiles_self row level security policy is not created.

alter table iam_memberships add column suspended_at text;
alter table iam_memberships add column suspended_reason text;

insert into themis_upstream_gaps (id, reason) values (
  '0020_membership_lifecycle.sql:policy',
  'The profiles_self row level security policy is not created.'
);
