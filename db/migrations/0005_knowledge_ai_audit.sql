-- SQLite stand-in for db/upstream/0005_knowledge_ai_audit.sql
-- pgvector and the tsvector search column are not created.
-- Store an embedding as JSON text when a row has one.

create table knowledge_documents (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text references clinical_reports (id) on delete cascade,
  attachment_id text references clinical_attachments (id),
  title text not null,
  status text not null default 'pending' check (status in ('pending', 'ready', 'failed')),
  error text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table knowledge_chunks (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  document_id text not null references knowledge_documents (id) on delete cascade,
  attachment_id text references clinical_attachments (id),
  ordinal integer not null,
  body text not null,
  embedding text check (embedding is null or json_valid(embedding)),
  embedding_model text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  unique (document_id, ordinal)
);

create index knowledge_chunks_org_doc
  on knowledge_chunks (organization_id, document_id);

create table knowledge_ingestion_jobs (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  document_id text not null references knowledge_documents (id) on delete cascade,
  status text not null default 'queued' check (status in ('queued', 'running', 'completed', 'failed')),
  error text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table ai_prompt_versions (
  id text primary key,
  agent_id text not null,
  version text not null,
  pack text not null check (json_valid(pack)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  unique (agent_id, version)
);

create table ai_agent_runs (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  user_id text not null references iam_profiles (id),
  report_id text references clinical_reports (id),
  agent_id text not null,
  agent_version text not null,
  prompt_version text not null,
  idempotency_key text,
  input text not null check (json_valid(input)),
  options text check (options is null or json_valid(options)),
  state text not null default 'queued'
    check (state in ('queued', 'running', 'completed', 'failed', 'cancelled', 'interrupted')),
  output text check (output is null or json_valid(output)),
  error text check (error is null or json_valid(error)),
  provider text,
  model text,
  heartbeat_at text,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  completed_at text
);

create unique index ai_agent_runs_idempotency
  on ai_agent_runs (organization_id, user_id, idempotency_key)
  where idempotency_key is not null;

create table ai_run_events (
  run_id text not null references ai_agent_runs (id) on delete cascade,
  organization_id text not null references iam_organisations (id),
  seq integer not null,
  type text not null,
  data text not null check (json_valid(data)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  primary key (run_id, seq)
);

create table ai_run_steps (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  run_id text not null references ai_agent_runs (id) on delete cascade,
  step_key text not null,
  status text not null check (status in ('pending', 'completed', 'failed')),
  output text check (output is null or json_valid(output)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  unique (run_id, step_key)
);

create table ai_tool_calls (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  run_id text not null references ai_agent_runs (id) on delete cascade,
  name text not null,
  arguments text check (arguments is null or json_valid(arguments)),
  result text check (result is null or json_valid(result)),
  status text not null,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table ai_citations (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  run_id text not null references ai_agent_runs (id) on delete cascade,
  document_id text,
  chunk_id text,
  attachment_id text,
  excerpt text not null,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table ai_validations (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  run_id text not null references ai_agent_runs (id) on delete cascade,
  validator text not null,
  valid integer not null check (valid in (0, 1)),
  issues text not null default '[]' check (json_valid(issues)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table ai_model_usage (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  run_id text references ai_agent_runs (id) on delete set null,
  provider text not null,
  model text not null,
  input_tokens integer not null default 0,
  output_tokens integer not null default 0,
  cost_micros integer not null default 0,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table audit_audit_log (
  id text primary key,
  organization_id text,
  actor_user_id text,
  actor_role text,
  db_session_user text,
  action text not null,
  target_type text,
  target_id text,
  before text check (before is null or json_valid(before)),
  after text check (after is null or json_valid(after)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table audit_export_audit (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  report_id text not null,
  user_id text not null,
  reason text not null,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table audit_ingest_audit (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  document_id text not null,
  user_id text not null,
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create table audit_usage_events (
  id text primary key,
  organization_id text not null references iam_organisations (id),
  user_id text,
  kind text not null,
  payload text not null default '{}' check (json_valid(payload)),
  created_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

create trigger knowledge_documents_updated_at
after update on knowledge_documents
for each row
begin
  update knowledge_documents
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger knowledge_ingestion_jobs_updated_at
after update on knowledge_ingestion_jobs
for each row
begin
  update knowledge_ingestion_jobs
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

create trigger ai_agent_runs_updated_at
after update on ai_agent_runs
for each row
begin
  update ai_agent_runs
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

insert into themis_upstream_gaps (id, reason) values
  (
    '0005_knowledge_ai_audit.sql:vector',
    'The vector extension, the embedding column type, the search_vector column, and the chunks_fts index are not created.'
  );
