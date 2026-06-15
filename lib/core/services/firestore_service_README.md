# Firestore Service

خدمة شاملة للتعامل مع قاعدة بيانات Firestore في تطبيق Barber Booking App.

## الميزات الأساسية

### 1. العمليات الأساسية (CRUD)

#### إضافة مستند (Add Document)
```dart
final firestoreService = FirestoreService();

// إضافة مستند بدون تحديد ID (Firestore يولد ID تلقائياً)
final result = await firestoreService.addDocument(
  collection: 'users',
  data: {
    'name': 'أحمد محمد',
    'email': 'ahmed@example.com',
    'phone': '+966501234567',
    'createdAt': FieldValue.serverTimestamp(),
  },
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (documentId) => print('Document added with ID: $documentId'),
);

// إضافة مستند بـ ID محدد
final result2 = await firestoreService.addDocument(
  collection: 'users',
  documentId: 'user123',
  data: {
    'name': 'فاطمة خالد',
    'email': 'fatima@example.com',
  },
);
```

#### قراءة مستند واحد (Get Document)
```dart
final result = await firestoreService.getDocument(
  collection: 'users',
  documentId: 'user123',
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (userData) {
    print('User name: ${userData['name']}');
    print('User email: ${userData['email']}');
    // الـ ID مضمّن في البيانات تلقائياً
    print('Document ID: ${userData['id']}');
  },
);
```

#### قراءة عدة مستندات (Get Documents)
```dart
// قراءة جميع المستندات من collection
final result = await firestoreService.getDocuments(
  collection: 'shops',
);

// قراءة مع query مخصص
final result2 = await firestoreService.getDocuments(
  collection: 'bookings',
  queryBuilder: (ref) => ref
      .where('userId', isEqualTo: 'user123')
      .where('status', isEqualTo: 'confirmed')
      .orderBy('dateTime', descending: true)
      .limit(10),
);

result2.fold(
  (failure) => print('Error: ${failure.message}'),
  (bookings) {
    for (var booking in bookings) {
      print('Booking ID: ${booking['id']}');
      print('Date: ${booking['dateTime']}');
    }
  },
);
```

#### تحديث مستند (Update Document)
```dart
final result = await firestoreService.updateDocument(
  collection: 'users',
  documentId: 'user123',
  data: {
    'name': 'أحمد محمد الجديد',
    'updatedAt': FieldValue.serverTimestamp(),
  },
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (_) => print('Document updated successfully'),
);
```

#### حذف مستند (Delete Document)
```dart
final result = await firestoreService.deleteDocument(
  collection: 'bookings',
  documentId: 'booking123',
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (_) => print('Document deleted successfully'),
);
```

### 2. البيانات الفورية (Real-time Streaming)

```dart
// الاستماع للتحديثات الفورية
final stream = firestoreService.streamCollection(
  collection: 'bookings',
  queryBuilder: (ref) => ref
      .where('userId', isEqualTo: 'user123')
      .orderBy('dateTime', descending: true),
);

stream.listen((result) {
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (bookings) {
      print('Received ${bookings.length} bookings');
      // تحديث UI مع البيانات الجديدة
    },
  );
});
```

### 3. Pagination (الترقيم)

```dart
DocumentSnapshot? lastDoc;
bool hasMore = true;

Future<void> loadMoreShops() async {
  if (!hasMore) return;

  final result = await firestoreService.getDocumentsWithPagination(
    collection: 'shops',
    lastDocument: lastDoc,
    limit: 10,
    orderBy: 'rating',
    descending: true,
    queryBuilder: (ref) => ref.where('category', isEqualTo: 'men'),
  );

  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (paginationData) {
      final shops = paginationData['data'] as List<Map<String, dynamic>>;
      lastDoc = paginationData['lastDocument'] as DocumentSnapshot?;
      hasMore = paginationData['hasMore'] as bool;
      
      print('Loaded ${shops.length} shops');
      print('Has more: $hasMore');
    },
  );
}
```

### 4. عمليات إضافية

#### التحقق من وجود مستند
```dart
final result = await firestoreService.documentExists(
  collection: 'users',
  documentId: 'user123',
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (exists) => print('Document exists: $exists'),
);
```

