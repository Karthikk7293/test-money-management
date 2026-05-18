import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60;

  final List<TextEditingController> _ctrls =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  int _seconds = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
      _showTestOtpToast();
    });
    _startTimer();
  }

  void _showTestOtpToast() {
    if (!mounted) return;
    final otp = context.read<AuthBloc>().state.challenge?.otp;
    if (otp == null || otp.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          content: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.accentBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                    children: [
                      const TextSpan(text: 'Test OTP: '),
                      TextSpan(
                        text: otp,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.accentBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Autofill',
            textColor: AppColors.accentBlue,
            onPressed: _autofillOtp,
          ),
        ),
      );
  }

  void _autofillOtp() {
    final otp = context.read<AuthBloc>().state.challenge?.otp ?? '';
    if (otp.length != _otpLength) return;
    for (int i = 0; i < _otpLength; i++) {
      _ctrls[i].text = otp[i];
    }
    _focusNodes.last.requestFocus();
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        if (mounted) setState(() => _seconds = 0);
      } else if (mounted) {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();
  bool get _isComplete => _otp.length == _otpLength;

  void _onChanged(int i, String value) {
    if (value.length > 1) {
      // Paste-friendly: distribute across cells.
      for (int j = 0; j < value.length && (i + j) < _otpLength; j++) {
        _ctrls[i + j].text = value[j];
      }
      final next = (i + value.length).clamp(0, _otpLength - 1);
      _focusNodes[next].requestFocus();
    } else if (value.isNotEmpty && i < _otpLength - 1) {
      _focusNodes[i + 1].requestFocus();
    } else if (value.isEmpty && i > 0) {
      _focusNodes[i - 1].requestFocus();
    }
    setState(() {});
  }

  void _submit() {
    if (!_isComplete) return;
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(_otp));
  }

  String _maskedPhone(String? phone) {
    if (phone == null || phone.length < 4) return '••••••****';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return phone;
    final last10 = digits.substring(digits.length - 10);
    final first = last10.substring(0, 4);
    final last2 = last10.substring(8, 10);
    return '$first****$last2';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage ||
              p.challenge?.otp != c.challenge?.otp,
          listener: (context, state) {
            final m = state.errorMessage;
            if (m != null && m.isNotEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(m)));
              return;
            }
            // A new challenge (e.g. resend) was issued — show the toast again.
            if (state.challenge?.otp != null && state.challenge!.otp.isNotEmpty) {
              _showTestOtpToast();
            }
          },
          builder: (context, state) {
            final maskedPhone = _maskedPhone(state.phone);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SquareBack(
                    onTap: () =>
                        context.read<AuthBloc>().add(const AuthResetFlow()),
                  ),
                  const SizedBox(height: 18),
                  Text('Verify OTP', style: AppTextStyles.displayLarge),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Enter the 6-Digit code sent to '),
                        TextSpan(
                          text: maskedPhone,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () =>
                        context.read<AuthBloc>().add(const AuthResetFlow()),
                    child: Text(
                      'Change Number',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_otpLength, (i) {
                      return _OtpCell(
                        controller: _ctrls[i],
                        focusNode: _focusNodes[i],
                        onChanged: (v) => _onChanged(i, v),
                        onSubmitted: () => _submit(),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (state.isSubmitting || !_isComplete)
                        ? null
                        : _submit,
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Verify'),
                  ),
                  const SizedBox(height: 18),
                  if (_seconds > 0)
                    Text.rich(
                      TextSpan(
                        style: AppTextStyles.bodyMedium,
                        children: [
                          const TextSpan(text: 'Resend OTP in  '),
                          TextSpan(
                            text: '${_seconds}s',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        if (state.phone != null) {
                          context
                              .read<AuthBloc>()
                              .add(AuthSendOtpRequested(state.phone!));
                          _startTimer();
                        }
                      },
                      child: Text(
                        'Resend OTP',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
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

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return SizedBox(
      width: 46,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: hasValue ? Colors.white : AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (!hasValue)
            Text(
              '-',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            cursorColor: Colors.white,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
        ],
      ),
    );
  }
}

class _SquareBack extends StatelessWidget {
  const _SquareBack({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.arrow_back_ios_new,
            size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}
