# Themis scaffold (ASD-STE100)

| Field | Value |
| --- | --- |
| Document ID | THEMIS-STE100-001 |
| Status | Active |
| Date | 2026-11-17 |
| Product | Themis |
| Audience | An intern who takes the Themis demo task |
| Main database | `tpt-api/packages/db/migrations` |
| Code authority | `Themis/db` and `Themis/src/lib` |

Write later changes to this document in ASD-STE100:

- Use short sentences.
- Use one idea in each sentence.
- Use the active voice.
- Use the same term for the same object.
- Use the verbs *do*, *set*, *copy*, *run*, *read*, *verify*, *add*, and *remove*.
- Do not use *handle*, *process*, or *support* when a clear verb exists.

## 1. Purpose

Themis is an internal tool. Themis holds a local copy of data from tpt-api and from tpt-webapp. The copy includes usage. A reader can read the copy. A reader cannot change the copy.

This cut scaffolds the project. This cut adds the migrations and the seeds. This cut does not build the monitor screens.

The full application is specified in [THEMIS-SPEC-STE100-001](./THEMIS-SPEC-STE100.md). Build the screens from that document. Keep the database rules in this document.

## 2. Words

| Term | Meaning |
| --- | --- |
| Main database | The Postgres database of tpt-api. |
| Upstream migration | One SQL file in `db/upstream`. The file is a byte copy of one main-database migration. |
| Themis migration | One SQL file in `db/migrations`. The file runs on SQLite. |
| Mirror table | A SQLite table that copies one main-database table. |
| Product user | A person who uses tpt-webapp. The row is in `iam_profiles`. |
| Reader | A person who uses Themis. The row is in `themis_users`. The role is `reader`. |
| Seed | Demo rows that you load after the migrations. |

Do not call a product user a reader. Do not call a reader a product user.

## 3. This cut

This cut does these things:

1. Create a Next.js project in `Themis`.
2. Copy every upstream migration into `db/upstream`.
3. Add one Themis migration for every upstream migration.
4. Add three new Themis migrations for auth, sync, and usage.
5. Add seeds for the plan catalogue, two demo organisations, usage totals, and two readers.
6. Add email and password checks in `src/lib/auth.ts`.
7. Add the read rule in `src/lib/read-access.ts`.

The home page states that the user interface is not in this cut.

## 4. Do not do these tasks in this cut

- Do not add monitor screens.
- Do not add a sign-in page.
- Do not add a route that writes a mirror row.
- Do not edit a file in `db/upstream`.
- Do not put patient data in a seed.
- Do not connect Themis to the live main database.
- Do not copy Postgres roles, row level security, or Postgres functions into SQLite.

Add a new Themis migration when you change a table. Do not edit a migration that `db:migrate` has already applied on a shared database file.

## 5. Layout

| Path | Content |
| --- | --- |
| `db/upstream` | Byte copy of the main-database migrations. |
| `db/migrations` | SQLite migrations. |
| `db/seeds` | SQL seeds. |
| `db/migrate.ts` | Applies Themis migrations. |
| `db/seed.ts` | Applies SQL seeds and reader passwords. |
| `db/verify.ts` | Checks migrations, gaps, seed rows, and the read rule. |
| `src/lib/db.ts` | Opens SQLite and runs SQL files. |
| `src/lib/auth.ts` | Hashes a password, checks a password, and creates a session. |
| `src/lib/read-access.ts` | Lists every object a reader may select. |
| `src/lib/demo-readers.ts` | Names the two demo readers and the demo password. |
| `src/app/page.tsx` | Scaffold page. |
| `data/themis.sqlite` | Local database file. Git ignores this file. |
| `pnpm-workspace.yaml` | Allows the install to build `better-sqlite3` and `esbuild`. |
| `.tool-versions` | Sets Node.js 22.17.0 and pnpm 11.5.2 for this folder. |

## 6. Database rules

Themis uses one SQLite file. The default path is `data/themis.sqlite`.

Set `THEMIS_DATABASE_PATH` when you want a different path. Use a path relative to the `Themis` folder.

Open the file with `openDatabase()`. That function sets foreign keys on.

Use these type maps:

| Main database | SQLite |
| --- | --- |
| `uuid` | `text` |
| `timestamptz` | `text` in ISO-8601 |
| `jsonb` | `text` that must pass `json_valid` |
| `text[]` | `text` that holds a JSON array |
| `boolean` | `integer` `0` or `1` |
| `inet` | `text` |

