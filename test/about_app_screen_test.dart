import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/core/theme.dart';
import 'package:nexora/features/settings/about_app_screen.dart';
import 'package:nexora/l10n_gen/app_localizations.dart';

Future<void> pumpAboutScreen(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: NexTheme.dark(),
      home: const AboutAppScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Arabic about page shows the requested NEXORA information', (
    tester,
  ) async {
    await pumpAboutScreen(tester, const Locale('ar'));

    expect(find.text('معلومات التطبيق'), findsOneWidget);
    expect(
      find.text(
        'NEXORA هو تطبيق اجتماعي حديث يهدف إلى توفير مساحة رقمية سهلة ومريحة للتواصل، مشاركة المنشورات، اكتشاف المحتوى، والتفاعل مع الآخرين في مكان واحد.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('✨ ماذا يقدم NEXORA؟'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('👤 إنشاء وإدارة الملف الشخصي.'), findsOneWidget);
    expect(
      find.text('🔒 أنظمة حماية وصلاحيات للحفاظ على أمان الحسابات والمحتوى.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text(
        'نسعى في NEXORA إلى تقديم تجربة اجتماعية بسيطة وحديثة تجمع التواصل والمحتوى والتفاعل في منصة واحدة، مع الاهتمام بسهولة الاستخدام والأمان واستقرار التطبيق.',
      ),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('مؤسس المنصة: الأستاذ عبدالرحمن الحقلي'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('الإصدار الحالي: 1.0.0'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('© جميع الحقوق محفوظة — NEXORA | الحقلي إتقان'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text('© جميع الحقوق محفوظة — NEXORA | الحقلي إتقان'),
      findsOneWidget,
    );
  });

  testWidgets('English about page localizes title, introduction, and version', (
    tester,
  ) async {
    await pumpAboutScreen(tester, const Locale('en'));

    expect(find.text('About the app'), findsOneWidget);
    expect(
      find.text(
        'NEXORA is a modern social app designed to provide an easy, comfortable digital space to connect, share posts, discover content, and interact with others in one place.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Current version: 1.0.0'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('© All rights reserved — NEXORA | Al-Haqli Itqan'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text('© All rights reserved — NEXORA | Al-Haqli Itqan'),
      findsOneWidget,
    );
  });
}
