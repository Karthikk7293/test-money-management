part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthBootstrapRequested extends AuthEvent {
  const AuthBootstrapRequested();
}

class AuthSendOtpRequested extends AuthEvent {
  const AuthSendOtpRequested(this.phone);
  final String phone;
  @override
  List<Object?> get props => [phone];
}

class AuthVerifyOtpRequested extends AuthEvent {
  const AuthVerifyOtpRequested(this.otp);
  final String otp;
  @override
  List<Object?> get props => [otp];
}

class AuthCreateAccountRequested extends AuthEvent {
  const AuthCreateAccountRequested(this.nickname);
  final String nickname;
  @override
  List<Object?> get props => [nickname];
}

class AuthOnboardingCompleted extends AuthEvent {
  const AuthOnboardingCompleted();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthResetFlow extends AuthEvent {
  const AuthResetFlow();
}
