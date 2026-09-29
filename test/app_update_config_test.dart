import 'package:flutter_test/flutter_test.dart';
import 'package:nexora/core/app_update_config.dart';

void main() {
  test('uses the public NEXORA release repository by default', () {
    expect(AppUpdateConfig.githubOwner, 'AbodyMesan8699');
    expect(AppUpdateConfig.githubRepository, 'nexora-app');
    expect(AppUpdateConfig.isConfigured, isTrue);
    expect(AppUpdateConfig.apkAssetName, 'Nexora-arm64-release.apk');
  });
}