#### عد المستندات
```dart
final result = await firestoreService.getCollectionCount(
  collection: 'shops',
  queryBuilder: (ref) => ref.where('rating', isGreaterThanOrEqualTo: 4.5),
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (count) => print('Number of high-rated shops: $count'),
);
```

#### عمليات Batch (مجموعة)
```dart
// تنفيذ عدة عمليات دفعة واحدة (حتى 500 عملية)
final operations = [
  BatchOperation(
    collection: 'bookings',
    docId: 'booking1',
    type: BatchOperationType.set,
    data: {'status': 'confirmed'},
  ),
  BatchOperation(
    collection: 'bookings',
    docId: 'booking2',
    type: BatchOperationType.update,
    data: {'status': 'cancelled'},
  ),
  BatchOperation(
    collection: 'bookings',
    docId: 'booking3',
    type: BatchOperationType.delete,
  ),
];

final result = await firestoreService.batchWrite(operations);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (_) => print('Batch operations completed successfully'),
);
```

## معالجة الأخطاء (Error Handling)

الخدمة تستخدم Either type من مكتبة dartz لمعالجة الأخطاء بشكل احترافي:

```dart
final result = await firestoreService.getDocument(
  collection: 'users',
  documentId: 'user123',
);

result.fold(
  // Left: حالة الخطأ
  (failure) {
    if (failure is NotFoundFailure) {
      print('المستند غير موجود');
    } else if (failure is FirebaseFailure) {
      print('خطأ في Firebase: ${failure.message}');
    } else if (failure is NetworkFailure) {
      print('خطأ في الاتصال بالإنترنت');
    } else {
      print('خطأ غير متوقع: ${failure.message}');
    }
  },
  // Right: حالة النجاح
  (userData) {
    print('تم جلب البيانات بنجاح');
    print('Name: ${userData['name']}');
  },
);
```

## أنواع الأخطاء المحتملة

- **FirebaseFailure**: خطأ في عمليات Firebase
- **NotFoundFailure**: المستند غير موجود
- **NetworkFailure**: مشكلة في الاتصال
- **UnknownFailure**: خطأ غير متوقع

## أمثلة الاستخدام في Repository Pattern

```dart
class BookingRepoImpl implements BookingRepo {
  final FirestoreService firestoreService;

  BookingRepoImpl({required this.firestoreService});

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookings(String userId) async {
    final result = await firestoreService.getDocuments(
      collection: 'bookings',
      queryBuilder: (ref) => ref
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: true),
    );

    return result.fold(
      (failure) => Left(failure),
      (docs) {
        try {
          final bookings = docs
              .map((doc) => BookingModel.fromJson(doc).toEntity())
              .toList();
          return Right(bookings);
        } catch (e) {
          return Left(UnknownFailure('Failed to parse bookings'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> createBooking(BookingEntity booking) async {
    final bookingModel = BookingModel.fromEntity(booking);
    
    return await firestoreService.addDocument(
      collection: 'bookings',
      data: bookingModel.toJson(),
    ).then((result) => result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    ));
  }
}
```

## ملاحظات مهمة

1. **Document IDs**: يتم تضمين ID المستند تلقائياً في البيانات المُرجعة تحت مفتاح `'id'`
2. **Timestamps**: استخدم `FieldValue.serverTimestamp()` للحصول على timestamp من السيرفر
3. **Pagination**: استخدم cursor-based pagination للأداء الأفضل
4. **Real-time**: استخدم `streamCollection` للبيانات التي تحتاج تحديثات فورية
5. **Batch Operations**: حد أقصى 500 عملية في batch واحد
6. **Error Handling**: دائماً استخدم fold() لمعالجة النتيجة بشكل آمن

## Integration مع GetIt

```dart
void setupGetIt() {
  // تسجيل FirestoreService كـ Singleton
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  
  // استخدامه في Repositories
  getIt.registerSingleton<BookingRepo>(
    BookingRepoImpl(
      firestoreService: getIt<FirestoreService>(),
    ),
  );
}
```

## Requirements المُغطاة

- ✅ Requirement 1.2: Repository Pattern implementation
- ✅ Requirement 2.2: Real-time database operations
- ✅ Requirement 26.7: Error handling with Either type
- ✅ جميع عمليات CRUD الأساسية
- ✅ البيانات الفورية (Real-time streaming)
- ✅ Pagination support
- ✅ Batch operations
