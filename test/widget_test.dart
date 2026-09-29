import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/core/theme.dart';

void main() {
  test('NEXORA dark theme builds', () {
    final theme = NexTheme.dark();
    expect(theme.scaffoldBackgroundColor, isNotNull);
  });
}
