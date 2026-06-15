# Barber Booking App - Clean Architecture Structure

## Overview
This project follows Clean Architecture principles with a Feature-First approach.

## Directory Structure

```
lib/
├── main.dart                      # Application entry point
├── core/                          # Core shared modules
│   ├── entities/                  # Shared domain entities
│   ├── models/                    # Shared data models
│   ├── repos/                     # Shared repository interfaces
│   ├── services/                  # Core services (Firebase, Supabase, etc.)
│   ├── utils/                     # Utilities and helpers
│   ├── widgets/                   # Shared/reusable widgets
│   └── errors/                    # Error handling (failures, exceptions)
├── features/                      # Feature modules
│   ├── splash/                    # Splash screen
│   ├── category_selection/        # Main category selection screen
│   ├── auth/                      # Authentication feature
│   ├── men_services/              # Men's barbershop services
│   ├── women_services/            # Women's salon services
│   ├── kids_services/             # Kids services
│   ├── store/                     # QUTI Store (products)
│   ├── cart/                      # Shopping cart
│   ├── booking/                   # Booking management
│   ├── provider_registration/     # Provider registration
│   ├── ai_advisor/                # AI hair style advisor
│   ├── profile/                   # User profile
│   ├── favorites/                 # Favorites management
│   └── search/                    # Search functionality
└── config/                        # App configuration
    ├── routes/                    # Navigation/routing
    └── themes/                    # Theme configuration

```

## Feature Structure
Each feature follows Clean Architecture layers:

```
feature_name/
├── data/                         # Data layer
│   ├── models/                   # Data models with JSON serialization
│   └── repos/                    # Repository implementations
├── domain/                       # Domain layer
│   ├── entities/                 # Business entities
│   └── repos/                    # Repository interfaces
└── presentation/                 # Presentation layer
    ├── views/                    # UI screens
    ├── widgets/                  # Feature-specific widgets
    └── cubit/                    # State management (Cubit/Bloc)
```

## Core Modules

### Core Services
- `firebase_auth_service.dart` - Firebase Authentication
- `firestore_service.dart` - Firestore database operations
- `supabase_storage_service.dart` - Supabase storage
- `get_it_service.dart` - Dependency injection setup
- `navigation_service.dart` - Navigation helper
- `fcm_service.dart` - Firebase Cloud Messaging
- `notification_service.dart` - Local notifications
- `location_service.dart` - Location services
- `payment_service.dart` - Payment integration

### Core Utilities
- `color_manager.dart` - App color palette
- `text_styles.dart` - Text styles
- `constants.dart` - App constants
- `validators.dart` - Input validation
- `date_formatter.dart` - Date formatting
- `image_compressor.dart` - Image compression

### Core Widgets
- `custom_button.dart` - Reusable button
- `custom_text_field.dart` - Reusable text field
- `loading_widget.dart` - Loading indicator
- `error_widget.dart` - Error display
- `shimmer_loading.dart` - Shimmer loading effect
- `cached_image_widget.dart` - Cached network image
- `rating_widget.dart` - Rating display

## Dependencies

### State Management
- flutter_bloc, bloc, equatable

### Dependency Injection
- get_it

### Backend
- Firebase (auth, firestore, storage, messaging)
- Supabase

### UI/UX
- cached_network_image, flutter_screenutil, shimmer

### Localization
- easy_localization, flutter_localizations

### Utilities
- dartz (functional programming)
- image_picker, geolocator, geocoding, google_maps_flutter
- permission_handler, connectivity_plus, shared_preferences

## Architecture Flow

**Presentation → Domain → Data**

- Presentation layer depends on Domain
- Data layer implements Domain interfaces
- Domain layer is independent (no dependencies on outer layers)

## Getting Started

1. Run `flutter pub get` to install dependencies
2. Initialize Firebase project
3. Configure Supabase credentials
4. Run `flutter run` to start the app

## Notes
- Use Repository pattern for all data operations
- Use Cubit/Bloc for state management
- Place shared code in `core/`
- Keep features independent and modular
