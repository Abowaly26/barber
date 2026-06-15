import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Error Handling System Tests', () {
    group('Failures', () {
      test('ServerFailure should contain correct message', () {
        const failure = ServerFailure('Server error occurred');
        expect(failure.message, 'Server error occurred');
        expect(failure.toString(), 'Server error occurred');
      });

      test('NetworkFailure should contain correct message', () {
        const failure = NetworkFailure('No internet connection');
        expect(failure.message, 'No internet connection');
        expect(failure.toString(), 'No internet connection');
      });

      test('Failures with same message should be equal', () {
        const failure1 = ServerFailure('Same error');
        const failure2 = ServerFailure('Same error');
        expect(failure1, equals(failure2));
      });

      test('Failures with different messages should not be equal', () {
        const failure1 = ServerFailure('Error 1');
        const failure2 = ServerFailure('Error 2');
        expect(failure1, isNot(equals(failure2)));
      });

      test('Different failure types with same message should not be equal', () {
        const serverFailure = ServerFailure('Error');
        const networkFailure = NetworkFailure('Error');
        expect(serverFailure, isNot(equals(networkFailure)));
      });
    });

    group('Exceptions', () {
      test('ServerException should contain correct message', () {
        const exception = ServerException('Server error occurred');
        expect(exception.message, 'Server error occurred');
        expect(exception.toString(), 'Server error occurred');
      });

      test('NetworkException should contain correct message', () {
        const exception = NetworkException('No internet connection');
        expect(exception.message, 'No internet connection');
        expect(exception.toString(), 'No internet connection');
      });

      test('Exception with stackTrace should store it', () {
        final stackTrace = StackTrace.current;
        final exception = ServerException('Error with stack', stackTrace);
        expect(exception.stackTrace, isNotNull);
        expect(exception.stackTrace, equals(stackTrace));
      });
    });

    group('Either Type Usage', () {
      test('Right should contain success value', () {
        const Either<Failure, String> result = Right('Success');

        result.fold(
          (failure) => fail('Should not be a failure'),
          (value) => expect(value, 'Success'),
        );
      });

      test('Left should contain failure', () {
        const Either<Failure, String> result = Left(ServerFailure('Error'));

        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Error');
        }, (value) => fail('Should not be a success'));
      });

      test('Repository pattern simulation - success case', () async {
        // Simulate a successful repository call
        Future<Either<Failure, List<String>>> getBookings() async {
          try {
            // Simulate fetching data
            await Future.delayed(const Duration(milliseconds: 10));
            return const Right(['Booking1', 'Booking2']);
          } catch (e) {
            return Left(ServerFailure(e.toString()));
          }
        }

        final result = await getBookings();

        expect(result.isRight(), true);
        result.fold((failure) => fail('Should be success'), (bookings) {
          expect(bookings, isA<List<String>>());
          expect(bookings.length, 2);
        });
      });

      test('Repository pattern simulation - failure case', () async {
        // Simulate a failed repository call
        Future<Either<Failure, List<String>>> getBookings() async {
          try {
            // Simulate an error
            throw const ServerException('Failed to fetch bookings');
          } on ServerException catch (e, stackTrace) {
            return Left(ServerFailure(e.message, stackTrace));
          } catch (e, stackTrace) {
            return Left(UnknownFailure(e.toString(), stackTrace));
          }
        }

        final result = await getBookings();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to fetch bookings');
        }, (bookings) => fail('Should be failure'));
      });
    });

    group('All Failure Types', () {
      test('Should create all failure types correctly', () {
        const failures = [
          ServerFailure('Server error'),
          CacheFailure('Cache error'),
          NetworkFailure('Network error'),
          UnauthorizedFailure('Unauthorized'),
          FirebaseFailure('Firebase error'),
          SupabaseFailure('Supabase error'),
          ValidationFailure('Validation error'),
          NotFoundFailure('Not found'),
          PaymentFailure('Payment failed'),
          LocationFailure('Location error'),
          ConflictFailure('Conflict'),
          UnknownFailure('Unknown error'),
        ];

        for (final failure in failures) {
          expect(failure, isA<Failure>());
          expect(failure.message, isNotEmpty);
        }
      });
    });

    group('All Exception Types', () {
      test('Should create all exception types correctly', () {
        const exceptions = [
          ServerException('Server error'),
          CacheException('Cache error'),
          NetworkException('Network error'),
          UnauthorizedException('Unauthorized'),
          FirebaseException('Firebase error'),
          SupabaseException('Supabase error'),
          ValidationException('Validation error'),
          NotFoundException('Not found'),
          PaymentException('Payment failed'),
          LocationException('Location error'),
          ConflictException('Conflict'),
          RequiresRecentLoginException('Recent login required'),
          UnknownException('Unknown error'),
        ];

        for (final exception in exceptions) {
          expect(exception, isA<AppException>());
          expect(exception.message, isNotEmpty);
        }
      });
    });
  });
}
