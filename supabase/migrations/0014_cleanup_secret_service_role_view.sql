-- Let the server-side cleanup Edge Function verify the cron secret via PostgREST.
-- The underlying table and its secret remain in the private schema.
CREATE VIEW public.private_cleanup_config WITH (security_barrier = true) AS
SELECT id, secret
FROM private.private_cleanup_config;

REVOKE ALL ON public.private_cleanup_config FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.private_cleanup_config TO service_role;

COMMENT ON VIEW public.private_cleanup_config IS
  'Service-role-only view for verifying the internal cleanup cron secret.';

NOTIFY pgrst, 'reload schema';
