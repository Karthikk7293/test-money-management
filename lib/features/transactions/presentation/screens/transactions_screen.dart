import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const TransactionsRequested());
  }

  void _confirmDelete(String id) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete transaction?', style: AppTextStyles.titleMedium),
        content: Text(
            'It will be hidden immediately and removed from the cloud on next sync.',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionBloc>().add(TransactionDeleted(id));
              Navigator.of(dialogContext).pop();
            },
            child: Text('Delete',
                style: TextStyle(color: AppColors.debit)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Transactions',
                        style: AppTextStyles.headlineMedium),
                  ),
                  Expanded(
                    child: _buildList(state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(TransactionState state) {
    if (state.isLoading) return const TransactionShimmer(itemCount: 10);
    if (state.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  color: AppColors.textSecondary, size: 44),
              const SizedBox(height: 12),
              Text('No transactions yet', style: AppTextStyles.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Add your first transaction from the + button.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context
          .read<TransactionBloc>()
          .add(const TransactionsRefreshed()),
      backgroundColor: AppColors.surface,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 4, bottom: 120),
        itemCount: state.transactions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final t = state.transactions[i];
          return TransactionCard(
            transaction: t,
            onDelete: () => _confirmDelete(t.id),
          );
        },
      ),
    );
  }
}
