// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? Colors.white10 : Colors.grey[300]!),
      highlightColor: highlightColor ?? (isDark ? Colors.white12 : Colors.grey[100]!),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonListLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonListLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            const SkeletonLoader(width: 48, height: 48, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  SkeletonLoader(width: 120, height: 10),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class SkeletonCardLoader extends StatelessWidget {
  const SkeletonCardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 140, borderRadius: 12),
          const SizedBox(height: 16),
          SkeletonLoader(width: 180, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          SkeletonLoader(width: double.infinity, height: 12, borderRadius: 4),
          const SizedBox(height: 6),
          SkeletonLoader(width: 140, height: 12, borderRadius: 4),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) => SkeletonLoader(
              width: 80, height: 32, borderRadius: 8,
            )),
          ),
        ],
      ),
    );
  }
}
