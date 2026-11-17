-- SQLite stand-in for db/upstream/0029_profile_extensions.sql
-- The profiles_update_self row level security policy is not created.

alter table iam_profiles add column first_name text
  check (first_name is null or length(first_name) between 1 and 100);
alter table iam_profiles add column last_name text
  check (last_name is null or length(last_name) between 1 and 100);
alter table iam_profiles add column preferences text not null default '{}'
  check (json_valid(preferences));
alter table iam_profiles add column mfa_enrolled_at text;
alter table iam_profiles add column active integer not null default 1
  check (active in (0, 1));

insert into themis_upstream_gaps (id, reason) values (
  '0029_profile_extensions.sql:policy',
  'The profiles_update_self row level security policy is not created.'
);
