import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class NeonGlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color glowColor;
  final EdgeInsets padding;
  const NeonGlassCard({super.key, required this.child, this.borderRadius = 24, this.glowColor = const Color(0xFF4DA3FF), this.padding = const EdgeInsets.all(20)});

  @override
  State<NeonGlassCard> createState() => _NeonGlassCardState();
}

class _NeonGlassCardState extends State<NeonGlassCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _NeonBorderPainter(progress: _ctrl.value, radius: widget.borderRadius, glow: widget.glowColor),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                ),
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NeonBorderPainter extends CustomPainter {
  final double progress; // 0..1
  final double radius;
  final Color glow;
  _NeonBorderPainter({required this.progress, required this.radius, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final rect = rrect.outerRect;

    // Outer glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = glow.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 20);
    canvas.drawRRect(rrect, glowPaint);

    // Animated sweep highlight traveling around the border
    final start = progress;
    final mid = (progress + 0.02) % 1.0;
    final end = (progress + 0.04) % 1.0;
    final sweep = SweepGradient(
      colors: [
        Colors.transparent,
        glow.withOpacity(0.95),
        Colors.transparent,
      ],
      stops: [start, mid, end]..sort(),
      transform: GradientRotation(-math.pi / 2),
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = sweep.createShader(rect);
    canvas.drawRRect(rrect, stroke);

    // Thin static outline for shape definition
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.15);
    canvas.drawRRect(rrect.deflate(0.5), outline);
  }

  @override
  bool shouldRepaint(covariant _NeonBorderPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.glow != glow || oldDelegate.radius != radius;
}

class NeonBackground extends StatelessWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 1.2,
          center: Alignment(-0.6, -0.6),
          colors: [Color(0xFF0B1B2B), Color(0xFF0A1725), Color(0xFF08121C)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _glowBlob(const Color(0xFF3BA4FF)),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _glowBlob(const Color(0xFF6A5BE2)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _glowBlob(Color c) => Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withOpacity(0.15),
          boxShadow: [
            BoxShadow(color: c.withOpacity(0.35), blurRadius: 100, spreadRadius: 60),
          ],
        ),
      );
}

