# Themis application specification (ASD-STE100)

| Field | Value |
| --- | --- |
| Document ID | THEMIS-SPEC-STE100-001 |
| Status | Active |
| Date | 2026-11-17 |
| Product | Themis |
| Audience | An intern who builds the Themis monitor |
| Baseline | [THEMIS-STE100-001](./THEMIS-STE100.md) |
| Data authority | `Themis/db/migrations` and `Themis/src/lib/read-access.ts` |

Write later changes to this document in ASD-STE100:

- Use short sentences.
- Use one idea in each sentence.
- Use the active voice.
- Use the same term for the same object.
- Use the verbs *do*, *set*, *show*, *read*, *run*, *verify*, *add*, and *remove*.
- Do not use *handle*, *process*, or *support* when a clear verb exists.

## 1. Purpose

Themis is an internal monitor. A reader uses Themis to read a local copy of tpt-api data and tpt-webapp usage.

This document states the full application. The scaffold in THEMIS-STE100-001 is the start. You build the screens on that start.

A reader can read every mirror row. A reader cannot change a mirror row.

## 2. Words

Use the words in THEMIS-STE100-001. This document adds these words.

| Term | Meaning |
| --- | --- |
| Screen | One page in the Themis application. |
| Shell | The signed-in frame. The shell shows the navigation and the reader email. |
| Overview | The home screen after sign-in. |
| Mirror row | One row in a mirror table. |
| Usage total | One row in `themis_usage_daily`. |
| Sync run | One row in `themis_sync_runs`. |
| Sign-in | The act of sending an email and a password to open a session. |

Do not call a product user a reader. Do not call a reader a product user.

## 3. What you build

Build these screens:

| Route | Screen |
| --- | --- |
| `/sign-in` | Sign-in |
| `/` | Overview |
| `/organisations` | Organisation list |
| `/organisations/[id]` | Organisation detail |
| `/product-users` | Product user list |
| `/product-users/[id]` | Product user detail |
| `/reports` | Report list |
| `/reports/[id]` | Report detail |
| `/usage` | Usage |
| `/activity` | Activity |
| `/billing` | Billing |
| `/ai-runs` | AI run list |
| `/ai-runs/[id]` | AI run detail |
| `/sync` | Sync |

Build a session check. Send a reader with no session to `/sign-in`. Send a signed-in reader away from `/sign-in` to `/`.

Read the SQLite file on the server. Do not import `src/lib/db.ts` from a client component.

Use `selectAll` or a query that calls `assertReaderSelect` before the query. Add a new name to `READER_SELECT` only when you add a new readable table or view.

## 4. What you do not build

- Do not add a control that inserts, updates, or deletes a mirror row.
- Do not add a live copy job from Postgres. Show the sync runs and cursors that are already in SQLite.
- Do not connect the browser to the main database.
- Do not add Firebase sign-in.
- Do not add a second role.
- Do not edit a file in `db/upstream`.
- Do not put patient data in a seed.
- Do not log a password, a session token, or report `content`.
- Do not show `password_hash` or `token_hash`.

A later cut may add a copy job. This specification does not include that job.

## 5. Sign-in

Show two fields: email and password. Show one button: Sign in.

Call `authenticate`. On success, call `createSession`. Store the session token in an HTTP-only cookie. Do not store the token in `localStorage`.

On failure, show this sentence only: `Sign-in failed.`

Use that same sentence when the email is unknown, the password is wrong, or `active` is `0`. Do not tell the reader which check failed.

The session lasts 12 hours. `readSessionUser` rejects an expired token. Send that reader to `/sign-in`.

The shell shows the reader email and a Sign out control. Sign out deletes the cookie. Sign out does not delete the mirror data.

Demo readers are in THEMIS-STE100-001 §11. Use them to verify sign-in. Do not use that password outside the local database file.

## 6. Shell

The shell wraps every screen except `/sign-in`.

Show these links:

