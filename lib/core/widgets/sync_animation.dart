import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SyncSpinner extends StatefulWidget {
  const SyncSpinner({super.key, this.size = 22, this.color});

  final double size;
  final Color? color;

  @override
  State<SyncSpinner> createState() => _SyncSpinnerState();
}

class _SyncSpinnerState extends State<SyncSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.sync_rounded,
        size: widget.size,
        color: widget.color ?? AppColors.primary,
      ),
    );
  }
}

class SyncOverlay extends StatelessWidget {
  const SyncOverlay({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SyncSpinner(size: 24),
            const SizedBox(width: 14),
            Text(message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}
