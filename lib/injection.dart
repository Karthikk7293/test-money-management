import 'core/network/api_client.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/preferences_service.dart';
import 'features/auth/data/repositories/local_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/create_account.dart';
import 'features/auth/domain/usecases/send_otp.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/categories/data/datasources/category_local_datasource.dart';
import 'features/categories/data/datasources/category_remote_datasource.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/domain/usecases/category_usecases.dart';
import 'features/sync/data/repositories/sync_repository_impl.dart';
import 'features/sync/domain/repositories/sync_repository.dart';
import 'features/sync/domain/usecases/sync_usecases.dart';
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/transaction_usecases.dart';

/// Lightweight manual DI container — no third-party packages required.
class AppContainer {
  AppContainer._({
    required this.prefs,
    required this.db,
    required this.notifications,
    required this.api,
    required this.authRepository,
    required this.sendOtp,
    required this.verifyOtp,
    required this.createAccount,
    required this.categoryRepository,
    required this.loadCategories,
    required this.addCategory,
    required this.deleteCategory,
    required this.transactionRepository,
    required this.loadTransactions,
    required this.loadRecentTransactions,
    required this.loadDashboardSummary,
    required this.addTransaction,
    required this.deleteTransaction,
    required this.syncRepository,
    required this.runSync,
    required this.loadPendingCounts,
    required this.categoryLocal,
    required this.categoryRemote,
    required this.transactionLocal,
    required this.transactionRemote,
  });

  final PreferencesService prefs;
  final DatabaseService db;
  final NotificationService notifications;
  final ApiClient api;

  // Auth
  final AuthRepository authRepository;
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final CreateAccount createAccount;

  // Categories
  final CategoryRepository categoryRepository;
  final LoadCategories loadCategories;
  final AddCategory addCategory;
  final DeleteCategory deleteCategory;
  final CategoryLocalDataSource categoryLocal;
  final CategoryRemoteDataSource categoryRemote;

  // Transactions
  final TransactionRepository transactionRepository;
  final LoadTransactions loadTransactions;
  final LoadRecentTransactions loadRecentTransactions;
  final LoadDashboardSummary loadDashboardSummary;
  final AddTransaction addTransaction;
  final DeleteTransaction deleteTransaction;
  final TransactionLocalDataSource transactionLocal;
  final TransactionRemoteDataSource transactionRemote;

  // Sync
  final SyncRepository syncRepository;
  final RunSync runSync;
  final LoadPendingCounts loadPendingCounts;

  static Future<AppContainer> bootstrap() async {
    final prefs = await PreferencesService.create();
    final db = DatabaseService.instance;
    final notifications = NotificationService.instance;
    await notifications.init();
    final api = ApiClient(prefs);

    // Auth — fully local while the remote OTP service is unreliable.
    final authRepository = LocalAuthRepository(prefs);

    // Categories
    final categoryLocal = CategoryLocalDataSourceImpl(db);
    final categoryRemote = CategoryRemoteDataSourceImpl(api);
    final categoryRepository = CategoryRepositoryImpl(categoryLocal);

    // Transactions
    final transactionLocal = TransactionLocalDataSourceImpl(db);
    final transactionRemote = TransactionRemoteDataSourceImpl(api);
    final transactionRepository = TransactionRepositoryImpl(transactionLocal);

    // Sync
    final syncRepository = SyncRepositoryImpl(
      categoryLocal: categoryLocal,
      categoryRemote: categoryRemote,
      transactionLocal: transactionLocal,
      transactionRemote: transactionRemote,
    );

    return AppContainer._(
      prefs: prefs,
      db: db,
      notifications: notifications,
      api: api,
      authRepository: authRepository,
      sendOtp: SendOtp(authRepository),
      verifyOtp: VerifyOtp(authRepository),
      createAccount: CreateAccount(authRepository),
      categoryRepository: categoryRepository,
      loadCategories: LoadCategories(categoryRepository),
      addCategory: AddCategory(categoryRepository),
      deleteCategory: DeleteCategory(categoryRepository),
      categoryLocal: categoryLocal,
      categoryRemote: categoryRemote,
      transactionRepository: transactionRepository,
      loadTransactions: LoadTransactions(transactionRepository),
      loadRecentTransactions: LoadRecentTransactions(transactionRepository),
      loadDashboardSummary: LoadDashboardSummary(transactionRepository),
      addTransaction:
          AddTransaction(transactionRepository, notifications, prefs),
      deleteTransaction: DeleteTransaction(transactionRepository),
      transactionLocal: transactionLocal,
      transactionRemote: transactionRemote,
      syncRepository: syncRepository,
      runSync: RunSync(syncRepository),
      loadPendingCounts: LoadPendingCounts(syncRepository),
    );
  }
}
