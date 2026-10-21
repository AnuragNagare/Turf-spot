import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// White floating search field with a filter button.
class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final bool showClear;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
    required this.showClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: AppColors.authText, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.authText, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Search turf, area or landmark...',
                hintStyle: TextStyle(color: AppColors.authMuted, fontSize: 15),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (showClear)
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded, color: AppColors.authMuted, size: 20),
              onPressed: onClear,
            ),
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune_rounded, color: AppColors.authText, size: 24),
            onPressed: onFilterTap,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
