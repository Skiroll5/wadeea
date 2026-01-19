import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_config.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Dio());
});

class AdminRepository {
  final Dio _dio;
  final String _baseUrl = ApiConfig.baseUrl;

  AdminRepository(this._dio);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Options _authHeaders(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ===== User Management =====

  /// Fetch all users (admin only)
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _dio.get(
      '$_baseUrl/users',
      options: _authHeaders(token),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Fetch pending users awaiting activation
  Future<List<Map<String, dynamic>>> fetchPendingUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _dio.get(
      '$_baseUrl/users/pending',
      options: _authHeaders(token),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Activate a pending user
  Future<void> activateUser(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.post(
      '$_baseUrl/users/activate',
      data: {'userId': userId},
      options: _authHeaders(token),
    );
  }

  /// Enable a user (set isActive = true)
  Future<void> enableUser(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.post(
      '$_baseUrl/users/$userId/enable',
      options: _authHeaders(token),
    );
  }

  /// Disable a user (set isActive = false)
  Future<void> disableUser(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.post(
      '$_baseUrl/users/$userId/disable',
      options: _authHeaders(token),
    );
  }

  // ===== Class Manager Assignment =====

  /// Fetch all classes with managers
  Future<List<Map<String, dynamic>>> fetchClasses() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _dio.get(
      '$_baseUrl/classes',
      options: _authHeaders(token),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Get managers for a specific class
  Future<List<Map<String, dynamic>>> getClassManagers(String classId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _dio.get(
      '$_baseUrl/classes/$classId/managers',
      options: _authHeaders(token),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Assign a user as class manager
  Future<void> assignClassManager(String classId, String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.post(
      '$_baseUrl/classes/$classId/managers',
      data: {'userId': userId},
      options: _authHeaders(token),
    );
  }

  /// Remove a user as class manager
  Future<void> removeClassManager(String classId, String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.delete(
      '$_baseUrl/classes/$classId/managers/$userId',
      options: _authHeaders(token),
    );
  }

  // ===== Class Management =====

  /// Create a new class
  Future<void> createClass(String name, String grade) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.post(
      '$_baseUrl/classes',
      data: {'name': name, 'grade': grade},
      options: _authHeaders(token),
    );
  }

  // ===== Additional User Management =====

  /// Abort a pending user's activation (deny)
  Future<void> abortActivation(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.post(
      '$_baseUrl/users/$userId/abort-activation',
      options: _authHeaders(token),
    );
  }

  /// Delete a user (soft delete)
  Future<void> deleteUser(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    await _dio.delete('$_baseUrl/users/$userId', options: _authHeaders(token));
  }

  /// Fetch users with aborted activation
  Future<List<Map<String, dynamic>>> fetchAbortedUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _dio.get(
      '$_baseUrl/users/aborted',
      options: _authHeaders(token),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
