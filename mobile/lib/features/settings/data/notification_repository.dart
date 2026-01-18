import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/settings/domain/notification_preference.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiClientProvider));
});

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<NotificationPreference> getPreferences() async {
    try {
      final response = await _dio.get('/users/me/notifications/preferences');
      return NotificationPreference.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load preferences';
    }
  }

  Future<NotificationPreference> updatePreferences(
    NotificationPreference prefs,
  ) async {
    try {
      final response = await _dio.put(
        '/users/me/notifications/preferences',
        data: prefs.toJson(),
      );
      // The backend returns { message: '...', prefs: object }
      return NotificationPreference.fromJson(response.data['prefs']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update preferences';
    }
  }
}
