import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/classes_controller.dart';
import '../../../../l10n/app_localizations.dart';
import 'add_class_screen.dart';

class ClassListScreen extends ConsumerWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageClasses)),
      body: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return Center(child: Text(l10n.noClassesFoundAdd));
          }
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final klass = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.goldPrimary,
                    child: Icon(Icons.class_, color: Colors.white),
                  ),
                  title: Text(
                    klass.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: klass.grade != null ? Text(klass.grade!) : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to class details or edit
                    // context.push('/classes/${klass.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.errorGeneric(e.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddClassScreen()),
        ),
        backgroundColor: AppColors.goldPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
