-- Cloud SQL allows `postgres` to create this extension. Migrations that run as
-- tpt_migrator (prod) rely on infrastructure/scripts/bootstrap-cloudsql.sh to
-- create it first; ignore the privilege error only when it is already there.
do $$
begin
  create extension if not exists vector;
exception
  when insufficient_privilege then
    if not exists (select 1 from pg_extension where extname = 'vector') then
      raise;
    end if;
end
$$;

create table knowledge.documents (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid references clinical.reports (id) on delete cascade,
  attachment_id uuid references clinical.attachments (id),
  title text not null,
  status text not null default 'pending' check (status in ('pending', 'ready', 'failed')),
  error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table knowledge.chunks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  document_id uuid not null references knowledge.documents (id) on delete cascade,
  attachment_id uuid references clinical.attachments (id),
  ordinal integer not null,
  body text not null,
  embedding vector(1536),
  embedding_model text,
  search_vector tsvector generated always as (to_tsvector('english', coalesce(body, ''))) stored,
  created_at timestamptz not null default now(),
  unique (document_id, ordinal)
);

create index chunks_fts on knowledge.chunks using gin (search_vector);
create index chunks_org_doc on knowledge.chunks (organization_id, document_id);

create table knowledge.ingestion_jobs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  document_id uuid not null references knowledge.documents (id) on delete cascade,
  status text not null default 'queued' check (status in ('queued', 'running', 'completed', 'failed')),
  error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table ai.prompt_versions (
  id uuid primary key default gen_random_uuid(),
  agent_id text not null,
  version text not null,
  pack jsonb not null,
  created_at timestamptz not null default now(),
  unique (agent_id, version)
);

create table ai.agent_runs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  user_id uuid not null references iam.profiles (id),
  report_id uuid references clinical.reports (id),
  agent_id text not null,
  agent_version text not null,
  prompt_version text not null,
  idempotency_key text,
  input jsonb not null,
  options jsonb,
  state text not null default 'queued'
    check (state in ('queued', 'running', 'completed', 'failed', 'cancelled', 'interrupted')),
  output jsonb,
  error jsonb,
  provider text,
  model text,
  heartbeat_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);

create unique index agent_runs_idempotency
  on ai.agent_runs (organization_id, user_id, idempotency_key)
  where idempotency_key is not null;

create table ai.run_events (
  run_id uuid not null references ai.agent_runs (id) on delete cascade,
  organization_id uuid not null references iam.organisations (id),
  seq integer not null,
  type text not null,
  data jsonb not null,
  created_at timestamptz not null default now(),
  primary key (run_id, seq)
);

create table ai.run_steps (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  run_id uuid not null references ai.agent_runs (id) on delete cascade,
  step_key text not null,
  status text not null check (status in ('pending', 'completed', 'failed')),
  output jsonb,
  created_at timestamptz not null default now(),
  unique (run_id, step_key)
);

create table ai.tool_calls (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  run_id uuid not null references ai.agent_runs (id) on delete cascade,
  name text not null,
  arguments jsonb,
  result jsonb,
  status text not null,
  created_at timestamptz not null default now()
);

create table ai.citations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  run_id uuid not null references ai.agent_runs (id) on delete cascade,
  document_id uuid,
  chunk_id uuid,
  attachment_id uuid,
  excerpt text not null,
  created_at timestamptz not null default now()
);

create table ai.validations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  run_id uuid not null references ai.agent_runs (id) on delete cascade,
  validator text not null,
  valid boolean not null,
  issues jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table ai.model_usage (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  run_id uuid references ai.agent_runs (id) on delete set null,
  provider text not null,
  model text not null,
  input_tokens integer not null default 0,
  output_tokens integer not null default 0,
  cost_micros bigint not null default 0,
  created_at timestamptz not null default now()
);

create table audit.audit_log (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid,
  actor_user_id uuid,
  actor_role text,
  db_session_user text,
  action text not null,
  target_type text,
  target_id uuid,
  before jsonb,
  after jsonb,
  created_at timestamptz not null default now()
);

create table audit.export_audit (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  report_id uuid not null,
  user_id uuid not null,
  reason text not null,
  created_at timestamptz not null default now()
);

create table audit.ingest_audit (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  document_id uuid not null,
  user_id uuid not null,
  created_at timestamptz not null default now()
);

create table audit.usage_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references iam.organisations (id),
  user_id uuid,
  kind text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create trigger documents_updated_at before update on knowledge.documents
  for each row execute function util.set_updated_at();
create trigger ingestion_jobs_updated_at before update on knowledge.ingestion_jobs
  for each row execute function util.set_updated_at();
create trigger agent_runs_updated_at before update on ai.agent_runs
  for each row execute function util.set_updated_at();
