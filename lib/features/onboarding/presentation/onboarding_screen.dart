import 'package:exampro/core/analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.read(analyticsProvider);
    final theme = Theme.of(context);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
            SliverToBoxAdapter(
              child: _HeroHeader(
                onCreateAccount: () {
                  analytics.event('cta_create_account');
                  context.go('/register');
                },
                onSignIn: () {
                  analytics.event('cta_sign_in');
                  context.go('/auth');
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Everything you need for the Life in the UK Test',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Master the official handbook with practice questions, timed mock exams, and smart progress tracking.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(child: _FeatureGrid()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              sliver: const SliverToBoxAdapter(child: _HowItWorks()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () {
                        analytics.event('cta_get_started');
                        context.go('/register');
                      },
                      child: const Text('Get Started'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/auth'),
                      child: const Text('I already have an account'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;
  const _HeroHeader({required this.onCreateAccount, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final content = [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Life in the UK\nTest Prep',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Practice questions • Mock tests • Study plan',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _Pill(text: 'Timed mocks'),
                  _Pill(text: 'Official topics'),
                  _Pill(text: 'Progress insights'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(onPressed: onCreateAccount, child: const Text('Create Account')),
                  const SizedBox(width: 12),
                  OutlinedButton(onPressed: onSignIn, child: const Text('Sign In')),
                ],
              )
            ],
          ),
        ),
        const SizedBox(width: 12, height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(
              'assets/images/uk_hero.svg',
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Container(color: Colors.white),
            ),
          ),
        ),
      ];

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.15),
              theme.colorScheme.secondary.withOpacity(0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isNarrow
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: content)
            : Row(crossAxisAlignment: CrossAxisAlignment.center, children: content),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = const [
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

    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth > 640;
      final spacing = 12.0;
      if (isWide) {
        return Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(child: items[i]),
              if (i != items.length - 1) SizedBox(width: spacing),
            ]
          ],
        );
      }
      return Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1) SizedBox(height: spacing),
          ]
        ],
      );
    });
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = const [
      ('1. Learn', 'Skim the official handbook by topic.'),
      ('2. Practice', 'Answer curated questions with explanations.'),
      ('3. Mock', 'Timed tests that mirror exam format.'),
      ('4. Review', 'Focus on weak areas and improve.'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
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
                    if (i != children.length - 1) const SizedBox(width: 10),
                  ]
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) const SizedBox(height: 10),
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final Color color;
  const _FeatureCard({required this.title, required this.subtitle, required this.asset, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: SvgPicture.asset(asset, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          )
        ],
      ),
    );
  }
}
