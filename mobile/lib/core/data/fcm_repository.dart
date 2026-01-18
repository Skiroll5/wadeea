import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';

final fcmRepositoryProvider = Provider<FcmRepository>((ref) {
  return FcmRepository(ref.read(apiClientProvider));
});

class FcmRepository {
  final Dio _dio;

  FcmRepository(this._dio);

  Future<void> registerToken(String token) async {
    try {
      await _dio.post('/fcm/register', data: {'token': token});
    } catch (e) {
      // Fail silently or log
      print('Failed to register FCM token: $e');
    }
  }
}
