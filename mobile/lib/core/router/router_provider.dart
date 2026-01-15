import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: AuthNotifier(
      ref,
    ), // TODO: Properly implement refresh listner
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home Screen - Authenticated')),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});

// Helper to notify router when auth state changes
class AuthNotifier extends ChangeNotifier {
  final Ref _ref;
  AuthNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}
