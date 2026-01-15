import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart'; // Drift DB generated class

final syncServiceProvider = Provider(
  (ref) => SyncService(
    ref.read(appDatabaseProvider),
    Dio(), // Should use a configured Dio instance with interceptors
  ),
);

// Provider for AppDatabase (needs to be created in main or core provider)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Initialize AppDatabase in main');
}); // Placeholder, will fix in main.dart

class SyncService {
  final AppDatabase _db;
  final Dio _dio;
  final String _baseUrl = 'http://10.0.2.2:3000';

  SyncService(this._db, this._dio);

  Future<void> sync() async {
    await pushChanges();
    await pullChanges();
  }

  Future<void> pushChanges() async {
    final queueItems = await _db.select(_db.syncQueue).get();
    if (queueItems.isEmpty) return;

    final token = await _getToken();
    if (token == null) return;

    // Transform to payload
    final changes = queueItems.map((item) {
      return {
        'uuid': item.uuid,
        'entityType': item.entityType,
        'entityId': item.entityId,
        'operation': item.operation,
        'payload': jsonDecode(item.payload),
        'createdAt': item.createdAt.toIso8601String(),
      };
    }).toList();

    try {
      await _dio.post(
        '$_baseUrl/sync',
        data: {'changes': changes},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // If successful, delete from queue
      // TODO: Handle partial failures if server supports it, otherwise all or nothing
      await _db.batch((batch) {
        for (var item in queueItems) {
          batch.delete(_db.syncQueue, item);
        }
      });
    } catch (e) {
      print('Push failed: $e');
      rethrow;
    }
  }

  Future<void> pullChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString('last_sync_timestamp');

    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await _dio.get(
        '$_baseUrl/sync',
        queryParameters: lastSync != null ? {'since': lastSync} : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      final serverTimestamp = data['serverTimestamp'];
      final changes = data['changes'];
      // Expected structure: { students: [], attendance: [], ... }

      await _db.transaction(() async {
        // Process Students
        if (changes['students'] != null) {
          for (var s in changes['students']) {
            await _upsertStudent(s);
          }
        }
        // Process Attendance
        if (changes['attendance'] != null) {
          for (var a in changes['attendance']) {
            await _upsertAttendance(a);
          }
        }
      });

      await prefs.setString('last_sync_timestamp', serverTimestamp);
    } catch (e) {
      print('Pull failed: $e');
      rethrow;
    }
  }

  Future<void> _upsertStudent(Map<String, dynamic> data) async {
    final entity = StudentsCompanion(
      id: Value(data['id']),
      name: Value(data['name']),
      phone: Value(data['phone']),
      address: Value(data['address']),
      birthdate: Value(
        data['birthdate'] != null ? DateTime.parse(data['birthdate']) : null,
      ),
      classId: Value(data['classId']),
      createdAt: Value(DateTime.parse(data['createdAt'])),
      updatedAt: Value(DateTime.parse(data['updatedAt'])),
      isDeleted: Value(data['isDeleted'] ?? false),
      deletedAt: Value(
        data['deletedAt'] != null ? DateTime.parse(data['deletedAt']) : null,
      ),
    );

    await _db.into(_db.students).insertOnConflictUpdate(entity);
  }

  Future<void> _upsertAttendance(Map<String, dynamic> data) async {
    final entity = AttendanceRecordsCompanion(
      id: Value(data['id']),
      studentId: Value(data['studentId']),
      date: Value(DateTime.parse(data['date'])),
      status: Value(data['status']),
      createdAt: Value(DateTime.parse(data['createdAt'])),
      updatedAt: Value(DateTime.parse(data['updatedAt'])),
      isDeleted: Value(data['isDeleted'] ?? false),
      deletedAt: Value(
        data['deletedAt'] != null ? DateTime.parse(data['deletedAt']) : null,
      ),
    );
    await _db.into(_db.attendanceRecords).insertOnConflictUpdate(entity);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