1. Overview
2. Organisations
3. Product users
4. Reports
5. Usage
6. Activity
7. Billing
8. AI runs
9. Sync

Show the text `Read only` in the shell. A reader must see that text on every signed-in screen.

Follow [THEMIS-STYLE-STE100-001](./THEMIS-STYLE-STE100.md) for colour, type, chrome, and controls.

Show times in UTC. Use the form `YYYY-MM-DD HH:mm`. Label the column `UTC`.

Show an empty list with the sentence `No rows match this filter.`

A list shows 50 rows. Show older rows with a next control. Show the newer page with a previous control. Order lists by the time column in this specification, newest first, unless the screen says another order.

## 7. Overview

The overview answers four questions:

1. How many organisations, product users, and reports are in the copy?
2. How many reports are `draft`, `in_progress`, and `complete`?
3. What usage did each source record on the selected day?
4. When did the last sync run finish for `tpt-api` and for `tpt-webapp`?

Show a day field. The default day is `2026-11-01` when that day has usage totals. Otherwise the default day is the latest `day` in `themis_usage_daily`.

For the selected day, show one row per organisation and metric. Read the numbers from `themis_usage_daily`. Show `source`, `metric`, and `quantity`.

Show the latest sync run for each source. Show `status`, `started_at`, `finished_at`, and `error`.

Link each count to the matching list screen.

## 8. Organisations

### 8.1 List

Read `iam_organisations`. Show `name`, `org_type`, `status`, `created_at`, and `deleted_at`.

Add filters for `org_type` and `status`. The filters are `solo`, `institutional`, `active`, `suspended`, and `deleted`. An empty filter shows every organisation.

### 8.2 Detail

Open one organisation by `id`. Show these blocks:

| Block | Table | Fields |
| --- | --- | --- |
| Organisation | `iam_organisations` | `name`, `org_type`, `status`, `created_at`, `deleted_at`, `purge_eligible_at` |
| Settings | `iam_org_settings` | `stt_audio_retention_days` |
| AI policy | `iam_org_ai_policy` | `allowed_providers`, `cross_border_consent`, `consent_recorded_at` |
| Members | `iam_memberships` joined to `iam_profiles` | product user email, `role`, `status`, `suspended_at`, `suspended_reason`, `removed_at` |
| Invitations | `iam_invitations` | `email`, `role`, `status`, `expires_at` |
| Subscription | `billing_subscriptions` joined to `billing_plans` | plan `name`, subscription `status`, `current_period_start`, `current_period_end`, `last_payment_outcome` |
| Quota | `billing_quota_periods` | `capability`, `period_start`, `period_end`, `limit_value`, `consumed`, `reserved` |
| Billing settings | `billing_billing_settings` | `grace_days` |
| Entitlements | `billing_entitlement_overrides` | `capability`, `enabled`, `reason`, `created_at` |

Do not show `token_hash` from `iam_invitations`.

Link each member email to the product user detail. Link each report for that `organization_id` from the report list.

## 9. Product users

### 9.1 List

Read `iam_profiles`. Show `display_name`, `email`, `first_name`, `last_name`, `active`, and `created_at`.

Add a text filter on email and display name. The match is case-insensitive.

### 9.2 Detail

Show the profile fields above. Also show `firebase_uid`, `mfa_enrolled_at`, and `preferences`.

Show memberships from `iam_memberships` joined to `iam_organisations`. Show organisation name, `role`, and `status`.

Show the count of unused rows in `iam_mfa_recovery_codes` for that product user. Do not show `code_hash`.

## 10. Reports

### 10.1 List

Read `clinical_reports`. Show `title`, `entity_type`, `status`, `case_reference`, organisation name, owner email, and `updated_at`.

Add filters for `entity_type`, `status`, and organisation.

### 10.2 Detail

Show the list fields. Also show `version`, `finalised_reason`, `generation_locked_at`, and `created_at`.

Show `content` as read-only JSON. Report content is confidential. Do not write `content` to a log.

Show these child lists for the same `report_id`:

