import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/classes_controller.dart';
import '../../../admin/data/admin_controller.dart';

class AddClassScreen extends ConsumerStatefulWidget {
  const AddClassScreen({super.key});

  @override
  ConsumerState<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends ConsumerState<AddClassScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _selectedManagerIds = <String>{};
  String _searchQuery = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.createNewClass),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      l10n.addClassCaption,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ).animate().fade().slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 32),

                    // 1. Class Name Input
                    Text(
                      l10n.className,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ).animate().fade(delay: 100.ms).slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 12),

                    _buildPremiumTextField(
                          controller: _nameController,
                          hint: l10n
                              .classNameHint, // "e.g. 5th Grade Sunday School"
                          icon: Icons.class_outlined,
                          isDark: isDark,
                          autoFocus: true,
                        )
                        .animate()
                        .fade(delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 32),

                    // 2. Managers Selection Header
                    Text(
                      "Assign Managers", // Localize later if key missing
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ).animate().fade(delay: 300.ms).slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      "Search and select users to manage this class",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ).animate().fade(delay: 350.ms),

                    const SizedBox(height: 16),

                    // Search Bar
                    _buildPremiumTextField(
                      controller: _searchController,
                      hint: l10n.search,
                      icon: Icons.search,
                      isDark: isDark,
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.toLowerCase()),
                    ).animate().fade(delay: 400.ms),

                    const SizedBox(height: 16),

                    // Users List
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: allUsersAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, s) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text("Error loading users"),
                          ),
                        ),
                        data: (users) {
                          if (users.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text("No users found"),
                              ),
                            );
                          }

                          // Filter users
                          final filteredUsers = users.where((u) {
                            final name = (u['name'] as String? ?? '')
                                .toLowerCase();
                            final email = (u['email'] as String? ?? '')
                                .toLowerCase();
                            return name.contains(_searchQuery) ||
                                email.contains(_searchQuery);
                          }).toList();

                          if (filteredUsers.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text("No matching users"),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredUsers.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final userId = user['id'] as String;
                              final isSelected = _selectedManagerIds.contains(
                                userId,
                              );

                              return Column(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: CheckboxListTile(
                                      value: isSelected,
                                      title: Text(
                                        user['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(user['email'] ?? ''),
                                      activeColor: AppColors.goldPrimary,
                                      checkColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedManagerIds.add(userId);
                                          } else {
                                            _selectedManagerIds.remove(userId);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  if (index < filteredUsers.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ).animate().fade(delay: 500.ms),

                    // Spacer for keyboard
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.create,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ).animate().slideY(begin: 1.0, end: 0, delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool autoFocus = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      autofocus: autoFocus,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
      cursorColor: AppColors.goldPrimary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.goldPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      // Show error snackbar? Or validate
      return;
    }

    setState(() => _isCreating = true);
    try {
      await ref
          .read(classesControllerProvider)
          .addClass(name, _selectedManagerIds.toList());

      if (mounted) {
        context.pop();
        // Maybe show success snackbar here or in the caller
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
