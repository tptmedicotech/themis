-- SQLite stand-in for db/upstream/0026_dictation_session_ui_fields.sql

alter table clinical_dictation_sessions add column active_section_id text not null default '';
alter table clinical_dictation_sessions add column audio_retention_policy text not null default 'none';
alter table clinical_dictation_sessions add column paused integer not null default 0 check (paused in (0, 1));
