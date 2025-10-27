import 'package:flutter/material.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'package:my_documents/src/app/widgets/border_box.dart';

class VerefyPinScreen extends StatefulWidget {
  static Route route({
    required bool useBiometrics,
    required Future<bool> Function(String) onAuthByPIN,
    required Future<bool> Function() onAuthByBiometrics,
  }) =>
      AppPageRoute.build(
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
      MessageService.showSnackBar("Please enter your PIN.");
      return;
    }

    setState(() => _loading = true);
    try {
      final success = await widget.onAuthByPIN(controller.text);
      if (!success) {
        MessageService.showSnackBar("Invalid PIN, try again.");
      }
    } catch (e) {
       MessageService.showSnackBar("Error: $e");
    } finally {
       setState(() => _loading = false);
    }
  }

  Future<void> _handleBiometricAuth() async {
    setState(() => _loading = true);
    try {
      final success = await widget.onAuthByBiometrics();
      if (!success) {
        MessageService.showSnackBar("Biometric authentication failed.");
      }
    } catch (e) {
       MessageService.showSnackBar("Error: $e");
    } finally {
       setState(() => _loading = false);
    }
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
                Icon(Icons.lock_rounded,
                    size: 80, color: theme.colorScheme.primary),
                Text(
                  "My Documents",
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Enter your PIN to access your documents",
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
                        hintText: "Enter your PIN",
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _isObscureText = !_isObscureText),
                          icon: Icon(_isObscureText
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded),
                        ),
                      ),
                      onSubmitted: (_) => _loading ? null : _handlePinAuth(),
                    ),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _handlePinAuth,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_open_rounded),
                      label: Text(_loading ? "Verifying..." : "Unlock"),
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
                          Icon(Icons.fingerprint_rounded,
                              size: 28, color: theme.colorScheme.primary),
                          Text(
                            "Use Biometrics",
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
                  "Your data is securely protected",
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
