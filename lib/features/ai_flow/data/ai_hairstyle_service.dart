import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:app/core/services/supabase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIHairstyleGenerationRequest {
  final String photoPath;
  final Map<String, String> preferences;
  final int count;

  const AIHairstyleGenerationRequest({
    required this.photoPath,
    required this.preferences,
    required this.count,
  });
}

class AIHairstyleService {
  static const String edgeFunctionName = String.fromEnvironment(
    'SUPABASE_AI_HAIRSTYLE_FUNCTION',
    defaultValue: 'generate-hairstyles',
  );

  Future<List<String>> generateHairstyles(
    AIHairstyleGenerationRequest request,
  ) async {
    developer.log('Uploading source photo...', name: 'AIHairstyleService');
    final imageUrl = await _uploadSourcePhoto(request.photoPath);
    developer.log(
      'Source photo uploaded: $imageUrl',
      name: 'AIHairstyleService',
    );

    developer.log(
      'Invoking Supabase Edge Function: $edgeFunctionName',
      name: 'AIHairstyleService',
    );
    final response = await Supabase.instance.client.functions.invoke(
      edgeFunctionName,
      body: {
        'imageUrl': imageUrl,
        'preferences': request.preferences,
        'count': request.count,
      },
    );

    final imageUrls = _extractImageUrls(response.data);
    developer.log(
      'Edge Function returned ${imageUrls.length} image URLs',
      name: 'AIHairstyleService',
    );

    return imageUrls;
  }

  Future<String> _uploadSourcePhoto(String photoPath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to upload photos');
    }

    final result = await SupabaseStorageService.uploadHairstyleImage(
      file: File(photoPath),
      userId: user.uid,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (url) => url,
    );
  }

  List<String> _extractImageUrls(Object? data) {
    final decoded = data is String ? jsonDecode(data) : data;
    if (decoded is! Map<String, dynamic>) return const [];

    final imageUrls = decoded['imageUrls'];
    if (imageUrls is List) {
      return imageUrls.whereType<String>().toList(growable: false);
    }

    final results = decoded['results'];
    if (results is List) {
      return results
          .whereType<Map<String, dynamic>>()
          .map((result) => result['imageUrl'])
          .whereType<String>()
          .toList(growable: false);
    }

    return const [];
  }
}
