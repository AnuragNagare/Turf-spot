import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Bottom sheet to edit name, email and phone.
class EditProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileSheet({super.key, required this.user});

  static Future<void> show(BuildContext context, UserModel user) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.authSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => EditProfileSheet(user: user),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _phoneRegex = RegExp(r'^\d{10}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String? _contactError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? val) {
    if (val == null || val.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  String? _validateEmail(String? val) {
    final value = val?.trim() ?? '';
    if (value.isEmpty) return null;
    return _emailRegex.hasMatch(value) ? null : 'Enter a valid email address';
  }

  String? _validatePhone(String? val) {
    final value = val?.trim() ?? '';
    if (value.isEmpty) return null;
    return _phoneRegex.hasMatch(value) ? null : 'Enter a valid 10-digit phone number';
  }

  Future<void> _save() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    // At least one way to reach the user is required.
    final missingContact = email.isEmpty && phone.isEmpty;
    setState(() => _contactError = missingContact ? 'Add an email or a phone number' : null);

    if (!_formKey.currentState!.validate() || missingContact) return;

    await ref.read(authControllerProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          email: email,
          phone: phone,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.authFieldBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Profile',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.authText,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                light: true,
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.badge_outlined,
                validator: _validateName,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                light: true,
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                light: true,
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: 'Enter your 10-digit number',
                prefixIcon: Icons.smartphone_rounded,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              if (_contactError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _contactError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12.5),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: CustomButton(
                  text: 'Save Changes',
                  backgroundColor: AppColors.authForest,
                  borderRadius: 18,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
