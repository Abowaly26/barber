# Requirements Document

## Introduction

This document specifies requirements for a complete Flutter authentication and role-based navigation system integrated with Firebase Authentication and Cloud Firestore. The system provides user registration, login with email/password and Google Sign-In, role selection (Customer or Barber), and distinct navigation experiences based on user roles. The design follows a specific visual language with defined colors, typography, and component styles.

## Glossary

- **Auth_System**: The authentication subsystem handling user registration, login, logout, and session management
- **Role_Manager**: The subsystem managing user role assignment, persistence, and switching
- **UI_Router**: The navigation subsystem that directs users to appropriate screens based on authentication and role state
- **Firestore_Service**: The Cloud Firestore integration service for user data persistence
- **Input_Validator**: The validation subsystem for email format and password requirements
- **Google_Auth_Provider**: The Google Sign-In integration service
- **Customer**: A user role representing individuals looking for barber services
- **Barber**: A user role representing service providers offering haircut services
- **Theme_System**: The visual design system defining colors, typography, and component styles
- **State_Provider**: The state management system (Riverpod or Provider) managing authentication and user state
- **Session**: An authenticated user's active connection maintained by Firebase Auth

## Requirements

### Requirement 1: User Registration with Email and Password

**User Story:** As a new user, I want to register with my email and password, so that I can create an account and access the application.

#### Acceptance Criteria

1. WHEN the RegisterScreen is displayed, THE Auth_System SHALL render email input field, password input field, and confirm password input field
2. WHEN a user enters text in the password field, THE Auth_System SHALL display a toggle icon to show or hide the password
3. WHEN a user enters text in the confirm password field, THE Auth_System SHALL display a toggle icon to show or hide the confirm password
4. WHEN the email field loses focus, THE Input_Validator SHALL validate the email format against standard email pattern (contains @ and valid domain)
5. WHEN the password field loses focus, THE Input_Validator SHALL validate the password has minimum 6 characters
6. WHEN the confirm password field loses focus, THE Input_Validator SHALL validate the confirm password matches the password field
7. IF email format is invalid, THEN THE Auth_System SHALL display an error message below the email field
8. IF password is less than 6 characters, THEN THE Auth_System SHALL display an error message below the password field
9. IF confirm password does not match password, THEN THE Auth_System SHALL display an error message below the confirm password field
10. WHEN all fields are valid AND the Sign Up button is tapped, THE Auth_System SHALL display a loading indicator inside the button
11. WHEN registration is in progress, THE Auth_System SHALL disable the Sign Up button to prevent duplicate submissions
12. WHEN Firebase Auth successfully creates the user, THE Auth_System SHALL create a Firestore document at users/{uid} with fields: email, createdAt
13. WHEN Firebase Auth successfully creates the user, THE UI_Router SHALL navigate to the RoleSelectionScreen
14. IF Firebase Auth returns an error during registration, THEN THE Auth_System SHALL display the error message in a SnackBar
15. IF network error occurs during registration, THEN THE Auth_System SHALL display a network error message in a SnackBar

### Requirement 2: User Registration with Google Sign-In

**User Story:** As a new user, I want to register using my Google account, so that I can quickly create an account without entering credentials manually.

#### Acceptance Criteria

1. WHEN the RegisterScreen is displayed, THE Auth_System SHALL render a "Sign up with Google" button with Google "G" icon
2. WHEN the "Sign up with Google" button is tapped, THE Google_Auth_Provider SHALL initiate the Google Sign-In flow
3. WHEN Google Sign-In is in progress, THE Auth_System SHALL display a loading indicator
4. WHEN Google Sign-In completes successfully, THE Auth_System SHALL authenticate the user with Firebase Auth using the Google credential
5. WHEN a new Google user authenticates successfully, THE Auth_System SHALL create a Firestore document at users/{uid} with fields: email, createdAt
6. WHEN a new Google user authenticates successfully, THE UI_Router SHALL navigate to the RoleSelectionScreen
7. WHEN an existing Google user authenticates successfully, THE Firestore_Service SHALL fetch the user document from users/{uid}
8. WHEN an existing Google user has a role field in Firestore, THE UI_Router SHALL navigate to the HomeScreen
9. WHEN an existing Google user does not have a role field in Firestore, THE UI_Router SHALL navigate to the RoleSelectionScreen
10. IF Google Sign-In is cancelled by the user, THEN THE Auth_System SHALL remain on the RegisterScreen without displaying an error
11. IF Google Sign-In returns an error, THEN THE Auth_System SHALL display the error message in a SnackBar

