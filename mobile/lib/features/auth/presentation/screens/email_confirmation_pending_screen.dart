import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/premium_card.dart';
import '../../../../core/components/premium_button.dart';
import 'package:mobile/l10n/app_localizations.dart';
import '../widgets/auth_background.dart';

class EmailConfirmationPendingScreen extends StatelessWidget {
  const EmailConfirmationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header Image/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mark_email_read_rounded,
                  size: 80,
                  color: isDark ? AppColors.goldPrimary : AppColors.bluePrimary,
                ),
              ).animate().fade().scale(
                duration: 800.ms,
                curve: Curves.easeOutBack,
              ),

              const SizedBox(height: 40),

              PremiumCard(
                isGlass: true,
                child: Column(
                  children: [
                    Text(
                      l10n.checkYourEmail,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.bluePrimary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    Text(
                      l10n.confirmEmailDescription,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 40),

                    PremiumButton(
                      label: l10n.goBackToLogin,
                      isFullWidth: true,
                      onPressed: () => context.go('/login'),
                    ).animate().fade(delay: 500.ms).scale(),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        // Resend logic could be added here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.emailResent)),
                        );
                      },
                      child: Text(
                        l10n.resendEmail,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.goldPrimary
                              : AppColors.bluePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fade(delay: 600.ms),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
