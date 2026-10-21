import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_hero.dart';
import '../widgets/auth_method_tabs.dart';
import '../widgets/auth_mode_toggle.dart';
import '../widgets/google_logo.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _phoneRegex = RegExp(r'^\d{10}$');

  late final TabController _modeController; // Login / Sign Up
  late final TabController _methodController; // Email / Phone / Google

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPhone = GlobalKey<FormState>();

  bool _obscurePassword = true;

  bool get _isSignUp => _modeController.index == 1;

  @override
  void initState() {
    super.initState();
    _modeController = TabController(length: 2, vsync: this)..addListener(_onTabChanged);
    _methodController = TabController(length: 3, vsync: this)..addListener(_onTabChanged);
  }

  void _onTabChanged() => setState(() {});

  @override
  void dispose() {
    _modeController.dispose();
    _methodController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Handle Email / Password Login and Sign-Up
  Future<void> _handleEmailSubmit() async {
    if (!_formKeyEmail.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final controller = ref.read(authControllerProvider.notifier);

    try {
      if (_isSignUp) {
        await controller.signUpWithEmail(_nameController.text.trim(), email, password);
      } else {
        await controller.signInWithEmail(email, password);
      }

      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        _showErrorSnackBar(state.error.toString().replaceAll('Exception: ', ''));
      } else {
        if (_isSignUp) _showSuccessSnackBar('Account created successfully!');
        if (mounted) context.go('/home');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  // Send the phone OTP and open the verification sheet
  void _handlePhoneSubmit() {
    if (!_formKeyPhone.currentState!.validate()) return;

    _openOtpBottomSheet(
      _phoneController.text.trim(),
      name: _isSignUp ? _nameController.text.trim() : null,
    );
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        _showErrorSnackBar(state.error.toString());
      } else {
        if (mounted) context.go('/home');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  // Open OTP Modal Dialog
  void _openOtpBottomSheet(String phone, {String? name}) {
    ref.read(authControllerProvider.notifier).sendOtp(phone);

    final otpController = TextEditingController();
    int secondsRemaining = 30;
    Timer? timer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.authSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsRemaining > 0) {
                setModalState(() => secondsRemaining--);
              } else {
                t.cancel();
              }
            });

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.authFieldBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Verify Phone Number',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.authText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the 6-digit OTP sent to +91 $phone (Demo: 123456)',
                    style: const TextStyle(color: AppColors.authMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    light: true,
                    controller: otpController,
                    hintText: '• • • • • •',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.security_rounded,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        secondsRemaining > 0
                            ? 'Resend in ${secondsRemaining}s'
                            : 'Didn\'t receive code?',
                        style: const TextStyle(color: AppColors.authMuted, fontSize: 13),
                      ),
                      if (secondsRemaining == 0)
                        TextButton(
                          onPressed: () {
                            setModalState(() => secondsRemaining = 30);
                            ref.read(authControllerProvider.notifier).sendOtp(phone);
                          },
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(color: AppColors.authForest),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Verify & Continue',
                    backgroundColor: AppColors.authForest,
                    borderRadius: 18,
                    onPressed: () async {
                      if (otpController.text.trim().isEmpty) return;
                      Navigator.pop(ctx);
                      timer?.cancel();
                      await ref.read(authControllerProvider.notifier).verifyOtp(
                            phone,
                            otpController.text.trim(),
                          );
                      final state = ref.read(authControllerProvider);
                      if (state.hasError) {
                        _showErrorSnackBar(
                            state.error.toString().replaceAll('Exception: ', ''));
                      } else {
                        if (mounted) context.go('/home');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => timer?.cancel());
  }

  // Forgot Password Dialog
  void _openForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.authSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.authText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address and we will send you a password reset link.',
              style: TextStyle(color: AppColors.authMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              light: true,
              controller: emailController,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.authMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSuccessSnackBar('Password reset link sent to ${emailController.text}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authForest,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? val) {
    if (val == null || val.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Please enter your email';
    if (!_emailRegex.hasMatch(val.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? val) {
    if (val == null || val.trim().isEmpty) return 'Please enter your phone number';
    if (!_phoneRegex.hasMatch(val.trim())) return 'Enter a valid 10-digit phone number';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Widget _fieldLabelGap() => const SizedBox(height: 18);

  Widget _nameField() {
    return Column(
      children: [
        CustomTextField(
          light: true,
          controller: _nameController,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icons.badge_outlined,
          validator: _validateName,
        ),
        _fieldLabelGap(),
      ],
    );
  }

  Widget _buildEmailForm(bool isLoading) {
    return Form(
      key: _formKeyEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSignUp) _nameField(),
          CustomTextField(
            light: true,
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          _fieldLabelGap(),
          CustomTextField(
            light: true,
            controller: _passwordController,
            labelText: _isSignUp ? 'Create Password' : 'Password',
            hintText: _isSignUp ? 'At least 8 characters' : 'Enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.authMuted,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: _validatePassword,
          ),
          if (!_isSignUp)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _openForgotPasswordDialog,
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    color: AppColors.authForest,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.authForest,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 16),
          const SizedBox(height: 8),
          _primaryButton(
            text: _isSignUp ? 'Create Account' : 'Login',
            isLoading: isLoading,
            onPressed: _handleEmailSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm(bool isLoading) {
    return Form(
      key: _formKeyPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSignUp) _nameField(),
          CustomTextField(
            light: true,
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: 'Enter your 10-digit number',
            prefixIcon: Icons.smartphone_rounded,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          const SizedBox(height: 10),
          const Text(
            'We will text you a 6-digit code to verify your number.',
            style: TextStyle(color: AppColors.authMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            text: 'Send OTP',
            isLoading: isLoading,
            onPressed: _handlePhoneSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleBody(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Use your Google account to sign in or create your TurfSpot account in one tap.',
          style: TextStyle(color: AppColors.authMuted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 24),
        _googleButton(isLoading),
      ],
    );
  }

  Widget _primaryButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 60,
      child: CustomButton(
        text: text,
        isLoading: isLoading,
        onPressed: onPressed,
        trailingIcon: Icons.arrow_forward_rounded,
        backgroundColor: AppColors.authForest,
        borderRadius: 20,
      ),
    );
  }

  Widget _googleButton(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 58),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.authText,
          side: const BorderSide(color: AppColors.authFieldBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        icon: const GoogleLogo(size: 26),
        label: Text(
          'Continue with Google',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.authText,
          ),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.authFieldBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.authText,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.authFieldBorder)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final method = _methodController.index;

    final Widget methodBody = switch (method) {
      0 => _buildEmailForm(isLoading),
      1 => _buildPhoneForm(isLoading),
      _ => _buildGoogleBody(isLoading),
    };

    return Scaffold(
      backgroundColor: AppColors.authSheet,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = constraints.maxHeight;
          final heroHeight = (viewport * 0.34).clamp(230.0, 340.0);

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                AuthHero(height: heroHeight),
                // The hero's base colour shows behind the sheet's rounded corners.
                Container(
                  color: authHeroBase,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: (viewport - heroHeight).clamp(0.0, double.infinity),
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.authSheet,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 56,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: AppColors.authFieldBorder,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  AuthModeToggle(controller: _modeController),
                                  const SizedBox(height: 18),
                                  AuthMethodTabs(controller: _methodController),
                                  const SizedBox(height: 20),
                                  methodBody,
                                  if (method != 2) ...[
                                    const SizedBox(height: 18),
                                    _orDivider(),
                                    const SizedBox(height: 18),
                                    _googleButton(isLoading),
                                  ],
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const AuthFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
