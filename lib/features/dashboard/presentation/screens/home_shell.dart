import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../transactions/presentation/screens/add_transaction_sheet.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  NavTab _tab = NavTab.home;

  static const List<Widget> _pages = [
    DashboardScreen(),
    TransactionsScreen(),
    ProfileScreen(),
  ];

  int _indexOf(NavTab t) => switch (t) {
        NavTab.home => 0,
        NavTab.transactions => 1,
        NavTab.profile => 2,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _indexOf(_tab), children: _pages),
      bottomNavigationBar: AppBottomNav(
        current: _tab,
        onChanged: (t) => setState(() => _tab = t),
      ),
      floatingActionButton: _tab == NavTab.profile
          ? null
          : const _ShellFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ShellFab extends StatelessWidget {
  const _ShellFab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: GestureDetector(
        onTap: () => AddTransactionSheet.show(context),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppColors.credit,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.credit.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
