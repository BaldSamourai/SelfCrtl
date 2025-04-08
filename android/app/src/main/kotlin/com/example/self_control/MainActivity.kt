package com.example.self_control

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.myapp/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getInstalledApps") {
                val apps = getInstalledApps()
                result.success(apps)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm: PackageManager = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val appsList = mutableListOf<Map<String, Any>>()

        for (appInfo in packages) {
            if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0){
                val appName = pm.getApplicationLabel(appInfo).toString()
                val iconDrawable = pm.getApplicationIcon(appInfo.packageName)

                val bitmap = drawableToBitmap(iconDrawable)
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                val iconBytes = stream.toByteArray()

                appsList.add(
                    mapOf(
                        "name" to appName,
                        "package" to appInfo.packageName,
                        "icon" to iconBytes
                    )
                )
            }
        }

        return appsList
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










/* package com.example.self_control

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.myapp/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Erreur lors de la récupération des applications", null)
                    }
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val icon = getAppIcon(packageName)
                        if (icon != null) {
                            result.success(icon)
                        } else {
                            result.error("UNAVAILABLE", "Icône non disponible", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Argument packageName manquant", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = applicationContext.packageManager
        val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val appList = mutableListOf<Map<String, String>>()
    
        installedApps.forEach { appInfo ->
            if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0) { // Exclure les apps système
                val appName = pm.getApplicationLabel(appInfo).toString()
                val packageName = appInfo.packageName
    
                appList.add(
                    mapOf(
                        "name" to appName,
                        "package" to packageName
                    )
                )
            }
        }
        return appList
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        val pm = applicationContext.packageManager
        return try {
            val appInfo = pm.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            val iconDrawable = pm.getApplicationIcon(appInfo)
    
            val bitmap = when (iconDrawable) {
                is BitmapDrawable -> iconDrawable.bitmap
                is AdaptiveIconDrawable -> getBitmapFromAdaptiveIcon(iconDrawable)
                else -> null
            }
    
            if (bitmap != null) {
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun getBitmapFromAdaptiveIcon(icon: AdaptiveIconDrawable): Bitmap {
        val width = 128 // Largeur par défaut pour les icônes
        val height = 128 // Hauteur par défaut pour les icônes
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
    
        // Dessine l'icône adaptative sur un canvas
        icon.setBounds(0, 0, canvas.width, canvas.height)
        icon.draw(canvas)
    
        return bitmap
    }
    
    
    
}
 */

