/// Public GitHub Releases configuration for the Android self-updater.
/// These are public repository coordinates, never authentication credentials.
class AppUpdateConfig {
  /// Defaults to the public NEXORA release repository. Override for forks.
  static const githubOwner = String.fromEnvironment(
    'NEXORA_GITHUB_OWNER',
    defaultValue: 'AbodyMesan8699',
  );
  static const githubRepository = String.fromEnvironment(
    'NEXORA_GITHUB_REPOSITORY',
    defaultValue: 'nexora-app',
  );

  /// Upload future ARM64 builds to each GitHub Release using this exact asset name.
  static const apkAssetName = String.fromEnvironment(
    'NEXORA_APK_ASSET_NAME',
    defaultValue: 'Nexora-arm64-release.apk',
  );

  static bool get isConfigured =>
      _isSafeSegment(githubOwner) && _isSafeSegment(githubRepository);

  static bool _isSafeSegment(String value) =>
      value.isNotEmpty &&
      RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(value) &&
      value != '.' &&
      value != '..';
}
