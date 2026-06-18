import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:app/core/errors/failures.dart';
import 'package:app/core/services/firestore_service.dart';
import 'package:app/core/services/supabase_storage_service.dart';
import 'package:app/features/store_flow/data/models/store_item_model.dart';

class StoreRepository {
  StoreRepository({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  static const String collectionName = 'store_items';

  final FirestoreService _firestoreService;

  Stream<Either<Failure, List<StoreItemModel>>> streamItems({
    StoreItemType? type,
    int? limit,
  }) {
    return _firestoreService
        .streamCollection(
          collection: collectionName,
          queryBuilder: (ref) {
            Query<Map<String, dynamic>> query = ref.where(
              'isActive',
              isEqualTo: true,
            );
            if (type != null) {
              query = query.where('type', isEqualTo: type.value);
            }
            if (limit != null) {
              query = query.limit(limit);
            }
            return query;
          },
        )
        .map(
          (result) => result.map((items) {
            final mapped = items.map(StoreItemModel.fromMap).toList();
            mapped.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return mapped;
          }),
        );
  }

  Future<Either<Failure, String>> createItem({
    required StoreItemType type,
    required String title,
    required String brand,
    required String description,
    required String category,
    required double price,
    required double? oldPrice,
    required double rating,
    required String? badge,
    required File imageFile,
  }) async {
    final documentId = FirebaseFirestore.instance
        .collection(collectionName)
        .doc()
        .id;
    final uploadResult = await SupabaseStorageService.uploadProductImage(
      file: imageFile,
      productId: documentId,
    );

    return uploadResult.fold(Left.new, (imageUrl) async {
      final now = DateTime.now();
      final item = StoreItemModel(
        id: documentId,
        title: title,
        brand: brand,
        description: description,
        category: category,
        price: price,
        oldPrice: oldPrice,
        rating: rating,
        badge: badge,
        imageUrl: imageUrl,
        type: type,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await _firestoreService.addDocument(
        collection: collectionName,
        documentId: documentId,
        data: item.toMap(),
      );

      return saveResult.map((_) => documentId);
    });
  }
}
