import 'package:flutter/material.dart';

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
    // On mobile, we just render the custom button the user designed
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: mobileChild,
    );
  }
}
