import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _valid = false;
  String? _liveError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _onChanged() {
    final error = Validators.phone(_controller.text);
    final next = error == null;
    final touched = _controller.text.isNotEmpty;
    if (next != _valid || (touched ? error : null) != _liveError) {
      setState(() {
        _valid = next;
        _liveError = touched ? error : null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    final phone = '+91$digits';
    context.read<AuthBloc>().add(AuthSendOtpRequested(phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (p, c) => p.errorMessage != c.errorMessage,
          listener: (context, state) {
            final message = state.errorMessage;
            if (message != null && message.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text('Get Started', style: AppTextStyles.displayLarge),
                    const SizedBox(height: 6),
                    Text('Log In Using Phone & OTP',
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 18),
                          Text('+91', style: AppTextStyles.bodyLarge),
                          const SizedBox(width: 12),
                          Container(
                              height: 22,
                              width: 1,
                              color: AppColors.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _controller,
                              focusNode: _focus,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: Validators.phone,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: AppTextStyles.bodyLarge,
                              decoration: const InputDecoration(
                                hintText: 'Phone',
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 18),
                              ),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_liveError != null) ...[
                      const SizedBox(height: 8),
                      Text(_liveError!,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.debit)),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (state.isSubmitting || !_valid) ? null : _submit,
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
