import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../services/app_update_service.dart';

const _apkInstallerChannel = MethodChannel('com.nexora.nexora/apk_installer');

enum _UpdateMethod { inApp, browser }

Future<void> showAppUpdatePrompt(
  BuildContext context,
  AppRelease release,
) async {
  final l = AppLocalizations.of(context);
  final updateNow = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: NexTheme.accentGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.system_update_alt_rounded,
                color: Colors.black,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l.updateAvailable,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l.updateAvailableBody(release.version),
              textAlign: TextAlign.center,
              style: const TextStyle(color: NexColors.textDim, height: 1.5),
            ),
            if (release.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NexColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  release.releaseNotes,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: NexColors.textDim,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(l.updateLater),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    label: Text(l.updateNow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (updateNow != true || !context.mounted) return;

  final method = await showModalBottomSheet<_UpdateMethod>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final sheetL = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Text(
                  sheetL.updateChooseMethod,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(
                  Icons.download_for_offline_outlined,
                  color: NexColors.accent,
                ),
                title: Text(sheetL.updateInApp),
                subtitle: Text(sheetL.updateInAppSubtitle),
                onTap: () => Navigator.pop(sheetContext, _UpdateMethod.inApp),
              ),
              const SizedBox(height: 4),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(Icons.open_in_browser_rounded),
                title: Text(sheetL.updateInBrowser),
                subtitle: Text(sheetL.updateInBrowserSubtitle),
                onTap: () => Navigator.pop(sheetContext, _UpdateMethod.browser),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (method == null || !context.mounted) return;

  if (method == _UpdateMethod.browser) {
    final opened = await launchUrl(
      release.releasePageUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) _showUpdateError(context);
    return;
  }
  await _downloadAndInstall(context, release);
}

Future<void> _downloadAndInstall(
  BuildContext context,
  AppRelease release,
) async {
  if (!Platform.isAndroid) {
    final opened = await launchUrl(
      release.releasePageUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) _showUpdateError(context);
    return;
  }

  final l = AppLocalizations.of(context);
  final progress = ValueNotifier<double?>(null);
  final progressDialog = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: ValueListenableBuilder<double?>(
          valueListenable: progress,
          builder: (context, value, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value == null)
                const CircularProgressIndicator()
              else
                CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0).toDouble(),
                ),
              const SizedBox(height: 18),
              Text(l.updateDownloading, textAlign: TextAlign.center),
              if (value != null) ...[
                const SizedBox(height: 8),
                Text('${(value * 100).round()}%'),
              ],
            ],
          ),
        ),
      ),
    ),
  );
  var progressDialogDismissed = false;

  Future<void> dismissProgress() async {
    if (progressDialogDismissed) return;
    progressDialogDismissed = true;
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    await progressDialog;
  }

  try {
    final apk = await AppUpdateService().downloadApk(
      release,
      onProgress: (fraction) => progress.value = fraction,
    );
    if (!context.mounted) return;
    await dismissProgress();
    if (!context.mounted) return;
    await _requestSystemInstall(context, apk.path);
  } catch (_) {
    if (context.mounted) await dismissProgress();
    if (context.mounted) _showUpdateError(context);
  } finally {
    if (!progressDialogDismissed && context.mounted) await dismissProgress();
    progress.dispose();
  }
}

Future<void> _requestSystemInstall(BuildContext context, String path) async {
  try {
    final result = await _apkInstallerChannel.invokeMethod<String>(
      'installApk',
      {'path': path},
    );
    if (result == 'permission_required') {
      if (!context.mounted) return;
      final l = AppLocalizations.of(context);
      final continueInstall = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.updateInstallPermissionTitle),
          content: Text(l.updateInstallPermissionBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.updateContinueInstall),
            ),
          ],
        ),
      );
      if (continueInstall == true && context.mounted) {
        await _requestSystemInstall(context, path);
      }
      return;
    }
    if (result != 'installer_opened' && context.mounted) {
      _showUpdateError(context);
    }
  } on PlatformException {
    if (context.mounted) _showUpdateError(context);
  } catch (_) {
    if (context.mounted) _showUpdateError(context);
  }
}

void _showUpdateError(BuildContext context) {
  final l = AppLocalizations.of(context);
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.updateErrorTitle),
      content: Text(l.updateDownloadFailed),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l.ok),
        ),
      ],
    ),
  );
}
