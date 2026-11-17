-- Portal dictation UI state (active section, pause, retention policy) persisted with the session.

alter table clinical.dictation_sessions
  add column if not exists active_section_id text not null default '',
  add column if not exists audio_retention_policy text not null default 'none',
  add column if not exists paused boolean not null default false;
