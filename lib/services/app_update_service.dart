import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_update_config.dart';

class AppRelease {
  const AppRelease({
    required this.version,
    required this.tagName,
    required this.releaseNotes,
    required this.releasePageUrl,
    required this.apkUrl,
    required this.assetName,
    this.sha256Digest,
  });

  final String version;
  final String tagName;
  final String releaseNotes;
  final Uri releasePageUrl;
  final Uri apkUrl;
  final String assetName;
  final String? sha256Digest;

  static AppRelease? fromGitHubJson(Map<String, dynamic> json) {
    if (json['draft'] == true || json['prerelease'] == true) return null;

    final tag = json['tag_name']?.toString().trim() ?? '';
    final version = normalizeVersion(tag);
    if (!RegExp(r'^\d+(?:\.\d+){1,3}$').hasMatch(version)) return null;

    final rawAssets = json['assets'];
    if (rawAssets is! List) return null;
    final assets = rawAssets.whereType<Map>().cast<Map<String, dynamic>>();
    Map<String, dynamic>? chosen;
    for (final asset in assets) {
      if (asset['name']?.toString() == AppUpdateConfig.apkAssetName) {
        chosen = asset;
        break;
      }
    }
    chosen ??= assets.cast<Map<String, dynamic>?>().firstWhere((asset) {
      final name = asset?['name']?.toString().toLowerCase() ?? '';
      return name.endsWith('.apk') && name.contains('arm64');
    }, orElse: () => null);
    if (chosen == null) return null;

    final apkUrl = Uri.tryParse(
      chosen['browser_download_url']?.toString() ?? '',
    );
    final pageUrl = Uri.tryParse(json['html_url']?.toString() ?? '');
    if (!_isTrustedGitHubUri(apkUrl) || !_isTrustedGitHubUri(pageUrl)) {
      return null;
    }

    final digest = _parseSha256(chosen['digest']?.toString());
    return AppRelease(
      version: version,
      tagName: tag,
      releaseNotes: json['body']?.toString().trim() ?? '',
      releasePageUrl: pageUrl!,
      apkUrl: apkUrl!,
      assetName: chosen['name']?.toString() ?? AppUpdateConfig.apkAssetName,
      sha256Digest: digest,
    );
  }

  static bool _isTrustedGitHubUri(Uri? uri) =>
      uri != null &&
      uri.scheme == 'https' &&
      (uri.host == 'github.com' ||
          uri.host == 'release-assets.githubusercontent.com' ||
          uri.host == 'objects.githubusercontent.com');

  static String? _parseSha256(String? raw) {
    if (raw == null || !raw.startsWith('sha256:')) return null;
    final value = raw.substring('sha256:'.length).toLowerCase();
    return RegExp(r'^[a-f0-9]{64}$').hasMatch(value) ? value : null;
  }

  static String normalizeVersion(String value) {
    var version = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
    version = version.split('+').first;
    version = version.split('-').first;
    return version;
  }

  /// Returns a negative value when [left] is older, zero when equal, positive when newer.
  static int compareVersions(String left, String right) {
    final a = normalizeVersion(left).split('.');
    final b = normalizeVersion(right).split('.');
    final count = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < count; i++) {
      final av = i < a.length ? int.tryParse(a[i]) ?? 0 : 0;
      final bv = i < b.length ? int.tryParse(b[i]) ?? 0 : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }
}

