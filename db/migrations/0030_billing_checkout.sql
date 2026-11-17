-- SQLite stand-in for db/upstream/0030_billing_checkout.sql
-- billing.apply_payfast_itn_effects is not created.
-- The status check already exists on billing_payment_attempts.

alter table billing_payment_attempts add column owner_user_id text references iam_profiles (id);
alter table billing_payment_attempts add column plan_key text references billing_plans (key);
alter table billing_payment_attempts add column recurring_amount_cents integer;
alter table billing_payment_attempts add column kind text
  check (kind is null or kind in ('initial', 'upgrade'));
alter table billing_payment_attempts add column previous_plan_key text references billing_plans (key);
alter table billing_payment_attempts add column updated_at text not null default '1970-01-01T00:00:00Z';

create unique index billing_payment_attempts_payfast_payment_id
  on billing_payment_attempts (payfast_payment_id)
  where payfast_payment_id is not null;

alter table billing_subscriptions add column checkout_attempt_id text references billing_payment_attempts (id);
alter table billing_subscriptions add column last_payment_outcome text;
alter table billing_subscriptions add column previous_payfast_token text;
alter table billing_subscriptions add column previous_subscription_cancellation text;

create trigger billing_payment_attempts_updated_at
after update on billing_payment_attempts
for each row
begin
  update billing_payment_attempts
     set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
   where id = old.id
     and updated_at = old.updated_at;
end;

insert into themis_upstream_gaps (id, reason) values
  (
    '0030_billing_checkout.sql:function',
    'billing.apply_payfast_itn_effects is not created. Themis stores the checkout columns only.'
  ),
  (
    '0030_billing_checkout.sql:status_check',
    'SQLite cannot add a table check later. billing_payment_attempts.status already allows pending, complete, failed, and cancelled.'
  );
