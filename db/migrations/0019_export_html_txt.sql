-- Upstream replaces the export format check.
-- SQLite cannot replace a table check.
-- 0004_clinical.sql already allows pdf, docx, html, and txt.

insert into themis_upstream_gaps (id, reason) values (
  '0019_export_html_txt.sql',
  'SQLite cannot replace a table check. clinical_export_files.format already allows pdf, docx, html, and txt.'
);
