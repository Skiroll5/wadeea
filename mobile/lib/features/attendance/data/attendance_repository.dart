import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';

// Simple data class for record with student name
class AttendanceRecordWithStudent {
  final AttendanceRecord record;
  final String studentName;

  AttendanceRecordWithStudent({
    required this.record,
    required this.studentName,
  });
}

class AttendanceRepository {
  final AppDatabase _db;

  AttendanceRepository(this._db);

  // Watch attendance records for a specific session
  Stream<List<AttendanceRecord>> watchRecordsForSession(String sessionId) {
    return (_db.select(_db.attendanceRecords)..where(
          (r) => r.sessionId.equals(sessionId) & r.isDeleted.equals(false),
        ))
        .watch();
  }

  // Watch records with student names (joined)
  Stream<List<AttendanceRecordWithStudent>> watchRecordsWithStudents(
    String sessionId,
  ) {
    final query =
        _db.select(_db.attendanceRecords).join([
          innerJoin(
            _db.students,
            _db.students.id.equalsExp(_db.attendanceRecords.studentId),
          ),
        ])..where(
          _db.attendanceRecords.sessionId.equals(sessionId) &
              _db.attendanceRecords.isDeleted.equals(false),
        );

    return query.watch().map((rows) {
      return rows.map((row) {
        final record = row.readTable(_db.attendanceRecords);
        final student = row.readTable(_db.students);
        return AttendanceRecordWithStudent(
          record: record,
          studentName: student.name,
        );
      }).toList();
    });
  }

  // Get attendance records for a session (non-stream)
  Future<List<AttendanceRecord>> getRecordsForSession(String sessionId) {
    return (_db.select(_db.attendanceRecords)..where(
          (r) => r.sessionId.equals(sessionId) & r.isDeleted.equals(false),
        ))
        .get();
  }

  // Save attendance batch for a session
  Future<void> saveAttendanceBatch({
    required String sessionId,
    required Map<String, bool> attendance, // studentId -> isPresent
  }) async {
    final now = DateTime.now();

    await _db.batch((batch) {
      attendance.forEach((studentId, isPresent) {
        final id = const Uuid().v4();
        final status = isPresent ? 'PRESENT' : 'ABSENT';

        batch.insert(
          _db.attendanceRecords,
          AttendanceRecordsCompanion(
            id: Value(id),
            sessionId: Value(sessionId),
            studentId: Value(studentId),
            status: Value(status),
            isDeleted: const Value(false),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        // Add to SyncQueue
        batch.insert(
          _db.syncQueue,
          SyncQueueCompanion(
            uuid: Value(const Uuid().v4()),
            entityType: const Value('ATTENDANCE'),
            entityId: Value(id),
            operation: const Value('CREATE'),
            payload: Value(
              jsonEncode({
                'id': id,
                'sessionId': sessionId,
                'studentId': studentId,
                'status': status,
                'createdAt': now.toIso8601String(),
                'updatedAt': now.toIso8601String(),
              }),
            ),
            createdAt: Value(now),
          ),
        );
      });
    });
  }

  // Update a single attendance record
  Future<void> updateRecord(String recordId, String newStatus) async {
    final now = DateTime.now();

    await (_db.update(
      _db.attendanceRecords,
    )..where((r) => r.id.equals(recordId))).write(
      AttendanceRecordsCompanion(
        status: Value(newStatus),
        updatedAt: Value(now),
      ),
    );

    // Add to sync queue
    await _db
        .into(_db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            uuid: const Uuid().v4(),
            entityType: 'ATTENDANCE',
            entityId: recordId,
            operation: 'UPDATE',
            payload: jsonEncode({
              'id': recordId,
              'status': newStatus,
              'updatedAt': now.toIso8601String(),
            }),
            createdAt: now,
          ),
        );
  }

  // Delete all records for a session (usually when deleting the session)
  Future<void> deleteRecordsForSession(String sessionId) async {
    final now = DateTime.now();

    await (_db.update(
      _db.attendanceRecords,
    )..where((r) => r.sessionId.equals(sessionId))).write(
      AttendanceRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
