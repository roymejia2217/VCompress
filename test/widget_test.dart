// Test básico para la aplicación VCompressor
//
// Este test verifica que la aplicación se inicia correctamente y muestra
// los elementos principales de la interfaz.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/main.dart';

void main() {
  testWidgets('VCompressor app starts correctly', (WidgetTester tester) async {
    // Construir la aplicación y activar un frame
    await tester.pumpWidget(const ProviderScope(child: VCompressorApp()));

    // Verificar que la aplicación se inicia correctamente
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verificar que el título de la aplicación está presente
    expect(find.text('VCompress'), findsOneWidget);

    // Verificar que no hay errores de compilación
    expect(tester.takeException(), isNull);
  });

  testWidgets('App shows main interface elements', (WidgetTester tester) async {
    // Construir la aplicación
    await tester.pumpWidget(const ProviderScope(child: VCompressorApp()));

    // Verificar que la aplicación se renderiza sin errores
    expect(find.byType(Scaffold), findsOneWidget);

    // Verificar que no hay errores de compilación
    expect(tester.takeException(), isNull);
  });
}
