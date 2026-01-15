import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/premium_card.dart';
import '../../data/attendance_controller.dart';

class AttendanceDetailScreen extends ConsumerWidget {
  final String sessionId;

  const AttendanceDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(
      sessionRecordsWithStudentsProvider(sessionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.redPrimary),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          final presentCount = records
              .where((r) => r.record.status == 'PRESENT')
              .length;
          final absentCount = records
              .where((r) => r.record.status == 'ABSENT')
              .length;

          return Column(
            children: [
              // Summary Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.bluePrimary, AppColors.blueLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Present',
                      presentCount.toString(),
                      AppColors.goldLight,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildStat(
                      'Absent',
                      absentCount.toString(),
                      Colors.white70,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildStat(
                      'Total',
                      records.length.toString(),
                      Colors.white,
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: -0.1, end: 0),

              // Records List
              Expanded(
                child: records.isEmpty
                    ? const Center(child: Text('No attendance records'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final item = records[index];
                          final isPresent = item.record.status == 'PRESENT';

                          return PremiumCard(
                            delay: index * 0.03,
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isPresent
                                ? AppColors.goldPrimary.withOpacity(0.05)
                                : null,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isPresent
                                      ? AppColors.goldPrimary
                                      : Colors.grey.shade300,
                                  child: Text(
                                    item.studentName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: isPresent
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.studentName,
                                    style: TextStyle(
                                      fontWeight: isPresent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPresent
                                        ? AppColors.goldPrimary.withOpacity(0.2)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isPresent ? 'Present' : 'Absent',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isPresent
                                          ? AppColors.goldDark
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this attendance session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.redPrimary),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(attendanceControllerProvider.notifier)
                  .deleteSession(sessionId);
              if (context.mounted) context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
