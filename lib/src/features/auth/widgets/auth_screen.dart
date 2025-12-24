import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'package:my_documents/src/widgets/border_box.dart';

class VerefyPinScreen extends StatefulWidget {
  static Route route({
    required bool useBiometrics,
    required Future<bool> Function(String) onAuthByPIN,
    required Future<bool> Function() onAuthByBiometrics,
  }) => AppPageRoute.build(
    page: VerefyPinScreen(
      useBiometrics: useBiometrics,
      onAuthByPIN: onAuthByPIN,
      onAuthByBiometrics: onAuthByBiometrics,
    ),
  );

  final bool useBiometrics;
  final Future<bool> Function(String) onAuthByPIN;
  final Future<bool> Function() onAuthByBiometrics;

  const VerefyPinScreen({
    super.key,
    required this.useBiometrics,
    required this.onAuthByPIN,
    required this.onAuthByBiometrics,
  });

  @override
  State<VerefyPinScreen> createState() => _VerefyPinScreenState();
}

class _VerefyPinScreenState extends State<VerefyPinScreen> {
  final TextEditingController controller = TextEditingController();
  bool _loading = false;
  bool _isObscureText = true;

  Future<void> _handlePinAuth() async {
    if (controller.text.trim().isEmpty) {
      MessageService.showSnackBar(context.l10n.enterYourPIN);
      return;
    }

    setState(() => _loading = true);
    try {
      final success = await widget.onAuthByPIN(controller.text);
      if (!success && mounted) {
        MessageService.showSnackBar(context.l10n.invalidPIN);
      }
    } catch (e) {
      if (mounted) MessageService.showSnackBar("${context.l10n.error}: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleBiometricAuth() async {
    setState(() => _loading = true);
    try {
      final success = await widget.onAuthByBiometrics();
      if (!success && mounted) {
        MessageService.showSnackBar(context.l10n.biometricFailed);
      }
    } catch (e) {
      if (mounted) MessageService.showSnackBar("${context.l10n.error}: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  context.l10n.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.enterPINToAccess,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    TextField(
                      controller: controller,
                      maxLength: 10,
                      obscureText: _isObscureText,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: context.l10n.enterPIN,
                        suffixIcon: IconButton(
                          onPressed:
                              () => setState(
                                () => _isObscureText = !_isObscureText,
                              ),
                          icon: Icon(
                            _isObscureText
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _loading ? null : _handlePinAuth,
                    ),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _handlePinAuth,
                      icon:
                          _loading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.lock_open_rounded),
                      label: Text(
                        _loading ? context.l10n.verifying : context.l10n.unlock,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.useBiometrics)
                  GestureDetector(
                    onTap: _loading ? null : _handleBiometricAuth,
                    child: BorderBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Icon(
                            Icons.fingerprint_rounded,
                            size: 28,
                            color: theme.colorScheme.primary,
                          ),
                          Text(
                            context.l10n.useBiometrics,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                Text(
                  context.l10n.dataProtected,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
