import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/info_page_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/turf_ids_list_screen.dart';
import '../../features/turfs/presentation/providers/turf_provider.dart';
import '../../features/turfs/presentation/screens/home_screen.dart';
import '../../features/turfs/presentation/screens/turf_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/turf/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TurfDetailScreen(turfId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/saved-turfs',
        builder: (context, state) => TurfIdsListScreen(
          title: 'Saved Turfs',
          selectIds: (ref) => ref.watch(favouriteTurfsProvider).toList(),
          emptyIcon: Icons.favorite_border_rounded,
          emptyTitle: 'No saved turfs yet',
          emptyMessage: 'Tap the heart on a turf to save it here.',
        ),
      ),
      GoRoute(
        path: '/recently-viewed',
        builder: (context, state) => TurfIdsListScreen(
          title: 'Recently Viewed',
          selectIds: (ref) => ref.watch(recentlyViewedProvider),
          emptyIcon: Icons.history_rounded,
          emptyTitle: 'Nothing viewed yet',
          emptyMessage: 'Turfs you open will show up here.',
        ),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const InfoPageScreen(title: 'Terms & Conditions'),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const InfoPageScreen(title: 'Privacy Policy'),
      ),
    ],
  );
});
