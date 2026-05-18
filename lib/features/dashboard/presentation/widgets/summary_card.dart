import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.kind,
  });

  final String label;
  final double amount;
  final SummaryKind kind;

  @override
  Widget build(BuildContext context) {
    final gradient = kind == SummaryKind.income
        ? const LinearGradient(
            colors: [AppColors.incomeStart, AppColors.incomeEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.expenseStart, AppColors.expenseEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final arrow =
        kind == SummaryKind.income ? Icons.arrow_downward : Icons.arrow_upward;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(arrow, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  Formatters.currency(amount),
                  style: AppTextStyles.amount.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum SummaryKind { income, expense }
