// =============================================================================
// app_router.dart - Configuracion de GoRouter
// -----------------------------------------------------------------------------
// Define el router de la app con:
//  - Redirect global a login si no hay sesion.
//  - Shell route con BottomNavigationBar para home/library/progress/parent.
//  - Rutas push para story detail / reader / story end.
//  - Rutas protegidas (parental verification antes de home).
//
// Las screens se referencian como placeholders (TODO Fase 1: implementar).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../utils/logger.dart';

/// Provider de GoRouter.
///
/// Usa `refreshListenable` para reaccionar a cambios de estado de auth.
/// En Fase 1 se conectara al authControllerProvider.
final appRouterProvider = Provider<GoRouter>((ref) {
  // TODO(P1): conectar a authControllerProvider para redirigir en logout.
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    redirect: _globalRedirect,
    routes: _routes,
    errorBuilder: (context, state) => _errorScreen(state),
  );
});

/// Redirect global. Reglas (en orden):
///  1. Si no hay usuario autenticado y la ruta requiere auth -> `/login`.
///  2. Si hay usuario autenticado y esta en `/login` o `/signup` -> `/`.
///  3. Si el usuario no completo parental verification -> `/parental-verification`.
///  4. Si el usuario no completo onboarding -> `/onboarding`.
///
/// Por ahora (Fase 0 scaffold) no hace nada - todo se resuelve en Fase 1.
Future<String?> _globalRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final path = state.matchedLocation;
  AppLogger.debug('router redirect: $path');

  // TODO(P1): implementar con authControllerProvider:
  //   final authState = ref.read(authControllerProvider);
  //   final isAuthenticated = authState.valueOrNull != null;
  //   final isOnAuthFlow = path == AppRoutes.login ||
  //                       path == AppRoutes.signup ||
  //                       path == AppRoutes.parentalVerification;
  //
  //   if (!isAuthenticated && !isOnAuthFlow) return AppRoutes.login;
  //   if (isAuthenticated && isOnAuthFlow) return AppRoutes.home;
  //   if (isAuthenticated && !parentalVerified) return AppRoutes.parentalVerification;
  //   if (isAuthenticated && !onboardingCompleted) return AppRoutes.onboarding;

  return null; // por ahora, no redirige
}

/// Lista de rutas de la app.
final List<RouteBase> _routes = [
  // ---- Auth ----
  GoRoute(
    path: AppRoutes.login,
    name: AppRoutes.loginName,
    builder: (context, state) => _placeholderScreen('Login'), // TODO(P1): LoginScreen
  ),
  GoRoute(
    path: AppRoutes.signup,
    name: AppRoutes.signupName,
    builder: (context, state) => _placeholderScreen('Signup'), // TODO(P1): SignupScreen
  ),
  GoRoute(
    path: AppRoutes.parentalVerification,
    name: AppRoutes.parentalVerificationName,
    builder: (context, state) =>
        _placeholderScreen('Parental Verification'), // TODO(P1): ParentalVerificationScreen
  ),

  // ---- Onboarding ----
  GoRoute(
    path: AppRoutes.onboarding,
    name: AppRoutes.onboardingName,
    builder: (context, state) =>
        _placeholderScreen('Onboarding'), // TODO(P1): OnboardingFlow
  ),

  // ---- Main app con BottomNav (ShellRoute) ----
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        _placeholderScreen('Main (BottomNav)'), // TODO(P1): MainShellScreen
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            builder: (context, state) =>
                _placeholderScreen('Home'), // TODO(P1): HomeScreen
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.library,
            name: AppRoutes.libraryName,
            builder: (context, state) =>
                _placeholderScreen('Library'), // TODO(P1): LibraryScreen
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.progress,
            name: AppRoutes.progressName,
            builder: (context, state) =>
                _placeholderScreen('Progress'), // TODO(P1): ProgressScreen
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.parent,
            name: AppRoutes.parentName,
            builder: (context, state) =>
                _placeholderScreen('Parent Dashboard'), // TODO(P1): ParentDashboardScreen
          ),
        ],
      ),
    ],
  ),

  // ---- Story flow ----
  GoRoute(
    path: AppRoutes.storyDetail,
    name: AppRoutes.storyDetailName,
    builder: (context, state) => _placeholderScreen(
      'Story Detail',
      extra: state.pathParameters['storyId'],
    ), // TODO(P1): StoryDetailScreen
  ),
  GoRoute(
    path: AppRoutes.reader,
    name: AppRoutes.readerName,
    builder: (context, state) => _placeholderScreen(
      'Reader',
      extra: state.pathParameters['storyId'],
    ), // TODO(P1): ReaderScreen
  ),
  GoRoute(
    path: AppRoutes.storyEnd,
    name: AppRoutes.storyEndName,
    builder: (context, state) => _placeholderScreen(
      'Story End',
      extra: state.pathParameters['storyId'],
    ), // TODO(P1): StoryEndScreen
  ),

  // ---- Settings ----
  GoRoute(
    path: AppRoutes.subscription,
    name: AppRoutes.subscriptionName,
    builder: (context, state) =>
        _placeholderScreen('Manage Subscription'), // TODO(P3): ManageSubscriptionScreen
  ),
  GoRoute(
    path: AppRoutes.paywall,
    name: AppRoutes.paywallName,
    builder: (context, state) =>
        _placeholderScreen('Paywall'), // TODO(P3): PaywallScreen
  ),
  GoRoute(
    path: AppRoutes.childPicker,
    name: AppRoutes.childPickerName,
    builder: (context, state) =>
        _placeholderScreen('Child Picker'), // TODO(P1): ChildPickerScreen
  ),
  GoRoute(
    path: AppRoutes.editChild,
    name: AppRoutes.editChildName,
    builder: (context, state) => _placeholderScreen(
      'Edit Child',
      extra: state.pathParameters['childId'],
    ), // TODO(P1): EditChildScreen
  ),
];

/// Placeholder temporal mientras se implementan las screens reales.
/// TODO(P1): borrar cuando todas las screens existan.
Widget _placeholderScreen(String title, {String? extra}) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            '$title - scaffold placeholder',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (extra != null) ...[
            const SizedBox(height: 8),
            Text('param: $extra', style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 8),
          const Text(
            'Implementado en Fase 1 (MVP).',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

/// Pantalla de error 404 de router.
Widget _errorScreen(GoRouterState state) {
  return Scaffold(
    appBar: AppBar(title: const Text('Ruta no encontrada')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('404', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ruta no encontrada: ${state.matchedLocation}'),
          ],
        ),
      ),
    ),
  );
}
