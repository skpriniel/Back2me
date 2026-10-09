import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

/// Local/demo login only: validates a Gmail address format and a password of
/// at least 6 characters, then navigates to Home. It does not verify inbox
/// ownership or create, check, or store an account.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(initialEmail: _email.text.trim())));
  }

  String? _validateGmailAddress(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your Gmail address';

    final atIndex = email.indexOf('@');
    if (atIndex <= 0 || atIndex != email.lastIndexOf('@')) {
      return 'Enter a valid Gmail address';
    }

    final username = email.substring(0, atIndex);
    final domain = email.substring(atIndex + 1).toLowerCase();
    if (domain != 'gmail.com') return 'Use an @gmail.com address';

    final parts = username.split('+');
    if (parts.length > 2) return 'Enter a valid Gmail address';

    final accountName = parts.first;
    final accountNamePattern = RegExp(r'^[a-zA-Z0-9.]+$');
    if (accountName.length < 6 ||
        accountName.length > 30 ||
        !accountNamePattern.hasMatch(accountName) ||
        accountName.startsWith('.') ||
        accountName.endsWith('.') ||
        accountName.contains('..')) {
      return 'Enter a valid Gmail username';
    }

    if (parts.length == 2) {
      final alias = parts[1];
      if (alias.isEmpty || !RegExp(r'^[a-zA-Z0-9.-]+$').hasMatch(alias)) {
        return 'Enter a valid Gmail address';
      }
    }

    return null;
  }

  void _showDemoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.headlineSmall.copyWith(fontSize: 28),
                        children: const [
                          TextSpan(text: 'Back2', style: TextStyle(color: AppColors.primary)),
                          TextSpan(text: 'me', style: TextStyle(color: AppColors.accent)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg * 1.5),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Email',
                            controller: _email,
                            hint: 'name@gmail.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateGmailAddress,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Password', style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                              GestureDetector(
                                onTap: () => _showDemoDialog(
                                  'Demo mode',
                                  'Back2me stores data locally on this device only, so there is no real password reset. '
                                      'This screen exists to demonstrate the login flow for grading.',
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AppTextField(
                            label: '',
                            controller: _password,
                            hint: '********',
                            icon: Icons.lock_outline,
                            obscureText: _obscure,
                            suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryButton(label: 'Login', onPressed: _login),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Demo only: this checks Gmail address format, not account ownership.',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                        GestureDetector(
                          onTap: () => _showDemoDialog(
                            'Demo mode',
                            'Back2me does not use real accounts for this project, so there is nothing to sign up for. '
                                'Use a valid-format @gmail.com address and a 6+ character password to continue. '
                                    'This demo does not send a verification email.',
                          ),
                          child: Text(
                            'Create Account',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.mutedText),
                        const SizedBox(width: 6),
                        Text('Peer-to-peer accountability simplified', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
