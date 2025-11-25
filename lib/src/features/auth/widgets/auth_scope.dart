import 'package:flutter/material.dart';
// import 'package:my_documents/src/app/auth/widgets/auth_screen.dart';
// import 'package:my_documents/src/utils/theme/theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../auth_executor.dart';
// void main(List<String> args) async{
//   WidgetsFlutterBinding.ensureInitialized();
//   final prefs = await SharedPreferences.getInstance();
//   final authExecutor = AuthenticationExecutor(prefs);
//  await authExecutor.clearPin();
//  await authExecutor.savePin("1234");
//   runApp(MaterialApp(
//     theme: AppTheme.lightTheme,
//     debugShowCheckedModeBanner: false,
//     home: AuthScope(
//       authExecutor: authExecutor,
//       authScreen: CreatePinScreen(
//         canUseBiometrics: authExecutor.canCheckBiometrics,
//       onAuthByPIN: authExecutor.authenticateByPIN,
//       onAuthByBiometrics: authExecutor.authenticateByBiometrics),
//       child: Center(child: Text("Welcome"),),
//     )
//   ));
// }

class AuthScope extends StatelessWidget {
  final Widget child;
  final Widget Function(AuthenticationExecutor executor) authScreenBuilder;
  final AuthenticationExecutor authExecutor;

  const AuthScope({
    super.key,
    required this.child,
    required this.authScreenBuilder,
    required this.authExecutor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authExecutor,
      builder: (context, _) {
        if (!authExecutor.hasPassword) {
          authExecutor.authenticated = true;
          return child;
        }
        return authExecutor.authenticated
            ? child
            : authScreenBuilder(authExecutor);
      },
    );
  }
}
