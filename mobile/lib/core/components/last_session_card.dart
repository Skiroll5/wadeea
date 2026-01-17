import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/components/premium_card.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/l10n/app_localizations.dart';

class LastSessionCard extends StatelessWidget {
  final AttendanceSession session;
  final String? className;
  final double attendanceRate;

  const LastSessionCard({
    super.key,
    required this.session,
    this.className,
    required this.attendanceRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final formatter = DateFormat('EEE, MMM d', l10n?.localeName ?? 'en');

    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.goldPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.lastSession ?? "Last Session",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatter.format(session.date),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rate Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRateColor(attendanceRate).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getRateColor(
                        attendanceRate,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    "${(attendanceRate * 100).toInt()}%",
                    style: TextStyle(
                      color: _getRateColor(attendanceRate),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (className != null) ...[
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    className!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Color _getRateColor(double rate) {
    if (rate >= 0.8) return AppColors.goldPrimary; // High
    if (rate >= 0.5) return Colors.orange; // Medium
    return AppColors.redPrimary; // Low
  }
}
