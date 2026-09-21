package com.sitequant.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
    }
}
