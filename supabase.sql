-- StepOut: общая таблица добавленных мест.
-- Выполнить один раз: Supabase → SQL Editor → вставить всё → Run.

create table public.places (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  name        text not null check (char_length(name) between 1 and 60),
  type        text not null check (type in ('food','culture','nature','local','eco')),
  address     text not null check (char_length(address) between 1 and 100),
  about       text not null check (char_length(about) between 1 and 300),
  lat         double precision not null check (lat between 42.8 and 43.6),
  lng         double precision not null check (lng between 76.5 and 77.4),
  open_time   text not null default '' check (open_time ~ '^([0-9]{2}:[0-9]{2})?$'),
  close_time  text not null default '' check (close_time ~ '^([0-9]{2}:[0-9]{2})?$'),
  price       smallint not null default 1 check (price between 1 and 3),
  indoor      boolean not null default true,
  photo       text not null default '' check (
    char_length(photo) <= 400000
    and (photo = '' or photo ~ '^data:image/jpeg;base64,[A-Za-z0-9+/=]+$')
  )
);

alter table public.places enable row level security;

-- Посетители могут только читать и добавлять. Менять и удалять нельзя:
-- удаляет владелец проекта в Supabase → Table Editor.
revoke all on public.places from anon, authenticated;
grant select on public.places to anon;
grant insert (name, type, address, about, lat, lng, open_time, close_time, price, indoor, photo)
  on public.places to anon;

create policy "read places" on public.places for select to anon using (true);
create policy "add places"  on public.places for insert to anon with check (true);
