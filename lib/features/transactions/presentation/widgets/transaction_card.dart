import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  final TransactionEntity transaction;
  final VoidCallback? onDelete;

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('bill')) return Icons.water_drop_outlined;
    if (n.contains('transport') || n.contains('travel')) {
      return Icons.directions_car_outlined;
    }
    if (n.contains('shop')) return Icons.shopping_bag_outlined;
    if (n.contains('rent') || n.contains('home')) return Icons.home_outlined;
    return Icons.shopping_cart_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppColors.credit : AppColors.debit;
    final sign = isCredit ? '+' : '-';
    final title = transaction.note.isEmpty
        ? transaction.categoryName
        : transaction.note;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconForCategory(transaction.categoryName),
                color: AppColors.textSecondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(transaction.categoryName,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.date(transaction.timestamp),
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 4),
              Text(
                '$sign${Formatters.currency(transaction.amount)}',
                style: AppTextStyles.titleMedium.copyWith(color: color),
              ),
            ],
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: AppColors.debit.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.debit),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
