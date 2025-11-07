package com.rjmejia.vcompressor.plugins

import android.content.ContentUris
import android.content.Context
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Plugin para resolver URIs de MediaStore desde rutas de archivo
 * SOLID: Single Responsibility - solo resuelve URIs de MediaStore
 * DRY: Centraliza la lógica de consulta de MediaStore
 */
class MediaStoreUriResolverPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "media_store_uri_resolver")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "resolveUriFromPath" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    resolveUriFromPath(filePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "filePath is required", null)
                }
            }
            "resolvePathFromUri" -> {
                val uri = call.argument<String>("uri")
                if (uri != null) {
                    resolvePathFromUri(uri, result)
                } else {
                    result.error("INVALID_ARGUMENT", "uri is required", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Resuelve un URI de MediaStore desde la ruta de un archivo
     * Consulta MediaStore por DISPLAY_NAME y RELATIVE_PATH según la guía oficial
     */
    private fun resolveUriFromPath(filePath: String, result: Result) {
        try {
            val fileName = filePath.substringAfterLast("/")
            val relativePath = getRelativePathFromAbsolutePath(filePath)
            
            if (relativePath == null) {
                result.success(null)
                return
            }

            val projection = arrayOf(
                MediaStore.Video.Media._ID,
                MediaStore.Video.Media.DISPLAY_NAME,
                MediaStore.Video.Media.RELATIVE_PATH
            )
            
            val selection = "${MediaStore.Video.Media.DISPLAY_NAME}=? AND ${MediaStore.Video.Media.RELATIVE_PATH} LIKE ?"
            val selectionArgs = arrayOf(fileName, "$relativePath%")
            
            val collection = MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            
            context.contentResolver.query(collection, projection, selection, selectionArgs, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID))
                    val uri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    result.success(uri.toString())
                } else {
                    result.success(null)
                }
            } ?: run {
                result.success(null)
            }
        } catch (e: Exception) {
            result.error("RESOLVE_ERROR", "Error resolving URI: ${e.message}", null)
        }
    }

    /**
     * Resuelve la ruta original de un archivo desde un URI de MediaStore
     * Implementa el método moderno para Android 11+ según documentación oficial
     */
    private fun resolvePathFromUri(uriString: String, result: Result) {
        try {
            val uri = android.net.Uri.parse(uriString)
            
            // Convertir Document URI a MediaStore URI si es necesario
            val mediaStoreUri = convertDocumentUriToMediaStoreUri(uri)
            
            // Para Android 10+ usar Content URI directamente (no DATA column)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                // Verificar que el archivo existe usando ParcelFileDescriptor
                try {
                    context.contentResolver.openFileDescriptor(mediaStoreUri, "r")?.use { pfd ->
                        // Si podemos abrir el archivo, construir la ruta usando RELATIVE_PATH
                        val projection = arrayOf(
                            MediaStore.Video.Media.DISPLAY_NAME,
                            MediaStore.Video.Media.RELATIVE_PATH
                        )
                        
                        context.contentResolver.query(mediaStoreUri, projection, null, null, null)?.use { cursor ->
                            if (cursor.moveToFirst()) {
                                val displayName = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME))
                                val relativePath = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.RELATIVE_PATH))
                                
                                if (displayName != null && relativePath != null) {
                                    // Construir ruta completa para Android 11+
                                    val fullPath = "/storage/emulated/0/$relativePath$displayName"
                                    result.success(fullPath)
                                } else {
                                    result.success(null)
                                }
                            } else {
                                result.success(null)
                            }
                        } ?: run {
                            result.success(null)
                        }
                    }
                } catch (e: Exception) {
                    result.error("FILE_ACCESS_ERROR", "Cannot access file: ${e.message}", null)
                }
            } else {
                // Android 9 y anteriores: usar DATA column (deprecada pero funcional)
                val projection = arrayOf(MediaStore.Video.Media.DATA)
                context.contentResolver.query(mediaStoreUri, projection, null, null, null)?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val dataIndex = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                        val data = cursor.getString(dataIndex)
                        result.success(data)
                    } else {
                        result.success(null)
                    }
                } ?: run {
                    result.success(null)
                }
            }
        } catch (e: Exception) {
            result.error("RESOLVE_ERROR", "Error resolving path: ${e.message}", null)
        }
    }

    /**
     * Convierte Document URI a MediaStore URI
     * Maneja URIs como: content://com.android.providers.media.documents/document/video%3A1000159466
     */
    private fun convertDocumentUriToMediaStoreUri(uri: android.net.Uri): android.net.Uri {
        if (android.provider.DocumentsContract.isDocumentUri(context, uri)) {
            when (uri.authority) {
                "com.android.providers.media.documents" -> {
                    val docId = android.provider.DocumentsContract.getDocumentId(uri)
                    val split = docId.split(":")
                    val type = split[0]
                    val id = split[1]
                    
                    val contentUri = when (type) {
                        "video" -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                        "image" -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                        "audio" -> MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
                        else -> return uri
                    }
                    
                    return android.content.ContentUris.withAppendedId(contentUri, id.toLong())
                }
            }
        }
        return uri
    }

    /**
     * Extrae el RELATIVE_PATH desde una ruta absoluta
     * DRY: Utilidad para mapear rutas a RELATIVE_PATH de MediaStore
     */
    private fun getRelativePathFromAbsolutePath(filePath: String): String? {
        return when {
            filePath.contains("/DCIM/Camera/") -> "DCIM/Camera/"
            filePath.contains("/DCIM/Restored/") -> "DCIM/Restored/"
            filePath.contains("/DCIM/") -> "DCIM/"
            filePath.contains("/Pictures/") -> "Pictures/"
            filePath.contains("/Movies/") -> "Movies/"
            filePath.contains("/Android/media/") -> {
                // Extraer la parte después de /Android/media/
                val parts = filePath.split("/Android/media/")
                if (parts.size > 1) {
                    "Android/media/${parts[1].substringBefore("/")}/"
                } else {
                    null
                }
            }
            else -> null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

