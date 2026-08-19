package com.example.auto_connect

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.*
import android.net.Uri
import android.os.*
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object { const val CHANNEL = "auto_connect/native"; const val EVENTS = "auto_connect/events" }
    private var eventSink: EventChannel.EventSink? = null
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BluetoothDevice.ACTION_FOUND) {
                val d = if (Build.VERSION.SDK_INT >= 33) intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                        else @Suppress("DEPRECATION") intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                if (d != null) eventSink?.success(mapOf("name" to (d.name ?: "Unknown device"), "address" to d.address, "rssi" to intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, (-100).toShort()).toInt()))
            }
        }
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        EventChannel(engine.dartExecutor.binaryMessenger, EVENTS).setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) { eventSink = sink }
            override fun onCancel(args: Any?) { eventSink = null }
        })
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startScanner" -> startScanner(result)
                "stopScanner" -> { stopScanner(); result.success(true) }
                "requestOverlay" -> {
                    if (Settings.canDrawOverlays(this)) result.success(true)
                    else { startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))); result.success(false) }
                }
                "connect" -> {
                    val address = call.argument<String>("address")
                    val device = try { BluetoothAdapter.getDefaultAdapter()?.getRemoteDevice(address ?: "") } catch (_: Exception) { null }
                    if (device == null) result.error("DEVICE", "Устройство не найдено", null)
                    else try {
                        if (Build.VERSION.SDK_INT >= 31 && checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != 0) result.error("PERMISSION", "Нет Bluetooth CONNECT", null)
                        else { if (device.bondState != BluetoothDevice.BOND_BONDED) device.createBond() else device.connectGatt(this, false, BluetoothGattCallbackImpl()); result.success(true) }
                    } catch (e: Exception) { result.error("CONNECT", e.message, null) }
                }
                else -> result.notImplemented()
            }
        }
        registerReceiver(receiver, IntentFilter(BluetoothDevice.ACTION_FOUND))
    }

    private fun startScanner(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != 0) requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 51)
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter == null) { result.error("BT", "Bluetooth недоступен", null); return }
        if (!adapter.isEnabled) { result.error("BT_OFF", "Включите Bluetooth", null); return }
        try {
            if (Build.VERSION.SDK_INT >= 31 && checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN) != 0) requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT), 50)
            if (Settings.canDrawOverlays(this)) {
                val serviceIntent = Intent(this, BluetoothScanService::class.java)
                if (Build.VERSION.SDK_INT >= 26) startForegroundService(serviceIntent) else startService(serviceIntent)
            } else if (!Settings.canDrawOverlays(this)) {
                startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
            }
            if (!adapter.isDiscovering) adapter.startDiscovery()
            result.success(true)
        } catch (e: SecurityException) { result.error("PERMISSION", "Нужно разрешение Bluetooth", null) }
    }

    private fun stopScanner() {
        try { BluetoothAdapter.getDefaultAdapter()?.cancelDiscovery() } catch (_: Exception) {}
        try { stopService(Intent(this, BluetoothScanService::class.java)) } catch (_: Exception) {}
    }

    override fun onDestroy() { stopScanner(); try { unregisterReceiver(receiver) } catch (_: Exception) {}; super.onDestroy() }
}

private class BluetoothGattCallbackImpl : android.bluetooth.BluetoothGattCallback()
