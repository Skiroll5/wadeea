import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/settings/data/notification_repository.dart';
import 'package:mobile/features/settings/domain/notification_preference.dart';

final notificationSettingsProvider =
    StateNotifierProvider<
      NotificationSettingsController,
      AsyncValue<NotificationPreference>
    >((ref) {
      return NotificationSettingsController(
        ref.read(notificationRepositoryProvider),
      );
    });

class NotificationSettingsController
    extends StateNotifier<AsyncValue<NotificationPreference>> {
  final NotificationRepository _repository;

  NotificationSettingsController(this._repository)
    : super(const AsyncValue.loading()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      final prefs = await _repository.getPreferences();
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePreference(NotificationPreference newPrefs) async {
    // Optimistic update
    state = AsyncValue.data(newPrefs);
    try {
      final updated = await _repository.updatePreferences(newPrefs);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      // Revert or show error? Reverting is safer but complex if we don't have previous state easily accessible globally
      // (though we do have it in 'state' before the optimistic update if we didn't overwrite it immediately).
      // Ideally we would revert:
      // state = AsyncValue.data(oldState);
      // But for now let's just show error state so user knows sync failed.
      state = AsyncValue.error(e, st);
    }
  }
}
