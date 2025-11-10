#!/bin/bash
set -e

echo "🧹 Removing Google Play dependencies..."

# Remover de archivos Java/Kotlin
find . -type f \( -name "*.java" -o -name "*.kt" \) \
  -exec grep -l 'com\.google\.android\.play' {} \; \
  -exec sed -i '/com\.google\.android\.play/d' {} \; 2>/dev/null || true

# Remover de build.gradle
find . -type f -name "build.gradle*" \
  -exec sed -i '/com\.google\.android\.gms/d' {} \; 2>/dev/null || true

echo "✅ Google dependencies removed"
