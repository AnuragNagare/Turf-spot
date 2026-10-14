import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers - Login
  final _loginEmailOrPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginWithPhone = false;

  // Controllers - Sign Up
  final _signUpNameController = TextEditingController();
  final _signUpEmailOrPhoneController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeySignUp = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailOrPhoneController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailOrPhoneController.dispose();
    _signUpPasswordController.dispose();
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

  // Handle Email / Password Login
  Future<void> _handleLogin() async {
    if (!_formKeyLogin.currentState!.validate()) return;

    final input = _loginEmailOrPhoneController.text.trim();
    final isPhone = RegExp(r'^\d{10}$').hasMatch(input);

    if (isPhone) {
      _openOtpBottomSheet(input);
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            input,
            _loginPasswordController.text,
          );

      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        _showErrorSnackBar(state.error.toString().replaceAll('Exception: ', ''));
      } else {
        if (mounted) context.go('/home');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  // Handle Sign-Up
  Future<void> _handleSignUp() async {
    if (!_formKeySignUp.currentState!.validate()) return;

    final name = _signUpNameController.text.trim();
    final input = _signUpEmailOrPhoneController.text.trim();
    final password = _signUpPasswordController.text;
    final isPhone = RegExp(r'^\d{10}$').hasMatch(input);

    if (isPhone) {
      _openOtpBottomSheet(input, name: name);
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).signUpWithEmail(
            name,
            input,
            password,
          );

      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        _showErrorSnackBar(state.error.toString().replaceAll('Exception: ', ''));
      } else {
        _showSuccessSnackBar('Account created successfully!');
        if (mounted) context.go('/home');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: AppColors.surfaceLight,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the 6-digit OTP sent to +91 $phone (Demo: 123456)',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
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
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      if (secondsRemaining == 0)
                        TextButton(
                          onPressed: () {
                            setModalState(() => secondsRemaining = 30);
                            ref.read(authControllerProvider.notifier).sendOtp(phone);
                          },
                          child: const Text('Resend OTP'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Verify & Continue',
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
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address and we will send you a password reset link.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            CustomTextField(
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
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSuccessSnackBar('Password reset link sent to ${emailController.text}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(100, 42),
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Brand Icon & Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.sports_soccer_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TurfSpot',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to TurfSpot',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Discover and compare turfs in your city.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),

              // Tab Bar (Login / Sign Up)
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Log In'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Views
              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // LOGIN FORM
                    Form(
                      key: _formKeyLogin,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _loginEmailOrPhoneController,
                            labelText: 'Email or Mobile Number',
                            hintText: 'player@example.com or 10-digit mobile',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email or phone number';
                              }
                              final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(val.trim());
                              final isPhone = RegExp(r'^\d{10}$').hasMatch(val.trim());
                              if (!isEmail && !isPhone) {
                                return 'Enter a valid email or 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _loginPasswordController,
                            labelText: 'Password',
                            hintText: 'Enter your password (min 8 chars)',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (val) {
                              if (val == null || val.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _openForgotPasswordDialog,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Log In',
                            isLoading: isLoading,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),

                    // SIGN UP FORM
                    Form(
                      key: _formKeySignUp,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _signUpNameController,
                            labelText: 'Full Name',
                            hintText: 'John Doe',
                            prefixIcon: Icons.badge_outlined,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _signUpEmailOrPhoneController,
                            labelText: 'Email or Mobile Number',
                            hintText: 'name@example.com or 10-digit mobile',
                            prefixIcon: Icons.contact_mail_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter email or phone number';
                              }
                              final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(val.trim());
                              final isPhone = RegExp(r'^\d{10}$').hasMatch(val.trim());
                              if (!isEmail && !isPhone) {
                                return 'Enter a valid email or 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _signUpPasswordController,
                            labelText: 'Create Password',
                            hintText: 'At least 8 characters',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            validator: (val) {
                              if (val == null || val.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Create Account',
                            isLoading: isLoading,
                            onPressed: _handleSignUp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 20),

              // Google Sign In
              OutlinedButton.icon(
                onPressed: isLoading ? null : _handleGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.border),
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.white),
                label: Text(
                  'Continue with Google',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
