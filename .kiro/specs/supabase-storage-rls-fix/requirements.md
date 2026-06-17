# Requirements Document

## Introduction

This specification addresses the Supabase storage Row-Level Security (RLS) policy issue preventing users from uploading hairstyle images. The application currently uses Firebase Authentication for user identity management but attempts to upload files to Supabase Storage without proper authentication integration, resulting in RLS policy violations (403 errors: "new row violates row-level security policy").

The fix requires establishing proper authentication between Firebase and Supabase, implementing appropriate RLS policies for the hairstyle_images bucket, and ensuring the upload flow correctly authenticates users with Supabase before attempting storage operations.

## Glossary

- **Firebase_Auth**: The Firebase Authentication service used for user identity management in the application
- **Supabase_Storage**: The Supabase Storage service used for storing hairstyle images
- **RLS**: Row-Level Security - PostgreSQL security policies that control access to storage objects based on user identity
- **Hairstyle_Images_Bucket**: The Supabase storage bucket named "hairstyle_images" used for storing user hairstyle photos
- **Anonymous_User**: A user who has not signed in with Firebase Authentication
- **Authenticated_User**: A user who has successfully signed in with Firebase Authentication and has a valid Firebase user ID
- **Supabase_JWT**: JSON Web Token used by Supabase to authenticate requests and enforce RLS policies
- **AIHairstyleService**: The Dart service class responsible for uploading hairstyle images and invoking AI generation
- **SupabaseStorageService**: The Dart service class that handles all Supabase storage operations
- **Upload_Path**: The file path pattern used in storage: `{userId}/{timestamp}_hairstyle.jpg`

## Requirements

### Requirement 1: Authentication Integration

**User Story:** As a system architect, I want to integrate Firebase Authentication with Supabase Storage, so that authenticated Firebase users can access Supabase storage with proper permissions.

#### Acceptance Criteria

1. WHEN a Firebase user successfully authenticates, THE System SHALL generate a valid Supabase_JWT containing the Firebase user ID
2. WHEN making storage requests to Supabase_Storage, THE System SHALL include the Supabase_JWT in the authorization header
3. WHEN the Supabase_JWT is missing or invalid, THE Supabase_Storage SHALL reject the request with a 401 unauthorized error
4. WHEN the Supabase_JWT is valid, THE Supabase_Storage SHALL extract the user ID and apply RLS policies based on that identity

### Requirement 2: RLS Policy Configuration

**User Story:** As a system administrator, I want properly configured RLS policies on the hairstyle_images bucket, so that authenticated users can upload their own images securely.

#### Acceptance Criteria

1. THE Hairstyle_Images_Bucket SHALL have RLS enabled to enforce access control
2. WHEN an Authenticated_User uploads an image to their own folder path, THE System SHALL allow the insert operation
3. WHEN an Authenticated_User attempts to upload to another user's folder path, THE System SHALL reject the operation with a 403 forbidden error
4. WHEN an Anonymous_User attempts to upload an image, THE System SHALL reject the operation with a 403 forbidden error
5. THE RLS policy SHALL verify that the Upload_Path contains the authenticated user's ID matching the Supabase_JWT user claim

### Requirement 3: Upload Flow Authentication

**User Story:** As a user, I want to upload hairstyle images for AI generation, so that I can receive personalized hairstyle recommendations.

#### Acceptance Criteria

1. WHEN a user initiates hairstyle image upload, THE AIHairstyleService SHALL verify the user is authenticated with Firebase_Auth before proceeding
2. WHEN uploading to Supabase_Storage, THE SupabaseStorageService SHALL use the authenticated Supabase client with valid Supabase_JWT
3. WHEN the upload completes successfully, THE System SHALL return the public URL of the uploaded image
4. WHEN the upload fails due to authentication errors, THE System SHALL return a clear error message indicating authentication is required
5. WHEN the upload fails due to RLS policy violations, THE System SHALL return a clear error message indicating permission was denied

### Requirement 4: Error Handling and Diagnostics

**User Story:** As a developer, I want clear error messages and logging for storage operations, so that I can diagnose and fix authentication issues quickly.

#### Acceptance Criteria

1. WHEN a storage operation fails, THE System SHALL log the error type, error message, and relevant context
2. WHEN an RLS policy violation occurs, THE System SHALL distinguish between authentication failures and authorization failures
3. WHEN logging authentication errors, THE System SHALL include whether a Supabase_JWT was present and whether the user ID matched the requested path
4. THE System SHALL NOT log sensitive information such as authentication tokens or user credentials

### Requirement 5: Supabase Client Configuration

**User Story:** As a developer, I want a properly configured Supabase client that supports authentication, so that all storage operations use the correct auth context.

#### Acceptance Criteria

1. THE SupabaseStorageService SHALL initialize the Supabase client with both the anonymous key and authentication support
2. WHEN a Firebase user is authenticated, THE System SHALL configure the Supabase client to use a custom JWT based on the Firebase ID token
3. WHEN the Firebase authentication state changes, THE System SHALL update the Supabase client authentication accordingly
4. THE Supabase client SHALL maintain the authentication session across multiple storage operations
5. WHEN the app restarts with an authenticated Firebase user, THE System SHALL restore the Supabase authentication session

### Requirement 6: Database Schema and Policy Deployment

**User Story:** As a developer, I want SQL migration scripts or deployment instructions for RLS policies, so that I can apply the security configuration to Supabase.

#### Acceptance Criteria

1. THE System SHALL provide SQL migration scripts that create the necessary RLS policies for the Hairstyle_Images_Bucket
2. THE migration scripts SHALL be idempotent, allowing safe re-execution without errors
3. THE System SHALL provide clear documentation on how to apply the policies through the Supabase dashboard as an alternative to SQL migrations
4. THE RLS policies SHALL include both INSERT policies for uploads and SELECT policies for reading uploaded images
5. THE documentation SHALL specify which Supabase project settings must be configured for custom JWT authentication

### Requirement 7: Testing and Verification

**User Story:** As a developer, I want to verify the RLS policies and authentication flow work correctly, so that I can ensure the bug is fixed before deployment.

#### Acceptance Criteria

1. WHEN testing with an Authenticated_User, THE System SHALL successfully upload images to that user's folder path
2. WHEN testing with an Anonymous_User, THE System SHALL reject upload attempts with a 403 error
3. WHEN testing cross-user access attempts, THE System SHALL reject uploads to other users' folder paths with a 403 error
4. THE System SHALL provide integration tests that verify the end-to-end upload flow with authentication
5. THE System SHALL provide unit tests that verify RLS policy logic can be validated independently
