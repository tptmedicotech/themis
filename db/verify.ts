import { authenticate } from '../src/lib/auth';
import { DEMO_READER_PASSWORD, DEMO_READERS } from '../src/lib/demo-readers';
import { listSqlFiles, MIGRATIONS_DIR, openDatabase, UPSTREAM_DIR } from '../src/lib/db';
import {
  assertFullReadOnly,
  assertMirrorTablesAreReadable,
  assertReaderSelect,
  selectAll,
} from '../src/lib/read-access';

const POSTGRES_ONLY = [
  '0006_rls.sql',
  '0007_functions.sql',
  '0008_grants.sql',
  '0009_admin.sql',
  '0011_resume_stale_runs.sql',
  '0012_claim_stale_run_options.sql',
  '0013_billing_apply_payfast_itn.sql',
  '0014_claim_queued_runs.sql',
  '0015_accept_invitation.sql',
  '0015_knowledge_delete_grant.sql',
  '0016_invitation_preview.sql',
  '0017_invitation_preview_ambiguous.sql',
  '0018_invitation_preview_return_next.sql',
  '0022_org_hard_purge.sql',
  '0023_org_hard_purge_clinical.sql',
  '0024_org_hard_purge_ai_children.sql',
  '0025_definer_owner_rls.sql',
];

function fail(message: string): never {
  throw new Error(message);
}

const upstream = listSqlFiles(UPSTREAM_DIR);
const migrations = listSqlFiles(MIGRATIONS_DIR);
for (const file of upstream) {
  if (!migrations.includes(file)) fail(`missing SQLite migration for ${file}`);
}
for (const file of ['0100_themis_auth.sql', '0101_themis_sync.sql', '0102_themis_usage.sql']) {
  if (!migrations.includes(file)) fail(`missing Themis migration ${file}`);
}

const db = openDatabase();
const applied = new Set(
  (db.prepare('select id from schema_migrations').all() as Array<{ id: string }>).map((row) => row.id),
);
for (const file of migrations) {
  if (!applied.has(file)) fail(`migration ${file} is not applied. Run db:migrate.`);
}

const gapIds = new Set(
  (db.prepare('select id from themis_upstream_gaps').all() as Array<{ id: string }>).map((row) => row.id),
);
for (const file of POSTGRES_ONLY) {
  if (!gapIds.has(file)) fail(`missing upstream gap row for ${file}`);
}

assertFullReadOnly(db);
assertMirrorTablesAreReadable(db);

const reports = selectAll(db, 'clinical_reports');
if (reports.length < 2) fail('seed did not insert the demo reports. Run db:seed.');

const daily = selectAll(db, 'themis_usage_daily');
if (daily.length < 9) fail('seed did not insert usage totals. Run db:seed.');

const reader = authenticate(db, DEMO_READERS[0].email, DEMO_READER_PASSWORD);
if (!reader || reader.role !== 'reader') fail('reader sign-in failed');
if (authenticate(db, DEMO_READERS[0].email, 'wrong-password') !== null) {
  fail('wrong password was accepted');
}

let rejected = false;
try {
  assertReaderSelect('themis_sessions');
} catch (error) {
  rejected = error instanceof Error && error.message === 'FORBIDDEN';
}
if (!rejected) fail('a reader was allowed to select themis_sessions');

let writeRejected = false;
try {
  db.prepare(
    `insert into themis_users (id, email, password_hash, display_name, role)
     values ('ffffffff-ffff-4fff-8fff-ffffffffffff', 'no-admin@example.test', 'x', 'No Admin', 'admin')`,
  ).run();
} catch {
  writeRejected = true;
}
if (!writeRejected) fail('a non-reader role was inserted');

const plans = db.prepare(`select count(*) as n from billing_plans where placeholder = 0`).get() as {
  n: number;
};
if (plans.n !== 3) fail('the seed did not set three catalogue plans');

console.log(
  `verified ${applied.size} migrations, ${gapIds.size} upstream gaps, ${reports.length} reports, reader ${reader.email}`,
);
db.close();
