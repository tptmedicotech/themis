-- Org membership lifecycle fields aligned with Firestore org_memberships (suspend metadata).

alter table iam.memberships
  add column if not exists suspended_at timestamptz,
  add column if not exists suspended_reason text;

comment on column iam.memberships.suspended_at is 'Set when status becomes suspended (Firestore suspendedAt).';
comment on column iam.memberships.suspended_reason is 'Human-readable suspend reason (Firestore suspendedReason).';

-- Colleague profiles stay readable while membership is suspended (admin suspend/reactivate flows join profiles).
drop policy if exists profiles_self on iam.profiles;
create policy profiles_self on iam.profiles
  using (
    id = util.current_user_id()
    or exists (
      select 1 from iam.memberships m
      where m.user_id = iam.profiles.id
        and m.organization_id = util.current_org_id()
        and m.status in ('active', 'suspended')
    )
  );
