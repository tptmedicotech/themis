-- SQLite stand-in for db/upstream/0021_org_soft_delete.sql
-- The membership and invitation functions are not created.

alter table iam_organisations add column deleted_at text;
alter table iam_organisations add column purge_eligible_at text;
alter table iam_memberships add column removed_at text;

insert into themis_upstream_gaps (id, reason) values (
  '0021_org_soft_delete.sql:functions',
  'iam.memberships_for_user and iam.accept_invitation are not created.'
);
