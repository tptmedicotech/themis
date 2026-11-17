-- Placeholder plans. Clearly marked; not production prices. The org management system
-- overwrites limits later. Local/dev subscriptions use these keys.

-- Catalogue seed runs as tpt_migrator under FORCE RLS (Docker / Cloud SQL).
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'tpt_migrator')
     and not exists (
       select 1 from pg_policies
       where schemaname = 'billing' and tablename = 'plans' and policyname = 'plans_migrator_write'
     ) then
    execute $p$
      create policy plans_migrator_write on billing.plans
        for all to tpt_migrator using (true) with check (true)
    $p$;
  end if;
end
$$;

insert into billing.plans (
  key, name, price_cents, report_limit_monthly, seat_limit, features, public, active, placeholder
) values
  (
    'solo_basic',
    'Solo Basic (PLACEHOLDER — not a production price)',
    0,
    5,
    1,
    array[
      'clinical_psych_reports',
      'forensic_reports',
      'ep_reports',
      'psychometry',
      'document_ingest',
      'stt_dictation',
      'report_export'
    ],
    true,
    true,
    true
  ),
  (
    'solo_pro',
    'Solo Pro (PLACEHOLDER — not a production price)',
    0,
    25,
    1,
    array[
      'clinical_psych_reports',
      'forensic_reports',
      'ep_reports',
      'psychometry',
      'document_ingest',
      'stt_dictation',
      'report_export'
    ],
    true,
    true,
    true
  ),
  (
    'institutional_team',
    'Institutional Team (PLACEHOLDER — not a production price)',
    0,
    100,
    10,
    array[
      'clinical_psych_reports',
      'forensic_reports',
      'ep_reports',
      'psychometry',
      'document_ingest',
      'stt_dictation',
      'report_export',
      'organization_members'
    ],
    true,
    true,
    true
  ),
  (
    'dev_unlimited',
    'Local development (PLACEHOLDER — unlimited, never used in prod)',
    0,
    null,
    50,
    array[
      'clinical_psych_reports',
      'forensic_reports',
      'ep_reports',
      'psychometry',
      'document_ingest',
      'stt_dictation',
      'report_export',
      'organization_members'
    ],
    false,
    true,
    true
  )
on conflict (key) do nothing;
