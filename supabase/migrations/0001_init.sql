-- NEXORA — initial schema (PostgreSQL / Supabase)
create extension if not exists "pgcrypto";

-- ===================== ENUMS =====================
create type account_status as enum ('active','suspended');
create type post_visibility as enum ('public','friends','followers','private');
create type media_type as enum ('image','video');
create type friend_status as enum ('pending','accepted','declined');
create type message_type as enum ('text','image','video');
create type notification_type as enum ('friend_request','friend_accepted','like','comment','reply','share','follow','message','story_view');
create type report_target as enum ('profile','post','comment','message');
create type report_status as enum ('pending','reviewed','dismissed','actioned');
create type privacy_level as enum ('everyone','followers','friends','nobody');

-- ===================== TABLES =====================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  first_name text not null,
  last_name text not null,
  username text unique not null check (username ~ '^[a-z0-9_.]{3,24}$'),
  email text,
  avatar_url text,
  cover_url text,
  bio text check (char_length(bio) <= 300),
  locale text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_active timestamptz not null default now(),
  is_online boolean not null default false,
  is_verified boolean not null default false,
  account_status account_status not null default 'active'
);

create table public.admin_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  granted_at timestamptz not null default now()
);

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  content text not null default '' check (char_length(content) <= 5000),
  location text,
  feeling text,
  visibility post_visibility not null default 'public',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  is_deleted boolean not null default false
);

create table public.post_media (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  media_url text not null,
  media_type media_type not null,
  thumbnail_url text,
  created_at timestamptz not null default now()
);

create table public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  parent_id uuid references public.comments(id) on delete cascade,
  content text not null check (char_length(content) <= 1000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  is_deleted boolean not null default false
);

create table public.post_likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table public.comment_likes (
  comment_id uuid not null references public.comments(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (comment_id, user_id)
);

create table public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  check (follower_id <> following_id)
);

create table public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  receiver_id uuid not null references public.profiles(id) on delete cascade,
  status friend_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (sender_id <> receiver_id)
);
create unique index friend_requests_pending_uniq on public.friend_requests (sender_id, receiver_id) where status = 'pending';

