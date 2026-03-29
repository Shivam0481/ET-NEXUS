import 'package:flutter/material.dart';
import 'dart:math' as math;

class DynamicGradientBackground extends StatefulWidget {
  final Widget child;
  const DynamicGradientBackground({super.key, required this.child});

  @override
  State<DynamicGradientBackground> createState() => _DynamicGradientBackgroundState();
}

class _DynamicGradientBackgroundState extends State<DynamicGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _getAlignment(_controller.value),
              end: _getAlignment(_controller.value + 0.5),
              colors: [
                const Color(0xFF0F172A), // Deep Indigo
                const Color(0xFF1E293B), // Indigo Slate
                const Color(0xFFEAB308).withOpacity(0.05), // Very subtle Gold shimmer
                const Color(0xFF0F172A),
              ],
              stops: const [0.0, 0.4, 0.6, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Alignment _getAlignment(double value) {
    double angle = 2 * math.pi * value;
    return Alignment(math.cos(angle) * 1.5, math.sin(angle) * 1.5);
  }
}
