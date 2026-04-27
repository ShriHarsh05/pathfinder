package com.example.pathfinder_indoor_navigation

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.gdn.indoor/wifi"
    private val LOCATION_PERMISSION_REQUEST = 1001
    private lateinit var wifiManager: WifiManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

        // Request location permission (required for WiFi scan results on Android 6+)
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ),
                LOCATION_PERMISSION_REQUEST
            )
        } else {
            // Permission already granted — kick off initial scan
            wifiManager.startScan()
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWifiReadings" -> getWifiReadings(result)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == LOCATION_PERMISSION_REQUEST &&
            grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            // Permission just granted — start the first scan
            wifiManager.startScan()
        }
    }

    private fun getWifiReadings(result: MethodChannel.Result) {
        try {
            val readings = wifiManager.scanResults.map { ap ->
                mapOf(
                    "bssid" to ap.BSSID,
                    "ssid"  to ap.SSID,
                    "rssi"  to ap.level
                )
            }
            result.success(readings)
        } catch (e: Exception) {
            result.error("WIFI_ERROR", e.message, null)
        }
    }
}