| Block | Table | Fields |
| --- | --- | --- |
| Versions | `clinical_report_versions` | `version`, `created_at`, created-by email |
| Attachments | `clinical_attachments` | `file_name`, `mime_type`, `size_bytes`, `status` |
| Exports | `clinical_export_files` | `file_name`, `format`, `created_at` |
| Scans | `clinical_scan_compositions` | `id`, `created_at` |
| Dictation | `clinical_dictation_sessions` | `status`, `active_section_id`, `paused`, `audio_retention_policy` |
| Segments | `clinical_dictation_segments` | `section_id`, `transcript`, `created_at` |
| Slot | `billing_report_slots` | `state`, `reserved_at`, `consumed_at`, `released_at` |

A transcript is confidential. Do not write a transcript to a log.

## 11. Usage

The usage screen monitors tpt-api and tpt-webapp.

Show three blocks.

### 11.1 Daily totals

Read `themis_usage_daily`. Show organisation name, `source`, `day`, `metric`, and `quantity`.

Add filters for organisation, `source`, `day`, and `metric`. `source` is `tpt-api` or `tpt-webapp`.

Known metrics in the seed are `reports_created`, `usage_events`, `model_input_tokens`, `model_output_tokens`, `cost_micros`, and `page_views`. Show any other metric that is in the table. Do not hide an unknown metric.

### 11.2 API usage events

Read `audit_usage_events`. Show `created_at`, organisation name, product user email, `kind`, and `payload`.

The main API meters these kinds: `report.finalise`, `report.export`, `dictation.minute`, and `scan.compose`. The copy may also contain other kinds, such as `report_create`. Show the stored `kind`. Do not drop a row because the kind is outside that list.

### 11.3 Webapp usage

Read `themis_webapp_usage`. Show `occurred_at`, organisation name, product user email, `route`, `event_name`, and `metadata`.

### 11.4 Model usage

Read `ai_model_usage`. Show `created_at`, organisation name, `provider`, `model`, `input_tokens`, `output_tokens`, and `cost_micros`. Link `run_id` to the AI run detail when `run_id` is not null.

## 12. Activity

Read `audit_activity_events`. Show `occurred_at`, organisation name, product user email, `kind`, `entity_type`, `entity_id`, and `report_family`.

Link `report_id` to the report detail when `report_id` is not null.

Add filters for organisation, product user, and `kind`.

The allowed kinds are the `ACTIVITY_KINDS` list in `tpt-api/packages/contract/src/activity-kinds.ts`. Show the stored `kind` even when the seed uses a dotted form such as `report.finalise`. Do not drop the row.

Show `metadata` on the row as read-only JSON. Do not show a write control.

## 13. Billing

Show these lists. Filter each list by organisation, except the plan catalogue.

| Block | Table | Fields |
| --- | --- | --- |
| Plans | `billing_plans` | `key`, `name`, `price_cents`, `currency`, `seat_limit`, `report_limit_monthly`, `public`, `active`, `placeholder` |
| Subscriptions | `billing_subscriptions` | organisation name, `plan_key`, `status`, period start, period end, `last_payment_outcome` |
| Payments | `billing_payment_attempts` | `created_at`, organisation name, `amount_cents`, `status`, `kind`, `plan_key`, `payfast_payment_id` |
| PayFast notices | `billing_payfast_notifications` | `created_at`, `pf_payment_id`, `outcome`, `reason` |
| Platform | `billing_platform_settings` | `grace_days` |

Do not show `payfast_token` or `previous_payfast_token`. Those values are secrets.

Show `price_cents` as rand and cents. Example: `99900` is `R 999.00`. Keep the currency code beside the amount.

## 14. AI runs

### 14.1 List

Read `ai_agent_runs`. Show `created_at`, organisation name, product user email, `agent_id`, `state`, `provider`, `model`, and `completed_at`.

Add filters for `state` and organisation. The states are `queued`, `running`, `completed`, `failed`, `cancelled`, and `interrupted`.

