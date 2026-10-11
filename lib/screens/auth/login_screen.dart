import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_spacing.dart';
import '../../utils/validators.dart';
import '../../widgets/date_field.dart';
import '../../widgets/paw_logo.dart';
import '../../widgets/primary_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.logIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigation happens automatically via AuthGate's auth-state stream.
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand header. The logo already contains the tagline, so it
                // is the only thing here; centred explicitly so it can't
                // collapse to the left edge.
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(AppSpacing.lg,
                      topInset + AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: scheme.heroGradient,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40)),
                  ),
                  child: Center(
                    child: PurrLogo(
                      key: const Key('purrfile_logo'),
                      markSize: 88,
                      direction: Axis.vertical,
                      color: scheme.onPrimary,
                      faceColor: scheme.primary,
                      tagline: "Your cat's health, all in one place.",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Welcome back', style: text.headlineSmall),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: AppSpacing.sm + 4),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _loading ? null : _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscure
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password is required'
                              : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.sm + 4),
                          FormErrorBox(_error!),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                            label: 'Log In',
                            onPressed: _submit,
                            loading: _loading),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const SignupScreen()),
                                  ),
                          child: const Text('New here? Create an account'),
                        ),
                      ],
                    ),
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
