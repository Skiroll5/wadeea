import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/api_config.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(Dio()));

/// Error class to hold structured error information
class AuthError {
  final String message;
  final String code;

  AuthError(this.message, this.code);

  @override
  String toString() => message;
}

class AuthRepository {
  final Dio _dio;
  final String _baseUrl = ApiConfig.baseUrl;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data; // { token, user }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data?['message'] ?? 'Login failed';
      final code = data?['code'] ?? 'UNKNOWN';
      throw AuthError(message, code);
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data?['message'] ?? 'Registration failed';
      final code = data?['code'] ?? 'UNKNOWN';
      throw AuthError(message, code);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? whatsappTemplate,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/users/me',
        data: {
          if (name != null) 'name': name,
          if (whatsappTemplate != null) 'whatsappTemplate': whatsappTemplate,
        },
      );
      return response.data; // { message, user }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Update failed';
    }
  }
}
