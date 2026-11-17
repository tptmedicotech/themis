-- Public invitation preview (metadata only; no token_hash).

create or replace function iam.preview_invitation(p_invitation_id uuid)
returns table(
  id uuid,
  email text,
  role text,
  status text,
  expires_at timestamptz,
  organization_id uuid,
  organization_name text
)
language plpgsql
security definer
set search_path = iam, util, pg_temp
as $$
declare
  inv iam.invitations%rowtype;
  org_name text;
begin
  select * into inv from iam.invitations where id = p_invitation_id;
  if not found then
    raise exception 'NOT_FOUND' using errcode = 'P0002';
  end if;

  if inv.status = 'pending' and inv.expires_at <= now() then
    update iam.invitations set status = 'expired' where id = inv.id;
    inv.status := 'expired';
  end if;

  select name into org_name from iam.organisations where id = inv.organization_id;

  return query
  select inv.id as id,
         inv.email as email,
         inv.role as role,
         inv.status as status,
         inv.expires_at as expires_at,
         inv.organization_id as organization_id,
         org_name as organization_name;
end;
$$;

revoke all on function iam.preview_invitation(uuid) from public;
grant execute on function iam.preview_invitation(uuid) to tpt_app;
