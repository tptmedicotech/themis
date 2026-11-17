-- Accept a pending invitation for the authenticated user (email must match).

create or replace function iam.accept_invitation(p_user_id uuid, p_invitation_id uuid)
returns table(membership_id uuid, organization_id uuid, role text)
language plpgsql
security definer
set search_path = iam, billing, util, pg_temp
as $$
declare
  inv iam.invitations%rowtype;
  user_email text;
  seat_limit integer;
  active_seats integer;
  memb iam.memberships%rowtype;
begin
  if p_user_id is distinct from util.current_user_id() then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  select * into inv from iam.invitations where id = p_invitation_id for update;
  if not found then
    raise exception 'NOT_FOUND' using errcode = 'P0002';
  end if;

  if inv.status <> 'pending' then
    raise exception 'CONFLICT' using errcode = 'P0001';
  end if;

  if inv.expires_at <= now() then
    update iam.invitations set status = 'expired' where id = inv.id;
    raise exception 'CONFLICT' using errcode = 'P0001';
  end if;

  select lower(email) into user_email from iam.profiles where id = p_user_id;
  if user_email is null or user_email <> lower(inv.email) then
    raise exception 'FORBIDDEN' using errcode = '42501';
  end if;

  if not billing.subscription_allows_new_slots(inv.organization_id, now()) then
    raise exception 'SUBSCRIPTION_INACTIVE' using errcode = '55P03';
  end if;

  select p.seat_limit into seat_limit
    from billing.subscriptions s
    join billing.plans p on p.key = s.plan_key
   where s.organization_id = inv.organization_id;

  if seat_limit is null then
    raise exception 'SUBSCRIPTION_INACTIVE' using errcode = '55P03';
  end if;

  select count(*)::integer into active_seats
    from iam.memberships m
   where m.organization_id = inv.organization_id
     and m.status = 'active';

  if active_seats >= seat_limit then
    raise exception 'CONFLICT' using errcode = 'P0001';
  end if;

  select * into memb
    from iam.memberships m
   where m.organization_id = inv.organization_id
     and m.user_id = p_user_id;

  if found then
    if memb.status = 'active' then
      raise exception 'CONFLICT' using errcode = 'P0001';
    end if;
    update iam.memberships
       set role = inv.role,
           status = 'active',
           updated_at = now()
     where id = memb.id
     returning * into memb;
  else
    insert into iam.memberships (organization_id, user_id, role, status)
    values (inv.organization_id, p_user_id, inv.role, 'active')
    returning * into memb;
  end if;

  perform set_config('app.org_id', inv.organization_id::text, true);
  update iam.invitations set status = 'accepted' where id = inv.id;

  return query select memb.id, inv.organization_id, memb.role;
end;
$$;

grant execute on function iam.accept_invitation(uuid, uuid) to tpt_app;
