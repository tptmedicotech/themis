-- Extend export format check for portal html/txt strangler (P6 slice 6).
alter table clinical.export_files
  drop constraint if exists export_files_format_check;

alter table clinical.export_files
  add constraint export_files_format_check
  check (format in ('pdf', 'docx', 'html', 'txt'));
