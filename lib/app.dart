import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/nickname_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/auth/presentation/screens/phone_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/screens/home_shell.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'injection.dart';

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key, required this.container});

  final AppContainer container;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: container.prefs),
        RepositoryProvider.value(value: container.authRepository),
        RepositoryProvider.value(value: container.categoryRepository),
        RepositoryProvider.value(value: container.transactionRepository),
        RepositoryProvider.value(value: container.syncRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              sendOtpUseCase: container.sendOtp,
              verifyOtpUseCase: container.verifyOtp,
              createAccountUseCase: container.createAccount,
              prefs: container.prefs,
            )..add(const AuthBootstrapRequested()),
          ),
          BlocProvider(
            create: (_) => CategoryBloc(
              loadCategories: container.loadCategories,
              addCategory: container.addCategory,
              deleteCategory: container.deleteCategory,
            ),
          ),
          BlocProvider(
            create: (_) => TransactionBloc(
              loadTransactions: container.loadTransactions,
              addTransaction: container.addTransaction,
              deleteTransaction: container.deleteTransaction,
            ),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(
              loadSummary: container.loadDashboardSummary,
              loadRecent: container.loadRecentTransactions,
              transactionBloc: context.read<TransactionBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => SyncBloc(
              runSync: container.runSync,
              loadPendingCounts: container.loadPendingCounts,
              categoryBloc: context.read<CategoryBloc>(),
              transactionBloc: context.read<TransactionBloc>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const SplashScreen();
          case AuthStatus.onboarding:
            return const OnboardingScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const PhoneScreen();
          case AuthStatus.awaitingOtp:
            return const OtpScreen();
          case AuthStatus.awaitingNickname:
            return const NicknameScreen();
          case AuthStatus.authenticating:
            return const SplashScreen();
          case AuthStatus.authenticated:
            return const HomeShell();
        }
      },
    );
  }
}
