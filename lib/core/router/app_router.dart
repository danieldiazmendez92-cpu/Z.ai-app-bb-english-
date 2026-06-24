// =============================================================================
// app_router.dart - Configuracion de GoRouter
// -----------------------------------------------------------------------------
// Define el router de la app con:
//  - Redirect global segun estado de auth (login / parental / onboarding).
//  - Rutas de auth: `/login`, `/signup`, `/parental-verification`,
//    `/password-reset`.
//  - Shell route con BottomNavigationBar para home/library/progress/parent
//    (placeholder hasta que se implemente en Sprints 1.4 / 2.2).
//  - Rutas push para story detail / reader / story end (placeholder).
//
// El redirect observa `authControllerProvider` y `isParentalVerifiedProvider`.
// Cuando el estado de auth cambia, `refreshListenable` re-ejecuta el redirect.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/parental_verification_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/child_profile/presentation/screens/child_picker_screen.dart';
import '../../features/child_profile/presentation/screens/edit_child_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/onboarding/presentation/screens/pick_age_screen.dart';
import '../../features/onboarding/presentation/screens/pick_avatar_screen.dart';
import '../../features/onboarding/presentation/screens/pick_interests_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/story/presentation/screens/reader_screen.dart';
import '../../features/story/presentation/screens/story_detail_screen.dart';
import '../../features/story/presentation/screens/story_end_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/child_profile_provider.dart';
import '../router/routes.dart';
import '../utils/logger.dart';

/// Provider de GoRouter.
///
/// Usa `refreshListenable` para reaccionar a cambios de estado de auth.
/// Cuando `authControllerProvider` cambia, se llama `notifyListeners()` y
/// GoRouter re-ejecuta el redirect global.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RiverpodRouterRefreshNotifier();

  // Reaccionar a cambios de auth y parental verification.
  ref.listen(authControllerProvider, (_, __) {
    refreshNotifier.notifyListeners();
  });
  ref.listen(isParentalVerifiedProvider, (_, __) {
    refreshNotifier.notifyListeners();
  });
  // Reaccionar a cambios en la lista de hijos (para redirigir a
  // onboarding si el usuario no tiene perfiles, o salir si crea uno).
  ref.listen(hasAnyChildProvider, (_, __) {
    refreshNotifier.notifyListeners();
  });

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _globalRedirect(context, state, ref),
    routes: _routes,
    errorBuilder: (context, state) => _errorScreen(state),
  );
});

/// Rutas publicas (auth flow): no requieren sesion.
const _publicRoutes = <String>{
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.passwordReset,
};

/// Rutas del flujo de onboarding. Requieren sesion + parental verificado.
const _onboardingRoutes = <String>{
  AppRoutes.onboarding,
  AppRoutes.onboardingWelcome,
  AppRoutes.onboardingAvatar,
  AppRoutes.onboardingAge,
  AppRoutes.onboardingInterests,
};

/// Redirect global. Reglas (en orden de prioridad):
///  1. Si estamos cargando la sesion inicial -> no redirige (esperar).
///  2. Si no hay sesion y la ruta actual NO es publica -> `/login`.
///  3. Si hay sesion y la ruta actual ES publica (login/signup/password-reset)
///     -> `/parental-verification` (si no verifico) o `/` (si verifico).
///  4. Si hay sesion, NO verifico parental, y no esta en parental-verification
///     -> `/parental-verification`.
///  5. Si hay sesion, verifico parental, y esta en parental-verification
///     -> `/onboarding/welcome` (si no tiene hijos) o `/` (si tiene).
///  6. Si verifico parental, no tiene hijos, y no esta en onboarding
///     -> `/onboarding/welcome` (forzar onboarding).
///  7. Si verifico parental, tiene hijos, y esta en onboarding
///     -> `/` (salir del onboarding).
///  8. Caso contrario: no redirige.
String? _globalRedirect(
  BuildContext context,
  GoRouterState state,
  Ref ref,
) {
  final path = state.matchedLocation;
  final authAsync = ref.read(authControllerProvider);
  final isParentalVerified = ref.read(isParentalVerifiedProvider);
  final hasAnyChild = ref.read(hasAnyChildProvider);

  AppLogger.debug('router redirect: $path');

  // Mientras cargamos sesion inicial, no decidimos: dejamos al usuario en
  // la ruta actual. La pantalla de splash / login muestra un loader.
  if (authAsync.isLoading && !authAsync.hasValue) {
    return null;
  }

  final user = authAsync.valueOrNull;

  // (2) Sin sesion: solo se permiten rutas publicas.
  if (user == null) {
    if (_publicRoutes.contains(path)) {
      return null; // ya esta en ruta publica
    }
    return AppRoutes.login;
  }

  // (3) Con sesion: no deberia estar en login/signup/password-reset.
  if (_publicRoutes.contains(path)) {
    if (!isParentalVerified) {
      return AppRoutes.parentalVerification;
    }
    if (!hasAnyChild) {
      return AppRoutes.onboardingWelcome;
    }
    return AppRoutes.home;
  }

  // (4) Con sesion pero sin parental verification: forzar a la pantalla.
  if (!isParentalVerified && path != AppRoutes.parentalVerification) {
    return AppRoutes.parentalVerification;
  }

  // (5) Con sesion y parental verification: si esta en parental-verification,
  // mandarlo a onboarding o home.
  if (isParentalVerified && path == AppRoutes.parentalVerification) {
    if (!hasAnyChild) {
      return AppRoutes.onboardingWelcome;
    }
    return AppRoutes.home;
  }

  // (6) Verifico parental, no tiene hijos, no esta en onboarding: forzar.
  if (isParentalVerified && !hasAnyChild && !_onboardingRoutes.contains(path)) {
    return AppRoutes.onboardingWelcome;
  }

  // (7) Verifico parental, tiene hijos, y esta en onboarding: salir.
  if (isParentalVerified && hasAnyChild && _onboardingRoutes.contains(path)) {
    return AppRoutes.home;
  }

  // (8) Caso por defecto: no redirige.
  return null;
}

