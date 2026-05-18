import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../transactions/presentation/screens/add_transaction_sheet.dart';
import '../../../transactions/presentation/widgets/transaction_card.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/monthly_limit_card.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferencesService>();
    final nickname =
        (prefs.nickname?.isNotEmpty == true) ? prefs.nickname! : 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.summary == null) {
              return const DashboardShimmer();
            }

            final summary = state.summary;
            final budgetLimit = prefs.budgetLimit;
            final spent = summary?.monthExpense ?? 0;

            return RefreshIndicator(
              onRefresh: () async => context
                  .read<DashboardBloc>()
                  .add(const DashboardRefreshed()),
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.headlineMedium,
                      children: [
                        const TextSpan(text: '👋 '),
                        TextSpan(text: 'Welcome, $nickname!'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: 'Total Income',
                          amount: summary?.totalIncome ?? 0,
                          kind: SummaryKind.income,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          label: 'Total Expense',
                          amount: summary?.totalExpense ?? 0,
                          kind: SummaryKind.expense,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  MonthlyLimitCard(spent: spent, limit: budgetLimit),
                  const SizedBox(height: 22),
                  Text('Recent Transactions',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  if (state.recent.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              color: AppColors.textSecondary, size: 36),
                          const SizedBox(height: 10),
                          Text('No transactions yet',
                              style: AppTextStyles.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the + button to add your first one.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.recent.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TransactionCard(transaction: t),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DashboardFab extends StatelessWidget {
  const DashboardFab({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AddTransactionSheet.show(context),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: AppColors.credit,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.credit.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
