-- Extended user profile fields (Firestore profiles/{uid} → Postgres iam.profiles).

alter table iam.profiles
  add column if not exists first_name text,
  add column if not exists last_name text,
  add column if not exists preferences jsonb not null default '{}'::jsonb,
  add column if not exists mfa_enrolled_at timestamptz,
  add column if not exists active boolean not null default true;

comment on column iam.profiles.first_name is 'Given name (Firestore firstName).';
comment on column iam.profiles.last_name is 'Family name (Firestore lastName).';
comment on column iam.profiles.preferences is 'UI preferences (TTS, highContrastMode, etc.).';
comment on column iam.profiles.mfa_enrolled_at is 'Optional mirror of Firebase MFA enrollment time.';
comment on column iam.profiles.active is 'Account active flag (Firestore active).';

alter table iam.profiles
  add constraint profiles_first_name_len check (first_name is null or char_length(first_name) between 1 and 100),
  add constraint profiles_last_name_len check (last_name is null or char_length(last_name) between 1 and 100);

-- Self-service profile updates (first/last name, preferences).
drop policy if exists profiles_update_self on iam.profiles;
create policy profiles_update_self on iam.profiles
  for update
  using (id = util.current_user_id())
  with check (id = util.current_user_id());
