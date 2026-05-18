part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  onboarding,
  unauthenticated,
  awaitingOtp,
  awaitingNickname,
  authenticating,
  authenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.phone,
    this.challenge,
    this.session,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AuthStatus status;
  final String? phone;
  final OtpChallenge? challenge;
  final AuthSession? session;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? phone,
    OtpChallenge? challenge,
    AuthSession? session,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      challenge: challenge ?? this.challenge,
      session: session ?? this.session,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props =>
      [status, phone, challenge, session, errorMessage, isSubmitting];
}
