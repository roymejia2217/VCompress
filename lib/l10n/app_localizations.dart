import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'VCompress'**
  String get appName;

  /// Descripción de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Comprime videos sin perder calidad'**
  String get appDescription;

  /// Título de configuración
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// Subtítulo de configuración
  ///
  /// In es, this message translates to:
  /// **'Ajustes de la aplicación'**
  String get settingsSubtitle;

  /// Título de sección de apariencia
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// Título de sección de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Nombre del idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Nombre del idioma inglés
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// Nombre del idioma francés
  ///
  /// In es, this message translates to:
  /// **'Francés'**
  String get french;

  /// Nombre del idioma italiano
  ///
  /// In es, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// Título de sección de almacenamiento
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento'**
  String get storage;

  /// Mensaje mostrado mientras carga la configuración
  ///
  /// In es, this message translates to:
  /// **'Cargando configuración...'**
  String get loadingSettings;

  /// Mensaje de error cuando falla la carga de configuración
  ///
  /// In es, this message translates to:
  /// **'Error al cargar configuración'**
  String get errorLoadingSettings;

  /// Texto del botón reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Etiqueta semántica para la carpeta de guardado
  ///
  /// In es, this message translates to:
  /// **'Carpeta de guardado configurada como {path}'**
  String saveFolderSemantics(String path);

  /// Etiqueta semántica para el botón de cambiar carpeta
  ///
  /// In es, this message translates to:
  /// **'Cambiar carpeta de guardado'**
  String get changeFolderSemantics;

  /// Pista semántica para el botón de cambiar carpeta
  ///
  /// In es, this message translates to:
  /// **'Activa para seleccionar nueva carpeta'**
  String get changeFolderHint;

  /// Mensaje mostrando cantidad de archivos no válidos
  ///
  /// In es, this message translates to:
  /// **'Archivos no válidos: {count}'**
  String invalidFilesCount(int count);

  /// Texto del botón para ver detalles
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get view;

  /// No description provided for @light.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In es, this message translates to:
  /// **'Auto'**
  String get system;

  /// Etiqueta de carpeta de guardado
  ///
  /// In es, this message translates to:
  /// **'Carpeta de guardado'**
  String get saveFolder;

  /// Botón para cambiar carpeta
  ///
  /// In es, this message translates to:
  /// **'Cambiar carpeta'**
  String get changeFolder;

  /// No description provided for @noVideosSelected.
  ///
  /// In es, this message translates to:
  /// **'No hay videos seleccionados'**
  String get noVideosSelected;

  /// No description provided for @import.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get import;

  /// No description provided for @processing.
  ///
  /// In es, this message translates to:
  /// **'Procesando...'**
  String get processing;

  /// No description provided for @compress.
  ///
  /// In es, this message translates to:
  /// **'Comprimir'**
  String get compress;

  /// Título del modal de configuración
  ///
  /// In es, this message translates to:
  /// **'Configuración de compresión'**
  String get configurationTitle;

  /// No description provided for @configurationBatch.
  ///
  /// In es, this message translates to:
  /// **'Configuración para {videoCount} videos'**
  String configurationBatch(int videoCount);

  /// No description provided for @preset.
  ///
  /// In es, this message translates to:
  /// **'Preset'**
  String get preset;

  /// No description provided for @outputResolution.
  ///
  /// In es, this message translates to:
  /// **'Resolución de salida'**
  String get outputResolution;

  /// No description provided for @outputFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato de salida'**
  String get outputFormat;

  /// No description provided for @removeAudio.
  ///
  /// In es, this message translates to:
  /// **'Quitar audio'**
  String get removeAudio;

  /// No description provided for @mirrorMode.
  ///
  /// In es, this message translates to:
  /// **'Modo espejo'**
  String get mirrorMode;

  /// No description provided for @squareFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato cuadrado'**
  String get squareFormat;

  /// No description provided for @adjustSpeed.
  ///
  /// In es, this message translates to:
  /// **'Ajustar velocidad'**
  String get adjustSpeed;

  /// Resumen de edición: configuración de reemplazar archivo original
  ///
  /// In es, this message translates to:
  /// **'Reemplazar original'**
  String get replaceOriginal;

  /// Título de opciones avanzadas
  ///
  /// In es, this message translates to:
  /// **'Opciones avanzadas'**
  String get advancedOptions;

  /// Subtítulo de opciones avanzadas
  ///
  /// In es, this message translates to:
  /// **'Edición y ajustes técnicos'**
  String get advancedSubtitle;

  /// No description provided for @applyToAll.
  ///
  /// In es, this message translates to:
  /// **'Aplicar a todos'**
  String get applyToAll;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @configureVideosNow.
  ///
  /// In es, this message translates to:
  /// **'¿Configurar {videoCount} videos ahora?'**
  String configureVideosNow(int videoCount);

  /// No description provided for @useSameConfiguration.
  ///
  /// In es, this message translates to:
  /// **'Usar misma configuración'**
  String get useSameConfiguration;

  /// No description provided for @configureIndividually.
  ///
  /// In es, this message translates to:
  /// **'Configurar individualmente'**
  String get configureIndividually;

  /// No description provided for @completed.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get completed;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @fileSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del archivo'**
  String get fileSize;

  /// No description provided for @duration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get duration;

  /// No description provided for @resolution.
  ///
  /// In es, this message translates to:
  /// **'Resolución'**
  String get resolution;

  /// No description provided for @format.
  ///
  /// In es, this message translates to:
  /// **'Formato'**
  String get format;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @configure.
  ///
  /// In es, this message translates to:
  /// **'Configurar'**
  String get configure;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Etiqueta de accesibilidad para cargar videos
  ///
  /// In es, this message translates to:
  /// **'Cargando videos'**
  String get loadingVideos;

  /// Mensaje de progreso de carga
  ///
  /// In es, this message translates to:
  /// **'Cargando {current} de {total} videos'**
  String loadingProgress(int current, int total);

  /// Mensaje de análisis de videos
  ///
  /// In es, this message translates to:
  /// **'Analizando videos'**
  String get analyzingVideos;

  /// Mensaje de permiso único concedido
  ///
  /// In es, this message translates to:
  /// **'Permiso concedido correctamente'**
  String get permissionGranted;

  /// Mensaje de múltiples permisos concedidos
  ///
  /// In es, this message translates to:
  /// **'{count} permisos concedidos correctamente'**
  String permissionsGranted(int count);

  /// Error cuando no se puede obtener el directorio de guardado
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener el directorio de guardado'**
  String get saveDirectoryError;

  /// Error cuando no se encuentra la ruta del video comprimido
  ///
  /// In es, this message translates to:
  /// **'No se encontró la ruta del video comprimido'**
  String get compressedVideoPathNotFound;

  /// Texto de compartir para video comprimido
  ///
  /// In es, this message translates to:
  /// **'Video comprimido: {fileName}'**
  String compressedVideoShare(String fileName);

  /// Asunto de compartir para video comprimido
  ///
  /// In es, this message translates to:
  /// **'Video comprimido con {appName}'**
  String compressedVideoSubject(String appName);

  /// Mensaje de error cuando falla el compartir
  ///
  /// In es, this message translates to:
  /// **'Error al compartir: {errorMessage}'**
  String shareError(String errorMessage);

  /// Título de página de resultados
  ///
  /// In es, this message translates to:
  /// **'Resultados'**
  String get results;

  /// Mensaje de espacio liberado
  ///
  /// In es, this message translates to:
  /// **'{space} liberados'**
  String spaceFreed(String space);

  /// Número de videos comprimidos
  ///
  /// In es, this message translates to:
  /// **'{count} videos comprimidos'**
  String videosCompressed(int count);

  /// Título de página de compresión
  ///
  /// In es, this message translates to:
  /// **'Comprimiendo'**
  String get compressing;

  /// Mensaje de progreso de video
  ///
  /// In es, this message translates to:
  /// **'Video {current} de {total}'**
  String videoProgress(int current, int total);

  /// Texto del botón volver al inicio
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get backToHome;

  /// Texto de ayuda para selector de resolución
  ///
  /// In es, this message translates to:
  /// **'Altura objetivo. Se mantiene la relación de aspecto.'**
  String get resolutionHelperText;

  /// Etiqueta del toggle de fotogramas por segundo
  ///
  /// In es, this message translates to:
  /// **'Fotogramas por segundo'**
  String get framesPerSecond;

  /// Mensaje de estado en espera
  ///
  /// In es, this message translates to:
  /// **'En espera...'**
  String get waiting;

  /// Mensaje de porcentaje de progreso
  ///
  /// In es, this message translates to:
  /// **'{percent}% completado'**
  String percentCompleted(String percent);

  /// Mensaje de completado con tamaño
  ///
  /// In es, this message translates to:
  /// **'{size}'**
  String completedWithSize(String size);

  /// Mensaje de error desconocido
  ///
  /// In es, this message translates to:
  /// **'Error desconocido'**
  String get unknownError;

  /// Tooltip del botón cancelar compresión
  ///
  /// In es, this message translates to:
  /// **'Cancelar compresión'**
  String get cancelCompression;

  /// Tooltip del botón configuración
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuration;

  /// Tooltip del botón compartir
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// Resumen de edición: configuración sin audio
  ///
  /// In es, this message translates to:
  /// **'Sin audio'**
  String get noAudio;

  /// Resumen de edición: configuración de espejo
  ///
  /// In es, this message translates to:
  /// **'Espejo'**
  String get mirror;

  /// Resumen de edición: configuración de formato cuadrado
  ///
  /// In es, this message translates to:
  /// **'Cuadrado'**
  String get square;

  /// Resumen de edición: formato de velocidad
  ///
  /// In es, this message translates to:
  /// **'{speed}x'**
  String speedFormat(String speed);

  /// Resumen de edición: formato de fps
  ///
  /// In es, this message translates to:
  /// **'{fps} FPS'**
  String fpsFormat(String fps);

  /// Algoritmo de compresión: máxima calidad
  ///
  /// In es, this message translates to:
  /// **'Máxima Calidad'**
  String get maximaCalidad;

  /// Algoritmo de compresión: excelente calidad
  ///
  /// In es, this message translates to:
  /// **'Excelente Calidad'**
  String get excelenteCalidad;

  /// Algoritmo de compresión: buena calidad
  ///
  /// In es, this message translates to:
  /// **'Buena Calidad'**
  String get buenaCalidad;

  /// Algoritmo de compresión: compresión media
  ///
  /// In es, this message translates to:
  /// **'Compresión Media'**
  String get compresionMedia;

  /// Algoritmo de compresión: ultra compresión
  ///
  /// In es, this message translates to:
  /// **'Ultra Compresión'**
  String get ultraCompresion;

  /// Resolución de salida: resolución original
  ///
  /// In es, this message translates to:
  /// **'Original'**
  String get original;

  /// Resolución de salida: 1080p
  ///
  /// In es, this message translates to:
  /// **'1080p'**
  String get p1080;

  /// Resolución de salida: 720p
  ///
  /// In es, this message translates to:
  /// **'720p'**
  String get p720;

  /// Resolución de salida: 480p
  ///
  /// In es, this message translates to:
  /// **'480p'**
  String get p480;

  /// Resolución de salida: 360p
  ///
  /// In es, this message translates to:
  /// **'360p'**
  String get p360;

  /// Resolución de salida: 240p
  ///
  /// In es, this message translates to:
  /// **'240p'**
  String get p240;

  /// Resolución de salida: 144p
  ///
  /// In es, this message translates to:
  /// **'144p'**
  String get p144;

  /// Formato de salida: MP4
  ///
  /// In es, this message translates to:
  /// **'MP4'**
  String get mp4;

  /// Formato de salida: AVI
  ///
  /// In es, this message translates to:
  /// **'AVI'**
  String get avi;

  /// Formato de salida: MOV
  ///
  /// In es, this message translates to:
  /// **'MOV'**
  String get mov;

  /// Formato de salida: MKV
  ///
  /// In es, this message translates to:
  /// **'MKV'**
  String get mkv;

  /// Formato de salida: WebM
  ///
  /// In es, this message translates to:
  /// **'WebM'**
  String get webm;

  /// Etiqueta para el selector de códec de video
  ///
  /// In es, this message translates to:
  /// **'Códec de video'**
  String get videoCodec;

  /// Códec de video: H.264
  ///
  /// In es, this message translates to:
  /// **'H.264 (AVC)'**
  String get h264;

  /// Códec de video: H.265
  ///
  /// In es, this message translates to:
  /// **'H.265 (HEVC)'**
  String get h265;

  /// Mensaje de cantidad de elementos seleccionados
  ///
  /// In es, this message translates to:
  /// **'{count,plural, =0{No seleccionados} =1{1 seleccionado} other{{count} seleccionados}}'**
  String selected(int count);

  /// Error cuando falla la selección de archivos
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar archivos: {errorMessage}'**
  String filePickerError(String errorMessage);

  /// Error cuando falla la solicitud de permisos
  ///
  /// In es, this message translates to:
  /// **'Error al solicitar permisos: {errorMessage}'**
  String permissionRequestError(String errorMessage);

  /// Título del diálogo cuando los permisos son denegados
  ///
  /// In es, this message translates to:
  /// **'Permisos requeridos'**
  String get permissionRequired;

  /// Mensaje cuando los permisos son denegados
  ///
  /// In es, this message translates to:
  /// **'La aplicación necesita acceso a tus videos para continuar. Por favor, habilita los permisos en la configuración.'**
  String get permissionDeniedMessage;

  /// Botón para abrir configuración en diálogo de permisos
  ///
  /// In es, this message translates to:
  /// **'Abrir configuración'**
  String get openSettings;

  /// Advertencia cuando falla la resolución de URI
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener la ruta original, se usará ruta temporal'**
  String get uriResolutionFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
