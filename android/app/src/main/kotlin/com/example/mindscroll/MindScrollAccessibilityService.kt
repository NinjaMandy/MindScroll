package com.example.mindscroll

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileReader
import java.io.FileWriter
import java.util.Calendar

class MindScrollAccessibilityService : AccessibilityService() {

    private lateinit var windowManager: WindowManager
    private var floatingOverlay: View? = null
    private var blockingOverlay: View? = null
    private val handler = Handler(Looper.getMainLooper())
    private var hideOverlayRunnable: Runnable? = null

    // Tracking state
    private var lastPackageName = ""
    private var lastContentSignature = ""
    private val recentSignatures = LinkedHashSet<String>()
    private val MAX_RECENT_SIGNATURES = 10

    // Shared state data
    private var todayDate = ""
    private var dailyGoal = 50
    private var todayCounts = mutableMapOf<String, Int>()
    private var enabledPlatforms = mutableSetOf("youtube", "instagram", "facebook", "tiktok")
    private var overlayPosition = "top_right"
    private var emergencyUnlockUntil: Long = 0
    private var estimatedVideoDurationSeconds = 30

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        loadState()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        val rootNode = rootInActiveWindow ?: return

        // Sync and validate state
        loadState()
        checkDateAndResetIfNeeded()

        val platform = getPlatformFromPackage(packageName)
        if (platform == null || !enabledPlatforms.contains(platform)) {
            // Not a tracked application or disabled
            removeFloatingOverlay()
            removeBlockingOverlay()
            return
        }

        // Verify if short form is actively open on screen
        if (!isShortFormActive(platform, rootNode)) {
            removeFloatingOverlay()
            // Keep blocking overlay if limit is exceeded, in case they try to navigate around inside the app
            if (isLimitExceeded() && !isUnlocked()) {
                showBlockingOverlay()
            } else {
                removeBlockingOverlay()
            }
            return
        }

        // We are actively tracking a short form app
        if (isLimitExceeded() && !isUnlocked()) {
            removeFloatingOverlay()
            showBlockingOverlay()
            return
        } else {
            removeBlockingOverlay()
        }

