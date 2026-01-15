import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/premium_card.dart';
import '../../../../core/database/app_database.dart';
import 'package:mobile/l10n/app_localizations.dart';
import '../../data/students_controller.dart';
import '../../data/notes_controller.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentProvider(studentId));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.students ?? 'Student Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditDialog(context, ref, studentAsync.value!),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.redPrimary),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: studentAsync.when(
        data: (student) {
          if (student == null) {
            return const Center(child: Text('Student not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Section
                Hero(
                  tag: 'student_avatar_${student.id}',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.goldPrimary,
                      child: Text(
                        student.name.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  student.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade().slideY(begin: 0.1, end: 0, delay: 100.ms),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bluePrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 16, color: AppColors.bluePrimary),
                      const SizedBox(width: 8),
                      Text(
                        student.phone?.isNotEmpty == true
                            ? student.phone!
                            : 'No Phone',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.bluePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.1, end: 0, delay: 200.ms),

                const SizedBox(height: 32),

                // Info Cards
                PremiumCard(
                  delay: 0.3,
                  isGlass: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, "Details"),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.location_on_outlined,
                        "Address",
                        student.address ?? "No address provided",
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        Icons.cake_outlined,
                        "Birthdate",
                        student.birthdate?.toString().split(" ")[0] ??
                            "Not set",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Visitation Notes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader(context, "Visitation Notes"),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.goldPrimary,
                      ),
                      onPressed: () => _showAddNoteDialog(context, ref),
                    ).animate().scale(delay: 400.ms),
                  ],
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final notesAsync = ref.watch(
                      studentNotesProvider(studentId),
                    );
                    return notesAsync.when(
                      data: (notes) {
                        if (notes.isEmpty) {
                          return PremiumCard(
                            delay: 0.4,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No visitation notes yet.'),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: notes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final note = entry.value;
                            return PremiumCard(
                              delay: 0.4 + (index * 0.1),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.bluePrimary
                                      .withOpacity(0.1),
                                  child: const Icon(
                                    Icons.note,
                                    color: AppColors.bluePrimary,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  note.content,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  note.createdAt.toString().split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    );
                  },
                ),

                // Add bottom padding for better scroll
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  // --- Dialogs (Refactored to look cleaner) ---

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
                'Add Note',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a visitation note for this student',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: noteController,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What happened during the visit?',
                  prefixIcon: Icon(
                    Icons.note_outlined,
                    color: isDark
                        ? AppColors.goldPrimary
                        : AppColors.bluePrimary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.goldPrimary
                          : AppColors.bluePrimary,
                      width: 2,
                    ),
                  ),
                ),
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
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (noteController.text.isNotEmpty) {
                          await ref
                              .read(notesControllerProvider.notifier)
                              .addNote(studentId, noteController.text);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.goldPrimary
                            : AppColors.bluePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Note',
                        style: TextStyle(fontWeight: FontWeight.bold),
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

  void _showEditDialog(BuildContext context, WidgetRef ref, Student student) {
    final nameController = TextEditingController(text: student.name);
    final phoneController = TextEditingController(text: student.phone ?? '');
    final addressController = TextEditingController(
      text: student.address ?? '',
    );
    DateTime? selectedBirthdate = student.birthdate;
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
                    'Edit Student',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: isDark
                            ? AppColors.goldPrimary.withOpacity(0.7)
                            : AppColors.bluePrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Phone',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: isDark
                            ? AppColors.goldPrimary.withOpacity(0.7)
                            : AppColors.bluePrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextField(
                    controller: addressController,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Address',
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
                              final updatedStudent = student.copyWith(
                                name: nameController.text,
                                phone: Value(
                                  phoneController.text.isNotEmpty
                                      ? phoneController.text
                                      : null,
                                ),
                                address: Value(
                                  addressController.text.isNotEmpty
                                      ? addressController.text
                                      : null,
                                ),
                                birthdate: Value(selectedBirthdate),
                              );
                              await ref
                                  .read(studentsControllerProvider)
                                  .updateStudent(updatedStudent);
                              if (context.mounted) Navigator.pop(context);
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
                              'Save Changes',
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  color: AppColors.redPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_remove,
                  color: AppColors.redPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Student?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This student and all their records will be permanently removed. This action cannot be undone.',
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
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(studentsControllerProvider)
                            .deleteStudent(studentId);
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
