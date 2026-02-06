package com.rjmejia.vcompressor

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.content.Context
import android.media.MediaCodecList
import android.media.MediaScannerConnection
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.rjmejia.vcompressor/hardware_detection"
    private val SCAN_CHANNEL = "com.rjmejia.vcompressor/media_scan"

    // Scope for background tasks (IO/CPU intensive)
    private val ioScope = CoroutineScope(Dispatchers.IO)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Native plugin registration
        flutterEngine.plugins.add(com.rjmejia.vcompressor.plugins.MediaStoreUriResolverPlugin())
        flutterEngine.plugins.add(com.rjmejia.vcompressor.plugins.FileReplacementPlugin())
        
        // Hardware Detection Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getHardwareInfo" -> {
                    ioScope.launch {
                        try {
                            val info = getHardwareInfoSafety()
                            withContext(Dispatchers.Main) {
                                result.success(info)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("HARDWARE_DETECTION_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "getSupportedCodecs" -> {
                    ioScope.launch {
                        try {
                            val codecs = getSupportedCodecsSafety()
                            withContext(Dispatchers.Main) {
                                result.success(codecs)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("CODEC_DETECTION_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "getAndroidVersion" -> {
                    result.success(Build.VERSION.SDK_INT)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Media Scan Channel (Lightweight, can run on main thread wrapper but actual scan is async)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCAN_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    // MediaScannerConnection.scanFile is already async internally
                    MediaScannerConnection.scanFile(this, arrayOf(path), null) { _, _ -> }
                    result.success(null)
                } else {
                    result.error("INVALID_PATH", "Path cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    @SuppressLint("HardwareIds")
    private fun getHardwareInfoSafety(): Map<String, Any> {
        val info = mutableMapOf<String, Any>()
        
        // Basic Device Info
        info["manufacturer"] = Build.MANUFACTURER ?: "Unknown"
        info["model"] = Build.MODEL ?: "Unknown"
        info["brand"] = Build.BRAND ?: "Unknown"
        info["product"] = Build.PRODUCT ?: "Unknown"
        info["device"] = Build.DEVICE ?: "Unknown"
        info["board"] = Build.BOARD ?: "Unknown"
        info["hardware"] = Build.HARDWARE ?: "Unknown"
        
        // CPU Info
        info["cpuCores"] = Runtime.getRuntime().availableProcessors()
        info["cpuArchitecture"] = System.getProperty("os.arch") ?: "unknown"
        
        // Processor Type (SoC) - Improved Logic
        info["processorType"] = detectProcessorType()
        
        // GPU Info - Best Effort
        info["gpuInfo"] = detectGPUInfo()
        
        // Memory Info - CORRECTED to use ActivityManager
        val memoryInfo = getRealMemoryInfo()
        info["totalMemory"] = memoryInfo["total"] ?: 0L
        info["availableMemory"] = memoryInfo["available"] ?: 0L
        
        return info
    }

    private fun detectProcessorType(): String {
        // 1. Try Android 12+ SoC API
        if (Build.VERSION.SDK_INT >= 31) {
            val soc = Build.SOC_MANUFACTURER
            if (!soc.isNullOrEmpty() && soc != "unknown") {
                 val model = Build.SOC_MODEL ?: ""
                 return "$soc $model".trim()
            }
        }

        // 2. Fallback: Parse /proc/cpuinfo (Legacy)
        val cpuInfo = getCPUInfo()
        if (cpuInfo.isNotEmpty()) {
            return when {
                cpuInfo.contains("exynos", ignoreCase = true) -> "Samsung Exynos"
                cpuInfo.contains("snapdragon", ignoreCase = true) || 
                cpuInfo.contains("qualcomm", ignoreCase = true) -> "Qualcomm Snapdragon"
                cpuInfo.contains("mediatek", ignoreCase = true) || 
                cpuInfo.contains("mtk", ignoreCase = true) -> "MediaTek"
                cpuInfo.contains("unisoc", ignoreCase = true) || 
                cpuInfo.contains("spreadtrum", ignoreCase = true) -> "Unisoc"
                cpuInfo.contains("kirin", ignoreCase = true) || 
                cpuInfo.contains("hisilicon", ignoreCase = true) -> "HiSilicon Kirin"
                cpuInfo.contains("tensor", ignoreCase = true) ||
                cpuInfo.contains("google", ignoreCase = true) -> "Google Tensor"
                else -> "Unknown (Generic)"
            }
        }

        // 3. Fallback: Build.HARDWARE
        val hardware = Build.HARDWARE.lowercase()
        return when {
            hardware.contains("exynos") -> "Samsung Exynos"
            hardware.contains("qcom") || hardware.contains("msm") -> "Qualcomm Snapdragon"
            hardware.contains("mt") -> "MediaTek"
            hardware.contains("kirin") -> "HiSilicon Kirin"
            else -> hardware
        }
    }

    private fun getCPUInfo(): String {
        return try {
            val file = File("/proc/cpuinfo")
            if (!file.exists() || !file.canRead()) return ""
            
            BufferedReader(FileReader(file)).use { reader ->
                var line: String?
                val sb = StringBuilder()
                while (reader.readLine().also { line = it } != null) {
                    if (line?.contains("Hardware", ignoreCase = true) == true || 
                        line?.contains("model name", ignoreCase = true) == true ||
                        line?.contains("Processor", ignoreCase = true) == true) {
                        sb.append(line).append("\n")
                    }
                }
                sb.toString()
            }
        } catch (e: Exception) {
            ""
        }
    }

    private fun detectGPUInfo(): String {
        // 1. Try reading system files (Legacy/Root)
        val gpuFromFiles = getGPUFromSystemFiles()
        if (gpuFromFiles.isNotEmpty()) return gpuFromFiles

        // 2. Fallback: Infer from Chipset/Board
        val hardware = (Build.HARDWARE + " " + Build.BOARD).lowercase()
        return when {
            hardware.contains("exynos") -> "Mali (Exynos)"
            hardware.contains("snapdragon") || hardware.contains("qcom") -> "Adreno (Snapdragon)"
            hardware.contains("mediatek") || hardware.contains("mt") -> "Mali/PowerVR (MediaTek)"
            hardware.contains("unisoc") || hardware.contains("spreadtrum") -> "Mali/PowerVR (Unisoc)"
            hardware.contains("kirin") -> "Mali (Kirin)"
            else -> "Unknown GPU"
        }
    }

    private fun getGPUFromSystemFiles(): String {
        val gpuFiles = listOf(
            "/sys/class/kgsl/kgsl-3d0/gpu_model",
            "/sys/class/kgsl/kgsl-3d0/gpu_busy_percentage",
            "/proc/gpuinfo"
        )
        
        for (filePath in gpuFiles) {
            try {
                val file = File(filePath)
                if (file.exists() && file.canRead()) {
                    val content = file.readText().trim()
                    if (content.isNotEmpty()) return content
                }
            } catch (e: Exception) {
                // Ignore and try next
            }
        }
        return ""
    }

    private fun getRealMemoryInfo(): Map<String, Long> {
        return try {
            val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            actManager.getMemoryInfo(memInfo)
            
            mapOf(
                "total" to memInfo.totalMem,
                "available" to memInfo.availMem
            )
        } catch (e: Exception) {
            // Fallback to Runtime (incorrect but better than crash)
            val runtime = Runtime.getRuntime()
            mapOf(
                "total" to runtime.totalMemory(),
                "available" to runtime.freeMemory()
            )
        }
    }

    private fun getSupportedCodecsSafety(): Map<String, Any> {
        val codecs = mutableMapOf<String, Any>()
        
        try {
            val codecList = MediaCodecList(MediaCodecList.REGULAR_CODECS)
            val codecInfos = codecList.codecInfos
            
            val h264Encoders = mutableListOf<String>()
            val h265Encoders = mutableListOf<String>()
            val h264Decoders = mutableListOf<String>()
            val h265Decoders = mutableListOf<String>()
            
            for (codecInfo in codecInfos) {
                if (codecInfo.isEncoder) {
                    for (mimeType in codecInfo.supportedTypes) {
                        when (mimeType.lowercase()) {
                            "video/avc", "video/h264" -> h264Encoders.add(codecInfo.name)
                            "video/hevc", "video/h265" -> h265Encoders.add(codecInfo.name)
                        }
                    }
                } else {
                    for (mimeType in codecInfo.supportedTypes) {
                        when (mimeType.lowercase()) {
                            "video/avc", "video/h264" -> h264Decoders.add(codecInfo.name)
                            "video/hevc", "video/h265" -> h265Decoders.add(codecInfo.name)
                        }
                    }
                }
            }
            
            codecs["h264Encoders"] = h264Encoders
            codecs["h265Encoders"] = h265Encoders
            codecs["h264Decoders"] = h264Decoders
            codecs["h265Decoders"] = h265Decoders
            codecs["hasH264HwEncoder"] = h264Encoders.isNotEmpty()
            codecs["hasH265HwEncoder"] = h265Encoders.isNotEmpty()
            
        } catch (e: Exception) {
            // Return empty if failure
            codecs["h264Encoders"] = emptyList<String>()
            codecs["h265Encoders"] = emptyList<String>()
            codecs["h264Decoders"] = emptyList<String>()
            codecs["h265Decoders"] = emptyList<String>()
            codecs["hasH264HwEncoder"] = false
            codecs["hasH265HwEncoder"] = false
        }
        
        return codecs
    }
}