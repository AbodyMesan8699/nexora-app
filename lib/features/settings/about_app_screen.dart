import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../l10n_gen/app_localizations.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final features = <(IconData, String)>[
      (Icons.person_outline, l.aboutFeatureProfile),
      (Icons.article_outlined, l.aboutFeaturePosts),
      (Icons.favorite_border, l.aboutFeatureLikes),
      (Icons.chat_bubble_outline, l.aboutFeatureComments),
      (Icons.people_outline, l.aboutFeatureFriends),
      (Icons.search, l.aboutFeatureSearch),
      (Icons.notifications_none, l.aboutFeatureNotifications),
      (Icons.lock_outline, l.aboutFeatureSecurity),
      (Icons.settings_outlined, l.aboutFeatureSettings),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutApp)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: NexColors.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.hub_outlined,
                    color: NexColors.accent,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'NEXORA',
                  style: TextStyle(
                    color: NexColors.accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            child: Text(
              l.aboutIntro,
              style: const TextStyle(height: 1.65, fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(l.aboutFeaturesTitle),
          _InfoCard(
            child: Column(
              children: [
                for (var i = 0; i < features.length; i++) ...[
                  _FeatureRow(icon: features[i].$1, text: features[i].$2),
                  if (i < features.length - 1)
                    const Divider(height: 20, indent: 42),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(l.aboutVisionTitle),
          _InfoCard(
            child: Text(
              l.aboutVisionBody,
              style: const TextStyle(height: 1.65, fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(l.aboutDevelopmentTitle),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXORA',
                  style: TextStyle(
                    color: NexColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l.aboutDeveloper),
                const SizedBox(height: 6),
                Text(l.aboutFounder),
                const SizedBox(height: 14),
                Text(l.aboutVersionTitle),
                const SizedBox(height: 4),
                Text(l.aboutCurrentVersion('1.0.0')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.aboutCopyright,
            textAlign: TextAlign.center,
            style: const TextStyle(color: NexColors.textDim, fontSize: 12),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: NexColors.accent, size: 22),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(height: 1.45))),
    ],
  );
}
