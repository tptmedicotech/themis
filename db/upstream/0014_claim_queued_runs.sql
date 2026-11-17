-- Claim queued agent runs for background execution (skip locked for horizontal workers).
create or replace function ai.claim_queued_runs(batch_size integer default 8)
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
  with picked as (
    select r.id
      from ai.agent_runs r
     where r.state = 'queued'
     order by r.created_at
     limit greatest(batch_size, 1)
       for update skip locked
  )
  update ai.agent_runs r
     set state = 'running',
         heartbeat_at = now()
    from picked p
   where r.id = p.id
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

revoke all on function ai.claim_queued_runs(integer) from public;
grant execute on function ai.claim_queued_runs(integer) to tpt_app;