/// Lista de rutas de la app.
final List<RouteBase> _routes = [
  // ---- Auth flow ----
  GoRoute(
    path: AppRoutes.login,
    name: AppRoutes.loginName,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoutes.signup,
    name: AppRoutes.signupName,
    builder: (context, state) => const SignupScreen(),
  ),
  GoRoute(
    path: AppRoutes.passwordReset,
    name: AppRoutes.passwordResetName,
    builder: (context, state) => const PasswordResetScreen(),
  ),
  GoRoute(
    path: AppRoutes.parentalVerification,
    name: AppRoutes.parentalVerificationName,
    builder: (context, state) => const ParentalVerificationScreen(),
  ),

  // ---- Onboarding ----
  // Ruta `/onboarding` legacy: redirige a la primera pantalla del flujo.
  GoRoute(
    path: AppRoutes.onboarding,
    name: AppRoutes.onboardingName,
    redirect: (context, state) => AppRoutes.onboardingWelcome,
  ),
  GoRoute(
    path: AppRoutes.onboardingWelcome,
    name: AppRoutes.onboardingWelcomeName,
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: AppRoutes.onboardingAvatar,
    name: AppRoutes.onboardingAvatarName,
    builder: (context, state) => const PickAvatarScreen(),
  ),
  GoRoute(
    path: AppRoutes.onboardingAge,
    name: AppRoutes.onboardingAgeName,
    builder: (context, state) => const PickAgeScreen(),
  ),
  GoRoute(
    path: AppRoutes.onboardingInterests,
    name: AppRoutes.onboardingInterestsName,
    builder: (context, state) => const PickInterestsScreen(),
  ),

  // ---- Main app con BottomNav (ShellRoute) ----
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        MainShellScreen(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.library,
            name: AppRoutes.libraryName,
            builder: (context, state) => const LibraryScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.progress,
            name: AppRoutes.progressName,
            builder: (context, state) => const ProgressScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.parent,
            name: AppRoutes.parentName,
            builder: (context, state) =>
                _placeholderScreen('Parent Dashboard'), // TODO(P2.Sprint 2.3): ParentDashboardScreen
          ),
        ],
      ),
    ],
  ),

  // ---- Story flow ----
  GoRoute(
    path: AppRoutes.storyDetail,
    name: AppRoutes.storyDetailName,
    builder: (context, state) => StoryDetailScreen(
      storyId: state.pathParameters['storyId']!,
    ),
  ),
  GoRoute(
    path: AppRoutes.reader,
    name: AppRoutes.readerName,
    builder: (context, state) => ReaderScreen(
      storyId: state.pathParameters['storyId']!,
    ),
  ),
  GoRoute(
    path: AppRoutes.storyEnd,
    name: AppRoutes.storyEndName,
    builder: (context, state) => StoryEndScreen(
      storyId: state.pathParameters['storyId']!,
    ),
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
    builder: (context, state) => const ChildPickerScreen(),
  ),
  GoRoute(
    path: AppRoutes.editChild,
    name: AppRoutes.editChildName,
    builder: (context, state) => EditChildScreen(
      childId: state.pathParameters['childId'],
    ),
  ),

  // ---- Rutas legales (placeholder simple) ----
  GoRoute(
    path: AppRoutes.terms,
    name: 'terms',
    builder: (context, state) => _legalScreen(
      'Términos de Servicio',
      'TBD - Documento completo a definir antes del lanzamiento público. '
          'Mientras tanto, esta app es para uso de testing en desarrollo.',
    ),
  ),
  GoRoute(
    path: AppRoutes.privacy,
    name: 'privacy',
    builder: (context, state) => _legalScreen(
      'Política de Privacidad',
      'TBD - Documento completo a definir antes del lanzamiento público. '
          'StoryEnglish Kids cumple con COPPA y GDPR-K. Ver docs/05-security-and-privacy.md',
    ),
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

/// Pantalla legal simple (Términos / Privacidad).
/// Solo muestra un texto hasta que se definan los documentos legales finales.
Widget _legalScreen(String title, String body) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Text(body, style: const TextStyle(fontSize: 16, height: 1.6)),
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
            const Icon(Icons.sentiment_dissatisfied,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('404',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ruta no encontrada: ${state.matchedLocation}'),
          ],
        ),
      ),
    ),
  );
}

/// Listenable que llama `notifyListeners()` cuando Riverpod detecta un cambio
/// en los providers observados. GoRouter escucha esto para re-evaluar
/// `redirect`.
class _RiverpodRouterRefreshNotifier extends ChangeNotifier {
  void notifyListeners() {
    super.notifyListeners();
  }
}
