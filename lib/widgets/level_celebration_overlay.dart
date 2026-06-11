import 'dart:math';
import 'package:flutter/material.dart';

class LevelCelebrationOverlay extends StatefulWidget {
  final String level;
  const LevelCelebrationOverlay({super.key, required this.level});

  @override
  State<LevelCelebrationOverlay> createState() => _LevelCelebrationOverlayState();
}

class _LevelCelebrationOverlayState extends State<LevelCelebrationOverlay>
    with TickerProviderStateMixin {
  // Slow breathe: badge scale + glow + text shadow
  late final AnimationController _pulseController;
  // Continuous orbit rotation for the surrounding icons
  late final AnimationController _orbitController;
  // Staggered ripple rings that expand outward and fade
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  Color get _color => widget.level == 'Expert'
      ? const Color(0xFFFFD700)
      : const Color(0xFF00D4FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseController,
              _orbitController,
              _ringController,
            ]),
            builder: (context, _) {
              final pulse = _pulseController.value; // 0 → 1 → 0
              final orbit = _orbitController.value; // 0 → 1 continuous
              final ring  = _ringController.value;  // 0 → 1 continuous

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Animated badge area ──────────────────────────────────
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Three staggered expanding rings
                        for (int i = 0; i < 3; i++) _buildRing(i, ring),

                        // Eight orbiting bolt / star icons
                        for (int i = 0; i < 8; i++) _buildOrbitIcon(i, orbit, pulse),

                        // Central glowing badge
                        _buildCenterBadge(pulse),
                      ],
                    ),
                  ),

                  // ── Level name ───────────────────────────────────────────
                  const SizedBox(height: 8),
                  Text(
                    widget.level.toUpperCase(),
                    style: TextStyle(
                      color: _color,
                      fontFamily: 'RobotoMono',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: _color.withOpacity(0.35 + pulse * 0.65),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),

                  // ── Subtitle ─────────────────────────────────────────────
                  const SizedBox(height: 6),
                  Text(
                    'LEVEL ACTIVE',
                    style: TextStyle(
                      color: _color.withOpacity(0.55),
                      fontFamily: 'RobotoMono',
                      fontSize: 10,
                      letterSpacing: 3,
                    ),
                  ),

                  // ── Dismiss hint ─────────────────────────────────────────
                  const SizedBox(height: 28),
                  const Text(
                    '[ TAP TO CONTINUE ]',
                    style: TextStyle(
                      color: Color(0xFF607B96),
                      fontFamily: 'RobotoMono',
                      fontSize: 8,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Ring helper ─────────────────────────────────────────────────────────────
  // Each ring starts small (80 px), expands to 260 px, and fades out as it grows.
  Widget _buildRing(int index, double ring) {
    final phase = (ring + index / 3) % 1.0;
    final size  = 80.0 + phase * 180.0;
    final opacity = (1.0 - phase) * 0.45;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _color.withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }

  // ── Orbit icon helper ────────────────────────────────────────────────────────
  // Icons are placed on a circle of radius 108, with each one waving in size
  // and opacity using a phase-offset sine so they don't all pulse together.
  Widget _buildOrbitIcon(int index, double orbit, double pulse) {
    final angle = orbit * 2 * pi + (index / 8) * 2 * pi;
    const radius = 108.0;
    final x = radius * cos(angle);
    final y = radius * sin(angle);
    final wave = (sin(pulse * pi + index * pi / 4) + 1) / 2; // 0..1
    return Transform.translate(
      offset: Offset(x, y),
      child: Icon(
        index.isEven ? Icons.bolt : Icons.star,
        color: _color.withOpacity(0.25 + wave * 0.75),
        size: 10.0 + wave * 8.0,
      ),
    );
  }

  // ── Central badge helper ─────────────────────────────────────────────────────
  Widget _buildCenterBadge(double pulse) {
    final scale = 0.93 + pulse * 0.14;
    final glow  = 0.40 + pulse * 0.60;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _color.withOpacity(0.10),
          border: Border.all(color: _color, width: 2),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(glow * 0.65),
              blurRadius: 24,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Icon(Icons.bolt, color: _color, size: 44),
      ),
    );
  }
}