Name a mirror table with this rule. Take the Postgres schema. Add `_`. Add the Postgres table name.

Example: `iam.organisations` is `iam_organisations`. Example: `billing.billing_settings` is `billing_billing_settings`. Example: `audit.audit_log` is `audit_audit_log`.

`billing.platform_settings.id` is integer `1`. In Postgres the id is boolean `true`.

`knowledge.chunks` does not store `search_vector`. `knowledge.chunks.embedding` is JSON text. Themis does not create the `vector` extension.

## 7. Migration map

Each row is one upstream file. The Themis file has the same name.

| Upstream file | Themis result |
| --- | --- |
| `0001_schemas.sql` | Creates `schema_migrations` and `themis_upstream_gaps`. Does not create roles or `util` functions. |
| `0002_iam.sql` | Creates the `iam_*` mirror tables that exist in that file. |
| `0003_billing.sql` | Creates the billing mirror tables except `billing_report_slots`. Sets the final payment-attempt status check. |
| `0004_clinical.sql` | Creates the clinical mirror tables and `billing_report_slots`. Allows export formats `pdf`, `docx`, `html`, and `txt`. |
| `0005_knowledge_ai_audit.sql` | Creates knowledge, AI, and audit mirror tables. Records the vector gap. |
| `0006_rls.sql` | Gap row only. |
| `0007_functions.sql` | Gap row only. |
| `0008_grants.sql` | Gap row only. |
| `0009_admin.sql` | Gap row only. |
| `0010_seed_plans.sql` | Inserts four placeholder plans. Prices are zero. |
| `0011_resume_stale_runs.sql` | Gap row only. |
| `0012_claim_stale_run_options.sql` | Gap row only. |
| `0013_billing_apply_payfast_itn.sql` | Gap row only. |
| `0014_claim_queued_runs.sql` | Gap row only. |
| `0015_accept_invitation.sql` | Gap row only. |
| `0015_knowledge_delete_grant.sql` | Gap row only. |
| `0016_invitation_preview.sql` | Gap row only. |
| `0017_invitation_preview_ambiguous.sql` | Gap row only. |
| `0018_invitation_preview_return_next.sql` | Gap row only. |
| `0019_export_html_txt.sql` | Gap row only. The format check is already on `clinical_export_files`. |
| `0020_membership_lifecycle.sql` | Adds `suspended_at` and `suspended_reason`. Records the policy gap. |
| `0021_org_soft_delete.sql` | Adds `deleted_at`, `purge_eligible_at`, and `removed_at`. Records the function gap. |
| `0022_org_hard_purge.sql` | Gap row only. |
| `0023_org_hard_purge_clinical.sql` | Gap row only. |
| `0024_org_hard_purge_ai_children.sql` | Gap row only. |
| `0025_definer_owner_rls.sql` | Gap row only. |
| `0026_dictation_session_ui_fields.sql` | Adds dictation UI columns. |
| `0027_mfa_recovery_codes.sql` | Creates `iam_mfa_recovery_codes`. Records the function gap. |
| `0028_activity_events.sql` | Creates `audit_activity_events`. Records the policy gap. |
| `0029_profile_extensions.sql` | Adds profile columns. Records the policy gap. |
| `0030_billing_checkout.sql` | Adds checkout columns. Records the function gap. |

Read `themis_upstream_gaps` for the full gap text.

SQLite cannot add a foreign key to an existing column. `0004_clinical.sql` creates `billing_report_slots` for that reason. Upstream creates that table in `0003_billing.sql` and adds the report foreign key in `0004_clinical.sql`.

SQLite cannot replace a table check. The final checks are on the `CREATE TABLE` statements.

## 8. New Themis migrations

These files are not in the main database.

### 8.1 `0100_themis_auth.sql`

Creates `themis_users`, `themis_sessions`, and `themis_access_policy`.

Creates the view `themis_users_public`. The view omits `password_hash`.

The only role is `reader`. The policy row sets read to `1` and write to `0`.

### 8.2 `0101_themis_sync.sql`

Creates `themis_sync_runs` and `themis_sync_cursors`.

A sync run records one copy from `tpt-api` or from `tpt-webapp`. A cursor records the last copied id for one object. This cut does not run a live copy. The seed inserts two completed runs.

