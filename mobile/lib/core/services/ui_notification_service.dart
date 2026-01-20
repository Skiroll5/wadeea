import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uiNotificationServiceProvider = Provider<UiNotificationService>((ref) {
  return UiNotificationService();
});

enum UiNotificationLevel { info, success, warning, error }

class UiNotificationService {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void show({
    required String message,
    String? title,
    UiNotificationLevel level = UiNotificationLevel.info,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    final color = _backgroundFor(level);
    final text = title == null || title.trim().isEmpty
        ? message
        : '$title: $message';

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
        ),
      );
  }

  Color _backgroundFor(UiNotificationLevel level) {
    switch (level) {
      case UiNotificationLevel.success:
        return Colors.green.shade600;
      case UiNotificationLevel.warning:
        return Colors.orange.shade700;
      case UiNotificationLevel.error:
        return Colors.red.shade700;
      case UiNotificationLevel.info:
      default:
        return Colors.blueGrey.shade700;
    }
  }
}
