import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../errors/failures.dart';

/// Service for handling Firestore database operations
/// Provides generic CRUD operations with error handling using Either type
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a document to a collection
  ///
  /// Parameters:
  /// - [collection]: Name of the Firestore collection
  /// - [data]: Map containing the document data
  /// - [documentId]: Optional document ID. If null, Firestore will generate one
  ///
  /// Returns:
  /// - Right(documentId) on success
  /// - Left(Failure) on error
  Future<Either<Failure, String>> addDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (documentId != null && documentId.isNotEmpty) {
        // Set document with specific ID
        await _firestore
            .collection(collection)
            .doc(documentId)
            .set(data, SetOptions(merge: true));
        return Right(documentId);
      } else {
        // Add document with auto-generated ID
        final docRef = await _firestore.collection(collection).add(data);
        return Right(docRef.id);
      }
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error adding document: ${e.message}');
      return Left(
        FirebaseFailure('Failed to add document: ${e.message}', stackTrace),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error adding document: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while adding document',
          stackTrace,
        ),
      );
    }
  }

  
  Future<Either<Failure, Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();

      if (!docSnapshot.exists) {
        return Left(NotFoundFailure('Document not found in $collection'));
      }

      final data = docSnapshot.data();
      if (data == null) {
        return Left(NotFoundFailure('Document data is null'));
      }

      // Include document ID in the returned data
      data['id'] = docSnapshot.id;
      return Right(data);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error getting document: ${e.message}');
      return Left(
        FirebaseFailure('Failed to get document: ${e.message}', stackTrace),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error getting document: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while getting document',
          stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getDocuments({
    required String collection,
    Query<Map<String, dynamic>>? Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      // Apply custom query if provided
      if (queryBuilder != null) {
        final customQuery = queryBuilder(_firestore.collection(collection));
        if (customQuery != null) {
          query = customQuery;
        }
      }

      final querySnapshot = await query.get();

      // Map documents to list and include document IDs
      final documents = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return Right(documents);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error getting documents: ${e.message}');
      return Left(
        FirebaseFailure('Failed to get documents: ${e.message}', stackTrace),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error getting documents: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while getting documents',
          stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, void>> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error updating document: ${e.message}');
      return Left(
        FirebaseFailure('Failed to update document: ${e.message}', stackTrace),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error updating document: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while updating document',
          stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, void>> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error deleting document: ${e.message}');
      return Left(
        FirebaseFailure('Failed to delete document: ${e.message}', stackTrace),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error deleting document: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while deleting document',
          stackTrace,
        ),
      );
    }
  }

  Stream<Either<Failure, List<Map<String, dynamic>>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>>? Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      // Apply custom query if provided
      if (queryBuilder != null) {
        final customQuery = queryBuilder(_firestore.collection(collection));
        if (customQuery != null) {
          query = customQuery;
        }
      }

      return query.snapshots().map((snapshot) {
        try {
          // Map documents to list and include document IDs
          final documents = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          return Right(documents);
        } catch (e, stackTrace) {
          debugPrint('❌ Error mapping stream data: $e');
          return Left(
            UnknownFailure('Error processing real-time updates', stackTrace),
          );
        }
      });
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error streaming collection: ${e.message}');
      return Stream.value(
        Left(
          FirebaseFailure(
            'Failed to stream collection: ${e.message}',
            stackTrace,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error streaming collection: $e');
      return Stream.value(
        Left(
          UnknownFailure(
            'An unexpected error occurred while streaming collection',
            stackTrace,
          ),
        ),
      );
    }
  }


  Future<Either<Failure, bool>> documentExists({
    required String collection,
    required String documentId,
  }) async {
    try {
      if (documentId.isEmpty) return const Right(false);

      final docSnapshot = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      return Right(docSnapshot.exists);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error checking document existence: ${e.message}');
      return Left(
        FirebaseFailure(
          'Failed to check document existence: ${e.message}',
          stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error checking document existence: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while checking document existence',
          stackTrace,
        ),
      );
    }
  }

  /// Get documents with pagination support
  ///
  /// Parameters:
  /// - [collection]: Name of the Firestore collection
  /// - [lastDocument]: Last document from previous page (for cursor-based pagination)
  /// - [limit]: Number of documents to fetch (default: 10)
  /// - [orderBy]: Field to order by
  /// - [descending]: Sort order (default: false)
  /// - [queryBuilder]: Optional function to add filters
  ///
  /// Returns:
  /// - Right(Map) containing 'data', 'lastDocument', and 'hasMore' keys
  /// - Left(Failure) on error
  Future<Either<Failure, Map<String, dynamic>>> getDocumentsWithPagination({
    required String collection,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    required String orderBy,
    bool descending = false,
    Query<Map<String, dynamic>>? Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      // Apply custom query/filters if provided
      if (queryBuilder != null) {
        final customQuery = queryBuilder(_firestore.collection(collection));
        if (customQuery != null) {
          query = customQuery;
        }
      }

      // Apply ordering
      query = query.orderBy(orderBy, descending: descending);

      // Apply cursor-based pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Apply limit
      query = query.limit(limit);

      // Execute query
      final snapshot = await query.get();

      // Map documents to list and include document IDs
      final documents = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Get last document for next pagination
      final newLastDocument = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;

      // Check if has more data
      final hasMore = snapshot.docs.length == limit;

      return Right({
        'data': documents,
        'lastDocument': newLastDocument,
        'hasMore': hasMore,
      });
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error in pagination: ${e.message}');
      return Left(
        FirebaseFailure(
          'Failed to get paginated documents: ${e.message}',
          stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error in pagination: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while getting paginated documents',
          stackTrace,
        ),
      );
    }
  }

  /// Get collection count with optional filters
  ///
  /// Parameters:
  /// - [collection]: Name of the Firestore collection
  /// - [queryBuilder]: Optional function to add filters
  ///
  /// Returns:
  /// - Right(int) containing the count
  /// - Left(Failure) on error
  Future<Either<Failure, int>> getCollectionCount({
    required String collection,
    Query<Map<String, dynamic>>? Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      // Apply custom query/filters if provided
      if (queryBuilder != null) {
        final customQuery = queryBuilder(_firestore.collection(collection));
        if (customQuery != null) {
          query = customQuery;
        }
      }

      // Use aggregate query for better performance
      final snapshot = await query.count().get();
      return Right(snapshot.count ?? 0);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error getting count: ${e.message}');
      return Left(
        FirebaseFailure(
          'Failed to get collection count: ${e.message}',
          stackTrace,
        ),
      );
    } catch (e) {
      debugPrint('❌ Unknown error getting count: $e');
      // Fallback: return 0 if count fails
      return const Right(0);
    }
  }

  /// Batch write operations (up to 500 operations)
  ///
  /// Parameters:
  /// - [operations]: List of batch operations to perform
  ///
  /// Returns:
  /// - Right(void) on success
  /// - Left(Failure) on error
  Future<Either<Failure, void>> batchWrite(
    List<BatchOperation> operations,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final docRef = _firestore
            .collection(operation.collection)
            .doc(operation.docId);

        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(docRef, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(docRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('❌ Firebase error in batch write: ${e.message}');
      return Left(
        FirebaseFailure(
          'Failed to execute batch write: ${e.message}',
          stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error in batch write: $e');
      return Left(
        UnknownFailure(
          'An unexpected error occurred during batch write',
          stackTrace,
        ),
      );
    }
  }
}

/// Enum for batch operation types
enum BatchOperationType { set, update, delete }

/// Class representing a batch operation
class BatchOperation {
  final String collection;
  final String docId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  const BatchOperation({
    required this.collection,
    required this.docId,
    required this.type,
    this.data,
  });
}
