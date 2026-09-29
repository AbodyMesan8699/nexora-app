import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexora/services/app_update_service.dart';

Map<String, dynamic> releasePayload({
  String tag = 'v1.1.0',
  String assetName = 'Nexora-arm64-release.apk',
  bool draft = false,
  bool prerelease = false,
}) => {
  'tag_name': tag,
  'name': 'NEXORA $tag',
  'body': 'Performance and stability improvements.',
  'html_url': 'https://github.com/example/nexora/releases/tag/$tag',
  'draft': draft,
  'prerelease': prerelease,
  'assets': [
    {
      'name': assetName,
      'browser_download_url':
          'https://github.com/example/nexora/releases/download/$tag/$assetName',
      'digest': 'sha256:${'a' * 64}',
    },
  ],
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AppRelease version comparison', () {
    test('compares numeric parts, not lexical strings', () {
      expect(AppRelease.compareVersions('1.10.0', '1.9.9'), greaterThan(0));
      expect(AppRelease.compareVersions('1.2.0', '1.2.1'), lessThan(0));
    });

    test('ignores GitHub v prefix and build metadata', () {
      expect(AppRelease.compareVersions('v1.2.3+8', '1.2.3+2'), 0);
      expect(AppRelease.normalizeVersion('v2.0.0+11'), '2.0.0');
    });

    test('parses stable release and its SHA-256 digest', () {
      final release = AppRelease.fromGitHubJson(releasePayload());
      expect(release, isNotNull);
      expect(release!.version, '1.1.0');
      expect(release.assetName, 'Nexora-arm64-release.apk');
      expect(release.sha256Digest, 'a' * 64);
      expect(release.apkUrl.scheme, 'https');
    });

    test('ignores draft, prerelease, and non-ARM64 assets', () {
      expect(AppRelease.fromGitHubJson(releasePayload(draft: true)), isNull);
      expect(
        AppRelease.fromGitHubJson(releasePayload(prerelease: true)),
        isNull,
      );
      expect(
        AppRelease.fromGitHubJson(
          releasePayload(assetName: 'Nexora-armeabi-v7a.apk'),
        ),
        isNull,
      );
    });
  });

  test(
    'detects a newer public GitHub release than the installed version',
    () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.github.com/repos/example/nexora/releases/latest',
        );
        expect(request.headers['Accept'], 'application/vnd.github+json');
        return http.Response(jsonEncode(releasePayload()), 200);
      });
      final service = AppUpdateService(
        client: client,
        owner: 'example',
        repository: 'nexora',
        currentVersionLoader: () async => '1.0.9',
      );

      final result = await service.checkForUpdate(force: true);
      expect(result?.version, '1.1.0');
    },
  );

  test('does not announce the installed release as an update', () async {
    final client = MockClient(
      (_) async =>
          http.Response(jsonEncode(releasePayload(tag: 'v1.0.0')), 200),
    );
    final service = AppUpdateService(
      client: client,
      owner: 'example',
      repository: 'nexora',
      currentVersionLoader: () async => '1.0.0+1',
    );

    expect(await service.checkForUpdate(force: true), isNull);
  });
}
