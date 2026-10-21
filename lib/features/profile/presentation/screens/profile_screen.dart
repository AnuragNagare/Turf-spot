import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../turfs/presentation/providers/turf_provider.dart';
import '../widgets/coming_soon_sheet.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/preferred_sport_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _contentMaxWidth = 640.0;

  // Logout Confirmation Dialog
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.authSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Log Out',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.authText,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your TurfSpot account?',
          style: TextStyle(color: AppColors.authMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.authMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).signOut();
              if (mounted) context.go('/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(90, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // Delete Account Confirmation Dialog
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.authSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Account',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: const Text(
          'This action is irreversible. All your profile data and preferences will be permanently erased.',
          style: TextStyle(color: AppColors.authMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.authMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).deleteAccount();
              if (mounted) context.go('/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(110, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.sports_soccer_rounded,
        size: 40,
        color: AppColors.authForest,
      ),
      children: const [
        SizedBox(height: 8),
        Text(AppConstants.appTagline),
      ],
    );
  }

  Future<void> _contactSupport() async {
    final uri = Uri(scheme: 'mailto', path: AppConstants.supportEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support email: ${AppConstants.supportEmail}'),
        ),
      );
    }
  }

  void _changeSport(PreferredSport sport) {
    ref.read(authControllerProvider.notifier).updateProfile(preferredSport: sport);

    // Keep the Home screen's default filter in sync.
    final filterValue = switch (sport) {
      PreferredSport.cricket => 'Cricket',
      PreferredSport.football => 'Football',
      PreferredSport.both => 'All',
    };
    ref.read(selectedSportFilterProvider.notifier).state = filterValue;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value ?? ref.watch(authControllerProvider).value;

    return Scaffold(
      backgroundColor: AppColors.authSheet,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        items: const [
          AppBottomNavItem(icon: Icons.home_outlined, label: 'Home'),
          AppBottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/home');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              user: user,
              onCameraTap: () => ComingSoonSheet.show(
                context,
                title: 'Change profile photo',
                message: 'Photo upload is on the way.',
                options: const [
                  ComingSoonOption(Icons.photo_camera_outlined, 'Take photo'),
                  ComingSoonOption(Icons.photo_library_outlined, 'Choose from gallery'),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Column(
                    children: [
                      PreferredSportCard(
                        selected: user?.preferredSport ?? PreferredSport.both,
                        onChanged: _changeSport,
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuCard(
                        items: [
                          ProfileMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Update your name, email or phone',
                            onTap: () {
                              if (user != null) EditProfileSheet.show(context, user);
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notifications',
                            subtitle: 'Manage your preferences',
                            onTap: () => ComingSoonSheet.show(
                              context,
                              title: 'Notifications',
                              message: 'Notification settings are coming soon.',
                            ),
                          ),
                          ProfileMenuItem(
                            icon: Icons.location_on_outlined,
                            title: 'Saved Turfs',
                            subtitle: 'View your favourite turfs',
                            onTap: () => context.push('/saved-turfs'),
                          ),
                          ProfileMenuItem(
                            icon: Icons.history_rounded,
                            title: 'Recently Viewed',
                            subtitle: 'Your recently viewed turfs',
                            onTap: () => context.push('/recently-viewed'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuCard(
                        items: [
                          ProfileMenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About TurfSpot',
                            subtitle: 'App version ${AppConstants.appVersion}',
                            onTap: _showAbout,
                          ),
                          ProfileMenuItem(
                            icon: Icons.description_outlined,
                            title: 'Terms & Conditions',
                            onTap: () => context.push('/terms'),
                          ),
                          ProfileMenuItem(
                            icon: Icons.verified_user_outlined,
                            title: 'Privacy Policy',
                            onTap: () => context.push('/privacy'),
                          ),
                          ProfileMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            onTap: _contactSupport,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuCard(
                        items: [
                          ProfileMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Log Out',
                            subtitle: 'Sign out from your account',
                            onTap: _confirmLogout,
                          ),
                          ProfileMenuItem(
                            icon: Icons.delete_outline_rounded,
                            title: 'Delete Account',
                            subtitle: 'This action cannot be undone',
                            destructive: true,
                            onTap: _confirmDeleteAccount,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
