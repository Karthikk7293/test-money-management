import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/preferences_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SendOtp sendOtpUseCase,
    required VerifyOtp verifyOtpUseCase,
    required CreateAccount createAccountUseCase,
    required PreferencesService prefs,
  })  : _sendOtp = sendOtpUseCase,
        _verifyOtp = verifyOtpUseCase,
        _createAccount = createAccountUseCase,
        _prefs = prefs,
        super(const AuthState()) {
    on<AuthBootstrapRequested>(_onBootstrap);
    on<AuthOnboardingCompleted>(_onOnboardingCompleted);
    on<AuthSendOtpRequested>(_onSendOtp);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthCreateAccountRequested>(_onCreateAccount);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthResetFlow>(_onResetFlow);
  }

  final SendOtp _sendOtp;
  final VerifyOtp _verifyOtp;
  final CreateAccount _createAccount;
  final PreferencesService _prefs;

  Future<void> _onBootstrap(
      AuthBootstrapRequested event, Emitter<AuthState> emit) async {
    if (_prefs.isAuthenticated) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        session: AuthSession(
          phone: _prefs.phone ?? '',
          nickname: _prefs.nickname ?? '',
          token: _prefs.token!,
        ),
      ));
      return;
    }
    emit(state.copyWith(
      status: _prefs.onboardingCompleted
          ? AuthStatus.unauthenticated
          : AuthStatus.onboarding,
    ));
  }

  Future<void> _onOnboardingCompleted(
      AuthOnboardingCompleted event, Emitter<AuthState> emit) async {
    await _prefs.setOnboardingCompleted(true);
    emit(state.copyWith(status: AuthStatus.unauthenticated, clearError: true));
  }

  Future<void> _onSendOtp(
      AuthSendOtpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final challenge = await _sendOtp(event.phone);
      emit(state.copyWith(
        status: AuthStatus.awaitingOtp,
        phone: event.phone,
        challenge: challenge,
        isSubmitting: false,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.message,
          isSubmitting: false));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _messageOf(e),
          isSubmitting: false));
    }
  }

  Future<void> _onVerifyOtp(
      AuthVerifyOtpRequested event, Emitter<AuthState> emit) async {
    final challenge = state.challenge;
    if (challenge == null) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'OTP session expired. Please retry.'));
      return;
    }
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final session = await _verifyOtp(
        challenge: challenge,
        enteredOtp: event.otp,
      );
      if (session != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          isSubmitting: false,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.awaitingNickname,
          isSubmitting: false,
        ));
      }
    } on AuthException catch (e) {
      emit(state.copyWith(
          status: AuthStatus.awaitingOtp,
          errorMessage: e.message,
          isSubmitting: false));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _messageOf(e),
          isSubmitting: false));
    }
  }

  Future<void> _onCreateAccount(
      AuthCreateAccountRequested event, Emitter<AuthState> emit) async {
    final phone = state.phone;
    if (phone == null) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Phone not found. Restart sign-up.'));
      return;
    }
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final session =
          await _createAccount(phone: phone, nickname: event.nickname);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isSubmitting: false,
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _messageOf(e),
          isSubmitting: false));
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _prefs.clearSession();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onResetFlow(AuthResetFlow event, Emitter<AuthState> emit) {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  String _messageOf(Object e) {
    if (e is ServerException) return e.message;
    if (e is NetworkException) return e.message;
    return 'Something went wrong. Please try again.';
  }
}
