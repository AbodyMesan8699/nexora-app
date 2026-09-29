-- Account statistics: active means an active account, not merely online.
create or replace function public.admin_stats() returns json
language sql stable security definer set search_path = public as $$
  select case when public.is_admin() then json_build_object(
    'total_users', (select count(*) from public.profiles),
    'active_users', (select count(*) from public.profiles where account_status = 'active'),
    'total_posts', (select count(*) from public.posts where is_deleted = false),
    'total_comments', (select count(*) from public.comments where is_deleted = false),
    'pending_reports', (select count(*) from public.reports where status = 'pending'),
    'suspended_accounts', (select count(*) from public.profiles where account_status = 'suspended'),
    'storage_objects', (select count(*) from storage.objects),
    'recent_users', (select count(*) from public.profiles where created_at > now() - interval '7 days')
  ) else null end;
$$;

create or replace function public.is_connected_to(other uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select other <> auth.uid() and (
    exists (
      select 1 from public.friendships fr
      where (fr.user_a = auth.uid() and fr.user_b = other)
         or (fr.user_b = auth.uid() and fr.user_a = other)
    )
    or exists (
      select 1 from public.follows f
      where (f.follower_id = auth.uid() and f.following_id = other)
         or (f.follower_id = other and f.following_id = auth.uid())
    )
  );
$$;

create or replace function public.start_conversation(other uuid)
returns uuid language plpgsql security definer set search_path = public as $$
declare conv_id uuid;
begin
  if not public.is_connected_to(other) or public.is_blocked_with(other) then
    return null;
  end if;
  select c.id into conv_id from public.conversations c
    join public.conversation_members a on a.conversation_id = c.id and a.user_id = auth.uid()
    join public.conversation_members b on b.conversation_id = c.id and b.user_id = other
    where not c.is_group
      and (select count(*) from public.conversation_members m where m.conversation_id = c.id) = 2
    limit 1;
  if conv_id is null then
    insert into public.conversations default values returning id into conv_id;
    insert into public.conversation_members (conversation_id, user_id)
    values (conv_id, auth.uid()), (conv_id, other);
  end if;
  return conv_id;
end;
$$;

create or replace function public.conversation_relationship_ok(conv uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from public.conversation_members m
    where m.conversation_id = conv
      and m.user_id <> auth.uid()
      and public.is_connected_to(m.user_id)
      and not public.is_blocked_with(m.user_id)
  );
$$;

drop policy if exists conversations_select on public.conversations;
create policy conversations_select on public.conversations for select
  using (public.in_conversation(id) and public.conversation_relationship_ok(id));

drop policy if exists conversations_update on public.conversations;
create policy conversations_update on public.conversations for update
  using (public.in_conversation(id) and public.conversation_relationship_ok(id));

drop policy if exists cm_select on public.conversation_members;
create policy cm_select on public.conversation_members for select
  using (public.in_conversation(conversation_id) and public.conversation_relationship_ok(conversation_id));

drop policy if exists messages_select on public.messages;
create policy messages_select on public.messages for select
  using (public.in_conversation(conversation_id) and public.conversation_relationship_ok(conversation_id));

drop policy if exists messages_insert on public.messages;
create policy messages_insert on public.messages for insert
  with check (
    sender_id = auth.uid()
    and public.in_conversation(conversation_id)
    and public.conversation_relationship_ok(conversation_id)
    and public.account_status_ok()
  );

revoke execute on function public.is_connected_to(uuid) from public;
revoke execute on function public.conversation_relationship_ok(uuid) from public;
grant execute on function public.is_connected_to(uuid) to authenticated;
grant execute on function public.conversation_relationship_ok(uuid) to authenticated;
