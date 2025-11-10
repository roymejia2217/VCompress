#!/bin/bash
set -e

echo "🧹 Removing Google Play dependencies..."

# 1. Limpia pubspec.yaml
sed -i '/google_mobile_ads/d' pubspec.yaml
sed -i '/firebase/d' pubspec.yaml

# 2. Limpia android/app/build.gradle.kts
sed -i '/com.google.gms/d' android/app/build.gradle.kts
sed -i '/com.google.firebase/d' android/app/build.gradle.kts

# 3. CRÍTICO: Remueve Play Core de ffmpeg_kit después de pub get
# Esto debe ejecutarse DESPUÉS de flutter pub get
cleanup_ffmpeg() {
    if [ -d ".pub-cache/hosted/pub.dev/ffmpeg_kit_flutter_new-3.2.0" ]; then
        echo "🔧 Cleaning Play Core from ffmpeg_kit..."
        
        # Remueve imports de Play Core
        find .pub-cache/hosted/pub.dev/ffmpeg_kit_flutter_new-3.2.0 \
            -name "*.java" -o -name "*.kt" | \
            xargs sed -i '/import com\.google\.android\.play/d'
        
        # Remueve referencias a Play Core en código
        find .pub-cache/hosted/pub.dev/ffmpeg_kit_flutter_new-3.2.0 \
            -name "*.java" -o -name "*.kt" | \
            xargs sed -i 's/SplitInstall[A-Za-z]*//g'
        
        # Limpia build.gradle de ffmpeg_kit
        sed -i '/com.google.android.play/d' \
            .pub-cache/hosted/pub.dev/ffmpeg_kit_flutter_new-3.2.0/android/build.gradle
    fi
}

echo "✅ Google dependencies removed"
echo "⚠️  Run cleanup_ffmpeg after flutter pub get"
