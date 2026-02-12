import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/auth/widgets/auth_screen.dart';
import 'package:my_documents/src/presentation/onboarding_screen.dart';
import '../auth_executor.dart';

class AuthScope extends StatefulWidget {
  final Widget child;

  const AuthScope({super.key, required this.child});

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope> {
  late final Listenable _listenable;
  late final AuthenticationExecutor authExecutor;

  @override
  void initState() {
    super.initState();
    authExecutor = context.deps.authExecutor;
    _listenable = Listenable.merge([
      authExecutor.hasPasswordNotifier,
      authExecutor.authenticatedNotifier,
    ]);

    _listenable.addListener(_onAuthChanged);
    
    context.deps.settingsCubit.stream.listen((_)=>_onAuthChanged());
  }

  @override
  void dispose() {
    _listenable.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  List<Widget> _pages(BuildContext ctx) {
    final settings = ctx.deps.settingsCubit.state;
    
    return [
      widget.child,// AppNavigator(initialPages:[MaterialPage(child: widget.child)]),
      
      if (settings.isFirstLaunch)
         OnboardingScreen(),
      
      if (authExecutor.hasPassword && !authExecutor.authenticated)
        VerifyPinScreen(
            useBiometrics: settings.useBiometrics && 
                          ctx.deps.settingsCubit.canUseBiometrics,
            onAuthByPIN: authExecutor.authenticateByPIN,
            onAuthByBiometrics: authExecutor.authenticateByBiometrics,
          ),
    ];
  }

  @override
  Widget build(BuildContext ctx) => Stack(
    children: _pages(ctx),
  );
}