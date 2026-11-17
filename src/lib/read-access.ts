import type { Database } from 'better-sqlite3';

/** Tables and views a reader may select. Do not add password or session tables. */
export const READER_SELECT = [
  'iam_organisations',
  'iam_profiles',
  'iam_memberships',
  'iam_invitations',
  'iam_org_settings',
  'iam_org_ai_policy',
  'iam_mfa_recovery_codes',
  'billing_plans',
  'billing_billing_settings',
  'billing_platform_settings',
  'billing_subscriptions',
  'billing_payment_attempts',
  'billing_payfast_notifications',
  'billing_quota_periods',
  'billing_report_slots',
  'billing_entitlement_overrides',
  'clinical_reports',
  'clinical_report_versions',
  'clinical_attachments',
  'clinical_export_files',
  'clinical_scan_compositions',
  'clinical_dictation_sessions',
  'clinical_dictation_segments',
  'knowledge_documents',
  'knowledge_chunks',
  'knowledge_ingestion_jobs',
  'ai_prompt_versions',
  'ai_agent_runs',
  'ai_run_events',
  'ai_run_steps',
  'ai_tool_calls',
  'ai_citations',
  'ai_validations',
  'ai_model_usage',
  'audit_audit_log',
  'audit_export_audit',
  'audit_ingest_audit',
  'audit_usage_events',
  'audit_activity_events',
  'themis_upstream_gaps',
  'themis_access_policy',
  'themis_users_public',
  'themis_sync_runs',
  'themis_sync_cursors',
  'themis_webapp_usage',
  'themis_usage_daily',
] as const;

export type ReaderSelectName = (typeof READER_SELECT)[number];

const READER_SELECT_SET = new Set<string>(READER_SELECT);

const MIRROR_PREFIXES = ['iam_', 'billing_', 'clinical_', 'knowledge_', 'ai_', 'audit_'] as const;

export function assertReaderSelect(table: string): asserts table is ReaderSelectName {
  if (!READER_SELECT_SET.has(table)) {
    throw new Error('FORBIDDEN');
  }
}

export function selectAll(db: Database, table: string): unknown[] {
  assertReaderSelect(table);
  return db.prepare(`select * from ${table}`).all();
}

export function assertFullReadOnly(db: Database): void {
  const row = db
    .prepare(
      `select may_read_mirror as mayRead, may_write_mirror as mayWrite
         from themis_access_policy
        where role = 'reader'`,
    )
    .get() as { mayRead: number; mayWrite: number } | undefined;
  if (!row || row.mayRead !== 1 || row.mayWrite !== 0) {
    throw new Error('FORBIDDEN');
  }
}

export function assertMirrorTablesAreReadable(db: Database): void {
  const objects = db
    .prepare(
      `select name, type from sqlite_master
        where type in ('table', 'view')
          and name not like 'sqlite_%'`,
    )
    .all() as Array<{ name: string; type: string }>;
  const names = new Set(objects.map((object) => object.name));
  for (const table of READER_SELECT) {
    if (!names.has(table)) {
      throw new Error(`MISSING_READ_TARGET ${table}`);
    }
  }
  for (const object of objects) {
    if (object.type !== 'table') continue;
    if (!MIRROR_PREFIXES.some((prefix) => object.name.startsWith(prefix))) continue;
    if (!READER_SELECT_SET.has(object.name)) {
      throw new Error(`MIRROR_TABLE_NOT_READABLE ${object.name}`);
    }
  }
}
