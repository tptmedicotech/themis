-- MFA recovery codes (hashed at the webapp; Postgres stores HMAC digests only).

create table iam.mfa_recovery_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references iam.profiles (id) on delete cascade,
  code_hash text not null,
  used boolean not null default false,
  used_at timestamptz,
  created_at timestamptz not null default now(),
  unique (user_id, code_hash)
);

create index mfa_recovery_codes_user_id_idx on iam.mfa_recovery_codes (user_id);

alter table iam.mfa_recovery_codes enable row level security;
alter table iam.mfa_recovery_codes force row level security;

revoke all on table iam.mfa_recovery_codes from tpt_app;

do $$
declare
  owner_name name;
begin
  select r.rolname into owner_name
    from pg_class c
    join pg_roles r on r.oid = c.relowner
   where c.oid = 'iam.mfa_recovery_codes'::regclass;
  execute format(
    'create policy definer_owner_all on iam.mfa_recovery_codes as permissive for all to %I using (true) with check (true)',
    owner_name
  );
end
$$;

create or replace function iam.create_mfa_recovery_codes(
  p_firebase_uid text,
  p_email text,
  p_display_name text,
  p_code_hashes text[]
) returns jsonb
language plpgsql
security definer
set search_path = iam, pg_temp
as $$
declare
  v_profile iam.profiles;
  v_user_id uuid;
  v_hash text;
begin
  if p_firebase_uid is null or char_length(trim(p_firebase_uid)) = 0 then
    raise exception 'INVALID_ARGUMENT' using errcode = '22023';
  end if;
  if p_code_hashes is null or array_length(p_code_hashes, 1) is null then
    raise exception 'INVALID_ARGUMENT' using errcode = '22023';
  end if;

  v_profile := iam.upsert_profile(p_firebase_uid, p_email, p_display_name);
  v_user_id := v_profile.id;

  if exists (select 1 from iam.mfa_recovery_codes where user_id = v_user_id limit 1) then
    return jsonb_build_object('created', false, 'existing', true);
  end if;

  foreach v_hash in array p_code_hashes loop
    insert into iam.mfa_recovery_codes (user_id, code_hash)
    values (v_user_id, v_hash);
  end loop;

  return jsonb_build_object('created', true);
end;
$$;

create or replace function iam.mfa_recovery_codes_exist(p_firebase_uid text)
returns boolean
language plpgsql
stable
security definer
set search_path = iam, pg_temp
as $$
declare
  v_user_id uuid;
begin
  select p.id into v_user_id from iam.profiles p where p.firebase_uid = p_firebase_uid;
  if v_user_id is null then
    return false;
  end if;
  return exists (select 1 from iam.mfa_recovery_codes c where c.user_id = v_user_id limit 1);
end;
$$;

create or replace function iam.consume_mfa_recovery_code(p_firebase_uid text, p_code_hash text)
returns text
language plpgsql
security definer
set search_path = iam, pg_temp
as $$
declare
  v_user_id uuid;
  v_row iam.mfa_recovery_codes%rowtype;
begin
  select p.id into v_user_id from iam.profiles p where p.firebase_uid = p_firebase_uid;
  if v_user_id is null then
    return 'invalid';
  end if;

  select * into v_row
    from iam.mfa_recovery_codes
   where user_id = v_user_id
     and code_hash = p_code_hash
   for update;

  if not found then
    return 'invalid';
  end if;
  if v_row.used then
    return 'used';
  end if;

  update iam.mfa_recovery_codes
     set used = true, used_at = now()
   where id = v_row.id;

  return 'valid';
end;
$$;

grant execute on function iam.create_mfa_recovery_codes(text, text, text, text[]) to tpt_app;
grant execute on function iam.mfa_recovery_codes_exist(text) to tpt_app;
grant execute on function iam.consume_mfa_recovery_code(text, text) to tpt_app;
