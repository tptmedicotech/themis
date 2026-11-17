-- Themis auth. This table set is not in the main database.
-- A user signs in with email and password.
-- The only role is reader.
-- A reader may read mirror data. A reader must not write mirror data.

create table themis_users (
  id text primary key,
  email text not null collate nocase unique,
  password_hash text not null,
  display_name text not null,
  role text not null default 'reader' check (role = 'reader'),
  active integer not null default 1 check (active in (0, 1)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table themis_sessions (
  id text primary key,
  user_id text not null references themis_users (id) on delete cascade,
  token_hash text not null unique,
  expires_at text not null,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table themis_access_policy (
  role text primary key,
  may_read_mirror integer not null check (may_read_mirror in (0, 1)),
  may_write_mirror integer not null check (may_write_mirror in (0, 1)),
  check (role = 'reader' and may_read_mirror = 1 and may_write_mirror = 0)
);

insert into themis_access_policy (role, may_read_mirror, may_write_mirror)
values ('reader', 1, 0);

create view themis_users_public as
select id, email, display_name, role, active, created_at, updated_at
from themis_users;

create trigger themis_users_updated_at
after update on themis_users
for each row
begin
  update themis_users
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;
