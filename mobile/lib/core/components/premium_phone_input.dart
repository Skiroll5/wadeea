import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/animations.dart';
import '../constants/country_codes.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Premium phone input with formatted country codes and search
class PremiumPhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final double delay;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  const PremiumPhoneInput({
    super.key,
    required this.controller,
    required this.label,
    this.delay = 0,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<PremiumPhoneInput> createState() => PremiumPhoneInputState();
}

class PremiumPhoneInputState extends State<PremiumPhoneInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  // Default to Egypt (+20) - finding it in the list
  // Format: (dialCode, flag, name)
  (String, String, String) _selectedCountry = ('20', '🇪🇬', 'Egypt');

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    // Ensure we start with Egypt if available (sanity check)
    final egypt = kCountryCodes.where((c) => c.$1 == '20').firstOrNull;
    if (egypt != null) {
      _selectedCountry = egypt;
    }
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);

    // Fix RTL/LTR cursor position issue
    if (_isFocused && widget.controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _onChanged(String value) {
    // Keep raw value (user sees what they type)
  }

  /// Returns the full formatted number for the server.
  /// Handles the Egypt exception: If code is +20 and number starts with 0, remove the 0.
  String get fullNumber {
    final number = widget.controller.text.trim();
    if (number.isEmpty) return '';

    final code = '+${_selectedCountry.$1}';

    // Egypt logic
    if (code == '+20' && number.startsWith('0')) {
      return '$code${number.substring(1)}';
    }

    return '$code$number';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // "Vineyard" Inspired Input Style
    final bgColor = isDark
        ? AppColors.vineyardBrownLight.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.8);

    final borderColor = _isFocused
        ? AppColors.goldPrimary
        : (isDark
              ? AppColors.goldPrimary.withValues(alpha: 0.2)
              : Colors.black12);

    return Directionality(
      textDirection: TextDirection.ltr,
      child:
          AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                    width: _isFocused ? 1.5 : 1,
                  ),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    // Country Code Selector
                    GestureDetector(
                      onTap: () => _showCountryPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: isDark
                                  ? AppColors.goldPrimary.withValues(alpha: 0.2)
                                  : Colors.black12,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountry.$2,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+${_selectedCountry.$1}',
                              style: GoogleFonts.cairo(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Phone Number Input
                    Expanded(
                      child: TextFormField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.phone,
                        textInputAction: widget.textInputAction,
                        onFieldSubmitted: widget.onSubmitted,
                        validator: widget.validator,
                        textDirection: TextDirection.ltr,
                        onChanged: _onChanged,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        style: GoogleFonts.cairo(
                          textStyle: theme.textTheme.bodyLarge,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                          labelText: widget.label,
                          labelStyle: GoogleFonts.cairo(
                            color: _isFocused
                                ? AppColors.goldPrimary
                                : (isDark ? Colors.white70 : Colors.black54),
                            fontWeight: _isFocused
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                          floatingLabelStyle: GoogleFonts.cairo(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(
                delay: Duration(milliseconds: (widget.delay * 1000).toInt()),
              )
              .fade(duration: AppAnimations.defaultDuration)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: AppAnimations.defaultDuration,
                curve: AppAnimations.defaultCurve,
              ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // For full height/search
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerDialog(
        onSelect: (country) {
          setState(() => _selectedCountry = country);
        },
      ),
    );
  }
}

class _CountryPickerDialog extends StatefulWidget {
  final ValueChanged<(String, String, String)> onSelect;

  const _CountryPickerDialog({required this.onSelect});

  @override
  State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<_CountryPickerDialog> {
  late List<(String, String, String)> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _filteredCountries = kCountryCodes;
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = kCountryCodes;
      } else {
        final lower = query.toLowerCase();
        _filteredCountries = kCountryCodes.where((c) {
          final dial = c.$1;
          final name = c.$3.toLowerCase();
          return name.contains(lower) || dial.contains(lower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filter,
              autofocus:
                  false, // Don't autofocus to avoid keyboard jumping immediately if unnecessary
              decoration: InputDecoration(
                hintText: AppLocalizations.of(
                  context,
                )!.searchCountryPlaceholder,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  leading: Text(
                    country.$2,
                    style: const TextStyle(fontSize: 24),
                  ), // Flag
                  title: Text(
                    country.$3, // Name
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    '+${country.$1}', // Code
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    widget.onSelect(country);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