### 8.3 `0102_themis_usage.sql`

Creates `themis_webapp_usage` and `themis_usage_daily`.

`themis_webapp_usage` holds a usage row from tpt-webapp. `audit_usage_events` and `ai_model_usage` remain the raw tpt-api rows. `themis_usage_daily` holds one total per organisation, source, day, and metric.

## 9. Auth

A reader signs in with email and password. Themis does not use Firebase. A product user still has `firebase_uid` on the mirror row.

`hashPassword` stores a scrypt hash. `verifyPassword` checks that hash. `authenticate` returns a reader only when the email, the password, the role, and `active` all match. `createSession` stores the SHA-256 hash of the session token. `readSessionUser` returns the reader for a live token.

Do not log a password. Do not log a session token. Do not select `themis_users.password_hash` from a reader query. Do not select `themis_sessions`.

## 10. Read rule

A reader may read every mirror table. A reader may read the usage tables, the sync tables, `themis_upstream_gaps`, `themis_access_policy`, and `themis_users_public`.

A reader must not read `themis_users`, `themis_sessions`, or `schema_migrations`.

A reader must not write a mirror row. Do not add a write helper for a mirror table.

`selectAll` rejects a name that is not in `READER_SELECT`. Add a new mirror table to `READER_SELECT` in the same change as the migration.

## 11. Seed

Run `pnpm db:seed` after `pnpm db:migrate`. You can run the seed again. The seed deletes the same demo ids and inserts them again.

`db/seeds/001_plan_catalogue.sql` sets the three paid plans from `tpt-api/packages/db/src/billing-plan-catalog.ts`. The prices are provisional local prices. `dev_unlimited` stays a placeholder.

`db/seeds/002_demo_monitor.sql` inserts the named synthetic rows.

`db/seed-volume.ts` then inserts 1000 more synthetic rows in each multi-row table. You can run the seed again. The volume seed deletes the `vorg-` rows and inserts them again. `billing_platform_settings` and `themis_access_policy` stay at one row. The schema check allows one row only. Volume readers use `volume.reader.0001@example.test` through `volume.reader.1000@example.test` and the same local demo password.

| Object | Demo value |
| --- | --- |
| Solo organisation | `Demo Solo Practice` (`11111111-1111-4111-8111-111111111111`) |
| Clinic organisation | `Demo City Clinic` (`22222222-2222-4222-8222-222222222222`) |
| Product users | `demo.owner@example.test`, `demo.member@example.test`, `demo.clinic.admin@example.test` |
| Plans | Solo Pro for the solo organisation. Institutional Team for the clinic. |
| Reports | `DEMO synthetic report` and `DEMO synthetic EP report` |
| Usage day | `2026-11-01` |

The solo organisation has one finalised report, one export, one dictation session, one model-usage row, and one webapp page view. The clinic has one draft report, one usage event, and one webapp page view. Daily totals match those rows.

The seed also inserts two readers:

| Email | Password | Role |
| --- | --- | --- |
| `reader.one@example.test` | `Themis-Reader-100` | `reader` |
| `reader.two@example.test` | `Themis-Reader-100` | `reader` |

This password is a local demo password. Do not use this password outside the local database file.

## 12. Commands

Run the commands in the `Themis` folder.

| Command | Result |
| --- | --- |
| `pnpm install` | Installs Next.js, React, and `better-sqlite3`. |
| `pnpm db:migrate` | Applies each new file in `db/migrations` in file-name order. |
| `pnpm db:seed` | Loads the SQL seeds and the two readers. |
| `pnpm db:verify` | Fails when a migration, a gap row, a seed row, or the read rule is wrong. |
| `pnpm dev` | Serves the scaffold page. |

Delete `data/themis.sqlite` when you want a new database file. Then run `pnpm db:migrate` and `pnpm db:seed` again.

## 13. Check

Do these checks before you call the scaffold complete:

1. Run `pnpm db:verify`. The command must exit 0.
2. Open the dev page. The page must state that the user interface is not in this cut.
3. Read `themis_upstream_gaps`. Confirm that row level security and Postgres functions are gap rows.
4. Select `clinical_reports` through `selectAll`. The call must return the two demo reports.
5. Call `selectAll` with `themis_sessions`. The call must throw `FORBIDDEN`.
