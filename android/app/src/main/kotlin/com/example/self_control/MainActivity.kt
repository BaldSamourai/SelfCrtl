package com.example.self_control

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.Log
import android.provider.Settings
import android.content.Intent

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream


import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.myapp/apps"

    private val iconCache = mutableMapOf<String, ByteArray>();

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when(call.method) {
                "getInstalledAppsWithoutIcon" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        val apps = getInstalledAppsWithoutIcon()
                        withContext(Dispatchers.Main) {  // Retour sur le thread principal pour renvoyer le résultat
                            result.success(apps)
                        }
                    }
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        CoroutineScope(Dispatchers.IO).launch {
                            val icon = getAppIcon(packageName)
                            withContext(Dispatchers.Main) {
                                result.success(icon)
                            }
                        }
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is null", null)
                    }
                }
                "startBlocking" -> {
                    val packageList = call.argument<List<String>>("blockedPackages") ?: emptyList()
                    Log.d("MY_CUSTOM_TAG", "Liste de chaînes : ${packageList.joinToString(separator = ", ")}")

                    // Sauvegarde de la liste dans SharedPreferences pour utilisation ultérieure
                    saveBlockedAppsToPrefs(packageList)
                    result.success(null)
                }
                "openAccessibilitySettings" -> {
                    // Ouvre les paramètres d'accessibilité pour que l'utilisateur active le service
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Sauvegarde la liste des packages à bloquer dans SharedPreferences
    private fun saveBlockedAppsToPrefs(packageList: List<String>) {
        val prefs = getSharedPreferences("blocker_prefs", MODE_PRIVATE)
        prefs.edit().putStringSet("blocked_packages", packageList.toSet()).apply()
    }

    private fun getInstalledAppsWithoutIcon(): List<Map<String, String>> {
        val pm: PackageManager = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val appList = mutableListOf<Map<String, String>>()

        for(appInfo in packages) {
            if((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0){
                val appName = pm.getApplicationLabel(appInfo).toString()
                appList.add(
                    mapOf(
                        "name" to appName,
                        "package" to appInfo.packageName
                    )
                )
            }
        }

        return appList
    }

    private fun getAppIcon(packageName: String): ByteArray {
        iconCache[packageName]?.let { return it }  
        val pm: PackageManager = packageManager
        val iconDrawable = pm.getApplicationIcon(packageName)
        val bitmap = drawableToBitmap(iconDrawable)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        val iconBytes = stream.toByteArray()
        iconCache[packageName] = iconBytes  // Stocke dans le cache
        return iconBytes
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        return if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val width = drawable.intrinsicWidth.takeIf { it > 0 } ?: 1
            val height = drawable.intrinsicHeight.takeIf { it > 0 } ?: 1
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bitmap
        }
    }
}

