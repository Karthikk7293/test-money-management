import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _valid = false;
  String? _liveError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _onChanged() {
    final error = Validators.nickname(_controller.text);
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
    if (!_valid) return;
    context
        .read<AuthBloc>()
        .add(AuthCreateAccountRequested(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (p, c) => p.errorMessage != c.errorMessage,
          listener: (context, state) {
            final m = state.errorMessage;
            if (m != null && m.isNotEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(m)));
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.headlineLarge,
                      children: const [
                        TextSpan(text: '👋 '),
                        TextSpan(text: 'What should we call you?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('This name stays only on your device.',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 28),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focus,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 24,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Eg: Johnnie',
                          hintStyle: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.textPlaceholder),
                          counterText: '',
                          contentPadding: const EdgeInsets.fromLTRB(
                              18, 18, 50, 18),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_valid)
                        const Padding(
                          padding: EdgeInsets.only(right: 14),
                          child: Icon(Icons.check_circle,
                              color: AppColors.credit, size: 22),
                        ),
                    ],
                  ),
                  if (_liveError != null) ...[
                    const SizedBox(height: 8),
                    Text(_liveError!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.debit)),
                  ],
                  const SizedBox(height: 16),
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
            );
          },
        ),
      ),
    );
  }
}
