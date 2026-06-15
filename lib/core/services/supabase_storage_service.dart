import 'dart:io';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as path_helper;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/failures.dart';

/// Service for handling Supabase Storage operations
/// Provides image upload, deletion, and URL retrieval functionality
class SupabaseStorageService {
  static late Supabase _supabase;
  static bool _isInitialized = false;

  // Bucket names for different types of images
  static const String _profileImagesBucket = 'profile_images';
  static const String _shopImagesBucket = 'shop_images';
  static const String _businessLicensesBucket = 'business_licenses';
  static const String _reviewImagesBucket = 'review_images';
  static const String _productImagesBucket = 'product_images';
  static const String _hairstyleImagesBucket = 'hairstyle_images';

  // Supabase configuration
  static const String _supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Initialize Supabase client
  /// Must be called before using any other methods
  static Future<Either<Failure, void>> initSupabase() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      log(
        'Initializing Supabase at $_supabaseUrl',
        name: 'SupabaseStorageService',
      );

      _supabase = await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );

      _isInitialized = true;
      log('Supabase initialized successfully', name: 'SupabaseStorageService');

      // Initialize buckets
      await _initializeBuckets();

      return const Right(null);
    } on SocketException catch (e, stackTrace) {
      log(
        'Network error initializing Supabase: $e',
        name: 'SupabaseStorageService',
      );
      _isInitialized = false;
      return Left(
        NetworkFailure(
          'Network error: Failed to connect to Supabase. Please check your internet connection.',
          stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      log('Error initializing Supabase: $e', name: 'SupabaseStorageService');
      _isInitialized = false;
      return Left(
        SupabaseFailure(
          'Failed to initialize Supabase: ${e.toString()}',
          stackTrace,
        ),
      );
    }
  }

  /// Ensure Supabase is initialized before operations
  static Future<Either<Failure, void>> _ensureInitialized() async {
    if (!_isInitialized) {
      log(
        'Supabase not initialized, attempting to initialize now...',
        name: 'SupabaseStorageService',
      );
      return await initSupabase();
    }
    return const Right(null);
  }

  /// Initialize all required storage buckets
  static Future<void> _initializeBuckets() async {
    try {
      await _createBucketIfNotExists(_profileImagesBucket);
      await _createBucketIfNotExists(_shopImagesBucket);
      await _createBucketIfNotExists(_businessLicensesBucket);
      await _createBucketIfNotExists(_reviewImagesBucket);
      await _createBucketIfNotExists(_productImagesBucket);
      await _createBucketIfNotExists(_hairstyleImagesBucket);
      log('All buckets initialized', name: 'SupabaseStorageService');
    } catch (e) {
      log('Error initializing buckets: $e', name: 'SupabaseStorageService');
    }
  }

  /// Create a bucket if it doesn't exist
  static Future<void> _createBucketIfNotExists(String bucketName) async {
    try {
      // Attempt to list buckets to check existence
      List<Bucket> buckets = [];
      try {
        buckets = await _supabase.client.storage.listBuckets();
      } catch (e) {
        // RLS policies often prevent listing buckets for anon users.
        // This is expected behavior, not an error.
        // We assume the bucket exists and proceed.
        log(
          'Cannot list buckets (expected with RLS): $e',
          name: 'SupabaseStorageService',
        );
        return;
      }

      bool bucketExists = false;
      for (var bucket in buckets) {
        if (bucket.id == bucketName) {
          bucketExists = true;
          break;
        }
      }

      // Only attempt creation if we are SURE it doesn't exist
      if (!bucketExists) {
        try {
          await _supabase.client.storage.createBucket(
            bucketName,
            const BucketOptions(public: true),
          );
          log('Created bucket: $bucketName', name: 'SupabaseStorageService');
        } catch (e) {
          log(
            'Cannot create bucket $bucketName (may require service role): $e',
            name: 'SupabaseStorageService',
          );
        }
      }
    } catch (e) {
      log(
        'Error checking/creating bucket $bucketName: $e',
        name: 'SupabaseStorageService',
      );
    }
  }

  /// Upload an image to Supabase Storage
  ///
  /// [file] - The image file to upload
  /// [bucket] - The storage bucket name
  /// [path] - The path within the bucket (e.g., "userId/image.jpg")
  ///
  /// Returns Either<Failure, String> where String is the public URL
  static Future<Either<Failure, String>> uploadImage({
    required File file,
    required String bucket,
    required String path,
  }) async {
    final initResult = await _ensureInitialized();
    if (initResult.isLeft()) {
      return initResult.fold(
        (failure) => Left(failure),
        (_) => const Left(
          UnknownFailure('Unexpected error during initialization'),
        ),
      );
    }

    try {
      if (!file.existsSync()) {
        return Left(
          ValidationFailure('File does not exist at path: ${file.path}'),
        );
      }

      log('Uploading image to $bucket: $path', name: 'SupabaseStorageService');

      final bytes = await file.readAsBytes();
      final String extension = path_helper.extension(file.path);

      await _supabase.client.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: true,
            ),
          );

      final String publicUrl = _supabase.client.storage
          .from(bucket)
          .getPublicUrl(path);

      log(
        'Successfully uploaded image: $publicUrl',
        name: 'SupabaseStorageService',
      );
      return Right(publicUrl);
    } on SocketException catch (e, stackTrace) {
      log('Network error uploading image: $e', name: 'SupabaseStorageService');
      return Left(
        NetworkFailure(
          'Network error: Failed to upload image. Please check your internet connection.',
          stackTrace,
        ),
      );
    } on StorageException catch (e, stackTrace) {
      log('Storage error uploading image: $e', name: 'SupabaseStorageService');
      return Left(SupabaseFailure('Storage error: ${e.message}', stackTrace));
    } catch (e, stackTrace) {
      log('Error uploading image: $e', name: 'SupabaseStorageService');
      return Left(
        SupabaseFailure('Failed to upload image: ${e.toString()}', stackTrace),
      );
    }
  }

  /// Delete an image from Supabase Storage
  ///
  /// [bucket] - The storage bucket name
  /// [path] - The path of the file to delete
  ///
  /// Returns Either<Failure, void>
  static Future<Either<Failure, void>> deleteImage({
    required String bucket,
    required String path,
  }) async {
    final initResult = await _ensureInitialized();
    if (initResult.isLeft()) {
      return initResult.fold(
        (failure) => Left(failure),
        (_) => const Left(
          UnknownFailure('Unexpected error during initialization'),
        ),
      );
    }

    try {
      log('Deleting image from $bucket: $path', name: 'SupabaseStorageService');

      await _supabase.client.storage.from(bucket).remove([path]);

      log('Successfully deleted image: $path', name: 'SupabaseStorageService');
      return const Right(null);
    } on SocketException catch (e, stackTrace) {
      log('Network error deleting image: $e', name: 'SupabaseStorageService');
      return Left(
        NetworkFailure(
          'Network error: Failed to delete image. Please check your internet connection.',
          stackTrace,
        ),
      );
    } on StorageException catch (e, stackTrace) {
      log('Storage error deleting image: $e', name: 'SupabaseStorageService');
      return Left(SupabaseFailure('Storage error: ${e.message}', stackTrace));
    } catch (e, stackTrace) {
      log('Error deleting image: $e', name: 'SupabaseStorageService');
      return Left(
        SupabaseFailure('Failed to delete image: ${e.toString()}', stackTrace),
      );
    }
  }

  /// Delete multiple images for a specific user/entity
  ///
  /// [bucket] - The storage bucket name
  /// [folderPath] - The folder path containing files to delete
  ///
  /// Returns Either<Failure, void>
  static Future<Either<Failure, void>> deleteFolder({
    required String bucket,
    required String folderPath,
  }) async {
    final initResult = await _ensureInitialized();
    if (initResult.isLeft()) {
      return initResult.fold(
        (failure) => Left(failure),
        (_) => const Left(
          UnknownFailure('Unexpected error during initialization'),
        ),
      );
    }

    try {
      log(
        'Deleting folder from $bucket: $folderPath',
        name: 'SupabaseStorageService',
      );

      // List all files in the folder
      final List<FileObject> files = await _supabase.client.storage
          .from(bucket)
          .list(path: folderPath);

      if (files.isEmpty) {
        log(
          'No files found in folder: $folderPath',
          name: 'SupabaseStorageService',
        );
        return const Right(null);
      }

      // Delete all files
      final filePaths = files.map((f) => '$folderPath/${f.name}').toList();
      await _supabase.client.storage.from(bucket).remove(filePaths);

      log(
        'Successfully deleted ${files.length} files from folder: $folderPath',
        name: 'SupabaseStorageService',
      );
      return const Right(null);
    } on SocketException catch (e, stackTrace) {
      log('Network error deleting folder: $e', name: 'SupabaseStorageService');
      return Left(
        NetworkFailure(
          'Network error: Failed to delete folder. Please check your internet connection.',
          stackTrace,
        ),
      );
    } on StorageException catch (e, stackTrace) {
      log('Storage error deleting folder: $e', name: 'SupabaseStorageService');
      return Left(SupabaseFailure('Storage error: ${e.message}', stackTrace));
    } catch (e, stackTrace) {
      log('Error deleting folder: $e', name: 'SupabaseStorageService');
      return Left(
        SupabaseFailure('Failed to delete folder: ${e.toString()}', stackTrace),
      );
    }
  }

  /// Get the public URL for a file in storage
  ///
  /// [bucket] - The storage bucket name
  /// [path] - The path of the file
  ///
  /// Returns the public URL as a String
  static String getPublicUrl({required String bucket, required String path}) {
    if (!_isInitialized) {
      log(
        'Warning: Getting public URL before initialization',
        name: 'SupabaseStorageService',
      );
    }

    return _supabase.client.storage.from(bucket).getPublicUrl(path);
  }

  /// Upload profile image for a user
  /// Automatically handles deletion of old profile images
  ///
  /// [file] - The image file to upload
  /// [userId] - The user's ID
  ///
  /// Returns Either<Failure, String> where String is the public URL
  static Future<Either<Failure, String>> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    // Delete old profile images first
    await deleteFolder(bucket: _profileImagesBucket, folderPath: userId);

    final String extension = path_helper.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${userId}_$timestamp$extension';
    final String uploadPath = '$userId/$fileName';

    return uploadImage(
      file: file,
      bucket: _profileImagesBucket,
      path: uploadPath,
    );
  }

  /// Upload shop image
  ///
  /// [file] - The image file to upload
  /// [shopId] - The shop's ID
  ///
  /// Returns Either<Failure, String> where String is the public URL
  static Future<Either<Failure, String>> uploadShopImage({
    required File file,
    required String shopId,
  }) async {
    final String extension = path_helper.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${timestamp}_shop$extension';
    final String uploadPath = '$shopId/$fileName';

    return uploadImage(file: file, bucket: _shopImagesBucket, path: uploadPath);
  }

  /// Upload business license image
  ///
  /// [file] - The image file to upload
  /// [providerId] - The provider's ID
  ///
  /// Returns Either<Failure, String> where String is the public URL
  static Future<Either<Failure, String>> uploadBusinessLicense({
    required File file,
    required String providerId,
  }) async {
    final String extension = path_helper.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${timestamp}_license$extension';
    final String uploadPath = '$providerId/$fileName';

    return uploadImage(
      file: file,
      bucket: _businessLicensesBucket,
      path: uploadPath,
    );
  }

  /// Upload review image
  ///
  /// [file] - The image file to upload
  /// [reviewId] - The review's ID
  ///
  /// Returns Either<Failure, String> where String is the public URL
  static Future<Either<Failure, String>> uploadReviewImage({
    required File file,
    required String reviewId,
  }) async {
    final String extension = path_helper.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${timestamp}_review$extension';
    final String uploadPath = '$reviewId/$fileName';

    return uploadImage(
      file: file,
      bucket: _reviewImagesBucket,
      path: uploadPath,
    );
  }

  /// Upload product image
  ///
  /// [file] - The image file to upload
  /// [productId] - The product's ID
  ///
  /// Returns Either<Failure, String> where String is the public URL
  static Future<Either<Failure, String>> uploadProductImage({
    required File file,
    required String productId,
  }) async {
    final String extension = path_helper.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${timestamp}_product$extension';
    final String uploadPath = '$productId/$fileName';

    return uploadImage(
      file: file,
      bucket: _productImagesBucket,
      path: uploadPath,
    );
  }

  /// Upload hairstyle suggestion image (for AI advisor feature)
  ///
  /// [file] - The image file to upload
  /// [userId] - The user's ID
  ///
  /// Returns Either<Failure, String> where String is the public URL
  static Future<Either<Failure, String>> uploadHairstyleImage({
    required File file,
    required String userId,
  }) async {
    final String extension = path_helper.extension(file.path);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '${timestamp}_hairstyle$extension';
    final String uploadPath = '$userId/$fileName';

    return uploadImage(
      file: file,
      bucket: _hairstyleImagesBucket,
      path: uploadPath,
    );
  }

  /// Get the content type based on file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.svg':
        return 'image/svg+xml';
      default:
        return 'application/octet-stream';
    }
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _isInitialized;

  /// Get bucket names (useful for testing and debugging)
  static String get profileImagesBucket => _profileImagesBucket;
  static String get shopImagesBucket => _shopImagesBucket;
  static String get businessLicensesBucket => _businessLicensesBucket;
  static String get reviewImagesBucket => _reviewImagesBucket;
  static String get productImagesBucket => _productImagesBucket;
  static String get hairstyleImagesBucket => _hairstyleImagesBucket;
}