class AppUpdateService {
  AppUpdateService({
    http.Client? client,
    String? owner,
    String? repository,
    Future<String> Function()? currentVersionLoader,
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _client = client ?? http.Client(),
       _owner = owner ?? AppUpdateConfig.githubOwner,
       _repository = repository ?? AppUpdateConfig.githubRepository,
       _currentVersionLoader = currentVersionLoader ?? _installedVersion,
       _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static const _lastCheckKey = 'nexora_last_github_update_check_ms';
  static const _checkInterval = Duration(hours: 12);
  static const _maximumApkBytes = 200 * 1024 * 1024;

  final http.Client _client;
  final String _owner;
  final String _repository;
  final Future<String> Function() _currentVersionLoader;
  final Future<SharedPreferences> Function() _preferencesLoader;

  static Future<String> _installedVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  Future<AppRelease?> checkForUpdate({bool force = false}) async {
    if (!_isSafeSegment(_owner) || !_isSafeSegment(_repository)) return null;

    final preferences = await _preferencesLoader();
    final now = DateTime.now();
    final lastCheck = preferences.getInt(_lastCheckKey);
    if (!force && lastCheck != null) {
      final elapsed = now.difference(
        DateTime.fromMillisecondsSinceEpoch(lastCheck),
      );
      if (elapsed >= Duration.zero && elapsed < _checkInterval) return null;
    }

    final endpoint = Uri.https(
      'api.github.com',
      '/repos/$_owner/$_repository/releases/latest',
    );
    final response = await _client
        .get(
          endpoint,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2026-03-10',
            'User-Agent': 'NEXORA-Android-Updater',
          },
        )
        .timeout(const Duration(seconds: 15));

    await preferences.setInt(_lastCheckKey, now.millisecondsSinceEpoch);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw HttpException(
        'GitHub release check returned ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final release = AppRelease.fromGitHubJson(decoded);
    if (release == null) return null;

    final installedVersion = await _currentVersionLoader();
    return AppRelease.compareVersions(release.version, installedVersion) > 0
        ? release
        : null;
  }

  Future<File> downloadApk(
    AppRelease release, {
    required void Function(double? fraction) onProgress,
  }) async {
    final request = http.Request('GET', release.apkUrl)
      ..headers['Accept'] = 'application/octet-stream'
      ..headers['User-Agent'] = 'NEXORA-Android-Updater';
    final response = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('APK download returned ${response.statusCode}.');
    }
    final contentLength = response.contentLength;
    if (contentLength != null && contentLength > _maximumApkBytes) {
      throw const HttpException(
        'The update APK is larger than the allowed limit.',
      );
    }

    final temp = await getTemporaryDirectory();
    final updateDir = Directory('${temp.path}${Platform.pathSeparator}updates');
    await updateDir.create(recursive: true);
    final safeVersion = release.version.replaceAll(RegExp(r'[^0-9.]'), '_');
    final apkFile = File(
      '${updateDir.path}${Platform.pathSeparator}nexora-update-$safeVersion.apk',
    );
    if (await apkFile.exists()) await apkFile.delete();

    final sink = apkFile.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        received += chunk.length;
        if (received > _maximumApkBytes) {
          throw const HttpException(
            'The update APK is larger than the allowed limit.',
          );
        }
        sink.add(chunk);
        onProgress(
          contentLength == null || contentLength == 0
              ? null
              : received / contentLength,
        );
      }
      await sink.flush();
    } catch (_) {
      await sink.close();
      if (await apkFile.exists()) await apkFile.delete();
      rethrow;
    }
    await sink.close();

    if (release.sha256Digest != null) {
      final actualDigest = await sha256.bind(apkFile.openRead()).first;
      if (actualDigest.toString() != release.sha256Digest) {
        await apkFile.delete();
        throw const FormatException(
          'The update file failed its SHA-256 check.',
        );
      }
    }

    final handle = await apkFile.open();
    final header = await handle.read(4);
    await handle.close();
    if (header.length < 4 ||
        header[0] != 0x50 ||
        header[1] != 0x4b ||
        header[2] != 0x03 ||
        header[3] != 0x04) {
      await apkFile.delete();
      throw const FormatException(
        'The downloaded file is not a valid APK archive.',
      );
    }
    return apkFile;
  }

  static bool _isSafeSegment(String value) =>
      value.isNotEmpty &&
      RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(value) &&
      value != '.' &&
      value != '..';
}
