package com.example.self_control

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppBlockerService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // On ne réagit qu'aux changements d'état de la fenêtre
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        // Récupère le nom du package de la fenêtre actuelle
        val currentPackage = event.packageName?.toString() ?: return

        // Récupère les packages bloqués depuis SharedPreferences
        val prefs = getSharedPreferences("blocker_prefs", MODE_PRIVATE)
        val blockedPackages = prefs.getStringSet("blocked_packages", setOf()) ?: setOf()

        // Si le package courant est dans la liste, on effectue l'action de blocage
        if (blockedPackages.contains(currentPackage)) {
            Log.d("AppBlockerService", "Blocage de l'application: $currentPackage")
            performGlobalAction(GLOBAL_ACTION_BACK)
        }
    }

    override fun onInterrupt() {
        // Optionnel : gérer l'interruption du service si nécessaire
        Log.d("AppBlockerService", "Service interrompu")
    }
}
