-- Synthetic monitor rows. These rows are not patient data.
-- Re-run deletes the same ids, then inserts them again.

delete from themis_usage_daily
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from themis_webapp_usage
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from themis_sync_cursors
 where (source = 'tpt-api' and object_name in ('audit_activity_events', 'audit_usage_events', 'ai_model_usage'))
    or (source = 'tpt-webapp' and object_name = 'themis_webapp_usage');
delete from themis_sync_runs
 where id in (
   '82000000-0000-4000-8000-000000000001',
   '82000000-0000-4000-8000-000000000002'
 );

delete from ai_run_events
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from ai_run_steps
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from ai_tool_calls
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from ai_citations
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from ai_validations
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from ai_model_usage
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from ai_agent_runs
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from ai_prompt_versions where id = '63000000-0000-4000-8000-000000000001';

delete from knowledge_ingestion_jobs
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from knowledge_chunks
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from knowledge_documents
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );

delete from audit_activity_events
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from audit_usage_events
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from audit_export_audit
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from audit_ingest_audit
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from audit_audit_log where id = '70000000-0000-4000-8000-000000000001';

delete from clinical_dictation_segments
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from clinical_dictation_sessions
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from clinical_scan_compositions
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from clinical_export_files
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from clinical_attachments
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from clinical_report_versions
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from billing_report_slots
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from clinical_reports
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );

delete from billing_payment_attempts
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from billing_payfast_notifications
 where id = '42000000-0000-4000-8000-000000000001';
delete from billing_quota_periods
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from billing_entitlement_overrides
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from billing_subscriptions
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from billing_billing_settings
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );

delete from iam_mfa_recovery_codes
 where user_id in (
   '10000000-0000-4000-8000-000000000001',
   '10000000-0000-4000-8000-000000000002',
   '10000000-0000-4000-8000-000000000003'
 );
delete from iam_invitations
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from iam_memberships
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from iam_org_settings
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from iam_org_ai_policy
 where organization_id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from iam_organisations
 where id in (
   '11111111-1111-4111-8111-111111111111',
   '22222222-2222-4222-8222-222222222222'
 );
delete from iam_profiles
 where id in (
   '10000000-0000-4000-8000-000000000001',
   '10000000-0000-4000-8000-000000000002',
   '10000000-0000-4000-8000-000000000003'
 );

insert into iam_organisations (
  id, name, org_type, status, created_at, updated_at
) values
  (
    '11111111-1111-4111-8111-111111111111',
    'Demo Solo Practice',
    'solo',
    'active',
    '2026-11-01T08:00:00.000Z',
    '2026-11-01T08:00:00.000Z'
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    'Demo City Clinic',
    'institutional',
    'active',
    '2026-11-01T08:05:00.000Z',
    '2026-11-01T08:05:00.000Z'
  );

insert into iam_profiles (
  id, firebase_uid, email, display_name, first_name, last_name, preferences, mfa_enrolled_at, active, created_at, updated_at
) values
  (
    '10000000-0000-4000-8000-000000000001',
    'demo-firebase-owner',
    'demo.owner@example.test',
    'Demo Owner',
    'Demo',
    'Owner',
    '{"demo":true}',
    '2026-10-01T00:00:00.000Z',
    1,
    '2026-11-01T08:00:00.000Z',
    '2026-11-01T08:00:00.000Z'
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'demo-firebase-member',
    'demo.member@example.test',
    'Demo Member',
    'Demo',
    'Member',
    '{"demo":true}',
    null,
    1,
    '2026-11-01T08:01:00.000Z',
    '2026-11-01T08:01:00.000Z'
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    'demo-firebase-admin',
    'demo.clinic.admin@example.test',
    'Demo Admin',
    'Demo',
    'Admin',
    '{"demo":true}',
    null,
    1,
    '2026-11-01T08:05:00.000Z',
    '2026-11-01T08:05:00.000Z'
  );

insert into iam_memberships (
  id, organization_id, user_id, role, status, created_at, updated_at
) values
  (
    '30000000-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    '10000000-0000-4000-8000-000000000001',
    'owner',
    'active',
    '2026-11-01T08:00:00.000Z',
    '2026-11-01T08:00:00.000Z'
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    '11111111-1111-4111-8111-111111111111',
    '10000000-0000-4000-8000-000000000002',
    'member',
    'active',
    '2026-11-01T08:02:00.000Z',
    '2026-11-01T08:02:00.000Z'
  ),
  (
    '30000000-0000-4000-8000-000000000003',
    '22222222-2222-4222-8222-222222222222',
    '10000000-0000-4000-8000-000000000003',
    'admin',
    'active',
    '2026-11-01T08:05:00.000Z',
    '2026-11-01T08:05:00.000Z'
  );

