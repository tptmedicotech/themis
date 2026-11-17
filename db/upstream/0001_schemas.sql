-- Platform schemas. public holds only schema_migrations.
-- Roles are created by infrastructure in Docker/prod; this is idempotent for PGlite tests.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'tpt_app') then
    create role tpt_app nobypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'tpt_staff_readonly') then
    create role tpt_staff_readonly nologin nobypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'tpt_staff_support') then
    create role tpt_staff_support nologin nobypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'tpt_staff_billing') then
    create role tpt_staff_billing nologin nobypassrls;
  end if;
end
$$;

-- Infrastructure init (Docker/prod) may have created staff roles and grants as postgres.
do $$
begin
  if not pg_has_role('tpt_staff_support', 'tpt_staff_readonly', 'member') then
    grant tpt_staff_readonly to tpt_staff_support;
  end if;
  if not pg_has_role('tpt_staff_billing', 'tpt_staff_readonly', 'member') then
    grant tpt_staff_readonly to tpt_staff_billing;
  end if;
exception
  when insufficient_privilege then
    null;
end
$$;

create schema if not exists util;
create schema if not exists iam;
create schema if not exists billing;
create schema if not exists clinical;
create schema if not exists knowledge;
create schema if not exists ai;
create schema if not exists audit;
create schema if not exists admin;

create table if not exists public.schema_migrations (
  id text primary key,
  applied_at timestamptz not null default now()
);

create or replace function util.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function util.current_org_id()
returns uuid
language sql
stable
parallel safe
as $$
  select nullif(current_setting('app.org_id', true), '')::uuid;
$$;

create or replace function util.current_user_id()
returns uuid
language sql
stable
parallel safe
as $$
  select nullif(current_setting('app.user_id', true), '')::uuid;
$$;

create or replace function util.current_role()
returns text
language sql
stable
parallel safe
as $$
  select nullif(current_setting('app.role', true), '');
$$;
