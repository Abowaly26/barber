# Navigation Service

## Overview

The `NavigationService` provides a centralized way to handle navigation throughout the application without requiring `BuildContext`. It uses GetIt to access the `GlobalKey<NavigatorState>` for navigation operations.

## Features

- **Context-free navigation**: Navigate from anywhere in the app without needing BuildContext
- **Named routes**: All navigation uses named routes for better organization
- **Multiple navigation types**: Support for push, replace, and clear stack navigation
- **Dependency injection**: Integrated with GetIt for easy access

## Setup

### 1. Register NavigatorKey and NavigationService in GetIt

```dart
// In lib/core/services/get_it_service.dart

final getIt = GetIt.instance;

void setupGetIt() {
  // Register Navigator Key as singleton
  getIt.registerSingleton<GlobalKey<NavigatorState>>(
    GlobalKey<NavigatorState>(),
  );
  
  // Register Navigation Service as singleton
  getIt.registerSingleton<NavigationService>(NavigationService());
  
  // ... other registrations
}
```

### 2. Set navigatorKey in MaterialApp

```dart
// In main.dart or app.dart

class BarberBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: getIt<GlobalKey<NavigatorState>>(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: SplashView.routeName,
      // ... other properties
    );
  }
}
```

## Usage

### Basic Navigation

```dart
// Get the navigation service from GetIt
final navigationService = getIt<NavigationService>();

// Navigate to a route
navigationService.navigateTo('/home');

// Navigate with arguments
navigationService.navigateTo(
  '/shop-details',
  arguments: {'shopId': '123'},
);
```

### Replace Navigation

```dart
// Replace current route (useful for login -> home transitions)
navigationService.navigateAndReplace('/home');
```

### Clear Stack Navigation

```dart
// Navigate and remove all previous routes (useful for logout)
navigationService.navigateAndRemoveUntil('/login');
```

### Go Back

```dart
// Simple back navigation
navigationService.goBack();

// Go back with a result
navigationService.goBackWithResult({'status': 'success'});
```

## Use Cases

### 1. Navigation from Business Logic (Cubit/Bloc)

```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final NavigationService navigationService;
  
  AuthCubit({
    required this.authRepo,
    required this.navigationService,
  }) : super(AuthInitial());
  
  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    
    final result = await authRepo.signInWithEmail(email, password);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        emit(AuthSuccess(user));
        // Navigate without BuildContext
        navigationService.navigateAndRemoveUntil('/category-selection');
      },
    );
  }
}
```

### 2. Navigation from Services

```dart
class FCMService {
  final NavigationService navigationService;
  
  FCMService(this.navigationService);
  
  void _handleNotificationTap(RemoteMessage message) {
    // Navigate based on notification data
    final String? route = message.data['route'];
    if (route != null) {
      navigationService.navigateTo(route);
    }
  }
}
```

### 3. Navigation from Repositories (Error Handling)

```dart
class BookingRepoImpl implements BookingRepo {
  final FirestoreService firestoreService;
  final NavigationService navigationService;
  
  @override
  Future<Either<Failure, void>> createBooking(BookingEntity booking) async {
    try {
      // ... booking logic
      
      if (userNotAuthenticated) {
        // Navigate to login from repository
        navigationService.navigateTo('/login');
        return Left(UnauthorizedFailure('Please login first'));
      }
      
      // ... rest of logic
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

## API Reference

### `navigateTo(String routeName, {Object? arguments})`

Navigate to a named route.

- **Parameters:**
  - `routeName` (String): The name of the route to navigate to
  - `arguments` (Object?, optional): Arguments to pass to the route
- **Returns:** Future<dynamic> - Completes with the result when route is popped

### `navigateAndReplace(String routeName, {Object? arguments})`

Navigate to a route and replace the current route in the stack.

- **Parameters:**
  - `routeName` (String): The name of the route to navigate to
  - `arguments` (Object?, optional): Arguments to pass to the route
- **Returns:** Future<dynamic> - Completes with the result when new route is popped

### `navigateAndRemoveUntil(String routeName, {Object? arguments})`

Navigate to a route and remove all previous routes from the stack.

- **Parameters:**
  - `routeName` (String): The name of the route to navigate to
  - `arguments` (Object?, optional): Arguments to pass to the route
- **Returns:** Future<dynamic> - Completes with the result when new route is popped

### `goBack()`

Pop the current route off the navigation stack. Checks if navigation can pop before attempting.

- **Parameters:** None
- **Returns:** void

### `goBackWithResult<T>([T? result])`

Pop the current route and return a result value to the previous route.

- **Parameters:**
  - `result` (T?, optional): The result value to pass back
- **Returns:** void

## Benefits

1. **Testability**: Easy to mock in unit tests
2. **Separation of Concerns**: Navigation logic separated from UI
3. **Flexibility**: Navigate from anywhere (Cubits, Services, Repositories)
4. **Type Safety**: Named routes with optional arguments
5. **Safety Checks**: Built-in canPop() checks to prevent errors

## Requirements Mapping

This implementation satisfies the following requirements:

- **Requirement 1.4**: Use GetIt for dependency injection
- **Requirement 2.5**: Navigation Service implementation
- All navigation methods specified in the design document

## Notes

- Always register the NavigatorKey in GetIt before registering NavigationService
- The navigatorKey must be set in MaterialApp for the service to work
- Use named routes consistently throughout the application
- The service includes safety checks (canPop) to prevent navigation errors
