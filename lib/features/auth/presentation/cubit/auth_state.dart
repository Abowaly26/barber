part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserEntity userEntity;

  AuthSuccess({required this.userEntity});
}

final class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}

// Phone verification specific state
final class PhoneVerificationCodeSent extends AuthState {
  final String verificationId;

  PhoneVerificationCodeSent({required this.verificationId});
}

// Password reset email sent
final class PasswordResetSent extends AuthState {}
