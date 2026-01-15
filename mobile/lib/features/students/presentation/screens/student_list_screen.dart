import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/students_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/premium_card.dart';
import 'package:mobile/features/classes/data/classes_controller.dart';
import 'package:mobile/l10n/app_localizations.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(classStudentsProvider);
    final selectedClassId = ref.watch(selectedClassIdProvider);
    final classesAsync = ref.watch(classesStreamProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get class name for title
    String? className;
    classesAsync.whenData((classes) {
      final cls = classes.where((c) => c.id == selectedClassId).firstOrNull;
      className = cls?.name;
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(selectedClassIdProvider.notifier).state = null;
            context.go('/');
          },
        ),
        title: Text(className ?? l10n?.students ?? 'Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              // TODO: Implement Search
            },
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ).animate().fade(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Tap below to add the first student',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ).animate().fade(delay: 400.ms),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: students.length,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
            itemBuilder: (context, index) {
              final student = students[index];
              return PremiumCard(
                delay: index * 0.05,
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () => context.push('/students/${student.id}'),
                child: Row(
                  children: [
                    Hero(
                      tag: 'student_avatar_${student.id}',
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.goldPrimary,
                        child: Text(
                          student.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                student.phone?.isNotEmpty == true
                                    ? student.phone!
                                    : 'No phone',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
      // Bottom action buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddStudentDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text(
                    'Add Student',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/attendance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.blueLight
                        : AppColors.bluePrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.checklist),
                  label: const Text(
                    'Attendance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fade().slideY(begin: 0.3, end: 0),
    );
  }

  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    DateTime? selectedBirthdate;

    final selectedClassId = ref.read(selectedClassIdProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.goldPrimary : AppColors.bluePrimary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Add New Student',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a student to this class',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Student Name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: isDark
                            ? AppColors.goldPrimary.withOpacity(0.7)
                            : AppColors.bluePrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Phone Number (optional)',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: isDark
                            ? AppColors.goldPrimary.withOpacity(0.7)
                            : AppColors.bluePrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address Field
                  TextField(
                    controller: addressController,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Address (optional)',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: isDark
                            ? AppColors.goldPrimary.withOpacity(0.7)
                            : AppColors.bluePrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Birthday Picker
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedBirthdate ?? DateTime(2010),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: isDark
                                    ? const ColorScheme.dark(
                                        primary: AppColors.goldPrimary,
                                        onPrimary: Colors.black,
                                        surface: Color(0xFF1E1E1E),
                                        onSurface: Colors.white,
                                      )
                                    : const ColorScheme.light(
                                        primary: AppColors.bluePrimary,
                                        onPrimary: Colors.white,
                                      ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setSheetState(() => selectedBirthdate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              color: isDark
                                  ? AppColors.goldPrimary.withOpacity(0.7)
                                  : AppColors.bluePrimary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of Birth',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedBirthdate != null
                                        ? '${selectedBirthdate!.day}/${selectedBirthdate!.month}/${selectedBirthdate!.year}'
                                        : 'Not set',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: selectedBirthdate != null
                                          ? (isDark
                                                ? Colors.white
                                                : Colors.black87)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? AppColors.goldPrimary
                                            : AppColors.bluePrimary)
                                        .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isNotEmpty &&
                                  selectedClassId != null) {
                                try {
                                  await ref
                                      .read(studentsControllerProvider)
                                      .addStudent(
                                        name: nameController.text,
                                        phone: phoneController.text,
                                        address: addressController.text,
                                        birthdate: selectedBirthdate,
                                        classId: selectedClassId,
                                      );
                                  if (context.mounted) Navigator.pop(context);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a name'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.goldPrimary
                                  : AppColors.bluePrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Add Student',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
        ),
      ),
    );
  }
}
