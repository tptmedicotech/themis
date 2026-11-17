-- SQLite stand-in for db/upstream/0004_clinical.sql
-- export format already includes html and txt.
-- Upstream adds those values in 0019_export_html_txt.sql.
-- SQLite cannot replace a table check.

create table clinical_reports (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  owner_user_id text not null references iam_profiles (id),
  entity_type text not null check (entity_type in ('psychometry', 'ep', 'forensic', 'clinical')),
  title text not null,
  case_reference text,
  status text not null default 'draft' check (status in ('draft', 'in_progress', 'complete')),
  content text not null default '{}' check (json_valid(content)),
  version integer not null default 1 check (version >= 1),
  generation_locked_at text,
  finalised_reason text check (finalised_reason in ('export', 'download', 'complete', 'copy')),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create index clinical_reports_org_created
  on clinical_reports (organization_id, created_at desc);

create table clinical_report_versions (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text not null references clinical_reports (id) on delete cascade,
  version integer not null,
  content text not null check (json_valid(content)),
  created_by text references iam_profiles (id),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  unique (report_id, version)
);

create table clinical_attachments (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text not null references clinical_reports (id) on delete cascade,
  file_name text not null,
  mime_type text not null,
  size_bytes integer not null check (size_bytes > 0),
  object_path text not null,
  status text not null default 'pending_upload' check (status in ('pending_upload', 'uploaded', 'deleted')),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table clinical_export_files (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text not null references clinical_reports (id) on delete cascade,
  file_name text not null,
  format text not null check (format in ('pdf', 'docx', 'html', 'txt')),
  object_path text not null,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table clinical_scan_compositions (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text not null references clinical_reports (id) on delete cascade,
  attachment_ids text not null default '[]' check (json_valid(attachment_ids)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table clinical_dictation_sessions (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text not null references clinical_reports (id) on delete cascade,
  status text not null default 'open' check (status in ('open', 'closed')),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table clinical_dictation_segments (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  session_id text not null references clinical_dictation_sessions (id) on delete cascade,
  section_id text,
  transcript text not null default '',
  audio_object_path text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table billing_report_slots (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text not null unique references clinical_reports (id),
  state text not null check (state in ('reserved', 'consumed', 'released')),
  period_id text references billing_quota_periods (id),
  reserved_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  consumed_at text,
  released_at text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create trigger clinical_reports_updated_at
after update on clinical_reports
for each row
begin
  update clinical_reports
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger clinical_attachments_updated_at
after update on clinical_attachments
for each row
begin
  update clinical_attachments
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger clinical_dictation_sessions_updated_at
after update on clinical_dictation_sessions
for each row
begin
  update clinical_dictation_sessions
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger billing_report_slots_updated_at
after update on billing_report_slots
for each row
begin
  update billing_report_slots
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;
