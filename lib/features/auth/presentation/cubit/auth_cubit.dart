import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/entities/user_entity.dart';
import '../../domain/repos/auth_repo.dart';

part 'auth_state.dart';

/// Auth Cubit for managing authentication state
/// Handles sign in, sign up, Google sign in, phone sign in, OTP verification, and sign out
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepo) : super(AuthInitial());

  final AuthRepo authRepo;

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final result = await authRepo.signInWithEmail(
      email: email,
      password: password,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (userEntity) => emit(AuthSuccess(userEntity: userEntity)),
    );
  }

  /// Sign up (create new user) with email, password and name
  Future<void> signUp(String email, String password, String name) async {
    emit(AuthLoading());
    final result = await authRepo.createUserWithEmail(
      email: email,
      password: password,
      name: name,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (userEntity) => emit(AuthSuccess(userEntity: userEntity)),
    );
  }

  /// Sign in with Google account
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await authRepo.signInWithGoogle();
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (userEntity) => emit(AuthSuccess(userEntity: userEntity)),
    );
  }

  /// Sign in with phone number (sends OTP)
  /// Returns verification ID that should be used for OTP verification
  Future<void> signInWithPhone(String phoneNumber) async {
    emit(AuthLoading());
    final result = await authRepo.signInWithPhone(phoneNumber: phoneNumber);
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (verificationId) =>
          emit(PhoneVerificationCodeSent(verificationId: verificationId)),
    );
  }

  /// Verify OTP code received on phone
  /// Takes verificationId from signInWithPhone and the SMS code
  Future<void> verifyOTP(String verificationId, String smsCode) async {
    emit(AuthLoading());
    final result = await authRepo.verifyOTP(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (userEntity) => emit(AuthSuccess(userEntity: userEntity)),
    );
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    emit(AuthLoading());
    final result = await authRepo.sendPasswordResetEmail(email);
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(PasswordResetSent()),
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await authRepo.signOut();
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthInitial()),
    );
  }
}
