import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n_gen/app_localizations.dart';
import 'theme.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

/// NEXORA logo mark — original branding: orange gradient tile + N.
class NexoraLogo extends StatelessWidget {
  final double size;
  const NexoraLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: NexTheme.accentGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: NexColors.accent.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text('N',
          style: TextStyle(
            fontSize: size * 0.58,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          )),
    );
  }
}

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

/// Presence helpers (online status is written only for my own profile row —
/// RLS enforces that; visibility to others is controlled by user_settings).
class SupabasePresence {
  static Future<void> setOnline(bool online) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    try {
      await SupabaseService.client.from('profiles').update({
        'is_online': online,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', uid);
    } catch (_) {}
  }
}

class VerifiedBadge extends StatelessWidget {
  final double size;
  const VerifiedBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          gradient: NexTheme.accentGradient, shape: BoxShape.circle),
      child: Icon(Icons.check, size: size * 0.65, color: Colors.black),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final Profile? profile;
  final double radius;
  const ProfileAvatar({super.key, this.profile, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final url = profile?.avatarUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: NexColors.surfaceHi,
      backgroundImage: (url != null && url.isNotEmpty)
          ? CachedNetworkImageProvider(url)
          : null,
      child: (url == null || url.isEmpty)
          ? Text(
              (profile?.firstName.isNotEmpty ?? false)
                  ? profile!.firstName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  color: NexColors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: radius * 0.9),
            )
          : null,
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: NexColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const LinearProgressIndicator(
        minHeight: 2,
        color: NexColors.accent,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: NexColors.textDim),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: NexColors.textDim)),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: NexColors.textDim),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }
}

String timeAgo(DateTime dt, AppLocalizations l) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return l.justNow;
  if (d.inMinutes < 60) return l.minutesAgo(d.inMinutes);
  if (d.inHours < 24) return l.hoursAgo(d.inHours);
  return l.daysAgo(d.inDays);
}
