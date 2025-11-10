# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# CRÍTICO: Mantener GeneratedPluginRegistrant para todos los plugins
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# CRÍTICO: Mantener método registerWith para GeneratedPluginRegistrant
-keepclassmembers class io.flutter.plugins.GeneratedPluginRegistrant {
    public static void registerWith(io.flutter.embedding.engine.FlutterEngine);
}

# FFmpeg Kit specific rules - CRÍTICO para EventChannel en release
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.ffmpegkit.react.** { *; }

# FFmpeg Kit Flutter Plugin - NOMBRE CORRECTO: com.antonkarpenko.ffmpegkit
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.FFmpegKitFlutterPlugin { *; }
-keep class com.antonkarpenko.ffmpegkit.FFmpegKitFlutterPlugin$* { *; }

# Keep all FlutterPlugin implementations
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keepclassmembers class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keepclassmembers class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# FFmpeg Kit Flutter event handler methods - CRÍTICO
-keepclassmembers class com.antonkarpenko.ffmpegkit.FFmpegKitFlutterPlugin {
    public void onAttachedToEngine(io.flutter.embedding.engine.FlutterEngine);
    public void onDetachedFromEngine(io.flutter.embedding.engine.FlutterEngine);
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
    public void onEventChannel(io.flutter.plugin.common.EventChannel, io.flutter.plugin.common.EventChannel$EventSink);
}

# Keep all listener/callback interfaces for FFmpeg
-keep interface com.arthenica.ffmpegkit.** { *; }
-keep class * implements com.arthenica.ffmpegkit.FFmpegSessionCompleteCallback { *; }
-keep class * implements com.arthenica.ffmpegkit.LogCallback { *; }
-keep class * implements com.arthenica.ffmpegkit.StatisticsCallback { *; }

# FFmpeg Kit native libraries
-keepclasseswithmembernames class com.arthenica.ffmpegkit.** {
    native <methods>;
}

-keepclasseswithmembernames class com.antonkarpenko.ffmpegkit.** {
    native <methods>;
}

# file_picker package rules
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# permission_handler package rules - CRÍTICO para release builds
-keep class com.baseflow.permissionhandler.** { *; }
-keep class io.flutter.plugins.permissions.** { *; }

# MethodChannel específico para permission_handler
-keep class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keep class * extends io.flutter.plugin.common.MethodChannel$Result { *; }

# Plugin registrar para permission_handler
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Mantener todas las clases que implementan MethodCallHandler
-keep class * implements io.flutter.plugin.common.MethodCallHandler { *; }

# Mantener clases de permisos específicas
-keep class com.baseflow.permissionhandler.PermissionHandlerPlugin { *; }
-keep class com.baseflow.permissionhandler.PermissionManager { *; }
-keep class com.baseflow.permissionhandler.PermissionUtils { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# ===============================================
# SOLUCIÓN KISS: Solo lo esencial para evitar crashes
# ===============================================

# FFmpeg Kit Flutter - ProGuard rules para minificación con dynamic invocation
# Patrón wildcard para máxima compatibilidad con actualizaciones futuras
-keepclassmembers class com.arthenica.ffmpegkit.** {
    public *** get*();
    public void set*(***);
    public boolean is*();
    public static ** valueOf(java.lang.String);
    public static ** values();
    public int getState();
    public java.lang.Integer getReturnCode();
    public java.lang.String getAllLogsAsString();
    native <methods>;
}

-dontwarn com.arthenica.ffmpegkit.**
-dontwarn org.apache.tika.**

# Flutter Engine - BASE REQUERIDA
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# MethodChannel handlers - CRÍTICO
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keepclassmembers class * {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
}

# Video Thumbnail Plugin
-keep class vn.hunghd.flutter.plugins.videothumbnail.** { *; }
-keepclassmembers class vn.hunghd.flutter.plugins.videothumbnail.** {
    native <methods>;
}

# File Picker Plugin
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Path Provider Plugin
-keep class io.flutter.plugins.pathprovider.** { *; }

# Permission Handler Plugin
-keep class com.baseflow.permissionhandler.** { *; }

# CRÍTICO: MediaStore y ContentResolver - CAUSA DEL CRASH
-keep class android.provider.MediaStore** { *; }
-keep class android.content.ContentResolver { *; }
-keep class android.content.ContentUris { *; }
-keep class android.net.Uri { *; }
-keep class android.database.Cursor { *; }

# CRÍTICO: Context y Activity para MediaStore
-keep class android.content.Context { *; }
-keep class android.app.Activity { *; }
-keep class android.content.ContextWrapper { *; }

# CRÍTICO: Custom native plugins para MediaStore y FileReplacement
# Estos plugins son registrados en MainActivity y deben preservarse completamente
-keep class com.rjmejia.vcompressor.plugins.** { *; }
-keep class com.rjmejia.vcompressor.MainActivity { *; }

# Asegurar que los métodos de los plugins no sean obfuscados
-keepclassmembers class com.rjmejia.vcompressor.plugins.MediaStoreUriResolverPlugin {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
    public void onAttachedToEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
    public void onDetachedFromEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
    private void resolvePathFromUri(java.lang.String, io.flutter.plugin.common.MethodChannel$Result);
    private void resolveUriFromPath(java.lang.String, io.flutter.plugin.common.MethodChannel$Result);
}

-keepclassmembers class com.rjmejia.vcompressor.plugins.FileReplacementPlugin {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
    public void onAttachedToEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
    public void onDetachedFromEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
}

# ContentResolver y MediaStore - CRÍTICO para file selection
-keep class android.content.ContentResolver { *; }
-keep class android.provider.MediaStore** { *; }
-keep class android.provider.DocumentsContract { *; }

# Google Play Core rules - handled by F-Droid scandelete directive
# See fdroiddata metadata for F-Droid specific handling

