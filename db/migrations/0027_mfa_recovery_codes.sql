-- SQLite stand-in for db/upstream/0027_mfa_recovery_codes.sql
-- Recovery-code functions and row level security are not created.

create table iam_mfa_recovery_codes (
  id text primary key,
  user_id text not null references iam_profiles (id) on delete cascade,
  code_hash text not null,
  used integer not null default 0 check (used in (0, 1)),
  used_at text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  unique (user_id, code_hash)
);

create index iam_mfa_recovery_codes_user_id on iam_mfa_recovery_codes (user_id);

insert into themis_upstream_gaps (id, reason) values (
  '0027_mfa_recovery_codes.sql:functions',
  'Recovery-code functions and row level security are not created. Themis stores the code hash rows only.'
);
