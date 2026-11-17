-- Placeholder plans from db/upstream/0010_seed_plans.sql.
-- Prices are zero. The seed sets the local catalogue prices.

insert into billing_plans (
  key, name, price_cents, report_limit_monthly, seat_limit, features, "public", active, placeholder
) values
  (
    'solo_basic',
    'Solo Basic (PLACEHOLDER — not a production price)',
    0,
    5,
    1,
    '["clinical_psych_reports","forensic_reports","ep_reports","psychometry","document_ingest","stt_dictation","report_export"]',
    1,
    1,
    1
  ),
  (
    'solo_pro',
    'Solo Pro (PLACEHOLDER — not a production price)',
    0,
    25,
    1,
    '["clinical_psych_reports","forensic_reports","ep_reports","psychometry","document_ingest","stt_dictation","report_export"]',
    1,
    1,
    1
  ),
  (
    'institutional_team',
    'Institutional Team (PLACEHOLDER — not a production price)',
    0,
    100,
    10,
    '["clinical_psych_reports","forensic_reports","ep_reports","psychometry","document_ingest","stt_dictation","report_export","organization_members"]',
    1,
    1,
    1
  ),
  (
    'dev_unlimited',
    'Local development (PLACEHOLDER — unlimited, never used in prod)',
    0,
    null,
    50,
    '["clinical_psych_reports","forensic_reports","ep_reports","psychometry","document_ingest","stt_dictation","report_export","organization_members"]',
    0,
    1,
    1
  )
on conflict (key) do nothing;
