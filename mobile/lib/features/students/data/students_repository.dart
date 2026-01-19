import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/config/api_config.dart';
import '../../sync/data/sync_service.dart';

class StudentsRepository {
  final AppDatabase _db;
  final Dio _dio;
  final SyncService _syncService;
  final String _baseUrl = ApiConfig.baseUrl;

  StudentsRepository(this._db, this._dio, this._syncService);

  Stream<List<Student>> watchStudentsByClass(String classId) {
    return (_db.select(_db.students)
          ..where((t) => t.classId.equals(classId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<List<Student>> watchAllStudents() {
    return (_db.select(_db.students)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<Student?> watchStudent(String id) {
    return (_db.select(
      _db.students,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> addStudent(StudentsCompanion student) async {
    // Check required values
    if (!student.id.present || !student.name.present) {
      throw Exception('ID and Name are required');
    }

    final now = DateTime.now();
    // Ensure timestamps are set if not present
    final localEntity = student.copyWith(
      createdAt: student.createdAt.present ? student.createdAt : Value(now),
      updatedAt: student.updatedAt.present ? student.updatedAt : Value(now),
      isDeleted: student.isDeleted.present
          ? student.isDeleted
          : const Value(false),
    );

    // Prepare API Payload
    final apiPayload = {
      'id': student.id.value,
      'name': student.name.value,
      'phone': student.phone.value,
      'classId': student.classId.value,
      'address': student.address.value,
      'birthdate': student.birthdate.value?.toIso8601String(),
      'createdAt': localEntity.createdAt.value.toIso8601String(),
      'updatedAt': localEntity.updatedAt.value.toIso8601String(),
      'isDeleted': false,
    };

    await _syncService.trySyncFirst(
      entityType: 'STUDENT',
      entityId: student.id.value,
      operation: 'CREATE',
      payload: apiPayload,
      performOnline: () async {
        final token = await _getToken();
        if (token == null) throw Exception('No token');

        await _dio.post(
          '$_baseUrl/students',
          data: apiPayload,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            sendTimeout: const Duration(seconds: 5),
          ),
        );
      },
      performLocal: () async {
        await _db.into(_db.students).insert(localEntity);
      },
    );
  }

  Future<void> updateStudent(Student student) async {
    final now = DateTime.now();

    // Optimistic Update
    final localEntity = student.copyWith(updatedAt: now);

    // API Payload
    final apiPayload = {
      'id': student.id,
      'name': student.name,
      'phone': student.phone,
      'classId': student.classId,
      'address': student.address,
      'birthdate': student.birthdate?.toIso8601String(),
      'createdAt': student.createdAt.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isDeleted': student.isDeleted,
    };

    await _syncService.trySyncFirst(
      entityType: 'STUDENT',
      entityId: student.id,
      operation: 'UPDATE',
      payload: apiPayload,
      performOnline: () async {
        final token = await _getToken();
        if (token == null) throw Exception('No token');

        await _dio.put(
          '$_baseUrl/students/${student.id}',
          data: apiPayload,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            sendTimeout: const Duration(seconds: 5),
          ),
        );
      },
      performLocal: () async {
        await _db.update(_db.students).replace(localEntity);
      },
    );
  }

  Future<void> deleteStudent(String id) async {
    final now = DateTime.now();

    await _syncService.trySyncFirst(
      entityType: 'STUDENT',
      entityId: id,
      operation: 'DELETE',
      payload: {
        'id': id,
        'isDeleted': true,
        'deletedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
      performOnline: () async {
        final token = await _getToken();
        if (token == null) throw Exception('No token');

        await _dio.delete(
          '$_baseUrl/students/$id',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            sendTimeout: const Duration(seconds: 5),
          ),
        );
      },
      performLocal: () async {
        await (_db.update(_db.students)..where((t) => t.id.equals(id))).write(
          StudentsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(now),
          ),
        );
      },
    );
  }

  Future<void> saveStudentPreference(
    String studentId,
    String customMessage,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      await _dio.put(
        '$_baseUrl/users/me/students/$studentId/preference',
        data: {'customWhatsappMessage': customMessage},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      // print('StudentsRepo: Save Student Preference Failed ($e)');
      rethrow;
    }
  }

  Future<String?> getStudentPreference(String studentId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await _dio.get(
        '$_baseUrl/users/me/students/$studentId/preference',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.data != null &&
          response.data['customWhatsappMessage'] != null) {
        return response.data['customWhatsappMessage'] as String;
      }
      return null;
    } catch (e) {
      // print('StudentsRepo: Get Student Preference Failed ($e)');
      return null;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
