-- PostgreSQL version --
-- see aiosql operators manual:
-- https://nackjicholson.github.io/aiosql/defining-sql-queries.html#operators
--
--
-- name: ddl_lock#
-- Call this to ensure that only one client can perform DDL at a time:
select
  pg_advisory_xact_lock(1);

-- name: log_user_encounter!
-- Log an encounter with a user
insert into visitor (name, salutation, ip_address)
  values (:username, :salutation, :ip_address);

-- name: count_user_encounters$
-- Read how many times a user has been greeted
select
  count(*) as total_visits
from
  visitor
where
  name = :username
group by
  name;

-- name: top_visitors
-- List the top 10 visitors
select
  name,
  count(*) as total_visits
from
  visitor
group by
  name
order by
  total_visits desc
limit 10;