### 14.2 Detail

Show the list fields. Also show `agent_version`, `prompt_version`, `idempotency_key`, `heartbeat_at`, and links to the report and the product user.

Show `input`, `output`, and `error` as read-only JSON.

Show child rows:

| Block | Table | Fields |
| --- | --- | --- |
| Events | `ai_run_events` | `seq`, `type`, `created_at` |
| Steps | `ai_run_steps` | `step_key`, `status` |
| Tool calls | `ai_tool_calls` | `name`, `status`, `created_at` |
| Citations | `ai_citations` | `excerpt`, `created_at` |
| Validations | `ai_validations` | `validator`, `valid` |
| Model usage | `ai_model_usage` | `provider`, `model`, token counts, `cost_micros` |

A citation excerpt is confidential. Do not write an excerpt to a log.

## 15. Sync

This screen tells the reader how fresh the copy is.

Read `themis_sync_runs`. Show `source`, `status`, `started_at`, `finished_at`, `row_counts`, and `error`. Newest `started_at` first.

Read `themis_sync_cursors`. Show `source`, `object_name`, `last_seen_at`, `last_id`, and `updated_at`.

Read `themis_upstream_gaps`. Show `id` and `reason`. Order by `id`. This list tells the reader which Postgres behaviour SQLite does not copy.

Do not add a button that starts a copy. The seed already inserts two completed sync runs.

## 16. Read rule

A reader may read every mirror table. A reader may read the usage tables, the sync tables, `themis_upstream_gaps`, `themis_access_policy`, and `themis_users_public`.

A reader must not read `themis_users`, `themis_sessions`, or `schema_migrations`.

Call `assertFullReadOnly` when the server starts a signed-in request. Stop the request when that call throws.

Do not add a write helper for a mirror table.

## 17. Seed check

Run `pnpm db:migrate` and `pnpm db:seed` before this check. Sign in as `reader.one@example.test`.

Verify these facts on the screens:

| Check | Expected result |
| --- | --- |
| Organisations | `Demo Solo Practice` is `solo`. `Demo City Clinic` is `institutional`. |
| Solo subscription | Plan Solo Pro. Status `active`. |
| Clinic subscription | Plan Institutional Team. Status `active`. |
| Product users | Three rows: Demo Owner, Demo Member, Demo Admin. |
| Reports | `DEMO synthetic report` is `clinical` and `complete`. `DEMO synthetic EP report` is `ep` and `draft`. |
| Solo usage on `2026-11-01` | `reports_created` 1, `usage_events` 1, `model_input_tokens` 120, `model_output_tokens` 40, `cost_micros` 1500, `page_views` 1. |
| Clinic usage on `2026-11-01` | `reports_created` 1, `usage_events` 1, `page_views` 1. |
| Webapp usage | `/reports` for the solo organisation. `/ep-reports` for the clinic. |
| Model usage | Provider `openai`, model `gpt-demo`, 120 input tokens, 40 output tokens, cost 1500. |
| Activity | One `report.finalise` for the solo report. One `report.create` for the clinic report. |
| Sync | One completed `tpt-api` run. One completed `tpt-webapp` run. |
| Gaps | The list includes `0006_rls.sql` and `0007_functions.sql`. |
| Write controls | No screen shows a save, delete, or edit control for a mirror row. |
| Secrets | The screens do not show a password hash, a session token, an invite `token_hash`, or a PayFast token. |
| Failed sign-in | A wrong password shows `Sign-in failed.` and does not open the overview. |

Run `pnpm db:verify` after the screen check. The command must exit 0.

## 18. Done

The application is done when all of these are true:

1. Each route in §3 renders for a signed-in reader.
2. A reader with no session cannot open a route in §3 except `/sign-in`.
3. The seed check in §17 passes.
4. `pnpm db:verify` exits 0.
5. The shell shows `Read only` on every signed-in screen.
6. Report content, transcripts, and citation excerpts are visible to the reader and are absent from server logs.
