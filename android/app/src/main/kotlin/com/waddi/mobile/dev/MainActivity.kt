package com.waddi.mobile.dev

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.waddi.mobile.dev/back_button"
    private var isBackButtonHandled = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "MainActivity created")
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "FlutterEngine configured")
        
        // Set up method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "flutterReady" -> {
                    Log.d("MainActivity", "Flutter is ready")
                    isBackButtonHandled = false
                    result.success(null)
                }
                "test" -> {
                    Log.d("MainActivity", "Test method called from Flutter")
                    result.success("Android received test call")
                }
                else -> {
                    Log.d("MainActivity", "Unknown method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onBackPressed() {
        Log.d("MainActivity", "Android back button pressed - sending to Flutter")
        Log.d("MainActivity", "FlutterEngine: ${flutterEngine}")
        Log.d("MainActivity", "DartExecutor: ${flutterEngine?.dartExecutor}")
        Log.d("MainActivity", "BinaryMessenger: ${flutterEngine?.dartExecutor?.binaryMessenger}")
        
        // Send the back button event to Flutter
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            Log.d("MainActivity", "Sending method call to Flutter")
            MethodChannel(messenger, CHANNEL).invokeMethod("onBackPressed", null)
            isBackButtonHandled = true
        } ?: run {
            Log.e("MainActivity", "Failed to get binary messenger")
            // Fallback: just prevent the app from closing
            Log.d("MainActivity", "Using fallback - preventing app close")
            isBackButtonHandled = true
        }
        
        // Don't call super.onBackPressed() to prevent app from closing
        Log.d("MainActivity", "Back button handled - not calling super.onBackPressed()")
    }
}