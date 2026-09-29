// NEXORA — Edge Function: push (FCM)
// Deploy: supabase functions deploy push --no-verify-jwt=false
// Secrets: supabase secrets set FCM_SERVER_KEY=<your FCM legacy server key or OAuth token>
//
// The client inserts a row into `push_queue` (service-role only table); a
// database webhook on that table calls this function, which forwards the
// notification to Firebase Cloud Messaging. Message content is included in
// the payload only when the sender's privacy settings allow it.

// @ts-nocheck
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const FCM_ENDPOINT = "https://fcm.googleapis.com/fcm/send";

Deno.serve(async (req: Request) => {
  try {
    const { record } = await req.json();
    if (!record) return new Response("no record", { status: 400 });

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Resolve recipient device tokens (stored by the app after FCM registration)
    const { data: tokens } = await admin
      .from("device_tokens")
      .select("token")
      .eq("user_id", record.user_id);
    if (!tokens?.length) return new Response("no tokens", { status: 200 });

    const body: Record<string, unknown> = {
      registration_ids: tokens.map((t: { token: string }) => t.token),
      priority: "high",
      notification: {
        title: record.title,
        body: record.body,
        sound: "default",
      },
      data: {
        type: record.type ?? "generic",
        reference_id: record.reference_id ?? "",
      },
      android: { priority: "high" },
    };

    const res = await fetch(FCM_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `key=${Deno.env.get("FCM_SERVER_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
    return new Response(JSON.stringify({ ok: res.ok }), { status: 200 });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
