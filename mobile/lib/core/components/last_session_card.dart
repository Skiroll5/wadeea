import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/home/data/home_insights_repository.dart';

import 'premium_card.dart';

class LastSessionCard extends ConsumerWidget {
  final ClassSessionStatus? sessionStatus;

  const LastSessionCard({super.key, this.sessionStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sessionStatus == null || !sessionStatus!.hasSession) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final status = sessionStatus!;

    final locale = Localizations.localeOf(context);

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          // Navigate to session details: /attendance/:sessionId
          if (status.session != null) {
            context.push('/attendance/${status.session!.id}');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.lastSession ?? 'Last Session',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.className,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.goldPrimary
                                : AppColors.goldDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history,
                      color: isDark
                          ? AppColors.goldPrimary
                          : AppColors.goldDark,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(status.lastSessionDate!, locale),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(status.lastSessionDate!, locale),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRateColor(
                        status.attendanceRate,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.percent, // Changed from pie_chart_outline
                          size: 14,
                          color: _getRateColor(status.attendanceRate),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${(status.attendanceRate * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            color: _getRateColor(status.attendanceRate),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fade().slideY(begin: 0.1, duration: 400.ms);
  }

  String _formatDate(DateTime date, Locale locale) {
    // Force specific locale but we want day name localized
    final fmt = DateFormat('EEEE, MMM d', locale.toString());
    return _toWesternDigits(fmt.format(date));
  }

  String _formatTime(DateTime date, Locale locale) {
    final fmt = DateFormat('h:mm a', locale.toString());
    return _toWesternDigits(fmt.format(date));
  }

  String _toWesternDigits(String input) {
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < eastern.length; i++) {
      input = input.replaceAll(eastern[i], western[i]);
    }
    return input;
  }

  Color _getRateColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
