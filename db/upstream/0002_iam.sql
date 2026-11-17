create table iam.organisations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 200),
  org_type text not null default 'solo' check (org_type in ('solo', 'institutional')),
  status text not null default 'active' check (status in ('active', 'suspended', 'deleted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table iam.profiles (
  id uuid primary key default gen_random_uuid(),
  firebase_uid text not null unique,
  email text,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index profiles_email_lower on iam.profiles (lower(email)) where email is not null;

create table iam.memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  user_id uuid not null references iam.profiles (id),
  role text not null check (role in ('owner', 'admin', 'member', 'viewer')),
  status text not null default 'active' check (status in ('active', 'suspended', 'removed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

create table iam.invitations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  email text not null,
  role text not null check (role in ('admin', 'member', 'viewer')),
  token_hash text not null unique,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'revoked', 'expired')),
  expires_at timestamptz not null,
  invited_by uuid references iam.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table iam.org_settings (
  organization_id uuid primary key references iam.organisations (id),
  stt_audio_retention_days integer not null default 30 check (stt_audio_retention_days >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table iam.org_ai_policy (
  organization_id uuid primary key references iam.organisations (id),
  allowed_providers text[] not null default array['openai']::text[],
  cross_border_consent boolean not null default false,
  consent_recorded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger organisations_updated_at before update on iam.organisations
  for each row execute function util.set_updated_at();
create trigger profiles_updated_at before update on iam.profiles
  for each row execute function util.set_updated_at();
create trigger memberships_updated_at before update on iam.memberships
  for each row execute function util.set_updated_at();
create trigger invitations_updated_at before update on iam.invitations
  for each row execute function util.set_updated_at();
create trigger org_settings_updated_at before update on iam.org_settings
  for each row execute function util.set_updated_at();
create trigger org_ai_policy_updated_at before update on iam.org_ai_policy
  for each row execute function util.set_updated_at();
