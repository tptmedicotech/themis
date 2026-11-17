-- Include run options when resuming stale agent runs (tone presets, section filters).
drop function if exists ai.claim_stale_runs(integer);

create function ai.claim_stale_runs(stale_seconds integer)
returns table (
  id uuid,
  organization_id uuid,
  user_id uuid,
  report_id uuid,
  agent_id text,
  input jsonb,
  options jsonb,
  entity_type text
)
language plpgsql
security definer
set search_path = ai, clinical, pg_temp
as $$
begin
  return query
  update ai.agent_runs r
     set state = 'interrupted'
   where r.state = 'running'
     and r.heartbeat_at is not null
     and r.heartbeat_at < now() - (stale_seconds * interval '1 second')
  returning r.id,
            r.organization_id,
            r.user_id,
            r.report_id,
            r.agent_id,
            r.input,
            coalesce(r.options, '{}'::jsonb),
            (select rp.entity_type from clinical.reports rp where rp.id = r.report_id);
end;
$$;

revoke all on function ai.claim_stale_runs(integer) from public;
grant execute on function ai.claim_stale_runs(integer) to tpt_app;
