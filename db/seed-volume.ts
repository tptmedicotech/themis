import type { Database } from 'better-sqlite3';
import { hashPassword } from '../src/lib/auth';
import { DEMO_READER_PASSWORD } from '../src/lib/demo-readers';

export const VOLUME_ROWS = 1000;

const ENTITY_TYPES = ['clinical', 'ep', 'psychometry', 'forensic'] as const;
const REPORT_STATUSES = ['draft', 'in_progress', 'complete'] as const;
const MEMBER_ROLES = ['owner', 'admin', 'member', 'viewer'] as const;
const INVITE_ROLES = ['admin', 'member', 'viewer'] as const;
const PLAN_KEYS = ['solo_basic', 'solo_pro', 'institutional_team'] as const;

const SINGLETON_TABLES = new Set([
  'billing_platform_settings',
  'themis_access_policy',
  'schema_migrations',
]);

function pad(index: number): string {
  return String(index).padStart(4, '0');
}

function stamp(index: number): string {
  return new Date(Date.UTC(2026, 9, 1, 0, 0, 0) + index * 60_000).toISOString();
}

function clearVolume(db: Database): void {
  db.exec(`
    delete from themis_usage_daily where organization_id like 'vorg-%';
    delete from themis_webapp_usage where organization_id like 'vorg-%';
    delete from ai_run_events where organization_id like 'vorg-%';
    delete from ai_run_steps where organization_id like 'vorg-%';
    delete from ai_tool_calls where organization_id like 'vorg-%';
    delete from ai_citations where organization_id like 'vorg-%';
    delete from ai_validations where organization_id like 'vorg-%';
    delete from ai_model_usage where organization_id like 'vorg-%';
    delete from ai_agent_runs where organization_id like 'vorg-%';
    delete from knowledge_ingestion_jobs where organization_id like 'vorg-%';
    delete from knowledge_chunks where organization_id like 'vorg-%';
    delete from knowledge_documents where organization_id like 'vorg-%';
    delete from audit_activity_events where organization_id like 'vorg-%';
    delete from audit_usage_events where organization_id like 'vorg-%';
    delete from audit_export_audit where organization_id like 'vorg-%';
    delete from audit_ingest_audit where organization_id like 'vorg-%';
    delete from audit_audit_log where id like 'vaudit-%';
    delete from clinical_dictation_segments where organization_id like 'vorg-%';
    delete from clinical_dictation_sessions where organization_id like 'vorg-%';
    delete from clinical_scan_compositions where organization_id like 'vorg-%';
    delete from clinical_export_files where organization_id like 'vorg-%';
    delete from clinical_attachments where organization_id like 'vorg-%';
    delete from clinical_report_versions where organization_id like 'vorg-%';
    delete from billing_report_slots where organization_id like 'vorg-%';
    delete from clinical_reports where organization_id like 'vorg-%';
    delete from billing_payment_attempts where organization_id like 'vorg-%';
    delete from billing_payfast_notifications where id like 'vpf-%';
    delete from billing_quota_periods where organization_id like 'vorg-%';
    delete from billing_entitlement_overrides where organization_id like 'vorg-%';
    delete from billing_subscriptions where organization_id like 'vorg-%';
    delete from billing_billing_settings where organization_id like 'vorg-%';
    delete from iam_mfa_recovery_codes where user_id like 'vusr-%';
    delete from iam_invitations where organization_id like 'vorg-%';
    delete from iam_memberships where organization_id like 'vorg-%';
    delete from iam_org_settings where organization_id like 'vorg-%';
    delete from iam_org_ai_policy where organization_id like 'vorg-%';
    delete from iam_organisations where id like 'vorg-%';
    delete from iam_profiles where id like 'vusr-%';
    delete from billing_plans where key like 'volume_plan_%';
    delete from ai_prompt_versions where id like 'vprompt-%';
    delete from themis_sessions where id like 'vses-%';
    delete from themis_users where id like 'vreader-%';
    delete from themis_sync_cursors where object_name like 'volume_object_%';
    delete from themis_sync_runs where id like 'vsync-%';
    delete from themis_upstream_gaps where id like 'volume-gap-%';
  `);
}

