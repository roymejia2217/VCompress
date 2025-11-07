import 'package:flutter/material.dart';

/// Variantes de presentación del item de video
enum AppVideoListItemVariant {
  /// ListTile con Card elevated para home_page (videos pendientes)
  standard,

  /// ListTile dense sin Card para listas compactas
  compact,

  /// ListTile con Card elevated para process_page (videos completados)
  results,

  /// ListTile con Card elevated para process_page (videos en proceso)
  /// Muestra barra de progreso animada y botón cancelar
  process;

  // Computed properties - cero almacenamiento, derivado del variant

  /// Todos los variants muestran thumbnail
  bool get showThumbnail => true;

  /// Dense mode solo para compact
  bool get isDense => this == compact;

  /// Botón de configuración solo en standard
  bool get showSettings => this == standard;

  /// Botón de eliminar solo en standard
  bool get showDelete => this == standard;

  /// Edit summary solo en standard
  bool get showEditSummary => this == standard;

  /// Opciones (play/share) solo en results
  bool get showOptions => this == results;

  /// Barra de progreso solo en process
  bool get showProgress => this == process;

  /// Botón cancelar solo en process
  bool get showCancel => this == process;

  /// Tamaño de thumbnail según M3 ListTile constraints
  /// - compact (dense): 48dp
  /// - standard/results/process: 56dp (máximo M3 para ListTile.leading)
  double get thumbnailSize => isDense ? 48.0 : 56.0;

  /// Borde circular M3 small token (8dp) para todos los thumbnails
  double get thumbnailBorderRadius => 8.0;

  /// ContentPadding según M3 spec
  /// - standard/compact: null = usar default M3 (16-24dp)
  /// - results/process: padding custom para mayor spacing vertical
  EdgeInsetsGeometry? get contentPadding => switch (this) {
    standard || compact => null, // M3 default
    results || process => const EdgeInsetsDirectional.only(
      start: 16.0,
      end: 16.0,
      top: 12.0,
      bottom: 12.0,
    ),
  };

  /// Wrapper de Card según variant
  /// - standard/results: true (Card elevated)
  /// - compact: false (ListTile sin wrapper)
  bool get hasCardWrapper => this != compact;
}

/// Extension para determinar contexto de página
extension AppVideoListItemVariantExtension on AppVideoListItemVariant {
  /// Determina si es home page (debe usar originalPath)
  bool get isHomePage => switch (this) {
    AppVideoListItemVariant.standard => true, // Home page
    AppVideoListItemVariant.process => false,
    AppVideoListItemVariant.results => false,
    AppVideoListItemVariant.compact => true, // También home page
  };
}

/// Configuración simplificada de AppVideoListItem
/// Variant único controla todo el comportamiento (KISS/DRY)
@immutable
class AppVideoListItemConfig {
  final AppVideoListItemVariant variant;

  const AppVideoListItemConfig._(this.variant);

  // Factory constructors como API semántica

  /// Config estándar para home_page (Card elevated, settings/delete buttons)
  const AppVideoListItemConfig.standard()
    : variant = AppVideoListItemVariant.standard;

  /// Config compacto para listas densas (ListTile sin Card)
  const AppVideoListItemConfig.compact()
    : variant = AppVideoListItemVariant.compact;

  /// Config para resultados en process_page (Card elevated, play/share buttons)
  const AppVideoListItemConfig.results()
    : variant = AppVideoListItemVariant.results;

  /// Config para proceso activo en process_page (Card elevated, progress bar, cancel button)
  const AppVideoListItemConfig.process()
    : variant = AppVideoListItemVariant.process;

  // Getters delegados al variant - single source of truth

  bool get showThumbnail => variant.showThumbnail;
  bool get showSettings => variant.showSettings;
  bool get showDelete => variant.showDelete;
  bool get showEditSummary => variant.showEditSummary;
  bool get showOptions => variant.showOptions;
  bool get showProgress => variant.showProgress;
  bool get showCancel => variant.showCancel;
  bool get isDense => variant.isDense;
  double get thumbnailSize => variant.thumbnailSize;
  double get thumbnailBorderRadius => variant.thumbnailBorderRadius;
  EdgeInsetsGeometry? get contentPadding => variant.contentPadding;
  bool get hasCardWrapper => variant.hasCardWrapper;

  /// CopyWith para cambiar variant (raramente necesario)
  AppVideoListItemConfig copyWith({AppVideoListItemVariant? variant}) {
    return AppVideoListItemConfig._(variant ?? this.variant);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVideoListItemConfig &&
          runtimeType == other.runtimeType &&
          variant == other.variant;

  @override
  int get hashCode => variant.hashCode;
}
