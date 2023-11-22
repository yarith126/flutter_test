package com.yarith.flutter_demo

import androidx.annotation.NonNull
import com.yarith.flutter_demo.SecurityChecker.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "demo_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "detectDebugger" -> {
                    result.success(scanForDebugger())
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun scanForDebugger(): Int {
        if (detectDebugger()) return 1
        if (isDebuggable(context)) return 2
        if (hasTracerPid()) return 3
        if (detect_threadCpuTimeNanos()) return 4
        return 0;
    }
}
