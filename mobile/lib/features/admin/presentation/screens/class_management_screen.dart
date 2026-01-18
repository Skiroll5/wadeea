import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_controller.dart';

class ClassManagementScreen extends ConsumerWidget {
  const ClassManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(adminClassesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Class Management')),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(child: Text('No classes found'));
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
                      ).primaryColor.withOpacity(0.1),
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

    return Scaffold(
      appBar: AppBar(title: Text('Managers: $className')),
      body: Column(
        children: [
          // Current managers
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Current Managers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: managersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (managers) {
                if (managers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No managers assigned',
                      style: TextStyle(color: Colors.grey),
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
                                title: const Text('Remove Manager'),
                                content: Text(
                                  'Remove ${userData?['name']} as manager?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Remove'),
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
            child: const Text(
              'Add Manager',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: allUsersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (users) {
                // Filter to show only non-admin users
                final eligibleUsers = users
                    .where((u) => u['role'] != 'ADMIN' && u['isActive'] == true)
                    .toList();

                if (eligibleUsers.isEmpty) {
                  return const Center(child: Text('No eligible users'));
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
                      return const Center(
                        child: Text('All eligible users are already managers'),
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
                                            ? '${user['name']} added as manager'
                                            : 'Failed to add manager',
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
