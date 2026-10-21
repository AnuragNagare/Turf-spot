import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.color,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.color ?? AppColors.surfaceLight).withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class TurfCardSkeleton extends StatelessWidget {
  const TurfCardSkeleton({super.key});

  static const _shade = AppColors.authFieldBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 130, height: 170, borderRadius: 16, color: _shade),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 150, height: 20, color: _shade),
                SizedBox(height: 8),
                ShimmerBox(width: 110, height: 14, color: _shade),
                SizedBox(height: 12),
                Row(
                  children: [
                    ShimmerBox(width: 70, height: 24, borderRadius: 12, color: _shade),
                    SizedBox(width: 8),
                    ShimmerBox(width: 70, height: 24, borderRadius: 12, color: _shade),
                  ],
                ),
                SizedBox(height: 12),
                ShimmerBox(width: 120, height: 14, color: _shade),
                SizedBox(height: 14),
                ShimmerBox(width: double.infinity, height: 44, borderRadius: 14, color: _shade),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
