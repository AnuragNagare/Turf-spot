import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/turf_model.dart';
import '../providers/turf_provider.dart';
import '../widgets/detail/amenities_grid.dart';
import '../widgets/detail/detail_action_bar.dart';
import '../widgets/detail/detail_photo_header.dart';
import '../widgets/detail/detail_specs_row.dart';
import '../widgets/detail/detail_title_block.dart';
import '../widgets/detail/opening_hours_card.dart';
import '../widgets/detail/photo_thumbnail_strip.dart';
import '../widgets/detail/pricing_card.dart';

class TurfDetailScreen extends ConsumerStatefulWidget {
  final String turfId;

  const TurfDetailScreen({super.key, required this.turfId});

  @override
  ConsumerState<TurfDetailScreen> createState() => _TurfDetailScreenState();
}

class _TurfDetailScreenState extends ConsumerState<TurfDetailScreen> {
  static const _photoHeaderHeight = 260.0;
  static const _contentMaxWidth = 640.0;

  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    // Providers must not be modified while the widget tree is building.
    Future.microtask(() {
      if (mounted) ref.read(recentlyViewedProvider.notifier).add(widget.turfId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _selectPhoto(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Open Dialer Intent
  Future<void> _makeCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Open Google Maps Directions
  Future<void> _openDirections(TurfModel turf) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${turf.latitude},${turf.longitude}',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Share Turf Details
  void _shareTurf(TurfModel turf) {
    Share.share(
      'Check out ${turf.name} in ${turf.area}, ${turf.city}! Rates start at ${AppFormatters.formatCurrency(turf.pricePerHour)}/hr. Call: ${turf.phone}',
      subject: 'Play at ${turf.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final turfAsync = ref.watch(turfDetailProvider(widget.turfId));

    return Scaffold(
      backgroundColor: AppColors.authSheet,
      body: turfAsync.when(
        data: (turf) {
          if (turf == null) {
            return _buildMessage(
              const EmptyStateWidget(
                light: true,
                icon: Icons.error_outline_rounded,
                title: 'Turf Not Found',
                description: 'This turf is either unavailable or has been removed.',
              ),
            );
          }

          return _buildContent(turf);
        },
        loading: _buildLoading,
        error: (err, _) => _buildMessage(
          EmptyStateWidget(
            light: true,
            icon: Icons.error_outline_rounded,
            title: 'Error loading turf',
            description: err.toString(),
            actionText: 'Retry',
            onAction: () => ref.invalidate(turfDetailProvider(widget.turfId)),
          ),
        ),
      ),
    );
  }

  /// Back button above a centred message (not found / error).
  Widget _buildMessage(Widget message) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.authText),
              onPressed: _goBack,
            ),
          ),
        ),
        Expanded(child: message),
      ],
    );
  }

  Widget _buildLoading() {
    final topInset = MediaQuery.paddingOf(context).top;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(
          width: double.infinity,
          height: _photoHeaderHeight + topInset,
          borderRadius: 0,
          color: AppColors.authFieldBorder,
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 220, height: 30, color: AppColors.authFieldBorder),
              SizedBox(height: 12),
              ShimmerBox(width: 160, height: 18, color: AppColors.authFieldBorder),
              SizedBox(height: 24),
              ShimmerBox(
                width: double.infinity,
                height: 120,
                borderRadius: 20,
                color: AppColors.authFieldBorder,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(TurfModel turf) {
    final photos = turf.photos.isEmpty ? [turf.coverPhoto] : turf.photos;
    final topInset = MediaQuery.paddingOf(context).top;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _photoHeaderHeight + topInset,
                  width: double.infinity,
                  child: DetailPhotoHeader(
                    turfId: turf.id,
                    photos: photos,
                    controller: _pageController,
                    currentIndex: _currentPhotoIndex,
                    onPageChanged: (index) => setState(() => _currentPhotoIndex = index),
                    onBack: _goBack,
                    onShare: () => _shareTurf(turf),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhotoThumbnailStrip(
                          photos: photos,
                          currentIndex: _currentPhotoIndex,
                          onSelect: _selectPhoto,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DetailTitleBlock(turf: turf),
                              const SizedBox(height: 16),
                              DetailSpecsRow(turf: turf),
                              const SizedBox(height: 16),
                              PricingCard(turf: turf),
                              const SizedBox(height: 14),
                              OpeningHoursCard(openingHours: turf.openingHours),
                              const SizedBox(height: 20),
                              AmenitiesGrid(amenities: turf.amenities),
                              const SizedBox(height: 24),
                              _buildMapPreview(turf),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DetailActionBar(
          onCall: () => _makeCall(turf.phone),
          onDirections: () => _openDirections(turf),
          onShare: () => _shareTurf(turf),
        ),
      ],
    );
  }

  Widget _buildMapPreview(TurfModel turf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location on Map',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.authText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.authField,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.authFieldBorder),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pin_drop_rounded, size: 40, color: AppColors.authForest),
                    const SizedBox(height: 6),
                    Text(
                      turf.area,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.authText,
                      ),
                    ),
                    Text(
                      'Lat: ${turf.latitude}, Lon: ${turf.longitude}',
                      style: const TextStyle(fontSize: 11, color: AppColors.authMuted),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(turf),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.authForest,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Navigate'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
