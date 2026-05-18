class AppConstants {
  AppConstants._();

  static const String appName = 'Expense Manager';

  // Shared Preferences keys
  static const String prefsToken = 'auth_token';
  static const String prefsNickname = 'user_nickname';
  static const String prefsPhone = 'user_phone';
  static const String prefsOnboarded = 'onboarding_completed';
  static const String prefsBudgetLimit = 'budget_limit';
  static const String prefsKnownUsers = 'known_users_v1';

  // Database
  static const String dbName = 'expense_manager.db';
  static const int dbVersion = 1;

  // Budget
  static const double defaultBudgetLimit = 1000.0;

  // Notification channels
  static const String budgetChannelId = 'budget_alerts';
  static const String budgetChannelName = 'Budget Alerts';
}
