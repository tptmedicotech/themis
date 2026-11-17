-- Local catalogue prices from tpt-api/packages/db/src/billing-plan-catalog.ts.
-- Migration 0010 inserts placeholder rows. This seed replaces the three paid rows.
-- dev_unlimited stays a placeholder.

update billing_plans
   set name = 'Solo Basic',
       price_cents = 59900,
       report_limit_monthly = 5,
       seat_limit = 1,
       features = '["clinical_psych_reports","forensic_reports","ep_reports","psychometry"]',
       "public" = 1,
       active = 1,
       placeholder = 0
 where key = 'solo_basic';

update billing_plans
   set name = 'Solo Pro',
       price_cents = 99900,
       report_limit_monthly = 25,
       seat_limit = 1,
       features = '["clinical_psych_reports","forensic_reports","ep_reports","psychometry","report_export","document_ingest","stt_dictation"]',
       "public" = 1,
       active = 1,
       placeholder = 0
 where key = 'solo_pro';

update billing_plans
   set name = 'Institutional Team',
       price_cents = 249900,
       report_limit_monthly = 100,
       seat_limit = 5,
       features = '["clinical_psych_reports","forensic_reports","ep_reports","psychometry","report_export","document_ingest","stt_dictation","organization_members"]',
       "public" = 1,
       active = 1,
       placeholder = 0
 where key = 'institutional_team';
