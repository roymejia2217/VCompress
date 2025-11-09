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

# FFmpeg Kit specific rules
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.ffmpegkit.react.** { *; }

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

# FFmpeg Kit Flutter - CAUSA PRINCIPAL DEL CRASH
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.mobileffmpeg.** { *; }
-dontwarn com.arthenica.ffmpegkit.**
-dontwarn org.apache.tika.**

# FFmpeg native methods - CRÍTICO
-keepclassmembers class com.arthenica.ffmpegkit.** {
    native <methods>;
}

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

# Google Play Core rules - REMOVE for F-Droid compatibility
# These classes are only needed for Google Play Store dynamic delivery
# For F-Droid builds, remove them completely using -assumenosideeffects
-assumenosideeffects class com.google.android.play.core.** {
    public <methods>;
    public <fields>;
}
-dontwarn com.google.android.play.core.**

