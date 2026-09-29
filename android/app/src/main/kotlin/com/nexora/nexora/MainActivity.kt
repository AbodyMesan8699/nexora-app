package com.nexora.nexora

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APK_INSTALLER_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method != "installApk") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val apkPath = call.argument<String>("path")
            if (apkPath.isNullOrBlank()) {
                result.error("missing_path", "An APK file path is required.", null)
                return@setMethodCallHandler
            }

            try {
                val apk = File(apkPath)
                if (!apk.isFile || !apk.exists() || apk.length() == 0L) {
                    result.error("invalid_apk", "The downloaded APK is missing or empty.", null)
                    return@setMethodCallHandler
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                    !packageManager.canRequestPackageInstalls()
                ) {
                    val settingsIntent = Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(settingsIntent)
                    result.success("permission_required")
                    return@setMethodCallHandler
                }

                val contentUri = FileProvider.getUriForFile(
                    this,
                    "$packageName.fileprovider",
                    apk
                )
                val installIntent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(
                        contentUri,
                        "application/vnd.android.package-archive"
                    )
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(installIntent)
                result.success("installer_opened")
            } catch (error: Exception) {
                result.error("install_error", error.message ?: "Could not open the Android installer.", null)
            }
        }
    }

    companion object {
        private const val APK_INSTALLER_CHANNEL = "com.nexora.nexora/apk_installer"
    }
}
