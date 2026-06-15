# Error Handling System

نظام معالجة الأخطاء في التطبيق باستخدام `dartz` package والـ `Either` type.

## Structure

### Failures (lib/core/errors/failures.dart)
- **Purpose**: تُستخدم في الـ Domain والـ Presentation layers
- **Usage**: تُعاد من الـ Repositories إلى الـ Cubits/UI
- **Features**: تستخدم Equatable للمقارنة بين القيم

### Exceptions (lib/core/errors/exceptions.dart)
- **Purpose**: تُستخدم في الـ Data layer فقط
- **Usage**: تُرمى من الـ Data Sources وتُحوّل إلى Failures في الـ Repository
- **Features**: Custom exceptions مع معلومات مفصلة عن الخطأ

## Usage Pattern

### 1. في Data Layer (Repository Implementation)

```dart
import 'package:dartz/dartz.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/errors/failures.dart';

class BookingRepoImpl implements BookingRepo {
  final FirestoreService firestoreService;
  
  BookingRepoImpl({required this.firestoreService});
  
  @override
  Future<Either<Failure, List<BookingEntity>>> getBookings(String userId) async {
    try {
      // محاولة جلب البيانات
      final result = await firestoreService.getDocuments(
        'bookings',
        query: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId),
      );
      
      // تحويل البيانات إلى Entities
      final bookings = result.map((doc) => 
        BookingModel.fromJson(doc).toEntity()
      ).toList();
      
      // إرجاع النتيجة الناجحة
      return Right(bookings);
      
    } on ServerException catch (e, stackTrace) {
      // تحويل ServerException إلى ServerFailure
      return Left(ServerFailure(e.message, stackTrace));
      
    } on NetworkException catch (e, stackTrace) {
      // تحويل NetworkException إلى NetworkFailure
      return Left(NetworkFailure(e.message, stackTrace));
      
    } on FirebaseException catch (e, stackTrace) {
      // تحويل FirebaseException إلى FirebaseFailure
      return Left(FirebaseFailure(e.message, stackTrace));
      
    } catch (e, stackTrace) {
      // معالجة الأخطاء غير المتوقعة
      return Left(UnknownFailure(e.toString(), stackTrace));
    }
  }
}
```

### 2. في Presentation Layer (Cubit)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/errors/failures.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepo bookingRepo;
  
  BookingCubit(this.bookingRepo) : super(BookingInitial());
  
  Future<void> getBookings(String userId) async {
    emit(BookingLoading());
    
    // استدعاء الـ Repository
    final result = await bookingRepo.getBookings(userId);
    
    // معالجة النتيجة باستخدام fold
    result.fold(
      // في حالة الخطأ (Left)
      (failure) {
        String errorMessage = _mapFailureToMessage(failure);
        emit(BookingError(errorMessage));
      },
      // في حالة النجاح (Right)
      (bookings) {
        emit(BookingLoaded(bookings));
      },
    );
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً';
      case NetworkFailure:
        return 'لا يوجد اتصال بالإنترنت';
      case UnauthorizedFailure:
        return 'يجب تسجيل الدخول أولاً';
      case NotFoundFailure:
        return 'البيانات المطلوبة غير موجودة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
```

### 3. في UI (Widget)

```dart
BlocBuilder<BookingCubit, BookingState>(
  builder: (context, state) {
    if (state is BookingLoading) {
      return const LoadingWidget();
    }
    
    if (state is BookingError) {
      return ErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<BookingCubit>().getBookings(userId);
        },
      );
    }
    
    if (state is BookingLoaded) {
      return ListView.builder(
        itemCount: state.bookings.length,
        itemBuilder: (context, index) {
          return BookingCard(booking: state.bookings[index]);
        },
      );
    }
    
    return const SizedBox();
  },
)
```

## Available Failure Types

| Failure Type | Use Case | Arabic Message Example |
|-------------|----------|----------------------|
| `ServerFailure` | أخطاء الخادم والـ API | "حدث خطأ في الخادم" |
| `NetworkFailure` | مشاكل الاتصال بالإنترنت | "لا يوجد اتصال بالإنترنت" |
| `CacheFailure` | أخطاء التخزين المحلي | "حدث خطأ في حفظ البيانات" |
| `UnauthorizedFailure` | مشاكل المصادقة | "يجب تسجيل الدخول أولاً" |
| `FirebaseFailure` | أخطاء Firebase | "حدث خطأ في قاعدة البيانات" |
| `SupabaseFailure` | أخطاء Supabase | "فشل رفع الصورة" |
| `ValidationFailure` | أخطاء التحقق من البيانات | "البريد الإلكتروني غير صالح" |
| `NotFoundFailure` | البيانات غير موجودة | "الحجز غير موجود" |
| `PaymentFailure` | مشاكل الدفع | "فشلت عملية الدفع" |
| `LocationFailure` | مشاكل الموقع | "يرجى تفعيل خدمات الموقع" |
| `ConflictFailure` | تعارض في البيانات | "الموعد محجوز بالفعل" |
| `UnknownFailure` | أخطاء غير متوقعة | "حدث خطأ غير متوقع" |

## Available Exception Types

| Exception Type | When to Throw |
|---------------|---------------|
| `ServerException` | عند حدوث خطأ من الخادم (5xx errors) |
| `NetworkException` | عند عدم وجود اتصال بالإنترنت |
| `CacheException` | عند فشل عمليات التخزين المحلي |
| `UnauthorizedException` | عند فشل المصادقة (401, 403) |
| `FirebaseException` | عند فشل عمليات Firebase |
| `SupabaseException` | عند فشل عمليات Supabase |
| `ValidationException` | عند فشل التحقق من البيانات |
| `NotFoundException` | عند عدم إيجاد البيانات المطلوبة (404) |
| `PaymentException` | عند فشل عمليات الدفع |
| `LocationException` | عند فشل خدمات الموقع |
| `ConflictException` | عند وجود تعارض في البيانات (409) |
| `RequiresRecentLoginException` | عند الحاجة لإعادة المصادقة |
| `UnknownException` | للأخطاء غير المتوقعة |

## Best Practices

1. **استخدم Exceptions في Data Layer فقط**
   - ارمِ Exceptions من Data Sources
   - حوّل Exceptions إلى Failures في Repository

2. **استخدم Failures في Domain و Presentation Layers**
   - أعد Failures من Repositories
   - عالج Failures في Cubits
   - اعرض رسائل خطأ مناسبة في UI

3. **استخدم Either type دائماً**
   ```dart
   // ✅ صحيح
   Future<Either<Failure, User>> signIn(String email, String password);
   
   // ❌ خاطئ
   Future<User> signIn(String email, String password);
   ```

4. **احتفظ بالـ StackTrace للـ Debugging**
   ```dart
   try {
     // code
   } catch (e, stackTrace) {
     return Left(ServerFailure(e.toString(), stackTrace));
   }
   ```

5. **قدّم رسائل خطأ واضحة للمستخدم**
   ```dart
   String _mapFailureToMessage(Failure failure) {
     // قدم رسائل عربية واضحة ومفهومة
   }
   ```
