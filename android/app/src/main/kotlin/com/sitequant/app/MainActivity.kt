package com.sitequant.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var permissionResult: MethodChannel.Result? = null
    private var reminderChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.sitequant.app/support")
            .setMethodCallHandler { call, result ->
                if (call.method != "shareText") {
                    result.notImplemented()
                } else {
                    val text = call.argument<String>("text")
                    if (text.isNullOrBlank()) {
                        result.error("invalid_text", "Share text is required.", null)
                    } else {
                        try {
                            val intent = Intent(Intent.ACTION_SEND).apply {
                                type = "text/plain"
                                putExtra(Intent.EXTRA_TEXT, text)
                            }
                            startActivity(Intent.createChooser(intent, "Share SiteQuant"))
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("share_unavailable", "Could not open sharing.", null)
                        }
                    }
                }
            }

        reminderChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.sitequant.app/quiz_reminder",
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "requestPermission" -> requestNotificationPermission(result)
                        "scheduleWeekly" -> {
                            QuizReminderScheduler.schedule(this)
                            result.success(null)
                        }
                        "cancel" -> {
                            QuizReminderScheduler.cancel(this)
                            result.success(null)
                        }
                        "wasOpenedFromNotification" -> {
                            val opened = intent?.action == QuizReminderScheduler.openAction
                            if (opened) intent.action = null
                            result.success(opened)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("quiz_reminder_unavailable", error.message, null)
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.action == QuizReminderScheduler.openAction) {
            intent.action = null
            reminderChannel?.invokeMethod("notificationOpened", null)
        }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (permissionResult != null) {
            result.success(false)
            return
        }
        permissionResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 4109)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 4109) {
            permissionResult?.success(
                grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED,
            )
            permissionResult = null
        }
    }
}
