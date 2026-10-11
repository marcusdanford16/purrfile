import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth/login_screen.dart';
import 'screens/dashboard/home_shell.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class PurrFileApp extends StatelessWidget {
  const PurrFileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PurrFile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const AuthGate(),
    );
  }
}

/// Routes between the Login/Sign-up flow and the authenticated app shell
/// based on live Supabase Auth state — no custom/fake auth.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<AuthState>(
      stream: authService.onAuthStateChange,
      builder: (context, snapshot) {
        final loggedIn = authService.isLoggedIn;
        return loggedIn ? const HomeShell() : const LoginScreen();
      },
    );
  }
}
