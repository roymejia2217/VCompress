package com.rjmejia.vcompressor.plugins

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.IntentSender
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.app.RecoverableSecurityException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

/**
 * Plugin para reemplazar archivos por URI usando MediaStore/SAF
 * SOLID: Single Responsibility - solo maneja reemplazo de archivos
 * DRY: Centraliza la lógica de reemplazo con ContentResolver
 */
class FileReplacementPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    companion object {
        const val EDIT_REQUEST_CODE = 1007
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "file_replacement")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "replaceAtUri" -> {
                val uriString = call.argument<String>("uri")
                val tempPath = call.argument<String>("tempPath")
                
                if (uriString != null && tempPath != null) {
                    replaceAtUri(Uri.parse(uriString), tempPath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "uri and tempPath are required", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Reemplaza un archivo usando su URI de MediaStore
     * Usa ContentResolver.openFileDescriptor(uri, "rwt") para truncar y sobrescribir
     */
    private fun replaceAtUri(uri: Uri, tempPath: String, result: Result) {
        try {
            val tempFile = File(tempPath)
            if (!tempFile.exists()) {
                result.error("FILE_NOT_FOUND", "Temporary file not found: $tempPath", null)
                return
            }

            val contentResolver = context.contentResolver
            
            // Intentar abrir el URI en modo "rwt" para truncar y sobrescribir
            contentResolver.openFileDescriptor(uri, "rwt")?.use { pfd ->
                FileInputStream(tempFile).use { input ->
                    FileOutputStream(pfd.fileDescriptor).use { output ->
                        input.copyTo(output)
                        output.flush()
                    }
                }
            }
            
            result.success(null)
        } catch (e: SecurityException) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val rse = e as? RecoverableSecurityException
                if (rse != null) {
                    // Solicitar consentimiento del usuario
                    val intentSender = rse.userAction.actionIntent.intentSender
                    activity?.let { act ->
                        try {
                            act.startIntentSenderForResult(
                                intentSender,
                                EDIT_REQUEST_CODE,
                                null,
                                0,
                                0,
                                0,
                                null
                            )
                            result.error("CONSENT_REQUIRED", "User consent required for file replacement", null)
                        } catch (e: Exception) {
                            result.error("CONSENT_ERROR", "Error requesting consent: ${e.message}", null)
                        }
                    } ?: run {
                        result.error("NO_ACTIVITY", "No activity available to request consent", null)
                    }
                } else {
                    result.error("SECURITY_ERROR", "Security error: ${e.message}", null)
                }
            } else {
                result.error("SECURITY_ERROR", "Security error: ${e.message}", null)
            }
        } catch (e: Exception) {
            result.error("REPLACE_FAILED", "Error replacing file: ${e.message}", null)
        }
    }

    /**
     * Solicita consentimiento de escritura para un URI específico
     * Usa MediaStore.createWriteRequest para Android 11+
     */
    fun requestWritePermission(uri: Uri, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val contentResolver = context.contentResolver
                val uris = listOf(uri)
                val pendingIntent = MediaStore.createWriteRequest(contentResolver, uris)
                
                activity?.let { act ->
                    act.startIntentSenderForResult(
                        pendingIntent.intentSender,
                        EDIT_REQUEST_CODE,
                        null,
                        0,
                        0,
                        0,
                        null
                    )
                    result.success(null)
                } ?: run {
                    result.error("NO_ACTIVITY", "No activity available to request permission", null)
                }
            } catch (e: Exception) {
                result.error("PERMISSION_ERROR", "Error requesting write permission: ${e.message}", null)
            }
        } else {
            result.error("UNSUPPORTED_VERSION", "Write permission request requires Android 11+", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
