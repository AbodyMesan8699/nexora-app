import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexora/features/update/update_flow.dart';
import 'package:nexora/l10n_gen/app_localizations.dart';
import 'package:nexora/services/app_update_service.dart';

AppRelease testRelease() => AppRelease(
  version: '1.1.0',
  tagName: 'v1.1.0',
  releaseNotes: 'Stability improvements.',
  releasePageUrl: Uri.parse(
    'https://github.com/example/nexora/releases/tag/v1.1.0',
  ),
  apkUrl: Uri.parse(
    'https://github.com/example/nexora/releases/download/v1.1.0/Nexora-arm64-release.apk',
  ),
  assetName: 'Nexora-arm64-release.apk',
);

Future<void> pumpPrompt(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const ValueKey('show-update'),
              onPressed: () => showAppUpdatePrompt(context, testRelease()),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('show-update')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('English prompt offers both update routes', (tester) async {
    await pumpPrompt(tester, const Locale('en'));

    expect(find.text('A new update is available'), findsOneWidget);
    expect(
      find.text(
        'NEXORA version 1.1.0 is ready. Update now to get the latest improvements.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(find.text('How would you like to update?'), findsOneWidget);
    expect(find.text('Update inside the app'), findsOneWidget);
    expect(find.text('Update in a browser'), findsOneWidget);
  });

  testWidgets('Arabic prompt is localized and RTL-ready', (tester) async {
    await pumpPrompt(tester, const Locale('ar'));

    expect(find.text('يتوفر تحديث جديد'), findsOneWidget);
    await tester.tap(find.text('تحديث'));
    await tester.pumpAndSettle();
    expect(find.text('كيف تفضّل التحديث؟'), findsOneWidget);
    expect(find.text('التحديث داخل التطبيق'), findsOneWidget);
    expect(find.text('التحديث عبر المتصفح'), findsOneWidget);
  });
}