        // Content Signature matching to detect new videos
        val currentSignature = extractContentSignature(platform, rootNode)
        if (currentSignature.isNotEmpty() && currentSignature != lastContentSignature) {
            if (!recentSignatures.contains(currentSignature)) {
                // Add to recent list
                recentSignatures.add(currentSignature)
                if (recentSignatures.size > MAX_RECENT_SIGNATURES) {
                    val first = recentSignatures.iterator().next()
                    recentSignatures.remove(first)
                }

                lastContentSignature = currentSignature
                incrementCount(platform)
                saveState()

                // Trigger UI Feedback
                showFloatingOverlay()
            }
        }
    }

    override fun onInterrupt() {
        // Required method
    }

    override fun onDestroy() {
        super.onDestroy()
        removeFloatingOverlay()
        removeBlockingOverlay()
    }

    private fun getPlatformFromPackage(packageName: String): String? {
        return when (packageName) {
            "com.google.android.youtube" -> "youtube"
            "com.instagram.android" -> "instagram"
            "com.facebook.katana" -> "facebook"
            "com.zhiliaoapp.musically", "com.ss.android.ugc.trill" -> "tiktok"
            else -> null
        }
    }

    private fun isShortFormActive(platform: String, rootNode: AccessibilityNodeInfo): Boolean {
        // TikTok is entirely short form scrolling
        if (platform == "tiktok") return true

        // For other apps, search the hierarchy for indicators of Reels/Shorts
        return when (platform) {
            "youtube" -> checkNodeHierarchyForKeywords(rootNode, listOf("shorts_player_view", "shorts_image_view", "Shorts"))
            "instagram" -> checkNodeHierarchyForKeywords(rootNode, listOf("reel_viewer", "reels_viewer", "clips_viewer"))
            "facebook" -> checkNodeHierarchyForKeywords(rootNode, listOf("reels_video", "reel_viewer"))
            else -> false
        }
    }

    private fun checkNodeHierarchyForKeywords(node: AccessibilityNodeInfo?, keywords: List<String>): Boolean {
        if (node == null) return false
        
        val resourceId = node.viewIdResourceName
        if (resourceId != null) {
            for (keyword in keywords) {
                if (resourceId.contains(keyword, ignoreCase = true)) {
                    return true
                }
            }
        }

        val text = node.text?.toString() ?: ""
        val contentDesc = node.contentDescription?.toString() ?: ""
        for (keyword in keywords) {
            if (text.contains(keyword, ignoreCase = true) || contentDesc.contains(keyword, ignoreCase = true)) {
                return true
            }
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (checkNodeHierarchyForKeywords(child, keywords)) {
                return true
            }
        }
        return false
    }

    private fun extractContentSignature(platform: String, rootNode: AccessibilityNodeInfo): String {
        // Extract distinct texts (like username and description) to identify the video
        val texts = mutableListOf<String>()
        collectTextNodes(rootNode, texts)
        
        // Filter out typical static buttons to avoid signature changes from layout clicks
        val filtered = texts.filter { 
            val word = it.trim().lowercase()
            word != "share" && word != "comment" && word != "comments" && 
            word != "like" && word != "likes" && word != "dislike" && 
            word != "remix" && word != "reply"
        }

        // Combine the first 3 relevant text elements to construct a signature
        return filtered.take(3).joinToString("|")
    }

    private fun collectTextNodes(node: AccessibilityNodeInfo?, list: MutableList<String>) {
        if (node == null) return
        
        if (node.text != null && node.text.toString().trim().isNotEmpty()) {
            list.add(node.text.toString())
        }

        for (i in 0 until node.childCount) {
            collectTextNodes(node.getChild(i), list)
        }
    }

    private fun getTodayDateString(): String {
        val calendar = Calendar.getInstance()
        val year = calendar.get(Calendar.YEAR)
        val month = calendar.get(Calendar.MONTH) + 1
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        return String.format("%04d-%02d-%02d", year, month, day)
    }

    private fun checkDateAndResetIfNeeded() {
        val today = getTodayDateString()
        if (today != todayDate) {
            todayDate = today
            todayCounts.clear()
            todayCounts["youtube"] = 0
            todayCounts["instagram"] = 0
            todayCounts["facebook"] = 0
            todayCounts["tiktok"] = 0
            emergencyUnlockUntil = 0
            recentSignatures.clear()
            saveState()
        }
    }

    private fun isLimitExceeded(): Boolean {
        val total = todayCounts.values.sum()
        return total >= dailyGoal
    }

    private fun isUnlocked(): Boolean {
        return System.currentTimeMillis() < emergencyUnlockUntil
    }

    private fun incrementCount(platform: String) {
        val current = todayCounts[platform] ?: 0
        todayCounts[platform] = current + 1
    }

    // Shared State management (mindscroll_state.json)
    private fun getSharedFile(): File {
        return File(filesDir, "mindscroll_state.json")
    }

    private fun loadState() {
        val file = getSharedFile()
        if (!file.exists()) {
            todayDate = getTodayDateString()
            todayCounts["youtube"] = 0
            todayCounts["instagram"] = 0
            todayCounts["facebook"] = 0
            todayCounts["tiktok"] = 0
            saveState()
            return
        }

        try {
            val jsonStr = FileReader(file).use { it.readText() }
            val json = JSONObject(jsonStr)

            todayDate = json.optString("todayDate", getTodayDateString())
            emergencyUnlockUntil = json.optLong("emergencyUnlockUntil", 0)

            val countsJson = json.optJSONObject("todayCounts")
            if (countsJson != null) {
                todayCounts["youtube"] = countsJson.optInt("youtube", 0)
                todayCounts["instagram"] = countsJson.optInt("instagram", 0)
                todayCounts["facebook"] = countsJson.optInt("facebook", 0)
                todayCounts["tiktok"] = countsJson.optInt("tiktok", 0)
            } else {
                todayCounts["youtube"] = 0
                todayCounts["instagram"] = 0
                todayCounts["facebook"] = 0
                todayCounts["tiktok"] = 0
            }

            val settingsJson = json.optJSONObject("settings")
            if (settingsJson != null) {
                dailyGoal = settingsJson.optInt("dailyGoal", 50)
                estimatedVideoDurationSeconds = settingsJson.optInt("estimatedVideoDurationSeconds", 30)
                overlayPosition = settingsJson.optString("overlayPosition", "top_right")

                val platformsArr = settingsJson.optJSONArray("enabledPlatforms")
                if (platformsArr != null) {
                    enabledPlatforms.clear()
                    for (i in 0 until platformsArr.length()) {
                        enabledPlatforms.add(platformsArr.getString(i))
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun saveState() {
        try {
            val json = JSONObject()
            json.put("todayDate", todayDate)
            json.put("emergencyUnlockUntil", emergencyUnlockUntil)

            val countsJson = JSONObject()
            countsJson.put("youtube", todayCounts["youtube"] ?: 0)
            countsJson.put("instagram", todayCounts["instagram"] ?: 0)
            countsJson.put("facebook", todayCounts["facebook"] ?: 0)
            countsJson.put("tiktok", todayCounts["tiktok"] ?: 0)
            json.put("todayCounts", countsJson)

            val settingsJson = JSONObject()
            settingsJson.put("dailyGoal", dailyGoal)
            settingsJson.put("estimatedVideoDurationSeconds", estimatedVideoDurationSeconds)
            settingsJson.put("overlayPosition", overlayPosition)

            val platformsArr = JSONArray()
            enabledPlatforms.forEach { platformsArr.put(it) }
            settingsJson.put("enabledPlatforms", platformsArr)
            json.put("settings", settingsJson)

            FileWriter(getSharedFile()).use { it.write(json.toString(2)) }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // Floating Overlay
    private fun showFloatingOverlay() {
        handler.post {
            val total = todayCounts.values.sum()
            val textContent = "📱 $total / $dailyGoal"

            if (floatingOverlay == null) {
                val context = this
                val rootLayout = LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.CENTER
                    
                    val shape = GradientDrawable().apply {
                        cornerRadius = dpToPx(16f).toFloat()
                        setColor(Color.parseColor("#4F46E5")) // Primary: Deep Indigo
                    }
                    background = shape
                    setPadding(dpToPx(16f), dpToPx(8f), dpToPx(16f), dpToPx(8f))
                }

                val textView = TextView(context).apply {
                    text = textContent
                    textColor(Color.WHITE)
                    textSize = 14f
                    typeface = android.graphics.Typeface.DEFAULT_BOLD
                }
                rootLayout.addView(textView)

                val params = WindowManager.LayoutParams().apply {
                    width = WindowManager.LayoutParams.WRAP_CONTENT
                    height = WindowManager.LayoutParams.WRAP_CONTENT
                    type = WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY
                    flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                    format = PixelFormat.TRANSLUCENT
                    gravity = getGravityFromPosition()
                    x = dpToPx(16f)
                    y = dpToPx(64f)
                }

                floatingOverlay = rootLayout
                windowManager.addView(floatingOverlay, params)
            } else {
                val textView = (floatingOverlay as LinearLayout).getChildAt(0) as TextView
                textView.text = textContent
                floatingOverlay?.visibility = View.VISIBLE
                floatingOverlay?.alpha = 1.0f
            }

            // Hide after 1.5 seconds
            hideOverlayRunnable?.let { handler.removeCallbacks(it) }
            val hideRunnable = Runnable {
                floatingOverlay?.animate()?.alpha(0.0f)?.setDuration(300)?.withEndAction {
                    floatingOverlay?.visibility = View.GONE
                }?.start()
            }
            hideOverlayRunnable = hideRunnable
            handler.postDelayed(hideRunnable, 1500)
        }
    }

    private fun removeFloatingOverlay() {
        handler.post {
            floatingOverlay?.let {
                windowManager.removeView(it)
                floatingOverlay = null
            }
        }
    }

    private fun getGravityFromPosition(): Int {
        return when (overlayPosition) {
            "top_left" -> Gravity.TOP or Gravity.START
            "top_right" -> Gravity.TOP or Gravity.END
            "bottom_left" -> Gravity.BOTTOM or Gravity.START
            "bottom_right" -> Gravity.BOTTOM or Gravity.END
            "bottom_center" -> Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            else -> Gravity.TOP or Gravity.END
        }
    }

    // Blocking Overlay
    private fun showBlockingOverlay() {
        handler.post {
            if (blockingOverlay != null) return@post

            val context = this
            val total = todayCounts.values.sum()
            val estDurationMinutes = (total * estimatedVideoDurationSeconds) / 60

            val mainLayout = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundColor(Color.parseColor("#121212")) // Dark Gray Background
                setPadding(dpToPx(24f), dpToPx(48f), dpToPx(24f), dpToPx(48f))
            }

            // Title
            val titleView = TextView(context).apply {
                text = "MindScroll"
                textColor(Color.parseColor("#4F46E5")) // Deep Indigo
                textSize = 32f
                gravity = Gravity.CENTER
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, dpToPx(8f))
            }
            mainLayout.addView(titleView)

            // Warning
            val warningView = TextView(context).apply {
                text = "Daily Limit Reached"
                textColor(Color.parseColor("#DC2626")) // Crimson
                textSize = 20f
                gravity = Gravity.CENTER
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, dpToPx(32f))
            }
            mainLayout.addView(warningView)

            // Stats
            val statsCard = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                val shape = GradientDrawable().apply {
                    cornerRadius = dpToPx(12f).toFloat()
                    setColor(Color.parseColor("#1E1E1E"))
                }
                background = shape
                setPadding(dpToPx(24f), dpToPx(20f), dpToPx(24f), dpToPx(20f))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, dpToPx(24f))
                }
            }

            val countText = TextView(context).apply {
                text = "Today's Consumption: $total / $dailyGoal"
                textColor(Color.WHITE)
                textSize = 16f
                setPadding(0, 0, 0, dpToPx(8f))
            }
            statsCard.addView(countText)

            val timeText = TextView(context).apply {
                text = "Estimated Scroll Time: $estDurationMinutes mins"
                textColor(Color.parseColor("#9CA3AF"))
                textSize = 14f
            }
            statsCard.addView(timeText)

            mainLayout.addView(statsCard)

            // Encouragement message
            val encourageText = TextView(context).apply {
                text = "Take a moment to pause. Mindfulness is choosing what matters over what is next."
                textColor(Color.parseColor("#9CA3AF"))
                textSize = 15f
                gravity = Gravity.CENTER
                setPadding(dpToPx(8f), 0, dpToPx(8f), dpToPx(48f))
            }
            mainLayout.addView(encourageText)

            // Close App Button
            val closeBtn = Button(context).apply {
                text = "Close Application"
                val shape = GradientDrawable().apply {
                    cornerRadius = dpToPx(8f).toFloat()
                    setColor(Color.parseColor("#DC2626")) // Crimson
                }
                background = shape
                textColor(Color.WHITE)
                textSize = 16f
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, dpToPx(12f), 0, dpToPx(12f))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, dpToPx(16f))
                }
                setOnClickListener {
                    performGlobalAction(GLOBAL_ACTION_HOME)
                    removeBlockingOverlay()
                }
            }
            mainLayout.addView(closeBtn)

            // Emergency Unlock Dropdown Actions
            val unlockContainer = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            }

            fun createUnlockButton(label: String, durationMinutes: Int) {
                val btn = Button(context).apply {
                    text = label
                    val shape = GradientDrawable().apply {
                        cornerRadius = dpToPx(6f).toFloat()
                        setColor(Color.parseColor("#1E1E1E"))
                        setStroke(dpToPx(1f), Color.parseColor("#4F46E5"))
                    }
                    background = shape
                    textColor(Color.parseColor("#4F46E5"))
                    textSize = 12f
                    layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                        setMargins(dpToPx(4f), 0, dpToPx(4f), 0)
                    }
                    setOnClickListener {
                        unlockService(durationMinutes)
                    }
                }
                unlockContainer.addView(btn)
            }

            createUnlockButton("15 Min", 15)
            createUnlockButton("30 Min", 30)
            createUnlockButton("1 Hr", 60)

            mainLayout.addView(unlockContainer)

            val params = WindowManager.LayoutParams().apply {
                width = WindowManager.LayoutParams.MATCH_PARENT
                height = WindowManager.LayoutParams.MATCH_PARENT
                type = WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY
                flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_FULLSCREEN
                format = PixelFormat.TRANSLUCENT
                gravity = Gravity.CENTER
            }

            blockingOverlay = mainLayout
            windowManager.addView(blockingOverlay, params)
        }
    }

    private fun unlockService(minutes: Int) {
        val durationMs = minutes * 60 * 1000L
        emergencyUnlockUntil = System.currentTimeMillis() + durationMs
        
        // Record unlock in state JSON
        recordUnlockEvent(minutes)
        saveState()
        removeBlockingOverlay()
    }

    private fun recordUnlockEvent(durationMinutes: Int) {
        val file = getSharedFile()
        try {
            val jsonStr = FileReader(file).use { it.readText() }
            val json = JSONObject(jsonStr)
            
            val unlockHistory = json.optJSONArray("unlockHistory") ?: JSONArray()
            val newRecord = JSONObject().apply {
                put("timestamp", System.currentTimeMillis())
                put("durationMinutes", durationMinutes)
            }
            unlockHistory.put(newRecord)
            json.put("unlockHistory", unlockHistory)
            
            FileWriter(file).use { it.write(json.toString(2)) }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun removeBlockingOverlay() {
        handler.post {
            blockingOverlay?.let {
                windowManager.removeView(it)
                blockingOverlay = null
            }
        }
    }

    // Extensions & Helpers
    private fun dpToPx(dp: Float): Int {
        val density = resources.displayMetrics.density
        return (dp * density + 0.5f).toInt()
    }

    private fun TextView.textColor(color: Int) {
        this.setTextColor(color)
    }
}
