import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/sevices/message_service.dart';

class VerifyPinScreen extends StatefulWidget {
  static Route route({
    required bool useBiometrics,
    required Future<bool> Function(String) onAuthByPIN,
    required Future<bool> Function() onAuthByBiometrics,
  }) => AppPageRoute.build(
    page: VerifyPinScreen(
      useBiometrics: useBiometrics,
      onAuthByPIN: onAuthByPIN,
      onAuthByBiometrics: onAuthByBiometrics,
    ),
  );

  final bool useBiometrics;
  final Future<bool> Function(String) onAuthByPIN;
  final Future<bool> Function() onAuthByBiometrics;

  const VerifyPinScreen({
    super.key,
    required this.useBiometrics,
    required this.onAuthByPIN,
    required this.onAuthByBiometrics,
  });

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final TextEditingController controller = TextEditingController();
  bool _loading = false;
  bool _isObscureText = true;
  bool _showError = false;
  int _attempts = 0;

  Future<void> _handlePinAuth() async {
    if (controller.text.trim().isEmpty) {
      MessageService.showSnackBar(context.l10n.enterYourPIN);
      return;
    }

    setState(() {
      _loading = true;
      _showError = false;
    });

    try {
      final success = await widget.onAuthByPIN(controller.text);
      if (mounted) {
        if (!success) {
          setState(() {
            _loading = false;
            _showError = true;
            _attempts++;
          });
          controller.clear();
        } else {
          setState(() {
            _loading = false;
            _showError = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        MessageService.showSnackBar("${context.l10n.error}: $e");
      }
    }
  }

  Future<void> _handleBiometricAuth() async {
    setState(() {
      _loading = true;
      _showError = false;
    });

    try {
      final success = await widget.onAuthByBiometrics();
      if (mounted) {
        setState(() => _loading = false);
        if (!success) {
          MessageService.showSnackBar(context.l10n.biometricFailed);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        MessageService.showSnackBar("${context.l10n.error}: $e");
      }
    }
  }

  void _toggleObscureText() {
    setState(() => _isObscureText = !_isObscureText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section
                Column(
                  children: [
                    // Animated Lock Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color:
                            (_showError
                                    ? colorScheme.error
                                    : colorScheme.primary)
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              (_showError
                                      ? colorScheme.error
                                      : colorScheme.primary)
                                  .withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _showError
                            ? Icons.lock_reset_rounded
                            : Icons.lock_rounded,
                        size: 48,
                        color: _showError
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      context.l10n.appTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      context.l10n.enterPINToAccess,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // Error message if any
                    if (_showError && _attempts > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          context.l10n.invalidPIN,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),

                // PIN Input Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PIN Input Field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        maxLength: 4,
                        obscureText: _isObscureText,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          letterSpacing: 8,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          hintText: '••••',
                          hintStyle: theme.textTheme.headlineSmall?.copyWith(
                            letterSpacing: 8,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          suffixIcon: IconButton(
                            onPressed: _toggleObscureText,
                            icon: Icon(
                              _isObscureText
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _loading ? null : _handlePinAuth(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // PIN Help Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        context.l10n.enterYourPIN,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Unlock Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handlePinAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_open_rounded, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    context.l10n.unlock.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),

                // Biometric Authentication Section
                if (widget.useBiometrics) ...[
                  const SizedBox(height: 24),
                  // Divider with "or"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            context.l10n.or.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Biometric Button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _loading ? null : _handleBiometricAuth,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fingerprint_rounded,
                              size: 28,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.useBiometrics,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.l10n.fastAndSecure,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Footer Security Note
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.dataProtected,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Forgot PIN? (Optional)
                if (_attempts >= 3) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement forgot PIN flow
                      MessageService.showSnackBar(context.l10n.contactSupport);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    child: Text(
                      context.l10n.forgotPIN,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
