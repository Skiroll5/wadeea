import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/classes_controller.dart';
import '../../../../core/database/app_database.dart';

import '../../../admin/data/admin_controller.dart';

Future<void> showAddClassDialog(BuildContext context, WidgetRef ref) async {
  final nameController = TextEditingController();
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final l10n = AppLocalizations.of(context)!;

  // State for selected managers
  final selectedManagerIds = <String>{};

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.dragHandleDark
                        : AppColors.dragHandleLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                l10n.createNewClass,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addClassCaption,
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
                decoration: InputDecoration(
                  labelText: l10n.className,
                  hintText: l10n.classNameHint,
                  prefixIcon: Icon(
                    Icons.class_,
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
                      color: AppColors.goldPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Managers Selection Section
              Text(
                // l10n.assignManagers // If key exists, otherwise hardcode for now or check l10n
                "Assign Managers (Optional)",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final allUsersAsync = ref.watch(allUsersProvider);
                      return allUsersAsync.when(
                        data: (users) {
                          if (users.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: Text("No users found")),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: users.length,
                            separatorBuilder: (c, i) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final userId = user['id'] as String;
                              final isSelected = selectedManagerIds.contains(
                                userId,
                              );
                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: AppColors.goldPrimary,
                                title: Text(user['name'] ?? 'Unknown'),
                                subtitle: Text(user['email'] ?? ''),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedManagerIds.add(userId);
                                    } else {
                                      selectedManagerIds.remove(userId);
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) =>
                            Center(child: Text("Error loading users")),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Buttons
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
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          await ref
                              .read(classesControllerProvider)
                              .addClass(
                                nameController.text,
                                selectedManagerIds.toList(),
                              );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.create,
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
    ),
  );
}

Future<void> showRenameClassDialog(
  BuildContext context,
  WidgetRef ref,
  ClassesData cls,
) async {
  final nameController = TextEditingController(text: cls.name);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final l10n = AppLocalizations.of(context)!;

  await showModalBottomSheet(
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
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.dragHandleDark
                      : AppColors.dragHandleLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Text(
              l10n.rename,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Name Field
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.className,
                prefixIcon: Icon(Icons.class_, color: AppColors.goldPrimary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.goldPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
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
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty) {
                        await ref
                            .read(classesControllerProvider)
                            .updateClass(cls.id, nameController.text);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.save,
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

Future<void> showDeleteClassDialog(
  BuildContext context,
  WidgetRef ref,
  ClassesData cls,
) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final l10n = AppLocalizations.of(context)!;

  await showModalBottomSheet(
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
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.dragHandleDark
                      : AppColors.dragHandleLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.redPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_forever,
                color: isDark ? AppColors.redLight : AppColors.redPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              '${l10n.delete} "${cls.name}"?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.deleteWarning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Buttons
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
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(classesControllerProvider)
                          .deleteClass(cls.id);
                      if (context.mounted) Navigator.pop(context);
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
                      l10n.delete,
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