create table public.friendships (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references public.profiles(id) on delete cascade,
  user_b uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  check (user_a <> user_b),
  check (user_a < user_b)
);
create unique index friendships_uniq on public.friendships (least(user_a,user_b), greatest(user_a,user_b));

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  is_group boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  last_read_at timestamptz not null default now() - interval '100 years',
  primary key (conversation_id, user_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  content text not null check (char_length(content) <= 4000),
  message_type message_type not null default 'text',
  media_url text,
  created_at timestamptz not null default now(),
  edited_at timestamptz,
  deleted_at timestamptz
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete cascade,
  type notification_type not null,
  reference_id uuid,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.saved_posts (
  user_id uuid not null references public.profiles(id) on delete cascade,
  post_id uuid not null references public.posts(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);

create table public.stories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  media_url text,
  media_type media_type,
  content text check (char_length(content) <= 500),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '24 hours',
  check (media_url is not null or content is not null)
);

create table public.story_views (
  story_id uuid not null references public.stories(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  viewed_at timestamptz not null default now(),
  primary key (story_id, user_id)
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type report_target not null,
  target_id uuid not null,
  reason text not null,
  description text,
  status report_status not null default 'pending',
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id)
);

create table public.blocks (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create table public.user_settings (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  profile_visibility privacy_level not null default 'everyone',
  message_privacy privacy_level not null default 'everyone',
  follow_privacy privacy_level not null default 'everyone',
  online_status_visible boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.shares (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

-- ===================== INDEXES =====================
create index idx_posts_user_created on public.posts (user_id, created_at desc);
create index idx_posts_created on public.posts (created_at desc) where is_deleted = false;
create index idx_post_media_post on public.post_media (post_id);
create index idx_comments_post_created on public.comments (post_id, created_at);
create index idx_comments_parent on public.comments (parent_id);
create index idx_friend_requests_receiver on public.friend_requests (receiver_id, status);
create index idx_friend_requests_sender on public.friend_requests (sender_id, status);
create index idx_follows_follower on public.follows (follower_id);
create index idx_follows_following on public.follows (following_id);
create index idx_conversation_members_user on public.conversation_members (user_id);
create index idx_messages_conv_created on public.messages (conversation_id, created_at);
create index idx_messages_sender on public.messages (sender_id);
create index idx_notifications_user_read on public.notifications (user_id, is_read, created_at desc);
create index idx_stories_expires on public.stories (expires_at);
create index idx_stories_user on public.stories (user_id, expires_at desc);
create index idx_reports_status on public.reports (status, created_at desc);
create index idx_blocks_blocker on public.blocks (blocker_id);
create index idx_blocks_blocked on public.blocks (blocked_id);

-- ===================== HELPERS =====================
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admin_roles where user_id = auth.uid());
$$;

create or replace function public.is_blocked_with(other uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.blocks b
    where (b.blocker_id = auth.uid() and b.blocked_id = other)
       or (b.blocker_id = other and b.blocked_id = auth.uid())
  );
$$;

create or replace function public.can_view_post(p_owner uuid, p_visibility post_visibility) returns boolean
language sql stable security definer set search_path = public as $$
  select
    case
      when auth.uid() = p_owner then true
      when p_visibility = 'public' then not public.is_blocked_with(p_owner)
      when p_visibility = 'private' then false
      when p_visibility = 'followers' then exists (
        select 1 from public.follows f where f.follower_id = auth.uid() and f.following_id = p_owner)
      when p_visibility = 'friends' then exists (
        select 1 from public.friendships fr
        where (fr.user_a = auth.uid() and fr.user_b = p_owner) or (fr.user_b = auth.uid() and fr.user_a = p_owner))
    end;
$$;

create or replace function public.is_friends_with(other uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.friendships fr
    where (fr.user_a = auth.uid() and fr.user_b = other)
       or (fr.user_b = auth.uid() and fr.user_a = other));
$$;

create or replace function public.in_conversation(conv uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.conversation_members m
    where m.conversation_id = conv and m.user_id = auth.uid());
$$;

-- ===================== NEW USER TRIGGER =====================
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, first_name, last_name, username, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'first_name',''),
    coalesce(new.raw_user_meta_data->>'last_name',''),
    coalesce(new.raw_user_meta_data->>'username', 'user_' || left(new.id::text, 8)),
    new.email
  );
  insert into public.user_settings (user_id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ===================== NOTIFICATION TRIGGER =====================
create or replace function public.notify_on_action() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_owner uuid; ntype notification_type; v jsonb := to_jsonb(new);
begin
  if (tg_table_name = 'post_likes') then
    select user_id into v_owner from public.posts where id = (v->>'post_id')::uuid;
    ntype := 'like';
  elsif (tg_table_name = 'comments') then
    select user_id into v_owner from public.posts where id = (v->>'post_id')::uuid;
    ntype := case when v->>'parent_id' is not null then 'reply' else 'comment' end;
    if new.user_id = v_owner and v->>'parent_id' is null then return new; end if;
  elsif (tg_table_name = 'follows') then
    v_owner := new.following_id; ntype := 'follow';
  elsif (tg_table_name = 'friend_requests') then
    v_owner := new.receiver_id; ntype := 'friend_request';
  elsif (tg_table_name = 'shares') then
    select user_id into v_owner from public.posts where id = (v->>'post_id')::uuid;
    ntype := 'share';
  end if;
  if v_owner is not null and v_owner <> auth.uid() then
    insert into public.notifications (user_id, actor_id, type, reference_id)
    values (v_owner, auth.uid(), ntype,
      coalesce((v->>'parent_id')::uuid, (v->>'comment_id')::uuid, (v->>'post_id')::uuid, (v->>'id')::uuid));
  end if;
  return new;
end;
$$;

create trigger trg_notify_like after insert on public.post_likes
  for each row execute function public.notify_on_action();
create trigger trg_notify_comment after insert on public.comments
  for each row execute function public.notify_on_action();
create trigger trg_notify_follow after insert on public.follows
  for each row execute function public.notify_on_action();
create trigger trg_notify_friend_request after insert on public.friend_requests
  for each row execute function public.notify_on_action();
create trigger trg_notify_share after insert on public.shares
  for each row execute function public.notify_on_action();

-- ===================== RPCs =====================
create or replace function public.start_conversation(other uuid)
returns uuid language plpgsql security definer set search_path = public as $$
declare conv_id uuid;
begin
  if other = auth.uid() or public.is_blocked_with(other) then
    return null;
  end if;
  select c.id into conv_id from public.conversations c
    join public.conversation_members a on a.conversation_id = c.id and a.user_id = auth.uid()
    join public.conversation_members b on b.conversation_id = c.id and b.user_id = other
    where not c.is_group and (select count(*) from public.conversation_members m where m.conversation_id = c.id) = 2
    limit 1;
  if conv_id is null then
    insert into public.conversations default values returning id into conv_id;
    insert into public.conversation_members (conversation_id, user_id) values (conv_id, auth.uid()), (conv_id, other);
  end if;
  return conv_id;
end;
$$;

create or replace function public.feed_page(p_limit int default 10, p_before timestamptz default null)
returns setof public.posts language sql stable as $$
  select p.* from public.posts p
  where p.is_deleted = false and public.can_view_post(p.user_id, p.visibility)
    and (p_before is null or p.created_at < p_before)
  order by p.created_at desc
  limit least(p_limit, 50);
$$;

create or replace function public.expire_stories()
returns void language sql as $$
  delete from public.stories where expires_at < now();
$$;

-- ===================== RLS =====================
alter table public.profiles enable row level security;
alter table public.admin_roles enable row level security;
alter table public.posts enable row level security;
alter table public.post_media enable row level security;
alter table public.comments enable row level security;
alter table public.post_likes enable row level security;
alter table public.comment_likes enable row level security;
alter table public.follows enable row level security;
alter table public.friend_requests enable row level security;
alter table public.friendships enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.notifications enable row level security;
alter table public.saved_posts enable row level security;
alter table public.stories enable row level security;
alter table public.story_views enable row level security;
alter table public.reports enable row level security;
alter table public.blocks enable row level security;
alter table public.user_settings enable row level security;
alter table public.shares enable row level security;

-- profiles
create policy profiles_select on public.profiles for select to authenticated using (true);
create policy profiles_update on public.profiles for update
  using (id = auth.uid() or public.is_admin()) with check (id = auth.uid() or public.is_admin());

-- admin_roles: no client policy (only service role / SQL editor). Read only for admins:
create policy admin_roles_select on public.admin_roles for select using (public.is_admin());

-- posts
create policy posts_select on public.posts for select
  using (not is_deleted and public.can_view_post(user_id, visibility));
create policy posts_insert on public.posts for insert with check (user_id = auth.uid() and account_status_ok());
create policy posts_update on public.posts for update
  using (user_id = auth.uid() and account_status_ok()) with check (user_id = auth.uid());
create policy posts_delete on public.posts for delete using (user_id = auth.uid() or public.is_admin());
create policy posts_admin_read on public.posts for select using (public.is_admin());

create or replace function public.account_status_ok() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select account_status = 'active' from public.profiles where id = auth.uid()), false);
$$;

