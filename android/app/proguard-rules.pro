# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Flutter Official Rules (Minimal)
-dontwarn io.flutter.plugin.**
-dontwarn android.**
-if class * implements io.flutter.embedding.engine.plugins.FlutterPlugin
-keep,allowshrinking,allowobfuscation class <1>

# FFmpeg Kit - Essential Exceptions
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }

-keepclasseswithmembernames class com.arthenica.ffmpegkit.** {
    native <methods>;
}

-keepclasseswithmembernames class com.antonkarpenko.ffmpegkit.** {
    native <methods>;
}

-keepclassmembers class com.arthenica.ffmpegkit.** {
    public *** get*();
    public void set*(***);
    public boolean is*();
    public static ** valueOf(java.lang.String);
    public static ** values();
    public int getState();
    public java.lang.Integer getReturnCode();
    public java.lang.String getAllLogsAsString();
}

# VCompressor Custom Plugins
-keep class com.rjmejia.vcompressor.plugins.** { *; }
-keep class com.rjmejia.vcompressor.MainActivity { *; }

-keepclassmembers class com.rjmejia.vcompressor.plugins.MediaStoreUriResolverPlugin {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
    public void onAttachedToEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
    public void onDetachedFromEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
}

-keepclassmembers class com.rjmejia.vcompressor.plugins.FileReplacementPlugin {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
    public void onAttachedToEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
    public void onDetachedFromEngine(io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding);
}

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
