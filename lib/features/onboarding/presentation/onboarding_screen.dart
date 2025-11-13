import 'dart:async';
import 'package:citizentest/core/analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'widgets/language_picker.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.read(analyticsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? const LinearGradient(
            colors: [Color(0xFF2A2E79), Color(0xFF161A4F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFE6F3FF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive scale factors (kept simple; feel free to tweak)
    final contentMaxWidth = w.clamp(360.0, 720.0);
    final basePaddingH = (w < 380) ? 20.0 : 28.0;
    final basePaddingV = (h < 720) ? 28.0 : 36.0;
    final titleSize = (w.clamp(320, 820) / 9.8).clamp(26, 56).toDouble();
    final subSize = (titleSize * 0.36).clamp(13, 20).toDouble();
    final buttonHeight = (h < 720) ? 56.0 : 60.0;
    final bigGap = (h < 720) ? 20.0 : 28.0;
    final hugeGap = (h < 720) ? 28.0 : 40.0;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: bg),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Decorative bits (nudged further out so the content breathes)
              const _DotsPattern(top: 24, right: 12),
              const _DotsPattern(bottom: 24, left: 12),
              const Positioned(top: 12, left: 12, child: LanguagePicker()),
              const Positioned(bottom: 24, right: 16, child: _FlagCycler()),
              // Main content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: basePaddingH,
                  vertical: basePaddingV,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: bigGap),
                        _HeroTitle(isDark: isDark, fontSize: titleSize),
                        SizedBox(height: 12),
                        Opacity(
                          opacity: 0.88,
                          child: Text(
                            'Practice for UK, US, Canada, Australia and more.',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0B2540),
                              fontSize: subSize,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                        SizedBox(height: hugeGap),
                        const _ZenovFooter(),
                        Divider(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.20),
                          thickness: 1,
                        ),
                        SizedBox(height: bigGap),

                        // Ticker
                        const _PracticeTestsTicker(),

                        SizedBox(height: hugeGap),

                        // Sign in
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC33),
                              foregroundColor: const Color(0xFF0B2540),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            onPressed: () {
                              analytics.event('cta_sign_in');
                              context.go('/auth');
                            },
                            child: const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Create account
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : const Color(0xFF0B2540),
                              side: BorderSide(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.18),
                              ),
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            onPressed: () {
                              analytics.event('cta_create_account');
                              context.go('/register');
                            },
                            child: const Text(
                              'CREATE AN ACCOUNT',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),

                        // Big breathing space at the bottom on tall phones
                        SizedBox(height: hugeGap),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------------------------------------
/// Optional hero header (kept intact & improved)
/// ----------------------------------------------
class _HeroHeader extends StatelessWidget {
  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;
  const _HeroHeader({
    required this.onCreateAccount,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 640;

      final left = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover the best\nCitizenship tests',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Study smart. Practice more. Sure pass.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill(text: 'Timed mocks'),
              _Pill(text: 'Official topics'),
              _Pill(text: 'Progress insights'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              FilledButton(
                onPressed: onCreateAccount,
                child: const Text('Create Account'),
              ),
              const SizedBox(width: 14),
              OutlinedButton(
                onPressed: onSignIn,
                child: const Text('Sign In'),
              ),
            ],
          )
        ],
      );

      final right = ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1,
          child: SvgPicture.asset(
            'assets/images/uk_hero.svg',
            fit: BoxFit.cover,
            placeholderBuilder: (context) => Container(color: Colors.white),
          ),
        ),
      );

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.14),
              theme.colorScheme.secondary.withValues(alpha: 0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  left,
                  const SizedBox(height: 14),
                  right,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 14),
                  Expanded(child: right),
                ],
              ),
      );
    });
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FeatureCard(
        title: 'Practice Questions',
        subtitle: 'Hundreds of curated Q&As across all chapters',
        asset: 'assets/images/practice.svg',
        color: Color(0xFFE8F0FE),
      ),
      _FeatureCard(
        title: 'Mock Exams',
        subtitle: 'Timed tests that mirror the real exam',
        asset: 'assets/images/mock_test.svg',
        color: Color(0xFFFFF3E0),
      ),
      _FeatureCard(
        title: 'Study Planner',
        subtitle: 'Structured plan to finish on time',
        asset: 'assets/images/study_plan.svg',
        color: Color(0xFFE8F5E9),
      ),
      _FeatureCard(
        title: 'Progress & Insights',
        subtitle: 'Track accuracy and spot weak topics',
        asset: 'assets/images/progress.svg',
        color: Color(0xFFF3E5F5),
      ),
    ];

    const spacing = 14.0;

    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 640;
        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(child: items[i]),
                if (i != items.length - 1) const SizedBox(width: spacing),
              ]
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              items[i],
              if (i != items.length - 1) const SizedBox(height: spacing),
            ]
          ],
        );
      },
    );
  }
}

/// Decorative dotted pattern
class _DotsPattern extends StatelessWidget {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  const _DotsPattern({this.top, this.right, this.bottom, this.left});
  @override
  Widget build(BuildContext context) {
    final color = (Theme.of(context).brightness == Brightness.dark)
        ? const Color(0xFF69B7FF)
        : const Color(0xFF9ED7FF);
    final child = CustomPaint(
      size: const Size(120, 140),
      painter: _DotsPainter(color.withValues(alpha: 0.8)),
    );
    return Positioned(top: top, right: right, bottom: bottom, left: left, child: child);
  }
}

