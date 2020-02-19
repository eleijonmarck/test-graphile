\ connect forum_example;
/*Create user table in public schema*/
CREATE TABLE forum_example.person (
  -- creating a int that increases
  -- for each entry in the table
  id SERIAL PRIMARY KEY,
  first_name text not null check (char_length(first_name) < 80),
  last_name text check (char_length(last_name) < 80),
  about text,
  created_at timestamp default now()
);
comment on table forum_example.person is 'A user of the forum.';
comment on column forum_example.person.id is 'The primary unique identifier for the person.';
comment on column forum_example.person.first_name is 'The person’s first name.';
comment on column forum_example.person.last_name is 'The person’s last name.';
comment on column forum_example.person.about is 'A short description about the user, written by the user.';
comment on column forum_example.person.created_at is 'The time this person was created.';
create type forum_example.post_topic as enum (
  'discussion',
  'inspiration',
  'help',
  'showcase'
);
create table forum_example.post (
  id serial primary key,
  author_id integer not null references forum_example.person(id),
  headline text not null check (char_length(headline) < 280),
  body text,
  topic forum_example.post_topic,
  created_at timestamp default now()
);
comment on table forum_example.post is 'A forum post written by a user.';
comment on column forum_example.post.id is 'The primary key for the post.';
comment on column forum_example.post.headline is 'The title written by the user.';
comment on column forum_example.post.author_id is 'The id of the author user.';
comment on column forum_example.post.topic is 'The topic this has been posted in.';
comment on column forum_example.post.body is 'The main body text of our post.';
comment on column forum_example.post.created_at is 'The time this post was created.';
/*
functions
*/
create function forum_example.person_full_name(person forum_example.person) returns text as $ $
select
  person.first_name || ' ' || person.last_name $ $ language sql stable;
comment on function forum_example.person_full_name(forum_example.person) is 'A persons full name which is a concatenation of their first an dlast name';
create function forum_example.post_summary(
    post forum_example.post,
    length int default 50,
    omission text default '...'
  ) returns text as $ $
select
  case
    when post.body is null then null
    else substr(post.body, 0, length) || omission
  end $ $ language sql stable;
comment on function forum_example.post_summary(forum_example.post, int, text) is 'A truncated version of the body for summaries.';

create function forum_example.person_latest_post(
        person forum_example.person
) returns forum_example.post as $$
select post.*
from forum_example.post as post
where post.author_id = person.id
order by created_at desc
limit 1
$$ language sql stable;

comment on function forum_example.person_latest_post(forum_example.person) is 'Get’s the latest post written by the person.';

create function forum_example.search_posts(
        search text
) returns setof forum_example.post as $$
select post.*
from forum_example.post as post
where position(search in post.headline) > 0 or postition(search in post.body) > 0
$$ language sql stable;

comment on function forum_example.search_posts(text) is 'Returns posts containing a given search term.';

/*
Triggers
*/
