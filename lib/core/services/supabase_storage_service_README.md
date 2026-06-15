# Supabase Storage Service

## Overview

`SupabaseStorageService` provides a centralized service for handling all Supabase Storage operations in the Barber Booking App. It manages image uploads, deletions, and URL retrieval for various features including profile images, shop images, business licenses, reviews, and products.

## Features

- ✅ Initialize Supabase client
- ✅ Upload images to different buckets
- ✅ Delete images and folders
- ✅ Get public URLs for stored images
- ✅ Automatic bucket creation and initialization
- ✅ Comprehensive error handling with Either type
- ✅ Specialized methods for different image types
- ✅ Network error detection
- ✅ Content type detection
- ✅ Detailed logging for debugging

## Storage Buckets

The service manages six different storage buckets:

1. **profile_images** - User profile photos
2. **shop_images** - Barbershop/salon photos
3. **business_licenses** - Provider business license documents
4. **review_images** - Customer review photos
5. **product_images** - Store product images
6. **hairstyle_images** - AI advisor hairstyle suggestions

## Setup

### 1. Configuration

Update the Supabase credentials in the service file:

```dart
static const String _supabaseUrl = 'YOUR_SUPABASE_URL';
static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 2. Initialization

Initialize Supabase before using the service (typically in `main.dart`):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Supabase
  final result = await SupabaseStorageService.initSupabase();
  result.fold(
    (failure) => log('Supabase initialization failed: ${failure.message}'),
    (_) => log('Supabase initialized successfully'),
  );
  
  runApp(const MyApp());
}
```

### 3. Supabase Dashboard Setup

1. Go to your Supabase project dashboard
2. Navigate to Storage section
3. Create the following buckets (or let the service create them automatically):
   - profile_images
   - shop_images
   - business_licenses
   - review_images
   - product_images
   - hairstyle_images
4. Set each bucket to **Public** for direct URL access
5. Configure RLS policies as needed for security

## Usage Examples

### Upload Profile Image

```dart
Future<void> uploadUserProfile(File imageFile, String userId) async {
  final result = await SupabaseStorageService.uploadProfileImage(
    file: imageFile,
    userId: userId,
  );
  
  result.fold(
    (failure) {
      // Handle error
      print('Upload failed: ${failure.message}');
    },
    (publicUrl) {
      // Use the public URL
      print('Image uploaded: $publicUrl');
      // Save URL to Firestore user document
    },
  );
}
```

### Upload Shop Image

```dart
Future<void> uploadShopPhoto(File imageFile, String shopId) async {
  final result = await SupabaseStorageService.uploadShopImage(
    file: imageFile,
    shopId: shopId,
  );
  
  result.fold(
    (failure) => showError(failure.message),
    (publicUrl) => saveShopImage(publicUrl),
  );
}
```

### Upload Business License

```dart
Future<void> uploadLicense(File licenseFile, String providerId) async {
  final result = await SupabaseStorageService.uploadBusinessLicense(
    file: licenseFile,
    providerId: providerId,
  );
  
  result.fold(
    (failure) => emit(RegistrationError(failure.message)),
    (publicUrl) => emit(LicenseUploaded(publicUrl)),
  );
}
```

### Delete Image

```dart
Future<void> removeImage(String bucket, String path) async {
  final result = await SupabaseStorageService.deleteImage(
    bucket: bucket,
    path: path,
  );
  
  result.fold(
    (failure) => print('Delete failed: ${failure.message}'),
    (_) => print('Image deleted successfully'),
  );
}
```

### Delete User Folder

```dart
Future<void> deleteAllUserImages(String userId) async {
  final result = await SupabaseStorageService.deleteFolder(
    bucket: SupabaseStorageService.profileImagesBucket,
    folderPath: userId,
  );
  
  result.fold(
    (failure) => print('Folder delete failed: ${failure.message}'),
    (_) => print('All user images deleted'),
  );
}
```

### Get Public URL

```dart
String getImageUrl(String bucket, String path) {
  return SupabaseStorageService.getPublicUrl(
    bucket: bucket,
    path: path,
  );
}
```

### Generic Upload

```dart
Future<void> uploadCustomImage(File file, String bucket, String path) async {
  final result = await SupabaseStorageService.uploadImage(
    file: file,
    bucket: bucket,
    path: path,
  );
  
  result.fold(
    (failure) => handleError(failure),
    (url) => handleSuccess(url),
  );
}
```

## Use Cases in Barber Booking App

### 1. User Profile Management

```dart
class ProfileCubit extends Cubit<ProfileState> {
  Future<void> updateProfilePhoto(File imageFile) async {
    emit(ProfileLoading());
    
    final userId = getCurrentUserId();
    final result = await SupabaseStorageService.uploadProfileImage(
      file: imageFile,
      userId: userId,
    );
    
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (photoUrl) async {
        // Update Firestore with new photo URL
        await updateUserDocument(userId, {'photoUrl': photoUrl});
        emit(ProfileUpdated(photoUrl));
      },
    );
  }
}
```

### 2. Provider Registration

