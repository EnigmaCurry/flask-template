-- name: drop_table_magical_item#
drop table magical_item;

-- name: create_table_magical_item#
create table if not exists magical_item (
  id text not null primary key,
  name text not null,
  created datetime,
  destroyed datetime
);

-- name: save_magical_item!
insert into magical_item (id, name, created, destroyed)
  values (:id, :name, :created, :destroyed)
on conflict (id)
  do update set
    name = :name, created = :created, destroyed = :destroyed;

-- name: get_magical_items
select
  *
from
  magical_item;

-- name: get_magical_item_by_id^
select
  id,
  name,
  created,
  destroyed
from
  magical_item
where
  id = :id;

