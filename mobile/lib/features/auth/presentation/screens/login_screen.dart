import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            context.go('/'); // Navigate to home
          }
        },
        error: (err, st) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            }
                          },
                    child: authState.isLoading
                        ? const CircularProgressIndicator()
                        : Text(l10n.login),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text(l10n.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