### Requirement 3: User Login with Email and Password

**User Story:** As a registered user, I want to login with my email and password, so that I can access my account and use the application.

#### Acceptance Criteria

1. WHEN the LoginScreen is displayed, THE Auth_System SHALL render email input field and password input field
2. WHEN a user enters text in the password field, THE Auth_System SHALL display a toggle icon to show or hide the password
3. WHEN both email and password fields are empty, THE Auth_System SHALL display the Sign In button in disabled state with grey color (#B0BEC5)
4. WHEN both email and password fields contain text, THE Auth_System SHALL display the Sign In button in enabled state with teal color (#4A7C74)
5. WHEN the Sign In button is tapped with valid inputs, THE Auth_System SHALL display a loading indicator inside the button
6. WHEN login is in progress, THE Auth_System SHALL disable the Sign In button to prevent duplicate submissions
7. WHEN Firebase Auth successfully authenticates the user, THE Firestore_Service SHALL fetch the user document from users/{uid}
8. WHEN the user document contains a role field, THE UI_Router SHALL navigate to the HomeScreen
9. WHEN the user document does not contain a role field, THE UI_Router SHALL navigate to the RoleSelectionScreen
10. IF Firebase Auth returns an authentication error, THEN THE Auth_System SHALL display the error message in a SnackBar
11. IF network error occurs during login, THEN THE Auth_System SHALL display a network error message in a SnackBar

### Requirement 4: User Login with Google Sign-In

**User Story:** As a registered user, I want to login using my Google account, so that I can quickly access my account without entering credentials manually.

#### Acceptance Criteria

1. WHEN the LoginScreen is displayed, THE Auth_System SHALL render a "Sign in with Google" button with Google "G" icon
2. WHEN the "Sign in with Google" button is tapped, THE Google_Auth_Provider SHALL initiate the Google Sign-In flow
3. WHEN Google Sign-In is in progress, THE Auth_System SHALL display a loading indicator
4. WHEN Google Sign-In completes successfully, THE Auth_System SHALL authenticate the user with Firebase Auth using the Google credential
5. WHEN authentication succeeds, THE Firestore_Service SHALL fetch the user document from users/{uid}
6. WHEN the user document exists and contains a role field, THE UI_Router SHALL navigate to the HomeScreen
7. WHEN the user document exists but does not contain a role field, THE UI_Router SHALL navigate to the RoleSelectionScreen
8. WHEN the user document does not exist, THE Auth_System SHALL create a Firestore document at users/{uid} with fields: email, createdAt, THEN THE UI_Router SHALL navigate to the RoleSelectionScreen
9. IF Google Sign-In is cancelled by the user, THEN THE Auth_System SHALL remain on the LoginScreen without displaying an error
10. IF Google Sign-In returns an error, THEN THE Auth_System SHALL display the error message in a SnackBar

### Requirement 5: Password Reset Flow

**User Story:** As a user who forgot my password, I want to request a password reset, so that I can regain access to my account.

#### Acceptance Criteria

1. WHEN the LoginScreen is displayed, THE Auth_System SHALL render a "Forgot Password?" link aligned to the right in teal color (#4A7C74)
2. WHEN the "Forgot Password?" link is tapped, THE UI_Router SHALL navigate to a password reset screen or show a password reset dialog
3. WHEN the password reset screen is displayed, THE Auth_System SHALL render an email input field and a submit button
4. WHEN the submit button is tapped with a valid email, THE Auth_System SHALL call Firebase Auth sendPasswordResetEmail with the provided email
5. WHEN the password reset email is sent successfully, THE Auth_System SHALL display a success message in a SnackBar
6. IF Firebase Auth returns an error during password reset, THEN THE Auth_System SHALL display the error message in a SnackBar

### Requirement 6: Role Selection After Registration

**User Story:** As a newly registered user, I want to select my role (Customer or Barber), so that I can access features appropriate to my needs.

#### Acceptance Criteria

1. WHEN the RoleSelectionScreen is displayed, THE Role_Manager SHALL render two selectable cards labeled "Customer" and "Barber"
2. WHEN the Customer card is displayed, THE Role_Manager SHALL show an icon representing a customer and text "I'm looking for a barber"
3. WHEN the Barber card is displayed, THE Role_Manager SHALL show an icon representing a barber and text "I offer haircut services"
4. WHEN no card is selected, THE Role_Manager SHALL display both cards with grey borders
5. WHEN no card is selected, THE Role_Manager SHALL display the Continue button in disabled state
6. WHEN a user taps the Customer card, THE Role_Manager SHALL display the Customer card with teal border (#4A7C74) and teal icon
7. WHEN a user taps the Barber card, THE Role_Manager SHALL display the Barber card with teal border (#4A7C74) and teal icon
8. WHEN a card is selected, THE Role_Manager SHALL enable the Continue button with teal color (#4A7C74)
9. WHEN the Continue button is tapped with Customer selected, THE Firestore_Service SHALL update users/{uid} with role field set to "customer"
10. WHEN the Continue button is tapped with Barber selected, THE Firestore_Service SHALL update users/{uid} with role field set to "barber"
11. WHEN the Firestore update completes successfully, THE State_Provider SHALL cache the role value in SharedPreferences
12. WHEN the Firestore update completes successfully, THE UI_Router SHALL navigate to the HomeScreen
13. IF Firestore returns an error during role update, THEN THE Role_Manager SHALL display the error message in a SnackBar

### Requirement 7: Role-Based Home Screen Navigation

**User Story:** As a logged-in user with a role, I want to see a home screen tailored to my role, so that I can access features relevant to me.

#### Acceptance Criteria

1. WHEN a user with role "customer" navigates to the HomeScreen, THE UI_Router SHALL display the CustomerHomeScreen
2. WHEN a user with role "barber" navigates to the HomeScreen, THE UI_Router SHALL display the BarberHomeScreen
3. WHEN the CustomerHomeScreen is displayed, THE UI_Router SHALL render a BottomNavigationBar with items: Home, Search, Bookings, Profile
4. WHEN the BarberHomeScreen is displayed, THE UI_Router SHALL render a BottomNavigationBar with items: Home, Schedule, Clients, Profile
5. WHEN the CustomerHomeScreen is displayed, THE CustomerHomeScreen SHALL display nearby barbers list, search bar, and promotions section
6. WHEN the BarberHomeScreen is displayed, THE BarberHomeScreen SHALL display today's appointments, earnings summary, and status toggle (Available/Busy)

### Requirement 8: Role Switching Functionality

**User Story:** As a logged-in user, I want to switch between Customer and Barber roles, so that I can access different features without logging out.

#### Acceptance Criteria

1. WHEN the HomeScreen is displayed, THE Role_Manager SHALL render a role toggle switch in the AppBar
2. WHEN the toggle switch is displayed with role "customer", THE Role_Manager SHALL show "Customer" as the current selection
3. WHEN the toggle switch is displayed with role "barber", THE Role_Manager SHALL show "Barber" as the current selection
4. WHEN a user taps the toggle switch to change from "customer" to "barber", THE Firestore_Service SHALL update users/{uid} with role field set to "barber"
5. WHEN a user taps the toggle switch to change from "barber" to "customer", THE Firestore_Service SHALL update users/{uid} with role field set to "customer"
6. WHEN the Firestore update completes successfully, THE State_Provider SHALL update the cached role in SharedPreferences
7. WHEN the Firestore update completes successfully, THE State_Provider SHALL notify listeners to re-render the HomeScreen
8. WHEN the State_Provider notifies listeners, THE UI_Router SHALL display the appropriate home screen variant based on the new role
9. IF Firestore returns an error during role switch, THEN THE Role_Manager SHALL display the error message in a SnackBar and revert the toggle to the previous state

### Requirement 9: Authentication State Management

**User Story:** As a user, I want the app to remember my login state, so that I don't have to login every time I open the app.

#### Acceptance Criteria

1. WHEN the app launches, THE State_Provider SHALL listen to Firebase Auth authStateChanges stream
2. WHEN authStateChanges emits a null user, THE UI_Router SHALL redirect to the LoginScreen
3. WHEN authStateChanges emits a non-null user, THE Firestore_Service SHALL fetch the user document from users/{uid}
4. WHEN the user document contains a role field, THE UI_Router SHALL redirect to the HomeScreen
5. WHEN the user document does not contain a role field, THE UI_Router SHALL redirect to the RoleSelectionScreen
6. WHEN the user document does not exist, THE Auth_System SHALL create a Firestore document at users/{uid} with fields: email, createdAt, THEN THE UI_Router SHALL redirect to the RoleSelectionScreen
7. WHEN role data is fetched from Firestore, THE State_Provider SHALL cache the role value in SharedPreferences
8. WHEN the app launches and SharedPreferences contains a cached role, THE State_Provider SHALL use the cached value until Firestore fetch completes
9. WHEN the user successfully logs out, THE Auth_System SHALL call Firebase Auth signOut
10. WHEN Firebase Auth signOut completes, THE State_Provider SHALL clear the cached role from SharedPreferences
11. WHEN Firebase Auth signOut completes, THE UI_Router SHALL redirect to the LoginScreen

### Requirement 10: Visual Design System Implementation

**User Story:** As a user, I want the app to have a consistent and visually appealing design, so that I can have a pleasant user experience.

#### Acceptance Criteria

1. THE Theme_System SHALL define a background color constant with value #F0F2F5
2. THE Theme_System SHALL define a primary color constant with value #4A7C74
3. THE Theme_System SHALL define a disabled button color constant with value #B0BEC5
4. THE Theme_System SHALL define a text primary color constant with value #1C2B3A
5. THE Theme_System SHALL define a text secondary color constant with value #78909C
6. WHEN input fields are rendered, THE Theme_System SHALL apply white background color, border radius of 12 pixels, and subtle border
7. WHEN buttons are rendered, THE Theme_System SHALL apply full width, border radius of 12 pixels, and height of 56 pixels
8. WHEN the LoginScreen title is rendered, THE Theme_System SHALL display "Welcome Back!" in bold, 28 pixels size, dark navy color
9. WHEN the RegisterScreen title is rendered, THE Theme_System SHALL display "Register" in bold, 28 pixels size, dark navy color
10. WHEN the RoleSelectionScreen title is rendered, THE Theme_System SHALL display "Who are you?" in bold, 28 pixels size, dark navy color
11. THE Theme_System SHALL use system default font or Google Fonts Inter family for all text

### Requirement 11: Screen Navigation Flow

**User Story:** As a user, I want to navigate between different screens seamlessly, so that I can complete authentication and access features easily.

#### Acceptance Criteria

1. WHEN the LoginScreen is displayed AND the user taps "Register" link, THE UI_Router SHALL navigate to the RegisterScreen
2. WHEN the RegisterScreen is displayed AND the user taps "Login" link, THE UI_Router SHALL navigate to the LoginScreen
3. WHEN the RoleSelectionScreen is displayed AND the user completes role selection, THE UI_Router SHALL navigate to the HomeScreen
4. WHEN the user is not authenticated, THE UI_Router SHALL prevent navigation to RoleSelectionScreen and HomeScreen
5. WHEN the user is authenticated but has no role, THE UI_Router SHALL prevent navigation to HomeScreen
6. WHEN the user is authenticated with a role, THE UI_Router SHALL allow navigation to HomeScreen
7. WHEN the user navigates using browser back button or system back gesture on RoleSelectionScreen, THE UI_Router SHALL sign out the user and navigate to LoginScreen
8. WHEN the user navigates using browser back button or system back gesture on HomeScreen, THE UI_Router SHALL prevent navigation and remain on HomeScreen

### Requirement 12: Internationalization Support

**User Story:** As an Arabic-speaking user, I want to use the app in Arabic with proper right-to-left layout, so that I can understand and use the app comfortably.

#### Acceptance Criteria

1. THE Auth_System SHALL integrate the intl package for internationalization support
2. WHEN the user's device locale is set to Arabic, THE Theme_System SHALL render all screens with right-to-left (RTL) text direction
3. WHEN the user's device locale is set to Arabic, THE Theme_System SHALL mirror layout components (icons, navigation) to support RTL
4. THE Auth_System SHALL provide Arabic translations for all static text strings in authentication screens
5. THE Auth_System SHALL provide Arabic translations for all error messages and validation messages

### Requirement 13: Error Handling and User Feedback

**User Story:** As a user, I want to receive clear feedback when errors occur, so that I understand what went wrong and how to fix it.

#### Acceptance Criteria

1. WHEN Firebase Auth returns error code "user-not-found", THE Auth_System SHALL display message "No user found with this email" in a SnackBar
2. WHEN Firebase Auth returns error code "wrong-password", THE Auth_System SHALL display message "Incorrect password" in a SnackBar
3. WHEN Firebase Auth returns error code "email-already-in-use", THE Auth_System SHALL display message "Email is already registered" in a SnackBar
4. WHEN Firebase Auth returns error code "weak-password", THE Auth_System SHALL display message "Password is too weak" in a SnackBar
5. WHEN Firebase Auth returns error code "invalid-email", THE Auth_System SHALL display message "Invalid email format" in a SnackBar
6. WHEN Firebase Auth returns error code "network-request-failed", THE Auth_System SHALL display message "Network error. Please check your connection" in a SnackBar
7. WHEN Firestore operation fails, THE Auth_System SHALL display message "Failed to save data. Please try again" in a SnackBar
8. WHEN any async operation is in progress, THE Auth_System SHALL display a CircularProgressIndicator to indicate loading state
9. WHEN a SnackBar is displayed, THE Auth_System SHALL automatically dismiss it after 4 seconds

### Requirement 14: Data Persistence Layer

**User Story:** As a developer, I want user data persisted reliably in Firestore, so that user information is available across sessions and devices.

#### Acceptance Criteria

1. WHEN a new user registers, THE Firestore_Service SHALL create a document at collection "users" with document ID equal to Firebase Auth UID
2. THE Firestore_Service SHALL store email field as a string in the user document
3. THE Firestore_Service SHALL store role field as a string with allowed values "customer" or "barber" in the user document
4. THE Firestore_Service SHALL store createdAt field as a Firestore Timestamp in the user document
5. WHEN a user's role is updated, THE Firestore_Service SHALL update only the role field without modifying other fields
6. WHEN fetching user data, THE Firestore_Service SHALL read from collection "users" using the Firebase Auth UID as document ID
7. IF the user document does not exist during fetch, THEN THE Firestore_Service SHALL return a null or error result
8. THE Firestore_Service SHALL implement error handling for all Firestore operations (create, read, update)

### Requirement 15: Local Caching with SharedPreferences

**User Story:** As a user, I want the app to load quickly using cached data, so that I don't have to wait for network requests every time.

#### Acceptance Criteria

1. WHEN user role is fetched from Firestore, THE State_Provider SHALL store the role value in SharedPreferences with key "user_role"
2. WHEN user UID is available, THE State_Provider SHALL store the UID value in SharedPreferences with key "user_uid"
3. WHEN the app launches, THE State_Provider SHALL read the cached role from SharedPreferences before Firestore fetch completes
4. WHEN the Firestore fetch completes, THE State_Provider SHALL update the cached role in SharedPreferences if the value differs
5. WHEN the user logs out, THE State_Provider SHALL remove "user_role" and "user_uid" from SharedPreferences
6. WHEN Firestore is unavailable or offline, THE State_Provider SHALL use the cached role from SharedPreferences for navigation
7. IF SharedPreferences read operation fails, THEN THE State_Provider SHALL treat the cache as empty and proceed with Firestore fetch
