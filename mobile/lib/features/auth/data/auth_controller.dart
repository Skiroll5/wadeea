import 'dart:convert';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userData = prefs.getString('user_data');

      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      // If error (e.g. corrupt json), logout
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final data = await repo.login(email, password);

      final user = User.fromJson(data['user']);
      final token = data['token'];

      // Save token and user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user_data', jsonEncode(user.toJson()));

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
      // Registration successful, await approval
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateWhatsAppTemplate(String template) async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      final data = await repo.updateProfile(whatsappTemplate: template);

      final updatedUser = User.fromJson(data['user']);

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));

      state = AsyncValue.data(updatedUser);
      return true;
    } catch (e, st) {
      // Don't change state to error, just return false or rethrow?
      // Better to show snackbar in UI, but here we can keep state as data(oldUser)
      // or set error. Setting error might replace the UI with error screen which is bad.
      // So let's just return false and let UI handle error message.
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    state = const AsyncValue.data(null);
  }
}
