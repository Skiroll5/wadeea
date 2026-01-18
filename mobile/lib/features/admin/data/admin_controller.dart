import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_repository.dart';

/// Provider for all users (admin view)
final allUsersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.fetchAllUsers();
});

/// Provider for pending users awaiting activation
final pendingUsersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.fetchPendingUsers();
});

/// Provider for all classes (admin view)
final adminClassesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.fetchClasses();
});

/// Provider for class managers of a specific class
final classManagersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      classId,
    ) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getClassManagers(classId);
    });

/// Controller for admin actions
class AdminController extends StateNotifier<AsyncValue<void>> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  /// Activate a pending user
  Future<bool> activateUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.activateUser(userId);
      // Invalidate providers to refresh data
      _ref.invalidate(pendingUsersProvider);
      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Enable a user
  Future<bool> enableUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.enableUser(userId);
      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Disable a user
  Future<bool> disableUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.disableUser(userId);
      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Assign a class manager
  Future<bool> assignClassManager(String classId, String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.assignClassManager(classId, userId);
      _ref.invalidate(classManagersProvider(classId));
      _ref.invalidate(adminClassesProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Remove a class manager
  Future<bool> removeClassManager(String classId, String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeClassManager(classId, userId);
      _ref.invalidate(classManagersProvider(classId));
      _ref.invalidate(adminClassesProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
      return AdminController(ref.watch(adminRepositoryProvider), ref);
    });
