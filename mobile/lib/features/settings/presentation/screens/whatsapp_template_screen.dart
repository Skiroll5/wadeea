import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/data/auth_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WhatsAppTemplateScreen extends ConsumerStatefulWidget {
  const WhatsAppTemplateScreen({super.key});

  @override
  ConsumerState<WhatsAppTemplateScreen> createState() =>
      _WhatsAppTemplateScreenState();
}

class _WhatsAppTemplateScreenState
    extends ConsumerState<WhatsAppTemplateScreen> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    _controller = TextEditingController(text: user?.whatsappTemplate ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final success = await ref
        .read(authControllerProvider.notifier)
        .updateWhatsAppTemplate(_controller.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Template saved successfully'),
          backgroundColor: AppColors.goldPrimary,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save template'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewText = _controller.text
        .replaceAll('{firstname}', 'John')
        .replaceAll('{name}', 'John Doe')
        .replaceAll('{age}', '25');

    return Scaffold(
      appBar: AppBar(title: const Text("WhatsApp Template")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Define the default message to send to students.",
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Available placeholders:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildTag("{firstname}", isDark),
                _buildTag("{name}", isDark),
                _buildTag("{age}", isDark),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Hello {firstname}, how are you?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),
            Text(
              "Preview",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCF8C6), // WhatsApp light green
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                previewText.isEmpty ? "(Empty message)" : previewText,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ).animate().fade().scale(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Save Template",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        final textSelection = _controller.selection;
        final newText = _controller.text.replaceRange(
          textSelection.start < 0 ? 0 : textSelection.start,
          textSelection.end < 0 ? 0 : textSelection.end,
          text,
        );
        final newSelectionIndex =
            (textSelection.start < 0 ? 0 : textSelection.start) + text.length;
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newSelectionIndex),
        );
        setState(() {});
      },
      backgroundColor: isDark
          ? AppColors.goldPrimary.withValues(alpha: 0.2)
          : AppColors.goldPrimary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
        fontSize: 12,
      ),
    );
  }
}
