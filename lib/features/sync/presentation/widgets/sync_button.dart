import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/sync_animation.dart';
import '../bloc/sync_bloc.dart';

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SyncBloc, SyncState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SyncStatus.success) {
          final r = state.lastReport;
          final msg = r == null
              ? 'Synced'
              : 'Synced • '
                  'cats: +${r.categoriesUploaded} / −${r.categoriesDeleted}, '
                  'txns: +${r.transactionsUploaded} / −${r.transactionsDeleted}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        } else if (state.status == SyncStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Sync failed')),
          );
        }
      },
      builder: (context, state) {
        final pendingCount = state.pending?.total ?? 0;
        return GestureDetector(
          onTap: state.isRunning
              ? null
              : () => context.read<SyncBloc>().add(const SyncRunRequested()),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: state.isRunning
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isRunning)
                  const SyncSpinner(size: 18, color: AppColors.primary)
                else
                  const Icon(Icons.cloud_upload_outlined,
                      size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  state.isRunning ? 'Syncing…' : 'Sync',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: state.isRunning ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (pendingCount > 0 && !state.isRunning) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
