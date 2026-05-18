import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class MonthlyLimitCard extends StatelessWidget {
  const MonthlyLimitCard({
    super.key,
    required this.spent,
    required this.limit,
  });

  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final progress = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final remainingPct = (1 - progress) * 100;
    final exceeded = spent > limit;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MONTHLY LIMIT',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(Formatters.currency(spent),
                  style: AppTextStyles.titleLarge),
              const SizedBox(width: 4),
              Text(' / ${Formatters.currency(limit)}',
                  style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(
                exceeded ? AppColors.debit : AppColors.credit,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            exceeded
                ? 'Limit exceeded'
                : '${remainingPct.toStringAsFixed(0)}% Remaining',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