```dart
class ProviderRegistrationCubit extends Cubit<ProviderRegistrationState> {
  Future<void> uploadLicenseAndShopImages({
    required File licenseFile,
    required List<File> shopImages,
    required String providerId,
  }) async {
    emit(UploadingImages());
    
    // Upload license
    final licenseResult = await SupabaseStorageService.uploadBusinessLicense(
      file: licenseFile,
      providerId: providerId,
    );
    
    if (licenseResult.isLeft()) {
      emit(UploadError('Failed to upload license'));
      return;
    }
    
    // Upload shop images
    List<String> shopImageUrls = [];
    for (var imageFile in shopImages) {
      final result = await SupabaseStorageService.uploadShopImage(
        file: imageFile,
        shopId: providerId,
      );
      
      result.fold(
        (failure) => null,
        (url) => shopImageUrls.add(url),
      );
    }
    
    final licenseUrl = licenseResult.getOrElse(() => '');
    emit(ImagesUploaded(licenseUrl, shopImageUrls));
  }
}
```

### 3. Review with Images

```dart
class ReviewCubit extends Cubit<ReviewState> {
  Future<void> submitReviewWithImages({
    required String reviewId,
    required List<File> images,
  }) async {
    emit(SubmittingReview());
    
    List<String> imageUrls = [];
    
    for (var imageFile in images) {
      final result = await SupabaseStorageService.uploadReviewImage(
        file: imageFile,
        reviewId: reviewId,
      );
      
      result.fold(
        (failure) => log('Failed to upload review image: ${failure.message}'),
        (url) => imageUrls.add(url),
      );
    }
    
    emit(ReviewSubmitted(imageUrls));
  }
}
```

### 4. AI Hair Advisor

```dart
class AIAdvisorCubit extends Cubit<AIAdvisorState> {
  Future<void> uploadFacePhoto(File imageFile) async {
    emit(UploadingPhoto());
    
    final userId = getCurrentUserId();
    final result = await SupabaseStorageService.uploadHairstyleImage(
      file: imageFile,
      userId: userId,
    );
    
    result.fold(
      (failure) => emit(UploadError(failure.message)),
      (photoUrl) async {
        // Process with AI
        await analyzeHairstyle(photoUrl);
      },
    );
  }
}
```

## Error Handling

The service returns `Either<Failure, T>` for all operations. Handle errors appropriately:

```dart
result.fold(
  (failure) {
    if (failure is NetworkFailure) {
      // No internet connection
      showSnackbar('Please check your internet connection');
    } else if (failure is SupabaseFailure) {
      // Supabase-specific error
      showSnackbar('Storage error: ${failure.message}');
    } else if (failure is ValidationFailure) {
      // File validation error
      showSnackbar('Invalid file: ${failure.message}');
    } else {
      // Generic error
      showSnackbar('An error occurred');
    }
  },
  (data) {
    // Success
  },
);
```

## Failure Types

The service can return the following failure types:

- **NetworkFailure** - Network connectivity issues
- **SupabaseFailure** - Supabase storage errors
- **ValidationFailure** - File validation errors (file doesn't exist, etc.)
- **UnknownFailure** - Unexpected errors

## File Organization

Images are organized in buckets with the following structure:

```
bucket_name/
├── userId1/
│   ├── userId1_timestamp1.jpg
│   └── userId1_timestamp2.png
├── userId2/
│   └── userId2_timestamp3.jpg
└── userId3/
    └── userId3_timestamp4.png
```

This structure allows for:
- Easy deletion of all user images
- No filename conflicts
- User-specific folder isolation

## Supported File Types

The service automatically detects and sets the correct content type for:

- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)
- WebP (.webp)
- SVG (.svg)

## Best Practices

1. **Always initialize first** - Call `initSupabase()` in `main.dart`
2. **Handle errors** - Always handle both success and failure cases
3. **Use specific methods** - Use `uploadProfileImage()`, `uploadShopImage()`, etc. instead of generic `uploadImage()`
4. **Delete old images** - When updating, delete old images to save storage space
5. **Compress before upload** - Use image compression to reduce file sizes
6. **Validate files** - Check file existence and size before uploading
7. **Log operations** - The service logs operations for debugging
8. **Check initialization** - Use `SupabaseStorageService.isInitialized` to check status

## Security Considerations

1. **RLS Policies** - Configure Row Level Security policies in Supabase dashboard
2. **Public Buckets** - Only make buckets public if images need to be accessible without authentication
3. **File Size Limits** - Implement file size limits in your app (recommended: 5MB max)
4. **File Type Validation** - Validate file types on both client and server side
5. **Path Sanitization** - The service uses user IDs and timestamps to prevent path injection

## Debugging

The service provides detailed logging. To view logs:

```dart
import 'dart:developer';

// Logs are automatically written with name 'SupabaseStorageService'
// Filter logs in your console/IDE by this name
```

Check if Supabase is initialized:

```dart
if (SupabaseStorageService.isInitialized) {
  print('Supabase is ready');
} else {
  print('Supabase not initialized');
}
```

## Testing

Example test for upload functionality:

```dart
test('Upload profile image returns public URL', () async {
  final file = File('test_image.jpg');
  final userId = 'test_user_123';
  
  final result = await SupabaseStorageService.uploadProfileImage(
    file: file,
    userId: userId,
  );
  
  expect(result.isRight(), true);
  result.fold(
    (failure) => fail('Should not fail'),
    (url) => expect(url, contains('profile_images')),
  );
});
```

## Dependencies

Required packages in `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.12.0
  dartz: ^0.10.1
  path: ^1.9.0
```

## Additional Resources

- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Dartz Package Documentation](https://pub.dev/packages/dartz)
