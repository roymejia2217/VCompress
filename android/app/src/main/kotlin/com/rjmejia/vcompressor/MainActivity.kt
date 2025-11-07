package com.rjmejia.vcompressor

import android.annotation.SuppressLint
import android.content.Context
import android.media.MediaCodecList
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.rjmejia.vcompressor/hardware_detection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // CRÍTICO: Registrar todos los plugins manualmente para release builds
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Registrar plugins nativos
        flutterEngine.plugins.add(com.rjmejia.vcompressor.plugins.MediaStoreUriResolverPlugin())
        flutterEngine.plugins.add(com.rjmejia.vcompressor.plugins.FileReplacementPlugin())
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getHardwareInfo" -> {
                    try {
                        val hardwareInfo = getHardwareInfo()
                        result.success(hardwareInfo)
                    } catch (e: Exception) {
                        result.error("HARDWARE_DETECTION_ERROR", e.message, null)
                    }
                }
                "getSupportedCodecs" -> {
                    try {
                        val codecs = getSupportedCodecs()
                        result.success(codecs)
                    } catch (e: Exception) {
                        result.error("CODEC_DETECTION_ERROR", e.message, null)
                    }
                }
                "getAndroidVersion" -> {
                    try {
                        result.success(Build.VERSION.SDK_INT)
                    } catch (e: Exception) {
                        result.error("VERSION_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    @SuppressLint("HardwareIds")
    private fun getHardwareInfo(): Map<String, Any> {
        val info = mutableMapOf<String, Any>()
        
        // Información básica del dispositivo
        info["manufacturer"] = Build.MANUFACTURER
        info["model"] = Build.MODEL
        info["brand"] = Build.BRAND
        info["product"] = Build.PRODUCT
        info["device"] = Build.DEVICE
        info["board"] = Build.BOARD
        info["hardware"] = Build.HARDWARE
        
        // Información del procesador
        info["cpuCores"] = Runtime.getRuntime().availableProcessors()
        info["cpuArchitecture"] = System.getProperty("os.arch") ?: "unknown"
        
        // Detectar tipo de procesador
        val processorType = detectProcessorType()
        info["processorType"] = processorType
        
        // Información de GPU
        val gpuInfo = detectGPUInfo()
        info["gpuInfo"] = gpuInfo
        
        // Información de memoria
        val memoryInfo = getMemoryInfo()
        info["totalMemory"] = memoryInfo["total"] ?: 0L
        info["availableMemory"] = memoryInfo["available"] ?: 0L
        
        return info
    }

    private fun detectProcessorType(): String {
        val cpuInfo = getCPUInfo()
        
        return when {
            cpuInfo.contains("exynos", ignoreCase = true) -> "exynos"
            cpuInfo.contains("snapdragon", ignoreCase = true) || 
            cpuInfo.contains("qualcomm", ignoreCase = true) -> "snapdragon"
            cpuInfo.contains("mediatek", ignoreCase = true) || 
            cpuInfo.contains("mtk", ignoreCase = true) -> "mediatek"
            cpuInfo.contains("unisoc", ignoreCase = true) || 
            cpuInfo.contains("spreadtrum", ignoreCase = true) -> "unisoc"
            else -> "unknown"
        }
    }

    private fun getCPUInfo(): String {
        return try {
            val reader = BufferedReader(FileReader("/proc/cpuinfo"))
            val cpuInfo = StringBuilder()
            var line: String?
            
            while (reader.readLine().also { line = it } != null) {
                if (line?.startsWith("Hardware") == true || 
                    line?.startsWith("model name") == true ||
                    line?.startsWith("Processor") == true) {
                    cpuInfo.append(line).append("\n")
                }
            }
            reader.close()
            cpuInfo.toString()
        } catch (e: IOException) {
            "unknown"
        }
    }

    private fun detectGPUInfo(): String {
        return try {
            // Intentar obtener información de GPU desde archivos del sistema
            val gpuInfo = getGPUFromSystemFiles()
            if (gpuInfo.isNotEmpty()) {
                return gpuInfo
            }

            // Fallback: usar información del hardware (detectar familia genérica)
            val hardware = Build.HARDWARE.lowercase()
            val board = Build.BOARD.lowercase()

            when {
                hardware.contains("exynos") || board.contains("exynos") -> "Mali (Exynos)"
                hardware.contains("snapdragon") || board.contains("snapdragon") -> "Adreno (Snapdragon)"
                hardware.contains("mediatek") || board.contains("mediatek") -> "Mali (MediaTek)"
                hardware.contains("unisoc") || board.contains("unisoc") -> "Mali (UniSoC)"
                else -> "Unknown GPU"
            }
        } catch (e: Exception) {
            "Unknown GPU"
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
                if (file.exists()) {
                    val reader = BufferedReader(FileReader(file))
                    val content = reader.readText().trim()
                    reader.close()
                    if (content.isNotEmpty()) {
                        return content
                    }
                }
            } catch (e: Exception) {
                // Continuar con el siguiente archivo
            }
        }
        return ""
    }

    private fun getMemoryInfo(): Map<String, Long> {
        val runtime = Runtime.getRuntime()
        val totalMemory = runtime.totalMemory()
        val freeMemory = runtime.freeMemory()
        val availableMemory = freeMemory + (runtime.maxMemory() - totalMemory)
        
        return mapOf(
            "total" to totalMemory,
            "available" to availableMemory
        )
    }

    private fun getSupportedCodecs(): Map<String, Any> {
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
            // Fallback a valores por defecto
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