function insertVolume(db: Database, passwordHash: string): void {
  const org = db.prepare(
    `insert into iam_organisations (id, name, org_type, status, created_at, updated_at)
     values (?, ?, ?, 'active', ?, ?)`,
  );
  const profile = db.prepare(
    `insert into iam_profiles (
       id, firebase_uid, email, display_name, first_name, last_name, preferences, active, created_at, updated_at
     ) values (?, ?, ?, ?, 'Volume', ?, '{"demo":true,"volume":true}', 1, ?, ?)`,
  );
  const membership = db.prepare(
    `insert into iam_memberships (id, organization_id, user_id, role, status, created_at, updated_at)
     values (?, ?, ?, ?, 'active', ?, ?)`,
  );
  const invitation = db.prepare(
    `insert into iam_invitations (
       id, organization_id, email, role, token_hash, status, expires_at, invited_by, created_at, updated_at
     ) values (?, ?, ?, ?, ?, 'pending', '2027-01-01T00:00:00.000Z', ?, ?, ?)`,
  );
  const settings = db.prepare(
    `insert into iam_org_settings (organization_id, stt_audio_retention_days, created_at, updated_at)
     values (?, 30, ?, ?)`,
  );
  const policy = db.prepare(
    `insert into iam_org_ai_policy (
       organization_id, allowed_providers, cross_border_consent, created_at, updated_at
     ) values (?, '["openai"]', 0, ?, ?)`,
  );
  const mfa = db.prepare(
    `insert into iam_mfa_recovery_codes (id, user_id, code_hash, used, created_at)
     values (?, ?, ?, 0, ?)`,
  );
  const billingSettings = db.prepare(
    `insert into billing_billing_settings (organization_id, grace_days, created_at, updated_at)
     values (?, 7, ?, ?)`,
  );
  const subscription = db.prepare(
    `insert into billing_subscriptions (
       id, organization_id, plan_key, status, current_period_start, current_period_end,
       last_payment_outcome, created_at, updated_at
     ) values (?, ?, ?, 'active', '2026-10-01T00:00:00.000Z', '2026-11-01T00:00:00.000Z', 'applied', ?, ?)`,
  );
  const payment = db.prepare(
    `insert into billing_payment_attempts (
       id, organization_id, subscription_id, amount_cents, currency, status, payfast_payment_id,
       owner_user_id, plan_key, recurring_amount_cents, kind, created_at, updated_at
     ) values (?, ?, ?, 99900, 'ZAR', 'complete', ?, ?, ?, 99900, 'initial', ?, ?)`,
  );
  const payfast = db.prepare(
    `insert into billing_payfast_notifications (
       id, pf_payment_id, organization_id, payload, source_ip, outcome, created_at
     ) values (?, ?, ?, '{"demo":true,"volume":true}', '127.0.0.1', 'applied', ?)`,
  );
  const quota = db.prepare(
    `insert into billing_quota_periods (
       id, organization_id, capability, period_start, period_end, limit_value, consumed, reserved, created_at, updated_at
     ) values (?, ?, 'reports', '2026-10-01T00:00:00.000Z', '2026-11-01T00:00:00.000Z', 25, 1, 0, ?, ?)`,
  );
  const entitlement = db.prepare(
    `insert into billing_entitlement_overrides (
       id, organization_id, capability, enabled, reason, created_by, created_at
     ) values (?, ?, 'forensic_reports', 1, 'DEMO volume override', 'seed', ?)`,
  );
  const report = db.prepare(
    `insert into clinical_reports (
       id, organization_id, owner_user_id, entity_type, title, case_reference, status, content, version,
       finalised_reason, created_at, updated_at
     ) values (?, ?, ?, ?, ?, ?, ?, '{"demo":true,"volume":true,"sections":[]}', 1, ?, ?, ?)`,
  );
  const version = db.prepare(
    `insert into clinical_report_versions (id, organization_id, report_id, version, content, created_by, created_at)
     values (?, ?, ?, 1, '{"demo":true,"volume":true,"sections":[]}', ?, ?)`,
  );
  const attachment = db.prepare(
    `insert into clinical_attachments (
       id, organization_id, report_id, file_name, mime_type, size_bytes, object_path, status, created_at, updated_at
     ) values (?, ?, ?, ?, 'text/plain', 24, ?, 'uploaded', ?, ?)`,
  );
  const exportFile = db.prepare(
    `insert into clinical_export_files (id, organization_id, report_id, file_name, format, object_path, created_at)
     values (?, ?, ?, ?, 'html', ?, ?)`,
  );
  const scan = db.prepare(
    `insert into clinical_scan_compositions (id, organization_id, report_id, attachment_ids, created_at)
     values (?, ?, ?, ?, ?)`,
  );
  const dictation = db.prepare(
    `insert into clinical_dictation_sessions (
       id, organization_id, report_id, status, active_section_id, audio_retention_policy, paused, created_at, updated_at
     ) values (?, ?, ?, 'closed', 'history', 'none', 0, ?, ?)`,
  );
  const segment = db.prepare(
    `insert into clinical_dictation_segments (id, organization_id, session_id, section_id, transcript, created_at)
     values (?, ?, ?, 'history', ?, ?)`,
  );
  const slot = db.prepare(
    `insert into billing_report_slots (
       id, organization_id, report_id, state, period_id, reserved_at, consumed_at, created_at, updated_at
     ) values (?, ?, ?, 'consumed', ?, ?, ?, ?, ?)`,
  );
  const document = db.prepare(
    `insert into knowledge_documents (
       id, organization_id, report_id, attachment_id, title, status, created_at, updated_at
     ) values (?, ?, ?, ?, ?, 'ready', ?, ?)`,
  );
  const chunk = db.prepare(
    `insert into knowledge_chunks (
       id, organization_id, document_id, attachment_id, ordinal, body, embedding_model, created_at
     ) values (?, ?, ?, ?, 0, ?, 'demo-embedding', ?)`,
  );
  const job = db.prepare(
    `insert into knowledge_ingestion_jobs (id, organization_id, document_id, status, created_at, updated_at)
     values (?, ?, ?, 'completed', ?, ?)`,
  );
  const prompt = db.prepare(
    `insert into ai_prompt_versions (id, agent_id, version, pack, created_at)
     values (?, 'volume-agent', ?, '{"demo":true,"volume":true}', ?)`,
  );
  const run = db.prepare(
    `insert into ai_agent_runs (
       id, organization_id, user_id, report_id, agent_id, agent_version, prompt_version, idempotency_key,
       input, state, output, provider, model, created_at, updated_at, completed_at
     ) values (?, ?, ?, ?, 'volume-agent', '1', ?, ?, '{"demo":true,"volume":true}', 'completed', '{"demo":true,"volume":true}', 'openai', 'gpt-demo', ?, ?, ?)`,
  );
  const event = db.prepare(
    `insert into ai_run_events (run_id, organization_id, seq, type, data, created_at)
     values (?, ?, 1, 'volume.completed', '{"demo":true,"volume":true}', ?)`,
  );
  const step = db.prepare(
    `insert into ai_run_steps (id, organization_id, run_id, step_key, status, output, created_at)
     values (?, ?, ?, 'draft', 'completed', '{"demo":true,"volume":true}', ?)`,
  );
  const tool = db.prepare(
    `insert into ai_tool_calls (id, organization_id, run_id, name, arguments, result, status, created_at)
     values (?, ?, ?, 'volume_lookup', '{"demo":true}', '{"demo":true}', 'completed', ?)`,
  );
  const citation = db.prepare(
    `insert into ai_citations (
       id, organization_id, run_id, document_id, chunk_id, attachment_id, excerpt, created_at
     ) values (?, ?, ?, ?, ?, ?, ?, ?)`,
  );
  const validation = db.prepare(
    `insert into ai_validations (id, organization_id, run_id, validator, valid, issues, created_at)
     values (?, ?, ?, 'demo-validator', 1, '[]', ?)`,
  );
  const modelUsage = db.prepare(
    `insert into ai_model_usage (
       id, organization_id, run_id, provider, model, input_tokens, output_tokens, cost_micros, created_at
     ) values (?, ?, ?, 'openai', 'gpt-demo', 10, 4, 100, ?)`,
  );
  const auditLog = db.prepare(
    `insert into audit_audit_log (
       id, organization_id, actor_user_id, actor_role, action, target_type, target_id, after, created_at
     ) values (?, ?, ?, 'owner', 'demo.volume', 'report', ?, '{"demo":true,"volume":true}', ?)`,
  );
  const exportAudit = db.prepare(
    `insert into audit_export_audit (id, organization_id, report_id, user_id, reason, created_at)
     values (?, ?, ?, ?, 'DEMO volume export', ?)`,
  );
  const ingestAudit = db.prepare(
    `insert into audit_ingest_audit (id, organization_id, document_id, user_id, created_at)
     values (?, ?, ?, ?, ?)`,
  );
  const usageEvent = db.prepare(
    `insert into audit_usage_events (id, organization_id, user_id, kind, payload, created_at)
     values (?, ?, ?, 'report_create', '{"demo":true,"volume":true}', ?)`,
  );
  const activity = db.prepare(
    `insert into audit_activity_events (
       id, organization_id, user_id, kind, entity_type, entity_id, report_id, report_family,
       metadata, client_ip, user_agent, idempotency_key, occurred_at, created_at
     ) values (?, ?, ?, 'report_create', ?, ?, ?, ?, '{"demo":true,"volume":true}', '127.0.0.1', 'themis-seed', ?, ?, ?)`,
  );
  const webapp = db.prepare(
    `insert into themis_webapp_usage (id, organization_id, user_id, route, event_name, metadata, occurred_at)
     values (?, ?, ?, '/reports', 'page_view', '{"demo":true,"volume":true}', ?)`,
  );
  const daily = db.prepare(
    `insert into themis_usage_daily (id, organization_id, source, day, metric, quantity)
     values (?, ?, 'tpt-api', '2026-10-15', 'reports_created', 1)`,
  );
  const syncRun = db.prepare(
    `insert into themis_sync_runs (id, source, status, started_at, finished_at, row_counts)
     values (?, ?, 'completed', ?, ?, '{"volume":1}')`,
  );
  const cursor = db.prepare(
    `insert into themis_sync_cursors (source, object_name, last_seen_at, last_id, updated_at)
     values (?, ?, ?, ?, ?)`,
  );
  const reader = db.prepare(
    `insert into themis_users (id, email, password_hash, display_name, role, active)
     values (?, ?, ?, ?, 'reader', 1)`,
  );
  const session = db.prepare(
    `insert into themis_sessions (id, user_id, token_hash, expires_at)
     values (?, ?, ?, '2027-01-01T00:00:00.000Z')`,
  );
  const plan = db.prepare(
    `insert into billing_plans (
       key, name, price_cents, report_limit_monthly, seat_limit, features, "public", active, placeholder
     ) values (?, ?, 0, 1, 1, '[]', 0, 1, 1)`,
  );
  const gap = db.prepare(`insert into themis_upstream_gaps (id, reason) values (?, ?)`);

  for (let index = 1; index <= VOLUME_ROWS; index += 1) {
    const n = pad(index);
    const at = stamp(index);
    const orgId = `vorg-${n}`;
    const userId = `vusr-${n}`;
    const reportId = `vreport-${n}`;
    const attachmentId = `vatt-${n}`;
    const documentId = `vdoc-${n}`;
    const runId = `vrun-${n}`;
    const planKey = PLAN_KEYS[index % PLAN_KEYS.length];
    const entityType = ENTITY_TYPES[index % ENTITY_TYPES.length];
    const status = REPORT_STATUSES[index % REPORT_STATUSES.length];
    const finalised = status === 'complete' ? 'export' : null;

    org.run(orgId, `Volume Practice ${n}`, index % 2 === 0 ? 'institutional' : 'solo', at, at);
    profile.run(userId, `volume-firebase-${n}`, `volume.user.${n}@example.test`, `Volume User ${n}`, `User${n}`, at, at);
    membership.run(`vmem-${n}`, orgId, userId, MEMBER_ROLES[index % MEMBER_ROLES.length], at, at);
    invitation.run(
      `vinv-${n}`,
      orgId,
      `volume.invite.${n}@example.test`,
      INVITE_ROLES[index % INVITE_ROLES.length],
      `volume-invite-token-${n}`,
      userId,
      at,
      at,
    );
    settings.run(orgId, at, at);
    policy.run(orgId, at, at);
    mfa.run(`vmfa-${n}`, userId, `volume-mfa-${n}`, at);
    billingSettings.run(orgId, at, at);
    subscription.run(`vsub-${n}`, orgId, planKey, at, at);
    payment.run(`vpay-${n}`, orgId, `vsub-${n}`, `volume-pf-${n}`, userId, planKey, at, at);
    payfast.run(`vpf-${n}`, `volume-pf-${n}`, orgId, at);
    quota.run(`vquota-${n}`, orgId, at, at);
    entitlement.run(`vent-${n}`, orgId, at);
    report.run(
      reportId,
      orgId,
      userId,
      entityType,
      `DEMO volume report ${n}`,
      `DEMO-VOL-${n}`,
      status,
      finalised,
      at,
      at,
    );
    version.run(`vver-${n}`, orgId, reportId, userId, at);
    attachment.run(`vatt-${n}`, orgId, reportId, `volume-note-${n}.txt`, `demo/volume/${n}.txt`, at, at);
    exportFile.run(`vexp-${n}`, orgId, reportId, `volume-report-${n}.html`, `demo/volume/${n}.html`, at);
    scan.run(`vscan-${n}`, orgId, reportId, JSON.stringify([attachmentId]), at);
    dictation.run(`vdict-${n}`, orgId, reportId, at, at);
    segment.run(`vseg-${n}`, orgId, `vdict-${n}`, `DEMO synthetic transcript ${n}.`, at);
    slot.run(`vslot-${n}`, orgId, reportId, `vquota-${n}`, at, at, at, at);
    document.run(documentId, orgId, reportId, attachmentId, `DEMO volume document ${n}`, at, at);
    chunk.run(`vchunk-${n}`, orgId, documentId, attachmentId, `DEMO synthetic knowledge text ${n}.`, at);
    job.run(`vjob-${n}`, orgId, documentId, at, at);
    prompt.run(`vprompt-${n}`, String(index), at);
    run.run(runId, orgId, userId, reportId, String(index), `volume-run-${n}`, at, at, at);
    event.run(runId, orgId, at);
    step.run(`vstep-${n}`, orgId, runId, at);
    tool.run(`vtool-${n}`, orgId, runId, at);
    citation.run(
      `vcite-${n}`,
      orgId,
      runId,
      documentId,
      `vchunk-${n}`,
      attachmentId,
      `DEMO synthetic excerpt ${n}.`,
      at,
    );
    validation.run(`vval-${n}`, orgId, runId, at);
    modelUsage.run(`vmodel-${n}`, orgId, runId, at);
    auditLog.run(`vaudit-${n}`, orgId, userId, reportId, at);
    exportAudit.run(`vxaud-${n}`, orgId, reportId, userId, at);
    ingestAudit.run(`viaud-${n}`, orgId, documentId, userId, at);
    usageEvent.run(`vusage-${n}`, orgId, userId, at);
    activity.run(`vact-${n}`, orgId, userId, entityType, reportId, reportId, entityType, `volume-activity-${n}`, at, at);
    webapp.run(`vweb-${n}`, orgId, userId, at);
    daily.run(`vdaily-${n}`, orgId);
    syncRun.run(`vsync-${n}`, index % 2 === 0 ? 'tpt-webapp' : 'tpt-api', at, at);
    cursor.run(index % 2 === 0 ? 'tpt-webapp' : 'tpt-api', `volume_object_${n}`, at, `vact-${n}`, at);
    reader.run(`vreader-${n}`, `volume.reader.${n}@example.test`, passwordHash, `Volume Reader ${n}`);
    session.run(`vses-${n}`, `vreader-${n}`, `volume-session-hash-${n}`);
    plan.run(`volume_plan_${n}`, `Volume Plan ${n} (PLACEHOLDER — not a production price)`);
    gap.run(`volume-gap-${n}`, 'Volume seed row. This row is not an upstream gap.');
  }
}

export function seedVolume(db: Database): void {
  const passwordHash = hashPassword(DEMO_READER_PASSWORD);
  const apply = db.transaction(() => {
    clearVolume(db);
    insertVolume(db, passwordHash);
  });
  apply();
  assertVolume(db);
}

export function assertVolume(db: Database): void {
  const tables = db
    .prepare(
      `select name from sqlite_master
        where type = 'table' and name not like 'sqlite_%'
        order by name`,
    )
    .all() as Array<{ name: string }>;
  const short: string[] = [];
  for (const table of tables) {
    if (SINGLETON_TABLES.has(table.name)) continue;
    const row = db.prepare(`select count(*) as n from ${table.name}`).get() as { n: number };
    if (row.n < VOLUME_ROWS) short.push(`${table.name}=${row.n}`);
  }
  if (short.length > 0) {
    throw new Error(`volume seed is short: ${short.join(', ')}`);
  }
}
