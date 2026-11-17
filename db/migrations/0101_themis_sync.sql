-- Themis sync bookkeeping. This table set is not in the main database.
-- A sync run records one copy from tpt-api or from tpt-webapp.
-- A cursor records the last row Themis has copied for one object.

create table themis_sync_runs (
  id text primary key,
  source text not null check (source in ('tpt-api', 'tpt-webapp')),
  status text not null check (status in ('running', 'completed', 'failed')),
  started_at text not null,
  finished_at text,
  row_counts text not null default '{}' check (json_valid(row_counts)),
  error text
);

create table themis_sync_cursors (
  source text not null check (source in ('tpt-api', 'tpt-webapp')),
  object_name text not null,
  last_seen_at text,
  last_id text,
  updated_at text not null,
  primary key (source, object_name)
);
