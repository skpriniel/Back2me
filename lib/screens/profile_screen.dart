import 'package:flutter/material.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String initialEmail;

  const ProfileScreen({super.key, this.initialEmail = ''});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final profile = AppStateScope.of(context).profile;
    _nameController.text = profile?.fullName ?? '';
    _phoneController.text = profile?.phoneNumber ?? '';
    _nameController.addListener(_refreshHeader);
    _initialized = true;
  }

  void _refreshHeader() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshHeader);
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = AppStateScope.of(context);
    setState(() => _saving = true);
    try {
      await appState.saveProfile(
        fullName: _nameController.text,
        emailAddress: appState.profile?.emailAddress ?? widget.initialEmail,
        phoneNumber: _phoneController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved on this device.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save your profile. Please try again.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _logOut() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppStateScope.of(context).profile;
    final email = profile?.emailAddress.isNotEmpty == true ? profile!.emailAddress : widget.initialEmail;
    final displayName = _nameController.text.trim();
    final avatarLetter = displayName.isEmpty ? 'U' : displayName.characters.first.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primary,
                    child: Text(avatarLetter, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(displayName.isEmpty ? 'Your profile' : displayName, style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  const Text('Saved on this device', style: TextStyle(color: AppColors.mutedText)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal details', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Full name',
                      controller: _nameController,
                      hint: 'Your name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter your name';
                        if (value.trim().length < 2) return 'Name must have at least 2 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Gmail address', style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                    const SizedBox(height: 6),
                    InputDecorator(
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined)),
                      child: Text(email.isEmpty ? 'No Gmail address provided' : email),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Phone number',
                      controller: _phoneController,
                      hint: 'Optional',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: _saving ? 'Saving...' : 'Save profile',
                      icon: Icons.save_outlined,
                      onPressed: _saving ? null : _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline, color: AppColors.primary),
                title: Text('Local profile'),
                subtitle: Text('Your profile is stored on this device and is not synced to an online account.'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(label: 'Log out', icon: Icons.logout, onPressed: _logOut),
          ],
        ),
      ),
    );
  }
}
