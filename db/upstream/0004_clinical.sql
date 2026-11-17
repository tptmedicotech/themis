create table clinical.reports (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  owner_user_id uuid not null references iam.profiles (id),
  entity_type text not null check (entity_type in ('psychometry', 'ep', 'forensic', 'clinical')),
  title text not null,
  case_reference text,
  status text not null default 'draft' check (status in ('draft', 'in_progress', 'complete')),
  content jsonb not null default '{}'::jsonb,
  version integer not null default 1 check (version >= 1),
  generation_locked_at timestamptz,
  finalised_reason text check (finalised_reason in ('export', 'download', 'complete', 'copy')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index reports_org_created on clinical.reports (organization_id, created_at desc);

create table clinical.report_versions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid not null references clinical.reports (id) on delete cascade,
  version integer not null,
  content jsonb not null,
  created_by uuid references iam.profiles (id),
  created_at timestamptz not null default now(),
  unique (report_id, version)
);

create table clinical.attachments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid not null references clinical.reports (id) on delete cascade,
  file_name text not null,
  mime_type text not null,
  size_bytes bigint not null check (size_bytes > 0),
  object_path text not null,
  status text not null default 'pending_upload' check (status in ('pending_upload', 'uploaded', 'deleted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table clinical.export_files (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid not null references clinical.reports (id) on delete cascade,
  file_name text not null,
  format text not null check (format in ('pdf', 'docx')),
  object_path text not null,
  created_at timestamptz not null default now()
);

create table clinical.scan_compositions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid not null references clinical.reports (id) on delete cascade,
  attachment_ids uuid[] not null default '{}',
  created_at timestamptz not null default now()
);

create table clinical.dictation_sessions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid not null references clinical.reports (id) on delete cascade,
  status text not null default 'open' check (status in ('open', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table clinical.dictation_segments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  session_id uuid not null references clinical.dictation_sessions (id) on delete cascade,
  section_id text,
  transcript text not null default '',
  audio_object_path text,
  created_at timestamptz not null default now()
);

alter table billing.report_slots
  add constraint report_slots_report_fk
  foreign key (report_id) references clinical.reports (id);

create trigger reports_updated_at before update on clinical.reports
  for each row execute function util.set_updated_at();
create trigger attachments_updated_at before update on clinical.attachments
  for each row execute function util.set_updated_at();
create trigger dictation_sessions_updated_at before update on clinical.dictation_sessions
  for each row execute function util.set_updated_at();