insert into iam_invitations (
  id, organization_id, email, role, token_hash, status, expires_at, invited_by, created_at, updated_at
) values (
  '31000000-0000-4000-8000-000000000001',
  '22222222-2222-4222-8222-222222222222',
  'intern.pending@example.test',
  'member',
  'demo-invite-token-hash',
  'pending',
  '2026-12-01T00:00:00.000Z',
  '10000000-0000-4000-8000-000000000003',
  '2026-11-01T08:06:00.000Z',
  '2026-11-01T08:06:00.000Z'
);

insert into iam_org_settings (
  organization_id, stt_audio_retention_days, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111111111', 30, '2026-11-01T08:00:00.000Z', '2026-11-01T08:00:00.000Z'),
  ('22222222-2222-4222-8222-222222222222', 30, '2026-11-01T08:05:00.000Z', '2026-11-01T08:05:00.000Z');

insert into iam_org_ai_policy (
  organization_id, allowed_providers, cross_border_consent, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111111111', '["openai"]', 0, '2026-11-01T08:00:00.000Z', '2026-11-01T08:00:00.000Z'),
  ('22222222-2222-4222-8222-222222222222', '["openai"]', 0, '2026-11-01T08:05:00.000Z', '2026-11-01T08:05:00.000Z');

insert into iam_mfa_recovery_codes (id, user_id, code_hash, used, created_at) values (
  '59000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  'demo-not-a-real-code',
  0,
  '2026-10-01T00:00:00.000Z'
);

insert into billing_billing_settings (organization_id, grace_days, created_at, updated_at) values
  ('11111111-1111-4111-8111-111111111111', 7, '2026-11-01T08:00:00.000Z', '2026-11-01T08:00:00.000Z'),
  ('22222222-2222-4222-8222-222222222222', 7, '2026-11-01T08:05:00.000Z', '2026-11-01T08:05:00.000Z');

insert into billing_subscriptions (
  id, organization_id, plan_key, status, current_period_start, current_period_end,
  last_payment_outcome, created_at, updated_at
) values
  (
    '40000000-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    'solo_pro',
    'active',
    '2026-11-01T00:00:00.000Z',
    '2026-12-01T00:00:00.000Z',
    'applied',
    '2026-11-01T08:00:00.000Z',
    '2026-11-01T08:00:00.000Z'
  ),
  (
    '40000000-0000-4000-8000-000000000002',
    '22222222-2222-4222-8222-222222222222',
    'institutional_team',
    'active',
    '2026-11-01T00:00:00.000Z',
    '2026-12-01T00:00:00.000Z',
    'applied',
    '2026-11-01T08:05:00.000Z',
    '2026-11-01T08:05:00.000Z'
  );

insert into billing_payment_attempts (
  id, organization_id, subscription_id, amount_cents, currency, status, payfast_payment_id,
  owner_user_id, plan_key, recurring_amount_cents, kind, created_at, updated_at
) values (
  '41000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '40000000-0000-4000-8000-000000000001',
  99900,
  'ZAR',
  'complete',
  'demo-pf-001',
  '10000000-0000-4000-8000-000000000001',
  'solo_pro',
  99900,
  'initial',
  '2026-11-01T08:00:00.000Z',
  '2026-11-01T08:00:00.000Z'
);

insert into billing_payfast_notifications (
  id, pf_payment_id, organization_id, payload, source_ip, outcome, reason, created_at
) values (
  '42000000-0000-4000-8000-000000000001',
  'demo-pf-001',
  '11111111-1111-4111-8111-111111111111',
  '{"demo":true,"payment_status":"COMPLETE"}',
  '127.0.0.1',
  'applied',
  null,
  '2026-11-01T08:00:30.000Z'
);

insert into billing_quota_periods (
  id, organization_id, capability, period_start, period_end, limit_value, consumed, reserved, created_at, updated_at
) values
  (
    '43000000-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    'reports',
    '2026-11-01T00:00:00.000Z',
    '2026-12-01T00:00:00.000Z',
    25,
    1,
    0,
    '2026-11-01T08:00:00.000Z',
    '2026-11-01T08:00:00.000Z'
  ),
  (
    '43000000-0000-4000-8000-000000000002',
    '22222222-2222-4222-8222-222222222222',
    'reports',
    '2026-11-01T00:00:00.000Z',
    '2026-12-01T00:00:00.000Z',
    100,
    1,
    0,
    '2026-11-01T08:05:00.000Z',
    '2026-11-01T08:05:00.000Z'
  );

insert into billing_entitlement_overrides (
  id, organization_id, capability, enabled, reason, created_by, created_at
) values (
  '58000000-0000-4000-8000-000000000001',
  '22222222-2222-4222-8222-222222222222',
  'forensic_reports',
  1,
  'DEMO override',
  'seed',
  '2026-11-01T08:07:00.000Z'
);

insert into clinical_reports (
  id, organization_id, owner_user_id, entity_type, title, case_reference, status, content, version,
  finalised_reason, created_at, updated_at
) values
  (
    '50000000-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    '10000000-0000-4000-8000-000000000001',
    'clinical',
    'DEMO synthetic report',
    'DEMO-CASE-001',
    'complete',
    '{"demo":true,"sections":[]}',
    1,
    'export',
    '2026-11-01T09:00:00.000Z',
    '2026-11-01T09:30:00.000Z'
  ),
  (
    '50000000-0000-4000-8000-000000000002',
    '22222222-2222-4222-8222-222222222222',
    '10000000-0000-4000-8000-000000000003',
    'ep',
    'DEMO synthetic EP report',
    'DEMO-CASE-002',
    'draft',
    '{"demo":true,"sections":[]}',
    1,
    null,
    '2026-11-01T09:10:00.000Z',
    '2026-11-01T09:10:00.000Z'
  );

insert into clinical_report_versions (
  id, organization_id, report_id, version, content, created_by, created_at
) values (
  '51000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  1,
  '{"demo":true,"sections":[]}',
  '10000000-0000-4000-8000-000000000001',
  '2026-11-01T09:30:00.000Z'
);

insert into clinical_attachments (
  id, organization_id, report_id, file_name, mime_type, size_bytes, object_path, status, created_at, updated_at
) values (
  '52000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  'demo-note.txt',
  'text/plain',
  24,
  'demo/orgs/solo/demo-note.txt',
  'uploaded',
  '2026-11-01T09:05:00.000Z',
  '2026-11-01T09:05:00.000Z'
);

insert into clinical_export_files (
  id, organization_id, report_id, file_name, format, object_path, created_at
) values (
  '53000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  'demo-report.html',
  'html',
  'demo/orgs/solo/demo-report.html',
  '2026-11-01T09:30:00.000Z'
);

insert into clinical_scan_compositions (
  id, organization_id, report_id, attachment_ids, created_at
) values (
  '54000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  '["52000000-0000-4000-8000-000000000001"]',
  '2026-11-01T09:06:00.000Z'
);

insert into clinical_dictation_sessions (
  id, organization_id, report_id, status, active_section_id, audio_retention_policy, paused, created_at, updated_at
) values (
  '55000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  'closed',
  'history',
  'none',
  0,
  '2026-11-01T09:15:00.000Z',
  '2026-11-01T09:20:00.000Z'
);

insert into clinical_dictation_segments (
  id, organization_id, session_id, section_id, transcript, created_at
) values (
  '56000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '55000000-0000-4000-8000-000000000001',
  'history',
  'DEMO synthetic transcript.',
  '2026-11-01T09:16:00.000Z'
);

insert into billing_report_slots (
  id, organization_id, report_id, state, period_id, reserved_at, consumed_at, created_at, updated_at
) values (
  '57000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  'consumed',
  '43000000-0000-4000-8000-000000000001',
  '2026-11-01T09:00:00.000Z',
  '2026-11-01T09:30:00.000Z',
  '2026-11-01T09:00:00.000Z',
  '2026-11-01T09:30:00.000Z'
);

insert into knowledge_documents (
  id, organization_id, report_id, attachment_id, title, status, created_at, updated_at
) values (
  '60000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  '52000000-0000-4000-8000-000000000001',
  'DEMO synthetic document',
  'ready',
  '2026-11-01T09:07:00.000Z',
  '2026-11-01T09:08:00.000Z'
);

insert into knowledge_chunks (
  id, organization_id, document_id, attachment_id, ordinal, body, embedding_model, created_at
) values (
  '61000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '60000000-0000-4000-8000-000000000001',
  '52000000-0000-4000-8000-000000000001',
  0,
  'DEMO synthetic knowledge text.',
  'demo-embedding',
  '2026-11-01T09:08:00.000Z'
);

insert into knowledge_ingestion_jobs (
  id, organization_id, document_id, status, created_at, updated_at
) values (
  '62000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '60000000-0000-4000-8000-000000000001',
  'completed',
  '2026-11-01T09:07:00.000Z',
  '2026-11-01T09:08:00.000Z'
);

insert into ai_prompt_versions (id, agent_id, version, pack, created_at) values (
  '63000000-0000-4000-8000-000000000001',
  'demo-agent',
  '1',
  '{"demo":true}',
  '2026-11-01T09:00:00.000Z'
);

insert into ai_agent_runs (
  id, organization_id, user_id, report_id, agent_id, agent_version, prompt_version, idempotency_key,
  input, state, output, provider, model, created_at, updated_at, completed_at
) values (
  '64000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '10000000-0000-4000-8000-000000000001',
  '50000000-0000-4000-8000-000000000001',
  'demo-agent',
  '1',
  '1',
  'demo-run-1',
  '{"demo":true}',
  'completed',
  '{"demo":true}',
  'openai',
  'gpt-demo',
  '2026-11-01T09:20:00.000Z',
  '2026-11-01T09:21:00.000Z',
  '2026-11-01T09:21:00.000Z'
);

insert into ai_run_events (run_id, organization_id, seq, type, data, created_at) values (
  '64000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  1,
  'demo.completed',
  '{"demo":true}',
  '2026-11-01T09:21:00.000Z'
);

insert into ai_run_steps (
  id, organization_id, run_id, step_key, status, output, created_at
) values (
  '65000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '64000000-0000-4000-8000-000000000001',
  'draft',
  'completed',
  '{"demo":true}',
  '2026-11-01T09:21:00.000Z'
);

insert into ai_tool_calls (
  id, organization_id, run_id, name, arguments, result, status, created_at
) values (
  '66000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '64000000-0000-4000-8000-000000000001',
  'demo_lookup',
  '{"demo":true}',
  '{"demo":true}',
  'completed',
  '2026-11-01T09:20:30.000Z'
);

insert into ai_citations (
  id, organization_id, run_id, document_id, chunk_id, attachment_id, excerpt, created_at
) values (
  '67000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '64000000-0000-4000-8000-000000000001',
  '60000000-0000-4000-8000-000000000001',
  '61000000-0000-4000-8000-000000000001',
  '52000000-0000-4000-8000-000000000001',
  'DEMO synthetic excerpt.',
  '2026-11-01T09:21:00.000Z'
);

insert into ai_validations (
  id, organization_id, run_id, validator, valid, issues, created_at
) values (
  '68000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '64000000-0000-4000-8000-000000000001',
  'demo-validator',
  1,
  '[]',
  '2026-11-01T09:21:00.000Z'
);

insert into ai_model_usage (
  id, organization_id, run_id, provider, model, input_tokens, output_tokens, cost_micros, created_at
) values (
  '69000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '64000000-0000-4000-8000-000000000001',
  'openai',
  'gpt-demo',
  120,
  40,
  1500,
  '2026-11-01T09:21:00.000Z'
);

insert into audit_audit_log (
  id, organization_id, actor_user_id, actor_role, action, target_type, target_id, after, created_at
) values (
  '70000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '10000000-0000-4000-8000-000000000001',
  'owner',
  'demo.seed',
  'report',
  '50000000-0000-4000-8000-000000000001',
  '{"demo":true}',
  '2026-11-01T09:30:00.000Z'
);

insert into audit_export_audit (
  id, organization_id, report_id, user_id, reason, created_at
) values (
  '71000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '50000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  'DEMO export',
  '2026-11-01T09:30:00.000Z'
);

insert into audit_ingest_audit (
  id, organization_id, document_id, user_id, created_at
) values (
  '72000000-0000-4000-8000-000000000001',
  '11111111-1111-4111-8111-111111111111',
  '60000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000001',
  '2026-11-01T09:08:00.000Z'
);

insert into audit_usage_events (
  id, organization_id, user_id, kind, payload, created_at
) values
  (
    '73000000-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    '10000000-0000-4000-8000-000000000001',
    'report_finalise',
    '{"demo":true,"format":"html"}',
    '2026-11-01T09:30:00.000Z'
  ),
  (
    '73000000-0000-4000-8000-000000000002',
    '22222222-2222-4222-8222-222222222222',
    '10000000-0000-4000-8000-000000000003',
    'report_create',
    '{"demo":true,"entity_type":"ep"}',
    '2026-11-01T09:10:00.000Z'
  );

insert into audit_activity_events (
  id, organization_id, user_id, kind, entity_type, entity_id, report_id, report_family,
  metadata, client_ip, user_agent, idempotency_key, occurred_at, created_at
) values
  (
    '74000000-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    '10000000-0000-4000-8000-000000000001',
    'report.finalise',
    'clinical',
    '50000000-0000-4000-8000-000000000001',
    '50000000-0000-4000-8000-000000000001',
    'clinical',
    '{"demo":true}',
    '127.0.0.1',
    'themis-seed',
    'demo-activity-1',
    '2026-11-01T09:30:00.000Z',
    '2026-11-01T09:30:00.000Z'
  ),
  (
    '74000000-0000-4000-8000-000000000002',
    '22222222-2222-4222-8222-222222222222',
    '10000000-0000-4000-8000-000000000003',
    'report.create',
    'ep',
    '50000000-0000-4000-8000-000000000002',
    '50000000-0000-4000-8000-000000000002',
    'ep',
    '{"demo":true}',
    '127.0.0.1',
    'themis-seed',
    'demo-activity-2',
    '2026-11-01T09:10:00.000Z',
    '2026-11-01T09:10:00.000Z'
  );

insert into themis_webapp_usage (
  id, organization_id, user_id, route, event_name, metadata, occurred_at
) values
  (
    '80000000-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    '10000000-0000-4000-8000-000000000001',
    '/reports',
    'page_view',
    '{"demo":true}',
    '2026-11-01T09:00:00.000Z'
  ),
  (
    '80000000-0000-4000-8000-000000000002',
    '22222222-2222-4222-8222-222222222222',
    '10000000-0000-4000-8000-000000000003',
    '/ep-reports',
    'page_view',
    '{"demo":true}',
    '2026-11-01T09:10:00.000Z'
  );

insert into themis_usage_daily (
  id, organization_id, source, day, metric, quantity
) values
  ('81000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'tpt-api', '2026-11-01', 'reports_created', 1),
  ('81000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'tpt-api', '2026-11-01', 'usage_events', 1),
  ('81000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'tpt-api', '2026-11-01', 'model_input_tokens', 120),
  ('81000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'tpt-api', '2026-11-01', 'model_output_tokens', 40),
  ('81000000-0000-4000-8000-000000000005', '11111111-1111-4111-8111-111111111111', 'tpt-api', '2026-11-01', 'cost_micros', 1500),
  ('81000000-0000-4000-8000-000000000006', '11111111-1111-4111-8111-111111111111', 'tpt-webapp', '2026-11-01', 'page_views', 1),
  ('81000000-0000-4000-8000-000000000007', '22222222-2222-4222-8222-222222222222', 'tpt-api', '2026-11-01', 'reports_created', 1),
  ('81000000-0000-4000-8000-000000000008', '22222222-2222-4222-8222-222222222222', 'tpt-api', '2026-11-01', 'usage_events', 1),
  ('81000000-0000-4000-8000-000000000009', '22222222-2222-4222-8222-222222222222', 'tpt-webapp', '2026-11-01', 'page_views', 1);

insert into themis_sync_runs (
  id, source, status, started_at, finished_at, row_counts
) values
  (
    '82000000-0000-4000-8000-000000000001',
    'tpt-api',
    'completed',
    '2026-11-01T10:00:00.000Z',
    '2026-11-01T10:00:05.000Z',
    '{"organisations":2,"reports":2,"usage_events":2,"model_usage":1}'
  ),
  (
    '82000000-0000-4000-8000-000000000002',
    'tpt-webapp',
    'completed',
    '2026-11-01T10:00:06.000Z',
    '2026-11-01T10:00:07.000Z',
    '{"page_views":2}'
  );

insert into themis_sync_cursors (source, object_name, last_seen_at, last_id, updated_at) values
  ('tpt-api', 'audit_activity_events', '2026-11-01T09:30:00.000Z', '74000000-0000-4000-8000-000000000001', '2026-11-01T10:00:05.000Z'),
  ('tpt-api', 'audit_usage_events', '2026-11-01T09:30:00.000Z', '73000000-0000-4000-8000-000000000001', '2026-11-01T10:00:05.000Z'),
  ('tpt-api', 'ai_model_usage', '2026-11-01T09:21:00.000Z', '69000000-0000-4000-8000-000000000001', '2026-11-01T10:00:05.000Z'),
  ('tpt-webapp', 'themis_webapp_usage', '2026-11-01T09:10:00.000Z', '80000000-0000-4000-8000-000000000002', '2026-11-01T10:00:07.000Z');
