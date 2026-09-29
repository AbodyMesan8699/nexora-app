# Nexora social/profile fix

## Changes

- Profile screens distinguish the authenticated UID from the opened profile UID.
- Follow state is read from `follows` and refreshed from Supabase after follow/unfollow.
- Friend request state is pair-specific and distinguishes sender from receiver.
- Pending sent requests can be cancelled; pending received requests can be accepted.
- Friend removal is a real `friendships` delete after confirmation.
- Relationship buttons are disabled while an operation is in flight and are not changed before the backend succeeds.
- Profile counts use the existing `follows` and `friendships` tables.
- Added `supabase/migrations/0003_social_security.sql` to ensure only the authenticated receiver can accept/decline a request.
- Search continues to open profiles by the result's real `Profile.id`.

## Supabase deployment

Apply the existing migrations in order, then apply `0003_social_security.sql` in the Supabase SQL editor. No new relationship tables are created.

## APK build

The APK was built from the Flutter source with the Supabase URL and public anon key already present in the supplied reference APK. The public anon key is not a service-role secret; never ship a service-role key in the mobile app.
