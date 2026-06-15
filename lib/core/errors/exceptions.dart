/// Base exception class for all custom exceptions in the application
/// All custom exceptions should extend this class
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Exception thrown when there's a server-side error
/// This should be caught and converted to ServerFailure
class ServerException extends AppException {
  const ServerException(super.message, [super.stackTrace]);
}

/// Exception thrown when there's a cache/local storage error
/// This should be caught and converted to CacheFailure
class CacheException extends AppException {
  const CacheException(super.message, [super.stackTrace]);
}

/// Exception thrown when there's a network connectivity issue
/// This should be caught and converted to NetworkFailure
class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
}

/// Exception thrown when user authentication fails or is required
/// This should be caught and converted to UnauthorizedFailure
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.stackTrace]);
}

/// Exception thrown when Firebase operations fail
/// This should be caught and converted to FirebaseFailure
class FirebaseException extends AppException {
  const FirebaseException(super.message, [super.stackTrace]);
}

/// Exception thrown when Supabase operations fail
/// This should be caught and converted to SupabaseFailure
class SupabaseException extends AppException {
  const SupabaseException(super.message, [super.stackTrace]);
}

/// Exception thrown when validation fails
/// This should be caught and converted to ValidationFailure
class ValidationException extends AppException {
  const ValidationException(super.message, [super.stackTrace]);
}

/// Exception thrown when a requested resource is not found
/// This should be caught and converted to NotFoundFailure
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.stackTrace]);
}

/// Exception thrown when payment processing fails
/// This should be caught and converted to PaymentFailure
class PaymentException extends AppException {
  const PaymentException(super.message, [super.stackTrace]);
}

/// Exception thrown when location services fail
/// This should be caught and converted to LocationFailure
class LocationException extends AppException {
  const LocationException(super.message, [super.stackTrace]);
}

/// Exception thrown when there's a conflict
/// This should be caught and converted to ConflictFailure
class ConflictException extends AppException {
  const ConflictException(super.message, [super.stackTrace]);
}

/// Exception thrown when Firebase requires recent login
/// Common when performing sensitive operations like changing password
class RequiresRecentLoginException extends AppException {
  const RequiresRecentLoginException(super.message, [super.stackTrace]);
}

/// Generic exception for unexpected errors
class UnknownException extends AppException {
  const UnknownException(super.message, [super.stackTrace]);
}
