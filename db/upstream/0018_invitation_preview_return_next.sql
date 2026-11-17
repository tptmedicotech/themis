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
  select * into inv from iam.invitations where iam.invitations.id = p_invitation_id;
  if not found then
    raise exception 'NOT_FOUND' using errcode = 'P0002';
  end if;

  if inv.status = 'pending' and inv.expires_at <= now() then
    update iam.invitations set status = 'expired' where iam.invitations.id = inv.id;
    inv.status := 'expired';
  end if;

  select o.name into org_name from iam.organisations o where o.id = inv.organization_id;

  id := inv.id;
  email := inv.email;
  role := inv.role;
  status := inv.status;
  expires_at := inv.expires_at;
  organization_id := inv.organization_id;
  organization_name := org_name;
  return next;
end;
$$;
