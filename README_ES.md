<div align="center">
  <img src="android/app/src/main/play_store_512.png" alt="Logo VCompress" width="200" height="200">
</div>

# VCompress

[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-7.0%2B-green.svg)](https://www.android.com)
[![Lanzamiento GitHub](https://img.shields.io/github/v/release/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress/releases)
[![Último commit GitHub](https://img.shields.io/github/last-commit/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress)

Una poderosa aplicación Android de compresión de videos construida con Flutter. VCompress proporciona optimización inteligente de videos con aceleración por hardware, procesamiento por lotes y seguimiento de progreso en tiempo real.

**Plataformas**: Android (7.0+) | **Idiomas**: [English](README.md) | [Español](README_ES.md) | [Français](README_FR.md) | [Italiano](README_IT.md)

---

## Características

### Compresión Principal
- **Múltiples Algoritmos de Compresión**: VP8, VP9, H.264, H.265 con soporte de aceleración por hardware
- **Procesamiento por Lotes**: Comprime múltiples videos simultáneamente con cola inteligente
- **Seguimiento de Progreso en Tiempo Real**: Indicadores de progreso en vivo para importación y operaciones de compresión
- **Selección Inteligente de Resolución**: Perfiles predefinidos (720p, 1080p, 2K, 4K) con opciones personalizadas
- **Flexibilidad de Formato**: Soporte para contenedores de salida MP4, WebM, MKV

### Características Avanzadas
- **Detección de Hardware**: Detección automática de capacidades del dispositivo (núcleos CPU, RAM, soporte de codecs)
- **Integración FFmpeg**: Procesamiento de video estándar de la industria con ffmpeg_kit_flutter_new
- **Generación de Miniaturas**: Extracción automática de miniaturas de video con almacenamiento en caché
- **Extracción de Metadatos**: Análisis completo de videos (duración, resolución, codec, fps)
- **Gestión de Archivos**: Reemplazo seguro de archivos con opciones de copia de seguridad y resolución de URI de MediaStore
- **Sistema de Notificaciones**: Notificaciones de progreso de compresión en tiempo real

### Experiencia de Usuario
- **Material Design 3**: Interfaz moderna y responsiva con temas dinámicos de colores
- **Soporte Multiidioma**: Español (es), Inglés (en), Francés (fr) con Flutter Intl
- **Configuración Localizada**: Modo de tema (claro/oscuro/sistema), selección de idioma, directorio de guardado personalizado
- **Modo Oscuro**: Soporte completo de tema oscuro Material 3 con Flex Color Scheme
- **Accesibilidad**: Etiquetas semánticas, navegación por teclado, soporte para lectores de pantalla

---

## Especificaciones Técnicas

### Requisitos del Sistema

| Componente | Mínimo | Recomendado |
|-----------|--------|-----------|
| **Android** | 7.0 (API 24) | 12.0+ (API 31+) |
| **Dart** | 3.6.0 | 3.8.1 |
| **Flutter** | 3.19.0 | 3.32.8 |
| **RAM** | 2GB | 4GB+ |
| **Almacenamiento** | 150MB libres | 500MB+ libres |

### Codecs Soportados

**Codecs de Video**: VP8, VP9, H.264, H.265, AV1 (depende del hardware)
**Codecs de Audio**: AAC, Opus, Vorbis
**Contenedores**: MP4, WebM, MKV
**Formatos de Píxeles**: Yuv420, Yuv422, Yuv444

### Aceleración por Hardware

| Codec | Soporte |
|-------|---------|
| **H.264** | MediaCodec (hardware) |
| **H.265** | MediaCodec (hardware) |
| **VP9** | MediaCodec (hardware en 8.0+) |

---

## Arquitectura

### Stack Tecnológico

```
Gestión de Estado:   Riverpod 2.6.1 (FutureProvider, StateNotifier)
Navegación:          GoRouter 16.2.0 (enrutamiento type-safe)
Framework de UI:     Flutter Material 3
Procesamiento Video: FFmpeg (ffmpeg_kit_flutter_new 3.2.0)
Almacenamiento:      SharedPreferences + Path Provider
Iconos:              Phosphor Flutter
Temas:               Flex Color Scheme 8.2.0
Localización:        Flutter Intl (archivos .arb)
Permisos:            Permission Handler 12.0.1
Selección Archivos:  File Picker 10.3.2
Miniaturas:          Video Thumbnail 0.5.3
```

### Estructura del Proyecto

```
lib/
├── core/                              # Lógica principal de la aplicación
│   ├── constants/
│   │   ├── app_constants.dart        # Constantes globales
│   │   └── app_design_tokens.dart    # Espaciado M3, relleno, colores
│   ├── error/
│   │   └── app_error.dart            # Manejo centralizado de errores
│   ├── performance/
│   │   └── memory_manager.dart       # Monitoreo y optimización de memoria
│   └── result/
│       └── result.dart               # Tipo Result<T, E> genérico
│
├── data/                              # Capa de datos y servicios
│   ├── repositories/                 # Repositorios de datos
│   └── services/                     # 15 servicios especializados
│
├── domain/                            # Lógica de negocio y casos de uso
│   └── usecases/
│       └── add_video_files_usecase.dart
│
├── models/                            # Modelos de datos
│   ├── video_task.dart               # Tarea de compresión de video
│   ├── video_settings.dart           # Configuración de compresión
│   ├── hardware_info.dart            # Capacidades del dispositivo
│   └── compression_result.dart       # Resultados de procesamiento
│
├── providers/                         # Gestión de estado con Riverpod (8 proveedores)
│   ├── batch_config_provider.dart    # Configuración de procesamiento por lotes
│   ├── error_handler_provider.dart   # Manejo global de errores
│   ├── hardware_provider.dart        # Capacidades del dispositivo
│   ├── loading_provider.dart         # Estados de carga y progreso
│   ├── settings_provider.dart        # Preferencias del usuario
│   ├── tasks_provider.dart           # Gestión de cola de tareas
│   ├── video_config_provider.dart    # Configuración individual de compresión
│   └── video_services_provider.dart  # Proveedores de servicios
│
├── router/                            # Configuración de navegación
│   └── app_router.dart               # Configuración de GoRouter
│
├── theme/                             # Temas Material 3
│   └── app_theme.dart                # Configuración de tema (claro/oscuro)
│
├── ui/                                # Interfaz de usuario
│   ├── hardware/                     # Visualización de información de hardware
│   ├── home/                         # Página principal
│   ├── process/                      # Página de procesamiento de video
│   ├── settings/                     # Configuración y preferencias
│   ├── theme/                        # Utilidades de tema
│   ├── video/                        # Widgets relacionados con video
│   └── widgets/                      # Componentes reutilizables
│
├── utils/                             # Funciones de utilidad
│   └── cache_service.dart            # Servicio de caché en memoria y disco
│
├── l10n/                              # Localización
│   ├── app_localizations.dart        # Localizaciones generadas
│   ├── app_es.arb                    # Traducciones al español
│   ├── app_en.arb                    # Traducciones al inglés
│   └── app_fr.arb                    # Traducciones al francés
│
├── l10n.yaml                         # Configuración de localización
└── main.dart                         # Punto de entrada de la aplicación

android/                               # Configuración específica de Android
├── app/src/main/
│   ├── AndroidManifest.xml           # Manifiesto de Android
│   ├── java/                         # Código fuente Java
│   ├── kotlin/                       # Código fuente Kotlin
│   └── res/
│       ├── mipmap-*/                 # Iconos de la aplicación
│       ├── values/                   # Cadenas, colores, temas
│       └── play_store_512.png        # Icono de Play Store
│
├── build.gradle                      # Gradle a nivel de proyecto
└── settings.gradle                   # Configuración de Gradle

test/                                  # Suite de pruebas (5 categorías)
├── accessibility/                    # Pruebas de accesibilidad
├── integration/                      # Pruebas de integración
├── performance/                      # Pruebas de rendimiento
├── unit/                             # Pruebas unitarias
└── widget/                           # Pruebas de widgets
```

### Servicios Clave Explicados

#### VideoProcessorService / VideoProcessorServiceMobile
Gestiona la compresión de videos basada en FFmpeg. Construye comandos FFmpeg basados en configuración, monitorea progreso y maneja optimizaciones específicas de plataforma.

#### VideoMetadataService / VideoMetadataServiceMobile
Extrae metadatos de video usando FFprobe: duración, resolución, codec, fps. Genera miniaturas para vista previa de UI.

#### HardwareDetectionService
Detecta capacidades del dispositivo (núcleos CPU, RAM, codecs disponibles) para decisiones de optimización.

#### FFmpegProgressService
Seguimiento de progreso en tiempo real del análisis de salida de FFmpeg. Convierte velocidad de bits/tiempo en porcentaje de finalización.

#### NotificationService
Envía notificaciones del sistema para progreso de compresión y eventos.

#### CacheService
Singleton para almacenamiento en caché en memoria y en disco (SharedPreferences). Almacena miniaturas, metadatos, archivos recientes.

---

## Instalación y Configuración

### Requisitos Previos
- **Flutter**: 3.19.0+ ([guía de instalación](https://flutter.dev/docs/get-started/install))
- **Dart**: 3.6.0+ (incluido en Flutter)
- **Android SDK**: API 24+ para compilaciones de Android

### Clonar Repositorio
```bash
git clone https://github.com/roymejia2217/VCompress.git
cd VCompressor
```

### Instalar Dependencias
```bash
flutter pub get
```

### Generar Archivos de Localización
```bash
flutter gen-l10n
```

### Ejecutar Aplicación

**Dispositivo/Emulador Android**:
```bash
flutter run -d android
# o para dispositivo específico
flutter run -d <device_id>
```

**Compilación de Lanzamiento (Android)**:
```bash
flutter build apk --release
# o bundle de aplicación para Play Store
flutter build appbundle --release
```

---

## Uso

### Flujo de Trabajo Básico

1. **Importar Videos**: Toca el botón de importar, selecciona uno o múltiples videos
2. **Configurar Compresión**: Elige algoritmo, resolución, formato (individual o por lotes)
3. **Monitorear Progreso**: Observa barras de progreso en tiempo real durante importación y compresión
4. **Guardar Videos Comprimidos**: Los archivos se guardan en el directorio configurado (por defecto: Descargas/VCompress)

### Configuración de Compresión

| Configuración | Opciones | Notas |
|---|---|---|
| **Algoritmo** | VP8, VP9, H.264, H.265, AV1 | H.265 mejor compresión, H.264 mejor compatibilidad |
| **Resolución** | 720p, 1080p, 2K, 4K, Personalizado | Reducir resolución disminuye significativamente el tamaño de archivo |
| **Formato** | MP4, WebM, MKV | MP4 más compatible, WebM más pequeño |
| **Calidad** | 18-28 CRF | Menor = mejor calidad, archivos más grandes |
| **FPS** | Original, 15, 24, 30, 60 | Reducir fps ahorra ancho de banda |

### Procesamiento por Lotes

Habilita modo de lotes para comprimir múltiples videos con configuración consistente:
1. Selecciona múltiples videos durante importación
2. Configura ajustes una vez (se aplican a todos)
3. Los procesos se encolان automáticamente
4. Monitorea todo el progreso en una sola lista

### Configuración de Almacenamiento

Cambia el directorio de guardado en Configuración > Almacenamiento > Cambiar Carpeta. Ubicaciones personalizadas soportadas en Android 11+.

---

## Desarrollo

### Estilo de Código

- **Formato**: Ejecuta `flutter format lib/` regularmente
- **Análisis**: Mantén advertencias de `flutter analyze` en 0
- **Comentarios**: Explica *por qué*, no *qué* (el código muestra qué)
- **Nomenclatura**: Nombres descriptivos con sufijos para clases especializadas (ej: `_mobile.dart` para específico de plataforma)

### Flujos de Trabajo Comunes

**Flujo de Corrección de Errores**:
```bash
flutter analyze
grep -r "search_term" lib/
# (editar archivos)
flutter format lib/
flutter analyze
flutter test
flutter run -d android
```

**Implementación de Características**:
```bash
# (crear/modificar archivos)
flutter format lib/
flutter analyze
flutter test test/unit/
flutter run -d android
```

---

## Pruebas

### Categorías de Pruebas

| Categoría | Ubicación | Propósito |
|-----------|-----------|-----------|
| **Unitarias** | `test/unit/` | Lógica de servicios, algoritmos, cálculos |
| **Widget** | `test/widget/` | Componentes UI, renderizado, interacciones |
| **Integración** | `test/integration/` | Flujos de extremo a extremo, múltiples servicios |
| **Accesibilidad** | `test/accessibility/` | Lectores de pantalla, navegación por teclado |
| **Rendimiento** | `test/performance/` | Benchmarks, uso de memoria, tasas de fotogramas |

### Ejecutar Pruebas

```bash
flutter test
flutter test test/unit/
flutter test test/unit/services/video_processor_service_test.dart
flutter test --coverage
```

---

## Optimizaciones de Rendimiento

### Gestión de Memoria

- **Almacenamiento en Caché de Miniaturas**: Caché en disco para miniaturas de video
- **Carga Diferida**: Las listas usan `ListView.builder` para eficiencia de memoria
- **Monitoreo de Memoria**: `MemoryManager` rastrea uso de heap, activa limpieza
- **Almacenamiento en Caché de Metadatos**: Extrae una vez, reutiliza en todas las operaciones

### Optimización de FFmpeg

- **Aceleración por Hardware**: Usa MediaCodec en Android para H.264/H.265
- **Codificación Guiada por Perfil**: Ajuste de FFmpeg (ultrafast, superfast, fast) según dispositivo
- **Procesamiento por Segmentos**: Procesa video en segmentos para archivos grandes
- **Tareas Paralelas**: Múltiples compresiones con cola inteligente

### Rendimiento de UI

- **Selectores de Proveedor**: Observa solo estado necesario (`.select()`)
- **Límites de Repintado**: Barras de progreso no reconstruyen lista completa
- **Constructores Const**: Widgets marcados `const` donde es posible
- **Caché de Imagen**: Miniaturas cacheadas con ImageCache

### Almacenamiento y Red

- **Procesamiento Local**: Todo procesamiento ocurre en el dispositivo
- **E/S Eficiente**: SharedPreferences para configuración, Path Provider para archivos
- **Integración MediaStore**: Usa Android MediaStore para resolución correcta de URI

---

## Compatibilidad

### Versiones de Android

| Versión | API | Estado | Notas |
|---------|-----|--------|-------|
| **7.0** | 24 | Compatible | Versión mínima |
| **8.0** | 26 | Compatible | Soporte hardware VP9 |
| **9.0** | 28 | Compatible | Almacenamiento por alcance mejorado |
| **11.0+** | 30+ | Recomendado | Almacenamiento por alcance completo |
| **14.0+** | 34+ | Soporte completo | APIs más recientes |

---

## Solución de Problemas

### Problemas Comunes

#### Compilación Falla: "Android SDK not found"
```bash
flutter config --android-sdk /ruta/a/android-sdk
flutter doctor
```

#### Errores de FFmpeg Durante Compresión
```bash
ffmpeg -version
flutter run -d android --verbose
```

#### Timeout Durante Importación de Video (50+ archivos)
El timeout de importación escala automáticamente: **30 + (cantidad de archivos) segundos**.

#### Sin Memoria en Videos Grandes
- Cierra otras aplicaciones
- Reduce resolución destino
- Limpia caché: Configuración > Limpiar Caché

#### Modo Oscuro No Funciona
Asegúrate de que el dispositivo tenga:
1. "Usar tema del sistema" habilitado en Configuración
2. Modo oscuro del sistema activado (Android 9+)

---

## Gestión de Dependencias

### Dependencias Principales

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| **flutter** | 3.32.8 | Framework de UI |
| **flutter_riverpod** | 2.6.1 | Gestión de estado |
| **go_router** | 16.2.0 | Navegación |
| **ffmpeg_kit_flutter_new** | 3.2.0 | Procesamiento de video |
| **video_thumbnail** | 0.5.3 | Generación de miniaturas |
| **file_picker** | 10.3.2 | Selección de archivos |
| **permission_handler** | 12.0.1 | Solicitud de permisos |
| **flex_color_scheme** | 8.2.0 | Temas Material 3 |
| **phosphor_flutter** | 2.1.0 | Iconos (600+) |
| **path_provider** | 2.1.4 | Directorios de aplicación |
| **shared_preferences** | 2.3.2 | Configuración persistente |
| **provider** | 6.1.2 | Estado a nivel de widget |

---

## Decisiones de Arquitectura

### ¿Por qué Riverpod?
- Type-safe sin BuildContext
- Manejo excelente de async
- Estado con alcance usando `.family`
- Testeable sin frameworks de mocking

### ¿Por qué GoRouter?
- Parámetros de ruta type-safe
- Soporte para deep linking
- Árbol de enrutamiento declarativo
- Navegación anidada para tablets

### ¿Por qué FFmpeg?
- Estándar de la industria
- Soporta 100+ codecs/contenedores
- Soporte de aceleración por hardware
- Comunidad activa y actualizaciones

### Implementación Específica de Plataforma
- Archivos **_mobile.dart** para lógica específica de Android
- Optimizado para Android 7.0+ con soporte de aceleración por hardware

---

## Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. **Fork repositorio** y crea rama de características
2. **Código** siguiendo patrones establecidos (ver sección Desarrollo)
3. **Prueba** exhaustivamente (unitarias, widget, integración)
4. **Formatea** con `flutter format lib/`
5. **Analiza** con `flutter analyze` (0 advertencias)
6. **Envía PR** con descripción clara

### Áreas para Contribución

- [ ] Algoritmos de compresión adicionales
- [ ] Más traducciones de idiomas
- [ ] Benchmarks de rendimiento
- [ ] Mejoras de accesibilidad

---

## Licencia

Licencia MIT - Ver archivo LICENSE para detalles.

---

## Soporte

### Documentación
- [CLAUDE.md](./CLAUDE.md) - Directrices de desarrollo y decisiones arquitectónicas
- [Documentación de Flutter](https://flutter.dev/docs)
- [Documentación de FFmpeg](https://ffmpeg.org/documentation.html)

### Problemas y Retroalimentación
- Problemas de GitHub: [Problemas de VCompress](https://github.com/roymejia2217/VCompress/issues)
- Reportes de Errores: Incluye salida de `flutter doctor` y pasos para reproducir
- Solicitudes de Características: Describe caso de uso y comportamiento esperado

## Historial de Versiones

| Versión | Fecha | Destacados |
|---------|-------|-----------|
| **2.0** | 2025-11-06 | Rediseño Material 3, optimización de rendimiento, soporte multiidioma |
| **1.0** | 2025-10-01 | Lanzamiento inicial, compresión básica, soporte Android |

---

**Construido con ❤️ usando Flutter**

¿Preguntas? Abre un problema o visita el [repositorio de GitHub](https://github.com/roymejia2217/VCompress).