create or replace function public.profile_status(p uuid) returns json
language sql stable security definer set search_path = public as $$
  select case when s.online_status_visible
    then json_build_object('is_online', pr.is_online, 'last_active', pr.last_active)
    else json_build_object('is_online', false, 'last_active', null::timestamptz) end
  from public.profiles pr join public.user_settings s on s.user_id = pr.id
  where pr.id = p;
$$;

create or replace function public.admin_stats() returns json
language sql stable security definer set search_path = public as $$
  select case when public.is_admin() then json_build_object(
    'total_users', (select count(*) from public.profiles),
    'active_users', (select count(*) from public.profiles where is_online = true),
    'total_posts', (select count(*) from public.posts where is_deleted = false),
    'total_comments', (select count(*) from public.comments where is_deleted = false),
    'pending_reports', (select count(*) from public.reports where status = 'pending'),
    'suspended_accounts', (select count(*) from public.profiles where account_status = 'suspended'),
    'storage_objects', (select count(*) from storage.objects),
    'recent_users', (select count(*) from public.profiles where created_at > now() - interval '7 days')
  ) else null end;
$$;

-- post_media
create policy post_media_select on public.post_media for select
  using (exists (select 1 from public.posts p where p.id = post_id and public.can_view_post(p.user_id, p.visibility) and not p.is_deleted));
create policy post_media_write on public.post_media for all
  using (exists (select 1 from public.posts p where p.id = post_id and p.user_id = auth.uid()))
  with check (exists (select 1 from public.posts p where p.id = post_id and p.user_id = auth.uid()));

-- comments
create policy comments_select on public.comments for select
  using (not is_deleted and exists (select 1 from public.posts p where p.id = post_id and public.can_view_post(p.user_id, p.visibility) and not p.is_deleted));
create policy comments_insert on public.comments for insert
  with check (user_id = auth.uid() and account_status_ok() and exists (select 1 from public.posts p where p.id = post_id and public.can_view_post(p.user_id, p.visibility) and not p.is_deleted) and not public.is_blocked_with(user_id));
create policy comments_update on public.comments for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy comments_delete on public.comments for delete using (user_id = auth.uid() or public.is_admin());

-- likes
create policy likes_select on public.post_likes for select
  using (exists (select 1 from public.posts p where p.id = post_id and public.can_view_post(p.user_id, p.visibility) and not p.is_deleted));