class _DotsPainter extends CustomPainter {
  final Color c;
  _DotsPainter(this.c);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = c
      ..style = PaintingStyle.fill;
    const spacing = 12.0;
    const r = 2.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => false;
}

/// Big title with gradient word
class _HeroTitle extends StatelessWidget {
  final bool isDark;
  final double? fontSize;
  const _HeroTitle({required this.isDark, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          height: 1.05,
          fontSize: fontSize,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover the best',
          style: base?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF0B2540),
          ),
        ),
        _GradientWord('citizenship', style: base),
        Text(
          'practice tests',
          style: base?.copyWith(color: const Color(0xFFFFC107)),
        ),
      ],
    );
  }
}

class _GradientWord extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _GradientWord(this.text, {this.style});
  @override
  Widget build(BuildContext context) {
    const gradient =
        LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF2EA5FF)]);
    return ShaderMask(
      shaderCallback: (bounds) {
        // Guard against zero/negative sizes that can cause CoreGraphics NaNs
        final w = bounds.width.isFinite && bounds.width > 0 ? bounds.width : 1.0;
        final h = bounds.height.isFinite && bounds.height > 0 ? bounds.height : 1.0;
        return gradient.createShader(Rect.fromLTWH(0, 0, w, h));
      },
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

/// Rotating set of waving flags placed at bottom-right
class _FlagCycler extends StatefulWidget {
  const _FlagCycler();
  @override
  State<_FlagCycler> createState() => _FlagCyclerState();
}

class _FlagCyclerState extends State<_FlagCycler>
    with TickerProviderStateMixin {
  late final AnimationController _wave;
  int _index = 0;
  Timer? _timer;
  static const _flags = ['🇨🇦', '🇬🇧', '🇦🇺', '🇺🇸'];

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() => _index = (_index + 1) % _flags.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : const Color(0xFF0B2540);
    return AnimatedBuilder(
      animation: _wave,
      builder: (context, _) {
        final angle = 0.06 * (2 * (_wave.value - 0.5));
        return Transform.rotate(
          angle: angle,
          child: Text(
            _flags[_index],
            style: TextStyle(
              fontSize: 38,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.25), blurRadius: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Countries & tests ticker with slide-in animation every 2 seconds
class _PracticeTestsTicker extends StatefulWidget {
  const _PracticeTestsTicker();
  @override
  State<_PracticeTestsTicker> createState() => _PracticeTestsTickerState();
}

class _PracticeTestsTickerState extends State<_PracticeTestsTicker>
    with SingleTickerProviderStateMixin {
  static const _items = [
    (
      flag: '🇬🇧',
      country: 'United Kingdom',
      test: 'Life in the UK Test',
      desc:
          'A test on British history, culture, and government. Applicants also need a secure English test (e.g., IELTS Life Skills, Trinity GESE).',
    ),
    (
      flag: '🇺🇸',
      country: 'United States',
      test: 'American Civics & English',
      desc:
          'Includes an English test (speaking, reading, writing) and an oral civics test on U.S. history and government.',
    ),
    (
      flag: '🇨🇦',
      country: 'Canada',
      test: 'Canadian Citizenship Test',
      desc:
          'Assesses knowledge of Canada’s history, geography, government, and citizenship rights and responsibilities.',
    ),
    (
      flag: '🇦🇺',
      country: 'Australia',
      test: 'Australian Citizenship Test',
      desc: 'Covers Australian values, history, and symbols.',
    ),
  ];

  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ac.forward();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _ac.reverse();
      setState(() => _index = (_index + 1) % _items.length);
      _ac.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final on = isDark ? Colors.white : const Color(0xFF0B2540);
    final sub = on.withValues(alpha: 0.78);
    final item = _items[_index];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedBuilder(
          animation: _ac,
          builder: (context, _) {
            final dx = (1 - _ac.value) * -18.0;
            final op = _ac.value;
            return Opacity(
              opacity: op,
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.flag, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.country} • ${item.test}',
                            style: TextStyle(
                              color: on,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.desc,
                            style: TextStyle(
                              color: sub,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Section: How it works (kept for completeness)
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const steps = [
      ('1. Learn', 'Skim the official handbook by topic.'),
      ('2. Practice', 'Answer curated questions with explanations.'),
      ('3. Mock', 'Timed tests that mirror exam format.'),
      ('4. Review', 'Focus on weak areas and improve.'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, c) {
            final isWide = c.maxWidth > 640;
            final children = [
              for (final s in steps) _HowItem(title: s.$1, text: s.$2),
            ];
            if (isWide) {
              return Row(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    Expanded(child: children[i]),
                    if (i != children.length - 1) const SizedBox(width: 12),
                  ]
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) const SizedBox(height: 12),
                ]
              ],
            );
          })
        ],
      ),
    );
  }
}

class _HowItem extends StatelessWidget {
  final String title;
  final String text;
  const _HowItem({required this.title, required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZenovFooter extends StatelessWidget {
  const _ZenovFooter();
  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0B2540);
    final sub = on.withValues(alpha: 0.75);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Text('Developed by ZenovTech (c) 2025', style: TextStyle(color: sub, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('info@zenovtech.com', style: TextStyle(color: sub)),
        const SizedBox(height: 4),
        Text('Contact for websites and mobile app development', textAlign: TextAlign.center, style: TextStyle(color: sub)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final Color color;
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(asset, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
