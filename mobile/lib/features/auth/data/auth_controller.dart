import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
      return AuthController(ref);
    });

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // TODO: Implement persistent token check
    // For now starts unauthenticated
    state = const AsyncValue.data(null);
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final data = await repo.login(email, password);

      final user = User.fromJson(data['user']);
      final token = data['token'];

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.register(email, password, name);
      // Registration successful, but maybe not logged in automatically?
      // API returns user but no token usually for activation pending?
      // Actually my API returns user. But plan says default isActive=false.
      // So login will fail with PENDING_APPROVAL.
      state = const AsyncValue.data(null); // Still not logged in
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = const AsyncValue.data(null);
  }
}
