import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const String _bgImage = 'assets/images/walkthrough_bg.png';

  static const List<_WalkthroughItem> _items = [
    _WalkthroughItem(
      title: 'Privacy by Default, With Zero\nAds or Hidden Tracking',
      subtitle: 'No ads. No trackers. No third-party analytics.',
      cta: 'Next',
    ),
    _WalkthroughItem(
      title: 'Insights That Help You Spend\nBetter Without Complexity',
      subtitle: 'See category-wise spending, recent activity.',
      cta: 'Next',
    ),
    _WalkthroughItem(
      title: 'Local-First Tracking That\nStays Fully On Your Device',
      subtitle: 'Your finances stay on your phone.',
      cta: 'Get Started',
    ),
  ];

  bool get _isLast => _index == _items.length - 1;

  void _next() {
    if (_isLast) {
      context.read<AuthBloc>().add(const AuthOnboardingCompleted());
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _back() {
    if (_index == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _WalkthroughPage(item: _items[i]),
          ),
          // SKIP — top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: TextButton(
              onPressed: () => context
                  .read<AuthBloc>()
                  .add(const AuthOnboardingCompleted()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentBlue,
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentBlue,
                ),
              ),
              child: const Text('SKIP'),
            ),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageDots(count: _items.length, index: _index),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _items[_index].title,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _items[_index].subtitle,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        if (_index > 0)
                          _CircleBack(onTap: _back)
                        else
                          const SizedBox(width: 0),
                        if (_index > 0) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _next,
                            child: Text(_items[_index].cta),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkthroughItem {
  const _WalkthroughItem({
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  final String title;
  final String subtitle;
  final String cta;
}

class _WalkthroughPage extends StatelessWidget {
  const _WalkthroughPage({required this.item});
  final _WalkthroughItem item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            _OnboardingScreenState._bgImage,
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.background),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.58, 1.0],
                colors: [
                  AppColors.background.withValues(alpha: 0.0),
                  AppColors.background.withValues(alpha: 0.0),
                  AppColors.background.withValues(alpha: 0.85),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 3,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
    );
  }
}
