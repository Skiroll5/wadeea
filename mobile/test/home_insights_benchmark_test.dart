import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/home/data/home_insights_repository.dart';
import 'package:mobile/core/database/tables/tables.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late HomeInsightsRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = HomeInsightsRepository(db);

    // Seed data
    await _seedData(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Benchmark getClassesLatestSessions', () async {
    final stopwatch = Stopwatch()..start();
    final result = await repository.getClassesLatestSessions();
    stopwatch.stop();

    print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
    print('Result count: ${result.length}');

    // Basic verification
    expect(result.isNotEmpty, true);
  });
}

Future<void> _seedData(AppDatabase db) async {
  const classCount = 50;
  const sessionsPerClass = 10;
  const studentsPerClass = 30;
  final uuid = Uuid();

  final now = DateTime.now();

  await db.batch((batch) {
    for (var i = 0; i < classCount; i++) {
      final classId = uuid.v4();
      batch.insert(
        db.classes,
        ClassesCompanion.insert(
          id: classId,
          name: 'Class $i',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final studentIds = <String>[];
      for (var k = 0; k < studentsPerClass; k++) {
        final sId = uuid.v4();
        studentIds.add(sId);
        batch.insert(
          db.students,
          StudentsCompanion.insert(
            id: sId,
            name: 'Student $k',
            createdAt: now,
            updatedAt: now,
            classId: Value(classId),
          ),
        );
      }

      for (var j = 0; j < sessionsPerClass; j++) {
        final sessionId = uuid.v4();
        // distribute dates
        final date = now.subtract(Duration(days: j * 7));

        batch.insert(
          db.attendanceSessions,
          AttendanceSessionsCompanion.insert(
            id: sessionId,
            classId: classId,
            date: date,
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Only add records for the latest session to simulate real load where we fetch records for latest
        // Or add for all? The query fetches for latest only.
        // Let's add records for all sessions to be realistic about DB size.
        for (var sId in studentIds) {
          batch.insert(
            db.attendanceRecords,
            AttendanceRecordsCompanion.insert(
              id: uuid.v4(),
              sessionId: sessionId,
              studentId: sId,
              status: 'PRESENT',
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }
    }
  });
}
