import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/components/premium_card.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/attendance/data/attendance_controller.dart';

class AttendanceDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AttendanceDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<AttendanceDetailScreen> createState() =>
      _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState
    extends ConsumerState<AttendanceDetailScreen> {
  bool _isEditMode = false;

  // Track record IDs of newly added arrivals (to delete on cancel)
  Set<String> _addedRecordIds = {};

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      _addedRecordIds = {};
    });
  }

  Future<void> _cancelEdit() async {
    // Delete all newly added records
    final controller = ref.read(attendanceControllerProvider.notifier);
    for (final recordId in _addedRecordIds) {
      await controller.deleteRecord(recordId);
    }

    setState(() {
      _isEditMode = false;
      _addedRecordIds = {};
    });
    ref.invalidate(sessionRecordsWithStudentsProvider(widget.sessionId));
  }

  void _saveChanges() {
    // All changes are already saved, just exit edit mode
    setState(() {
      _isEditMode = false;
      _addedRecordIds = {};
    });
  }

  // Add a new arrival and track the record ID for potential cancellation
  Future<void> _addNewArrival(String studentId) async {
    final controller = ref.read(attendanceControllerProvider.notifier);
    await controller.createRecord(
      sessionId: widget.sessionId,
      studentId: studentId,
      status: 'PRESENT',
    );

    // Get the newly created record ID
    ref.invalidate(sessionRecordsWithStudentsProvider(widget.sessionId));

    // Wait a bit for the provider to refresh, then find the record ID
    await Future.delayed(const Duration(milliseconds: 100));
    final records = ref
        .read(sessionRecordsWithStudentsProvider(widget.sessionId))
        .value;
    final newRecord = records?.firstWhere(
      (r) => r.studentId == studentId && r.record != null,
      orElse: () => throw Exception('Record not found'),
    );

    if (newRecord?.record != null) {
      setState(() {
        _addedRecordIds.add(newRecord!.record!.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(
      sessionRecordsWithStudentsProvider(widget.sessionId),
    );
    final sessionsAsync = ref.watch(attendanceSessionsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get session info for date display
    String dateText = 'Attendance';
    sessionsAsync.whenData((sessions) {
      final session = sessions
          .where((s) => s.id == widget.sessionId)
          .firstOrNull;
      if (session != null) {
        dateText = DateFormat.yMMMd(l10n?.localeName).format(session.date);
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n?.attendanceDetails ?? 'Attendance Details',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        // No delete button in AppBar anymore
      ),
      body: recordsAsync.when(
        data: (records) {
          final presentCount = records
              .where((r) => r.record?.status == 'PRESENT')
              .length;
          // Only count students who have a record in this session (exclude new arrivals)
          final total = records.where((r) => r.record != null).length;
          final percentage = total > 0 ? (presentCount / total) : 0.0;

          return Column(
            children: [
              // Stats Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.goldPrimary.withValues(alpha: 0.2),
                            AppColors.goldDark.withValues(alpha: 0.1),
                          ]
                        : [
                            AppColors.goldPrimary.withValues(alpha: 0.1),
                            AppColors.goldLight.withValues(alpha: 0.05),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        (isDark ? AppColors.goldPrimary : AppColors.goldPrimary)
                            .withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    // Big Percentage
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(percentage),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.attendanceRate ?? 'Attendance Rate',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              Container(
                                height: 12,
                                width: constraints.maxWidth,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                height: 12,
                                width: constraints.maxWidth * percentage,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getProgressColor(percentage),
                                      _getProgressColor(
                                        percentage,
                                      ).withValues(alpha: 0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Present / Absent Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip(
                          icon: Icons.check_circle,
                          label: l10n?.present ?? 'Present',
                          count: presentCount,
                          color: AppColors.goldPrimary,
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                        _StatChip(
                          icon: Icons.cancel,
                          label: l10n?.absent ?? 'Absent',
                          count: total - presentCount,
                          color: Colors.grey,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade().scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),

              // Students List Header with Edit/Delete Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Row 1: Title
                    Row(
                      children: [
                        Text(
                          "${l10n?.students ?? 'Students'} ($total)",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Edit/Delete Buttons (or Cancel/Save in edit mode)
                    Row(
                      children: [
                        if (_isEditMode) ...[
                          // Cancel Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _cancelEdit,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.close, size: 18),
                              label: Text(l10n?.cancel ?? 'Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(l10n?.save ?? 'Save'),
                            ),
                          ),
                        ] else ...[
                          // Edit Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _enterEditMode,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black87,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(l10n?.edit ?? 'Edit'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delete Button (only in view mode)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showDeleteSheet(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.redPrimary
                                    .withValues(alpha: isDark ? 0.25 : 0.1),
                                foregroundColor: isDark
                                    ? Colors.redAccent.shade200
                                    : AppColors.redPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.redPrimary.withValues(
                                      alpha: isDark ? 0.6 : 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: Text(l10n?.delete ?? 'Delete'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Records List
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Text(
                          l10n?.noAttendanceRecords ?? 'No attendance records',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          // Separate students with records from those without
                          final existingStudents = records
                              .where((r) => r.record != null)
                              .toList();
                          final newStudents = records
                              .where((r) => r.record == null)
                              .toList();

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            children: [
                              // Existing Students Section
                              ...existingStudents.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final isPresent =
                                    item.record?.status == 'PRESENT';

                                return PremiumCard(
                                  delay: index * 0.02,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: isPresent
                                      ? AppColors.goldPrimary.withValues(
                                          alpha: isDark ? 0.1 : 0.05,
                                        )
                                      : null,
                                  onTap: _isEditMode
                                      ? () async {
                                          // Toggle attendance in edit mode
                                          final controller = ref.read(
                                            attendanceControllerProvider
                                                .notifier,
                                          );
                                          await controller.updateRecordStatus(
                                            item.record!.id,
                                            isPresent ? 'ABSENT' : 'PRESENT',
                                          );
                                          ref.invalidate(
                                            sessionRecordsWithStudentsProvider(
                                              widget.sessionId,
                                            ),
                                          );
                                        }
                                      : () {
                                          context.push(
                                            '/students/${item.studentId}',
                                          );
                                        },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: isPresent
                                            ? AppColors.goldPrimary
                                            : (isDark
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade200),
                                        child: Text(
                                          item.studentName[0].toUpperCase(),
                                          style: TextStyle(
                                            color: isPresent
                                                ? Colors.white
                                                : (isDark
                                                      ? Colors.white70
                                                      : Colors.grey),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.studentName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: isPresent
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isDark
                                                    ? (isPresent
                                                          ? Colors.grey.shade400
                                                          : Colors
                                                                .grey
                                                                .shade600)
                                                    : (isPresent
                                                          ? Colors.grey.shade600
                                                          : Colors
                                                                .grey
                                                                .shade400),
                                              ),
                                        ),
                                      ),
                                      // Show circular checkbox in edit mode
                                      if (_isEditMode)
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isPresent
                                                ? AppColors.goldPrimary
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isPresent
                                                  ? AppColors.goldPrimary
                                                  : (isDark
                                                        ? Colors.grey.shade600
                                                        : Colors.grey.shade400),
                                              width: 2,
                                            ),
                                          ),
                                          child: isPresent
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        )
                                      else
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isPresent
                                                  ? Icons.check_circle
                                                  : Icons.cancel_outlined,
                                              color: isPresent
                                                  ? AppColors.goldPrimary
                                                  : Colors.grey.shade400,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.chevron_right,
                                              color: isDark
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade400,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              }),

                              // New Students Section (show in both view and edit modes)
                              if (newStudents.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  l10n?.newArrivals ?? 'New Arrivals',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isEditMode
                                      ? (l10n?.tapToAddToSession ??
                                            'Tap to add to this session')
                                      : (l10n?.notInSession ??
                                            'Not in this session'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...newStudents.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  return PremiumCard(
                                    delay: index * 0.02,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: isDark
                                        ? Colors.blue.withValues(alpha: 0.08)
                                        : Colors.blue.withValues(alpha: 0.05),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.blue.withValues(alpha: 0.3)
                                          : Colors.blue.withValues(alpha: 0.2),
                                      style: BorderStyle.solid,
                                    ),
                                    onTap: _isEditMode
                                        ? () async {
                                            // Add student using helper to track for cancel
                                            await _addNewArrival(
                                              item.studentId,
                                            );
                                          }
                                        : () {
                                            // Navigate to student detail
                                            context.push(
                                              '/students/${item.studentId}',
                                            );
                                          },
                                    child: Row(
                                      children: [
                                        // Dashed circle with + icon
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.blue.withValues(
                                                alpha: 0.5,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              item.studentName[0].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.blue.shade400,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.studentName,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Colors.blue.shade300
                                                          : Colors
                                                                .blue
                                                                .shade700,
                                                    ),
                                              ),
                                              Text(
                                                l10n?.notInSession ??
                                                    'Not in this session',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: isDark
                                                          ? Colors.grey.shade600
                                                          : Colors
                                                                .grey
                                                                .shade500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Add icon in edit mode, chevron in view mode
                                        if (_isEditMode)
                                          Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue.withValues(
                                                alpha: 0.2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 18,
                                              color: Colors.blue.shade400,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.chevron_right,
                                            color: isDark
                                                ? Colors.grey.shade600
                                                : Colors.grey.shade400,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
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

  Color _getProgressColor(double percentage) {
    if (percentage >= 0.8) return AppColors.goldPrimary;
    if (percentage >= 0.5) return Colors.orange;
    return AppColors.redPrimary;
  }

  void _showDeleteSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.redPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever,
                  color: AppColors.redPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete this session?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This attendance session and all its records will be permanently deleted.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n?.cancel ?? 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref
                            .read(attendanceControllerProvider.notifier)
                            .deleteSession(widget.sessionId);
                        if (context.mounted) context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n?.delete ?? 'Delete',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
