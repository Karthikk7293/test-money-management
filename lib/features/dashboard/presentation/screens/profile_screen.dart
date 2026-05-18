import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/sync_animation.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../sync/presentation/bloc/sync_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  late double _currentLimit;

  @override
  void initState() {
    super.initState();
    _currentLimit = context.read<PreferencesService>().budgetLimit;
    context.read<CategoryBloc>().add(const CategoriesRequested());
  }

  @override
  void dispose() {
    _limitController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _saveLimit() async {
    final error = Validators.budgetLimit(_limitController.text);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    final n = double.parse(_limitController.text.trim());
    await context.read<PreferencesService>().setBudgetLimit(n);
    setState(() {
      _currentLimit = n;
      _limitController.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert limit set to ${Formatters.currency(n)}')),
    );
  }

  void _addCategory() {
    final name = _newCategoryController.text.trim();
    final error = Validators.categoryName(name);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.read<CategoryBloc>().add(CategoryAdded(name));
    _newCategoryController.clear();
  }

  Future<void> _editNickname() async {
    final prefs = context.read<PreferencesService>();
    final controller = TextEditingController(text: prefs.nickname ?? '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit nickname', style: AppTextStyles.titleMedium),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 24,
            style: AppTextStyles.bodyLarge,
            validator: Validators.nickname,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              hintText: 'Nickname',
              counterText: '',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await prefs.setNickname(result);
      final phone = prefs.phone;
      if (phone != null && phone.isNotEmpty) {
        await prefs.upsertKnownUser(phone, result);
      }
      if (mounted) setState(() {});
    }
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Log out?', style: AppTextStyles.titleMedium),
        content: Text(
            'You will need to verify your phone again to sign back in.',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: Text('Log Out',
                style: TextStyle(color: AppColors.debit)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    final nickname = prefs.nickname ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text('Profile & Settings', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),
            // Nickname
            Text('NICKNAME', style: AppTextStyles.labelSmall),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      nickname.isEmpty ? 'Set a nickname' : nickname,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                  GestureDetector(
                    onTap: _editNickname,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Alert limit
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ALERT LIMIT (₹)',
                      style: AppTextStyles.labelSmall),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _limitController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: AppTextStyles.bodyLarge,
                          onSubmitted: (_) => _saveLimit(),
                          decoration: const InputDecoration(
                            hintText: 'Amount  (₹)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _saveLimit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 56),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22),
                          ),
                          child: const Text('Set'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Current Limit: ${Formatters.currency(_currentLimit)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Categories
            Text('CATEGORIES', style: AppTextStyles.labelSmall),
            const SizedBox(height: 10),
            _SectionCard(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newCategoryController,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 30,
                              style: AppTextStyles.bodyLarge,
                              decoration: const InputDecoration(
                                hintText: 'New category Name',
                                counterText: '',
                              ),
                              onSubmitted: (_) => _addCategory(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _addCategory,
                            child: Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                      if (state.categories.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(),
                      ],
                      ...state.categories.map(
                        (c) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(c.name,
                                    style: AppTextStyles.bodyLarge),
                              ),
                              GestureDetector(
                                onTap: () => context
                                    .read<CategoryBloc>()
                                    .add(CategoryDeleted(c.id)),
                                child: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.debit
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.debit
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.debit),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Cloud sync card
            Text('CLOUD SYNC', style: AppTextStyles.labelSmall),
            const SizedBox(height: 10),
            BlocConsumer<SyncBloc, SyncState>(
              listenWhen: (p, c) => p.status != c.status,
              listener: (context, state) {
                if (state.status == SyncStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Synced to cloud')),
                  );
                } else if (state.status == SyncStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(state.errorMessage ?? 'Sync failed')),
                  );
                }
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: state.isRunning
                      ? null
                      : () => context
                          .read<SyncBloc>()
                          .add(const SyncRunRequested()),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sync To Cloud',
                                  style: AppTextStyles.titleMedium
                                      .copyWith(color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('Sync and update data to the backend',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                  )),
                            ],
                          ),
                        ),
                        state.isRunning
                            ? const SyncSpinner(size: 28, color: Colors.white)
                            : const Icon(Icons.cloud_upload_outlined,
                                color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            // Log out
            GestureDetector(
              onTap: _confirmLogout,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Log Out',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.debit),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.power_settings_new,
                        size: 18, color: AppColors.debit),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
