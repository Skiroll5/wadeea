import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import '../../../../core/config/api_config.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget mobileChild;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    required this.mobileChild,
    this.isLoading = false,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    final plugin = GoogleSignInPlatform.instance as GoogleSignInPlugin;
    // We must initialize the plugin with params before using renderButton.
    // This mirrors what GoogleSignIn() does under the hood.
    await plugin.initWithParams(
      SignInInitParameters(
        clientId: ApiConfig.googleServerClientId,
        scopes: ['email', 'profile'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 48,
        width: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 50,
            width: double.infinity,
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final plugin = GoogleSignInPlatform.instance as GoogleSignInPlugin;

        return SizedBox(
          height: 50,
          width: double.infinity,
          child: Center(
            child: plugin.renderButton(
              configuration: GSIButtonConfiguration(
                theme: GSIButtonTheme.outline,
                size: GSIButtonSize.large,
                text: GSIButtonText.signinWith,
                shape: GSIButtonShape.pill,
              ),
            ),
          ),
        );
      },
    );
  }
}
