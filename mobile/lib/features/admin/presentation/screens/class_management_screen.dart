import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_controller.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ClassManagementScreen extends ConsumerWidget {
  const ClassManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(adminClassesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.classManagement ?? 'Class Management')),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('${l10n?.errorGeneric(e.toString()) ?? "Error: $e"}'),
        ),
        data: (classes) {
          if (classes.isEmpty) {
            return Center(
              child: Text(l10n?.noClassesFound ?? 'No classes found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminClassesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classData = classes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.class_,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(classData['name'] ?? 'Unknown'),
                    subtitle: Text(classData['grade'] ?? 'No grade'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClassManagerAssignmentScreen(
                            classId: classData['id'],
                            className: classData['name'] ?? 'Class',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ClassManagerAssignmentScreen extends ConsumerWidget {
  final String classId;
  final String className;

  const ClassManagerAssignmentScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managersAsync = ref.watch(classManagersProvider(classId));
    final allUsersAsync = ref.watch(allUsersProvider);
    final adminController = ref.watch(adminControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.managersForClass(className) ?? 'Managers: $className',
        ),
      ),
      body: Column(
        children: [
          // Current managers
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n?.currentManagers ?? 'Current Managers',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: managersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '${l10n?.errorGeneric(e.toString()) ?? "Error: $e"}',
                ),
              ),
              data: (managers) {
                if (managers.isEmpty) {
                  return Center(
                    child: Text(
                      l10n?.noManagersAssigned ?? 'No managers assigned',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: managers.length,
                  itemBuilder: (context, index) {
                    final manager = managers[index];
                    final userData = manager['user'] as Map<String, dynamic>?;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(userData?['name'] ?? 'Unknown'),
                        subtitle: Text(userData?['email'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                  l10n?.removeManagerTitle ?? 'Remove Manager',
                                ),
                                content: Text(
                                  l10n?.removeManagerConfirm(
                                        userData?['name'] ?? '',
                                      ) ??
                                      'Remove ${userData?['name']} as manager?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(l10n?.cancel ?? 'Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(l10n?.remove ?? 'Remove'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await adminController.removeClassManager(
                                classId,
                                userData?['id'],
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          // Add new manager
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n?.addManager ?? 'Add Manager',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: allUsersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '${l10n?.errorGeneric(e.toString()) ?? "Error: $e"}',
                ),
              ),
              data: (users) {
                // Filter to show only non-admin users
                final eligibleUsers = users
                    .where((u) => u['role'] != 'ADMIN' && u['isActive'] == true)
                    .toList();

                if (eligibleUsers.isEmpty) {
                  return Center(
                    child: Text(l10n?.noEligibleUsers ?? 'No eligible users'),
                  );
                }

                return managersAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (currentManagers) {
                    final currentManagerIds = currentManagers
                        .map((m) => (m['user'] as Map?)?['id'])
                        .toSet();

                    final availableUsers = eligibleUsers
                        .where((u) => !currentManagerIds.contains(u['id']))
                        .toList();

                    if (availableUsers.isEmpty) {
                      return Center(
                        child: Text(
                          l10n?.allUsersAreManagers ??
                              'All eligible users are already managers',
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: availableUsers.length,
                      itemBuilder: (context, index) {
                        final user = availableUsers[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: const Icon(Icons.person_add),
                            ),
                            title: Text(user['name'] ?? 'Unknown'),
                            subtitle: Text(user['email'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                final success = await adminController
                                    .assignClassManager(classId, user['id']);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? (l10n?.managerAdded(
                                                    user['name'],
                                                  ) ??
                                                  '${user['name']} added as manager')
                                            : (l10n?.managerAddFailed ??
                                                  'Failed to add manager'),
                                      ),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
