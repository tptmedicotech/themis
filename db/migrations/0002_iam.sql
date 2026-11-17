-- SQLite stand-in for db/upstream/0002_iam.sql

create table iam_organisations (
  id text primary key,
  name text not null check (length(name) between 2 and 200),
  org_type text not null default 'solo' check (org_type in ('solo', 'institutional')),
  status text not null default 'active' check (status in ('active', 'suspended', 'deleted')),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table iam_profiles (
  id text primary key,
  firebase_uid text not null unique,
  email text,
  display_name text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create unique index iam_profiles_email_lower
  on iam_profiles (email collate nocase)
  where email is not null;

create table iam_memberships (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  user_id text not null references iam_profiles (id),
  role text not null check (role in ('owner', 'admin', 'member', 'viewer')),
  status text not null default 'active' check (status in ('active', 'suspended', 'removed')),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  unique (organization_id, user_id)
);

create table iam_invitations (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  email text not null,
  role text not null check (role in ('admin', 'member', 'viewer')),
  token_hash text not null unique,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'revoked', 'expired')),
  expires_at text not null,
  invited_by text references iam_profiles (id),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table iam_org_settings (
  organization_id text primary key references iam_organisations (id),
  stt_audio_retention_days integer not null default 30 check (stt_audio_retention_days >= 1),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table iam_org_ai_policy (
  organization_id text primary key references iam_organisations (id),
  allowed_providers text not null default '["openai"]' check (json_valid(allowed_providers)),
  cross_border_consent integer not null default 0 check (cross_border_consent in (0, 1)),
  consent_recorded_at text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create trigger iam_organisations_updated_at
after update on iam_organisations
for each row
begin
  update iam_organisations
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger iam_profiles_updated_at
after update on iam_profiles
for each row
begin
  update iam_profiles
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger iam_memberships_updated_at
after update on iam_memberships
for each row
begin
  update iam_memberships
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger iam_invitations_updated_at
after update on iam_invitations
for each row
begin
  update iam_invitations
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger iam_org_settings_updated_at
after update on iam_org_settings
for each row
begin
  update iam_org_settings
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where organization_id = old.organization_id
     and updated_at = old.updated_at;
end;

create trigger iam_org_ai_policy_updated_at
after update on iam_org_ai_policy
for each row
begin
  update iam_org_ai_policy
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where organization_id = old.organization_id
     and updated_at = old.updated_at;
end;
