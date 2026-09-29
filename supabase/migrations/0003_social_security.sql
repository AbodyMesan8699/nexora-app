-- Harden friend-request transitions without introducing a second relationship model.
-- Only the authenticated receiver may accept or decline a request.
drop policy if exists fr_update on public.friend_requests;
create policy fr_update on public.friend_requests for update
to authenticated
using (receiver_id = auth.uid())
with check (receiver_id = auth.uid());

-- Keep the sender/receiver ownership check explicit for new requests.
drop policy if exists fr_insert on public.friend_requests;
create policy fr_insert on public.friend_requests for insert
to authenticated
with check (sender_id = auth.uid() and sender_id <> receiver_id and not public.is_blocked_with(receiver_id));
