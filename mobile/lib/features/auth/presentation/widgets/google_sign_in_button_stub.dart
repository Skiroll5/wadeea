import 'package:flutter/material.dart';

/// A widget that renders the official Google Sign In button on Web,
/// and a custom provided widget on other platforms.
class GoogleSignInButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    throw UnimplementedError('This should be handled by conditional imports');
  }
}
