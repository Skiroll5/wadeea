import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/premium_card.dart';
import '../../../../core/components/premium_button.dart';
import '../../../../core/components/premium_text_field.dart';
import '../../data/auth_controller.dart';
import 'package:mobile/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, st) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              backgroundColor: AppColors.redPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.backgroundDark, AppColors.surfaceDark]
                : [AppColors.backgroundLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark
                          ? AppColors.goldPrimary
                          : AppColors.goldDark,
                    ),
                  ),
                ).animate().fade(duration: 300.ms),

                const SizedBox(height: 24),

                // Logo/Icon
                Icon(
                      Icons.person_add_alt_1,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    )
                    .animate()
                    .fade(duration: 500.ms)
                    .scale(delay: 200.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 16),

                Text(
                  l10n.register,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  l10n.createAccountCaption ??
                      'Create your account to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 350.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                PremiumCard(
                  delay: 0.2,
                  isGlass: true,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        PremiumTextField(
                          controller: _nameController,
                          label: l10n.name ?? 'Name',
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => value!.isEmpty
                              ? l10n.required ?? 'Required'
                              : null,
                          delay: 0.3,
                        ),
                        const SizedBox(height: 16),
                        PremiumTextField(
                          controller: _emailController,
                          label: l10n.email,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value!.isEmpty
                              ? l10n.required ?? 'Required'
                              : null,
                          delay: 0.4,
                        ),
                        const SizedBox(height: 16),
                        PremiumTextField(
                          controller: _passwordController,
                          label: l10n.password,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) => value!.isEmpty
                              ? l10n.required ?? 'Required'
                              : null,
                          delay: 0.5,
                        ),
                        const SizedBox(height: 32),
                        PremiumButton(
                          label: l10n.register,
                          isFullWidth: true,
                          isLoading: authState.isLoading,
                          delay: 0.6,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await ref
                                  .read(authControllerProvider.notifier)
                                  .register(
                                    _emailController.text,
                                    _passwordController.text,
                                    _nameController.text,
                                  );

                              if (!mounted) return;

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.waitActivation),
                                    backgroundColor: AppColors.goldPrimary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                context.pop();
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        PremiumButton(
                          label: l10n.backToLogin ?? 'Back to Login',
                          variant: ButtonVariant.outline,
                          isFullWidth: true,
                          delay: 0.7,
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
