import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../turfs/presentation/providers/turf_provider.dart';
import '../../../turfs/presentation/widgets/turf_card.dart';

/// List of turfs for a set of ids, used by Saved Turfs and Recently Viewed.
class TurfIdsListScreen extends ConsumerWidget {
  final String title;
  final List<String> Function(WidgetRef ref) selectIds;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  const TurfIdsListScreen({
    super.key,
    required this.title,
    required this.selectIds,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idsKey = selectIds(ref).join(',');
    final turfsAsync = ref.watch(turfsByIdsProvider(idsKey));

    return Scaffold(
      backgroundColor: AppColors.authSheet,
      appBar: AppBar(
        backgroundColor: AppColors.authSheet,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.authText),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.authText,
          ),
        ),
      ),
      body: turfsAsync.when(
        data: (turfs) {
          if (turfs.isEmpty) {
            return EmptyStateWidget(
              light: true,
              icon: emptyIcon,
              title: emptyTitle,
              description: emptyMessage,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: turfs.length,
            itemBuilder: (context, index) => TurfCard(turf: turfs[index]),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: 3,
          itemBuilder: (context, index) => const TurfCardSkeleton(),
        ),
        error: (err, _) => EmptyStateWidget(
          light: true,
          icon: Icons.error_outline_rounded,
          title: 'Something went wrong',
          description: err.toString(),
          actionText: 'Retry',
          onAction: () => ref.invalidate(turfsByIdsProvider(idsKey)),
        ),
      ),
    );
  }
}