create policy likes_insert on public.post_likes for insert with check (user_id = auth.uid() and account_status_ok());
create policy likes_delete on public.post_likes for delete using (user_id = auth.uid());

create policy comment_likes_select on public.comment_likes for select using (true);
create policy comment_likes_insert on public.comment_likes for insert with check (user_id = auth.uid());
create policy comment_likes_delete on public.comment_likes for delete using (user_id = auth.uid());

-- follows
create policy follows_select on public.follows for select using (true);
create policy follows_insert on public.follows for insert
  with check (follower_id = auth.uid() and not public.is_blocked_with(following_id));
create policy follows_delete on public.follows for delete using (follower_id = auth.uid() or following_id = auth.uid());

-- friend requests
create policy fr_select on public.friend_requests for select using (sender_id = auth.uid() or receiver_id = auth.uid());
create policy fr_insert on public.friend_requests for insert with check (sender_id = auth.uid() and not public.is_blocked_with(receiver_id));
create policy fr_update on public.friend_requests for update
  using (receiver_id = auth.uid() or sender_id = auth.uid()) with check (true);
create policy fr_delete on public.friend_requests for delete using (sender_id = auth.uid() or receiver_id = auth.uid());

-- friendships
create policy friendships_select on public.friendships for select
  using (user_a = auth.uid() or user_b = auth.uid());
create policy friendships_insert on public.friendships for insert with check (user_a = auth.uid() or user_b = auth.uid());
create policy friendships_delete on public.friendships for delete using (user_a = auth.uid() or user_b = auth.uid());

-- conversations
create policy conversations_select on public.conversations for select using (public.in_conversation(id));
create policy conversations_insert on public.conversations for insert with check (true);
create policy conversations_update on public.conversations for update using (public.in_conversation(id));

create policy cm_select on public.conversation_members for select using (public.in_conversation(conversation_id));
create policy cm_insert on public.conversation_members for insert with check (user_id = auth.uid());
create policy cm_update on public.conversation_members for update using (user_id = auth.uid()) with check (user_id = auth.uid());

-- messages
create policy messages_select on public.messages for select using (public.in_conversation(conversation_id));
create policy messages_insert on public.messages for insert
  with check (sender_id = auth.uid() and public.in_conversation(conversation_id) and account_status_ok());
create policy messages_update on public.messages for update
  using (sender_id = auth.uid()) with check (sender_id = auth.uid());
create policy messages_delete on public.messages for delete using (sender_id = auth.uid());

-- notifications
create policy notifications_select on public.notifications for select using (user_id = auth.uid());
create policy notifications_update on public.notifications for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notifications_delete on public.notifications for delete using (user_id = auth.uid());

-- saved posts
create policy saved_select on public.saved_posts for select using (user_id = auth.uid());
create policy saved_insert on public.saved_posts for insert with check (user_id = auth.uid());
create policy saved_delete on public.saved_posts for delete using (user_id = auth.uid());

-- stories
create policy stories_select on public.stories for select
  using (expires_at > now() and (user_id = auth.uid() or not public.is_blocked_with(user_id)));
create policy stories_insert on public.stories for insert with check (user_id = auth.uid() and account_status_ok());
create policy stories_delete on public.stories for delete using (user_id = auth.uid() or public.is_admin());

create policy story_views_select on public.story_views for select using (true);
create policy story_views_insert on public.story_views for insert with check (user_id = auth.uid());
create policy story_views_delete on public.story_views for delete using (user_id = auth.uid());

-- reports
create policy reports_insert on public.reports for insert with check (reporter_id = auth.uid());
create policy reports_select on public.reports for select
  using (reporter_id = auth.uid() or public.is_admin());
create policy reports_update on public.reports for update using (public.is_admin()) with check (public.is_admin());

-- blocks
create policy blocks_select on public.blocks for select using (blocker_id = auth.uid());
create policy blocks_insert on public.blocks for insert with check (blocker_id = auth.uid() and account_status_ok());
create policy blocks_delete on public.blocks for delete using (blocker_id = auth.uid());

-- user_settings
create policy settings_select on public.user_settings for select using (user_id = auth.uid());
create policy settings_update on public.user_settings for update using (user_id = auth.uid()) with check (user_id = auth.uid());

-- shares
create policy shares_select on public.shares for select using (true);
create policy shares_insert on public.shares for insert with check (user_id = auth.uid());
create policy shares_delete on public.shares for delete using (user_id = auth.uid());

-- ===================== REALTIME =====================
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.conversations;
