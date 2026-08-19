package com.example.auto_connect

import android.app.*
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.*
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.*
import android.provider.Settings
import android.view.*
import android.widget.*
import java.util.Locale

class BluetoothScanService : Service() {
    private val channelId = "auto_connect_scan"
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != BluetoothDevice.ACTION_FOUND) return
            val device = if (Build.VERSION.SDK_INT >= 33) intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
            else @Suppress("DEPRECATION") intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
            if (device != null) maybeShow(device)
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = Notification.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.stat_sys_data_bluetooth)
            .setContentTitle("Auto Connect")
            .setContentText("Ищем выбранные наушники рядом")
            .setOngoing(true).build()
        if (Build.VERSION.SDK_INT >= 29) startForeground(7, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE) else startForeground(7, notification)
        registerReceiver(receiver, IntentFilter(BluetoothDevice.ACTION_FOUND))
        startDiscovery()
    }

    private fun startDiscovery() {
        try {
            val adapter = BluetoothAdapter.getDefaultAdapter()
            if (adapter != null && adapter.isEnabled && !adapter.isDiscovering) adapter.startDiscovery()
        } catch (_: SecurityException) {}
    }

    private fun maybeShow(device: BluetoothDevice) {
        val name = try { device.name ?: "" } catch (_: SecurityException) { "" }
        if (name.isBlank() || !isEnabledHeadphone(name) || !Settings.canDrawOverlays(this)) return
        showPopup(device, name)
    }

    private fun isEnabledHeadphone(name: String): Boolean {
        val n = name.lowercase(Locale.getDefault())
        val patterns = getSharedPreferences("auto_connect_settings", MODE_PRIVATE)
            .getStringSet("enabled_patterns", emptySet()) ?: emptySet()
        return patterns.any { n.contains(it.lowercase(Locale.getDefault())) }
    }

    private fun showPopup(device: BluetoothDevice, name: String) {
        val wm = getSystemService(WINDOW_SERVICE) as WindowManager
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(28, 22, 28, 24)
            background = GradientDrawable().apply { setColor(Color.WHITE); cornerRadius = 42f }
        }
        val art = TextView(this).apply { text = "🎧"; textSize = 92f; gravity = Gravity.CENTER; setPadding(0, 10, 0, 8) }
        val title = TextView(this).apply { text = name; textSize = 23f; setTextColor(Color.BLACK); setTypeface(typeface, android.graphics.Typeface.BOLD); gravity = Gravity.CENTER }
        val subtitle = TextView(this).apply { text = "Выбранные наушники рядом"; textSize = 15f; setTextColor(Color.DKGRAY); gravity = Gravity.CENTER }
        val button = Button(this).apply {
            text = "Подключить"; textSize = 17f; isAllCaps = false
            setOnClickListener {
                try {
                    if (device.bondState != BluetoothDevice.BOND_BONDED) device.createBond()
                    else Toast.makeText(this@BluetoothScanService, "Наушники уже сопряжены", Toast.LENGTH_SHORT).show()
                } catch (_: Exception) { Toast.makeText(this@BluetoothScanService, "Не удалось подключить", Toast.LENGTH_SHORT).show() }
                try { wm.removeView(root) } catch (_: Exception) {}
            }
        }
        root.addView(art, LinearLayout.LayoutParams(-1, 190))
        root.addView(title, LinearLayout.LayoutParams(-1, -2))
        root.addView(subtitle, LinearLayout.LayoutParams(-1, -2))
        val bp = LinearLayout.LayoutParams(-1, 56); bp.topMargin = 16; root.addView(button, bp)
        val type = if (Build.VERSION.SDK_INT >= 26) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE
        val lp = WindowManager.LayoutParams(
            (resources.displayMetrics.widthPixels * .92).toInt(),
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            android.graphics.PixelFormat.TRANSLUCENT
        ).apply { gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL; y = 34 }
        try {
            wm.addView(root, lp)
            root.postDelayed({ try { wm.removeView(root) } catch (_: Exception) {} }, 15000)
        } catch (_: Exception) {}
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= 26) getSystemService(NotificationManager::class.java)
            .createNotificationChannel(NotificationChannel(channelId, "Auto Connect", NotificationManager.IMPORTANCE_LOW))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int { startDiscovery(); return START_STICKY }
    override fun onDestroy() { try { unregisterReceiver(receiver) } catch (_: Exception) {}; try { BluetoothAdapter.getDefaultAdapter()?.cancelDiscovery() } catch (_: Exception) {}; super.onDestroy() }
    override fun onBind(intent: Intent?) = null
}
