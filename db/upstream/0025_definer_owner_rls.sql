-- SECURITY DEFINER helpers (iam.upsert_profile, iam.memberships_for_user, iam.accept_invitation,
-- billing.reserve_report_slot, hard-purge, …) run as the table owner (`tpt_migrator` in Docker/Cloud SQL).
-- 0006 FORCEs row-level security on every tenant table, which also subjects that owner to the policies
-- (the "owner is exempt" assumption only held for PGlite tests, where the owner is a superuser).
-- Result on a real Postgres: the gateway's per-request `upsert_profile` / `memberships_for_user` fail with
-- "new row violates row-level security policy for table profiles", so no authenticated call ever succeeds.
--
-- Give each FORCE-RLS table an explicit permissive policy for its *owner role only*. The runtime role
-- (`tpt_app`) is not the owner and stays fully subject to the tenant policies; the owner can already
-- bypass RLS by owning the table (ALTER TABLE … DISABLE), so this adds no privilege.
do $$
declare
  rec record;
begin
  for rec in
    select n.nspname as schema_name,
           c.relname as table_name,
           r.rolname as owner_name
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      join pg_roles r on r.oid = c.relowner
     where c.relkind in ('r', 'p')
       and c.relforcerowsecurity
       and n.nspname in ('iam', 'billing', 'clinical', 'knowledge', 'ai', 'audit')
       and not r.rolsuper
       and not r.rolbypassrls
  loop
    execute format('drop policy if exists definer_owner_all on %I.%I', rec.schema_name, rec.table_name);
    execute format(
      'create policy definer_owner_all on %I.%I as permissive for all to %I using (true) with check (true)',
      rec.schema_name, rec.table_name, rec.owner_name
    );
  end loop;
end
$$;
