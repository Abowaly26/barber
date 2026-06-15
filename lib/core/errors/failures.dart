import 'package:equatable/equatable.dart';

/// Base abstract class for all failures in the application
/// Uses Equatable for value comparison
abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => message;
}

/// Failure that occurs when there's a server-side error
/// Examples: API errors, backend failures, 500 errors
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's a cache/local storage error
/// Examples: SharedPreferences errors, local database failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's a network connectivity issue
/// Examples: No internet connection, timeout errors
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when user authentication fails or is required
/// Examples: Invalid credentials, expired tokens, unauthorized access
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when Firebase operations fail
/// Examples: Firestore errors, Firebase Auth errors, Firebase Storage errors
class FirebaseFailure extends Failure {
  const FirebaseFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when Supabase operations fail
/// Examples: Supabase Storage errors, Supabase Database errors
class SupabaseFailure extends Failure {
  const SupabaseFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when validation fails
/// Examples: Invalid email format, empty required fields, invalid phone number
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when a requested resource is not found
/// Examples: User not found, booking not found, shop not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when payment processing fails
/// Examples: Payment declined, insufficient funds, payment gateway errors
class PaymentFailure extends Failure {
  const PaymentFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when location services fail
/// Examples: Location permission denied, GPS not available
class LocationFailure extends Failure {
  const LocationFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's a conflict
/// Examples: Booking slot already taken, duplicate entries
class ConflictFailure extends Failure {
  const ConflictFailure(super.message, [super.stackTrace]);
}

/// Generic failure for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.stackTrace]);
}
