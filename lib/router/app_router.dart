import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ignore_for_file: unused_import
import 'package:flutter/material.dart';

import 'package:vcompressor/ui/home/home_page.dart';
import 'package:vcompressor/ui/settings/settings_page.dart';
import 'package:vcompressor/ui/process/process_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/process',
        name: 'process',
        builder: (context, state) => const ProcessPage(),
      ),
    ],
  );
});
