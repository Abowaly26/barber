# Requirements Document - Barber Booking App

## Introduction

تطبيق حجز حلاقة متكامل يربط بين العملاء ومقدمي خدمات الحلاقة والتجميل. يوفر التطبيق منصة سهلة الاستخدام لحجز المواعيد، تصفح الخدمات، والحصول على استشارات تجميلية باستخدام الذكاء الاصطناعي. التطبيق مبني باستخدام Clean Architecture مع Flutter للواجهة الأمامية وFirebase وSupabase للخلفية.

## Glossary

- **System**: تطبيق Barber Booking App
- **User**: العميل الذي يستخدم التطبيق لحجز المواعيد
- **Provider**: مقدم الخدمة (صاحب صالون أو حلاق)
- **Service_Category**: فئة الخدمة (رجال، نساء، أطفال)
- **Booking**: الحجز أو الموعد
- **AI_Advisor**: مستشار الذكاء الاصطناعي للتسريحات
- **Store**: متجر منتجات العناية
- **Firebase_Service**: خدمة Firebase للمصادقة والبيانات
- **Supabase_Service**: خدمة Supabase للتخزين والبيانات
- **Splash_Screen**: شاشة البداية مع اللوجو
- **Category_Selection_Screen**: شاشة اختيار الفئة (الشاشة الرئيسية)
- **Repository**: نمط Repository للوصول للبيانات
- **Cubit**: مدير الحالة باستخدام Cubit/Bloc
- **GetIt**: أداة Dependency Injection
- **Navigation_Service**: خدمة التنقل بين الشاشات

## Requirements

### Requirement 1: Application Architecture

**User Story:** كمطور، أريد بناء التطبيق باستخدام Clean Architecture، حتى يكون الكود منظماً وسهل الصيانة

#### Acceptance Criteria

1. THE System SHALL organize code using Feature-First structure with core and features directories
2. THE System SHALL implement Repository Pattern for all data access operations
3. THE System SHALL use Cubit/Bloc for state management across all features
4. THE System SHALL use GetIt for dependency injection
5. THE System SHALL separate code into data, domain, and presentation layers for each feature
6. THE System SHALL place shared entities in core/entities directory
7. THE System SHALL place shared models in core/models directory
8. THE System SHALL place shared repositories in core/repos directory
9. THE System SHALL place shared services in core/services directory
10. THE System SHALL place shared utilities in core/utils directory
11. THE System SHALL place shared widgets in core/widgets directory

### Requirement 2: Backend Integration

**User Story:** كمطور، أريد دمج Firebase وSupabase في التطبيق، حتى أتمكن من إدارة المستخدمين والبيانات

#### Acceptance Criteria

1. THE Firebase_Service SHALL provide authentication functionality
2. THE Firebase_Service SHALL provide real-time database operations
3. THE Firebase_Service SHALL provide cloud storage for images
4. THE Supabase_Service SHALL provide additional storage capabilities
5. THE Supabase_Service SHALL provide database operations
6. THE System SHALL initialize Firebase in main.dart before app starts
7. THE System SHALL initialize Supabase in main.dart before app starts
8. WHEN initialization fails, THEN THE System SHALL display error message and retry option

### Requirement 3: Splash Screen

**User Story:** كمستخدم، أريد رؤية شاشة بداية جذابة عند فتح التطبيق، حتى أعرف أن التطبيق يعمل

#### Acceptance Criteria

1. THE Splash_Screen SHALL display the app logo centered on screen
2. THE Splash_Screen SHALL show for minimum 2 seconds
3. THE Splash_Screen SHALL show for maximum 5 seconds
4. WHEN app initialization completes, THEN THE Splash_Screen SHALL navigate to Category_Selection_Screen
5. WHILE app is initializing, THE Splash_Screen SHALL display loading indicator
6. THE Splash_Screen SHALL use the same background color as app theme

### Requirement 4: Category Selection Screen

**User Story:** كمستخدم، أريد اختيار فئة الخدمة المناسبة، حتى أتمكن من الوصول للخدمات التي أحتاجها

#### Acceptance Criteria

1. THE Category_Selection_Screen SHALL display six category options
2. THE Category_Selection_Screen SHALL display "Men - Barbershops & Grooming" option with barber icon
3. THE Category_Selection_Screen SHALL display "Women - Salons & Beauty" option with comb icon
4. THE Category_Selection_Screen SHALL display "Kids - Fun & Friendly Cuts" option with child icon
5. THE Category_Selection_Screen SHALL display "QUTI Store - Shop grooming products" option with bag icon
6. THE Category_Selection_Screen SHALL display "Join as Provider - Barbers & shop owners" option with scissors icon
7. THE Category_Selection_Screen SHALL display "AI Hair Advisor - Find your perfect style" option with star icon
8. WHEN User taps on category option, THEN THE System SHALL navigate to corresponding feature screen
9. THE Category_Selection_Screen SHALL use card-based layout for options
10. THE Category_Selection_Screen SHALL display icons with consistent size of 48x48 pixels
11. THE Category_Selection_Screen SHALL use app theme colors for styling

### Requirement 5: Men's Service Feature

**User Story:** كمستخدم رجل، أريد تصفح صالونات الحلاقة والحجز، حتى أحصل على خدمات العناية

#### Acceptance Criteria

1. WHEN User selects "Men" category, THEN THE System SHALL navigate to men's services screen
2. THE System SHALL display list of available barbershops
3. THE System SHALL display barbershop name, rating, and distance for each item
4. WHEN User taps on barbershop, THEN THE System SHALL navigate to barbershop details screen
5. THE System SHALL allow User to filter barbershops by rating, distance, and price
6. THE System SHALL allow User to search barbershops by name
7. THE System SHALL use Repository Pattern to fetch barbershop data
8. THE System SHALL use Cubit to manage barbershops state

### Requirement 6: Women's Service Feature

**User Story:** كمستخدمة، أريد تصفح صالونات التجميل والحجز، حتى أحصل على خدمات العناية والتجميل

#### Acceptance Criteria

1. WHEN User selects "Women" category, THEN THE System SHALL navigate to women's services screen
2. THE System SHALL display list of available beauty salons
3. THE System SHALL display salon name, rating, distance, and services for each item
4. WHEN User taps on salon, THEN THE System SHALL navigate to salon details screen
5. THE System SHALL allow User to filter salons by rating, distance, price, and service type
6. THE System SHALL allow User to search salons by name
7. THE System SHALL use Repository Pattern to fetch salon data
8. THE System SHALL use Cubit to manage salons state

### Requirement 7: Kids' Service Feature

**User Story:** كولي أمر، أريد حجز موعد حلاقة لطفلي، حتى يحصل على قصة شعر مناسبة

#### Acceptance Criteria

1. WHEN User selects "Kids" category, THEN THE System SHALL navigate to kids' services screen
2. THE System SHALL display list of kid-friendly barbershops
3. THE System SHALL display shop name, rating, kid-friendly badge for each item
4. WHEN User taps on shop, THEN THE System SHALL navigate to shop details screen
5. THE System SHALL highlight shops with kid-friendly features
6. THE System SHALL use Repository Pattern to fetch kids' shop data
7. THE System SHALL use Cubit to manage kids' shops state

### Requirement 8: QUTI Store Feature

**User Story:** كمستخدم، أريد شراء منتجات العناية، حتى أحافظ على مظهري

#### Acceptance Criteria

1. WHEN User selects "QUTI Store" category, THEN THE System SHALL navigate to store screen
2. THE System SHALL display list of grooming products
3. THE System SHALL display product image, name, price, and rating for each item
4. WHEN User taps on product, THEN THE System SHALL navigate to product details screen
5. THE System SHALL allow User to add products to cart
6. THE System SHALL allow User to filter products by category and price range
7. THE System SHALL allow User to search products by name
8. THE System SHALL use Repository Pattern to fetch product data
9. THE System SHALL use Cubit to manage products and cart state

### Requirement 9: Provider Registration Feature

**User Story:** كمقدم خدمة، أريد التسجيل في المنصة، حتى أتمكن من تقديم خدماتي للعملاء

#### Acceptance Criteria

1. WHEN Provider selects "Join as Provider" category, THEN THE System SHALL navigate to provider registration screen
2. THE System SHALL collect provider name, business name, phone number, and email
3. THE System SHALL collect business license number
4. THE System SHALL collect business address with map location picker
5. THE System SHALL allow Provider to upload business license image
6. THE System SHALL allow Provider to upload shop images
7. WHEN Provider submits registration, THEN THE System SHALL validate all required fields
8. WHEN validation passes, THEN THE System SHALL send registration for admin approval
9. THE System SHALL use Firebase_Service to store provider data
10. THE System SHALL use Supabase_Service to store uploaded images

### Requirement 10: AI Hair Advisor Feature

**User Story:** كمستخدم، أريد الحصول على اقتراحات لتسريحة شعر مناسبة، حتى أختار أفضل مظهر لي

#### Acceptance Criteria

1. WHEN User selects "AI Hair Advisor" category, THEN THE System SHALL navigate to AI advisor screen
2. THE System SHALL allow User to upload face photo
3. THE System SHALL allow User to select face shape from predefined options
4. THE System SHALL allow User to select hair type from predefined options
5. WHEN User submits information, THEN THE AI_Advisor SHALL analyze face features
6. THE AI_Advisor SHALL suggest suitable hairstyles based on face shape and hair type
7. THE AI_Advisor SHALL display suggested hairstyles with images
8. THE System SHALL allow User to save favorite suggestions
9. THE System SHALL use Supabase_Service to process AI requests

### Requirement 11: Booking Management

**User Story:** كمستخدم، أريد حجز موعد في الصالون، حتى أضمن الحصول على الخدمة في الوقت المناسب

#### Acceptance Criteria

1. WHEN User selects shop, THEN THE System SHALL display available time slots
2. THE System SHALL display available services with prices
3. THE System SHALL allow User to select date from calendar
4. THE System SHALL allow User to select time slot
5. THE System SHALL allow User to select one or more services
6. WHEN User confirms booking, THEN THE System SHALL validate slot availability
7. WHEN slot is available, THEN THE System SHALL create booking in Firebase_Service
8. WHEN booking is created, THEN THE System SHALL send confirmation notification to User
9. THE System SHALL allow User to view booking history
10. THE System SHALL allow User to cancel booking at least 2 hours before appointment
11. THE System SHALL use Repository Pattern to manage booking operations
12. THE System SHALL use Cubit to manage booking state

### Requirement 12: User Authentication

**User Story:** كمستخدم، أريد إنشاء حساب والدخول للتطبيق، حتى أتمكن من حجز المواعيد وتتبع طلباتي

#### Acceptance Criteria

1. THE System SHALL provide phone number authentication via Firebase_Service
2. THE System SHALL provide email/password authentication via Firebase_Service
3. THE System SHALL provide Google Sign-In option
4. WHEN User enters phone number, THEN THE System SHALL send OTP code
5. WHEN User enters valid OTP, THEN THE System SHALL authenticate User
6. THE System SHALL store user profile data in Firebase_Service
7. THE System SHALL navigate authenticated User to Category_Selection_Screen
8. THE System SHALL allow User to logout
9. THE System SHALL use Repository Pattern for authentication operations

### Requirement 13: User Profile Management

**User Story:** كمستخدم، أريد إدارة معلومات حسابي، حتى أحافظ على بياناتي محدثة

#### Acceptance Criteria

1. THE System SHALL display user profile screen with name, email, phone, and photo
2. THE System SHALL allow User to update name
3. THE System SHALL allow User to update email
4. THE System SHALL allow User to upload profile photo
5. WHEN User updates profile, THEN THE System SHALL validate input fields
6. WHEN validation passes, THEN THE System SHALL update profile in Firebase_Service
7. THE System SHALL use Supabase_Service to store profile photo
8. THE System SHALL use Repository Pattern for profile operations
9. THE System SHALL use Cubit to manage profile state

### Requirement 14: Favorites Management

**User Story:** كمستخدم، أريد حفظ الصالونات المفضلة، حتى أتمكن من الوصول إليها بسرعة

#### Acceptance Criteria

1. THE System SHALL allow User to add shop to favorites list
2. THE System SHALL allow User to remove shop from favorites list
3. THE System SHALL display favorites list in profile section
4. WHEN User taps on favorite item, THEN THE System SHALL navigate to shop details
5. THE System SHALL store favorites in Firebase_Service linked to user account
6. THE System SHALL sync favorites across user devices
7. THE System SHALL use Repository Pattern for favorites operations
8. THE System SHALL use Cubit to manage favorites state

### Requirement 15: Search Functionality

**User Story:** كمستخدم، أريد البحث عن صالونات أو خدمات محددة، حتى أجد ما أحتاجه بسرعة

#### Acceptance Criteria

1. THE System SHALL provide search bar on main category screens
2. WHEN User types search query, THEN THE System SHALL filter results in real-time
3. THE System SHALL search by shop name, service name, and location
4. THE System SHALL display search results sorted by relevance
5. THE System SHALL highlight matching text in search results
6. THE System SHALL show "No results found" message when search yields no results
7. THE System SHALL use Repository Pattern to perform search operations

### Requirement 16: Location Services

**User Story:** كمستخدم، أريد رؤية الصالونات القريبة مني، حتى أختار الأقرب والأكثر ملاءمة

#### Acceptance Criteria

1. WHEN app launches, THEN THE System SHALL request location permission
2. WHEN permission granted, THEN THE System SHALL get user current location
3. THE System SHALL calculate distance between User and each shop
4. THE System SHALL display distance in kilometers for each shop
5. THE System SHALL allow User to filter shops by distance radius
6. THE System SHALL allow User to view shops on map
7. THE System SHALL use Google Maps integration for map display

### Requirement 17: Notifications System

**User Story:** كمستخدم، أريد تلقي إشعارات عن حجوزاتي، حتى أتذكر مواعيدي

#### Acceptance Criteria

1. THE System SHALL request notification permission on first launch
2. THE System SHALL send booking confirmation notification
3. THE System SHALL send reminder notification 1 hour before appointment
4. THE System SHALL send notification when booking is cancelled
5. THE System SHALL send notification for special offers when User has enabled offers notifications
6. THE System SHALL use Firebase Cloud Messaging for push notifications
7. WHEN User taps notification, THEN THE System SHALL navigate to relevant screen

### Requirement 18: Multi-language Support

**User Story:** كمستخدم، أريد استخدام التطبيق بلغتي المفضلة، حتى أفهم المحتوى بسهولة

#### Acceptance Criteria

1. THE System SHALL support Arabic language
2. THE System SHALL support English language
3. THE System SHALL detect device language on first launch
4. THE System SHALL allow User to change language from settings
5. WHEN User changes language, THEN THE System SHALL update all UI text immediately
6. THE System SHALL use RTL layout for Arabic
7. THE System SHALL use LTR layout for English
8. THE System SHALL store language preference in local storage

### Requirement 19: Offline Support

**User Story:** كمستخدم، أريد تصفح بعض المحتوى بدون إنترنت، حتى أتمكن من الاستخدام في أي وقت

#### Acceptance Criteria

1. THE System SHALL cache recently viewed shops data locally
2. THE System SHALL cache user booking history locally
3. THE System SHALL cache user favorites locally
4. WHEN network is unavailable, THEN THE System SHALL display cached data
5. WHEN network is unavailable, THEN THE System SHALL display "Offline" indicator
6. WHEN network becomes available, THEN THE System SHALL sync local changes with server
7. THE System SHALL show error message when attempting offline-only operations without network

### Requirement 20: Rating and Review System

**User Story:** كمستخدم، أريد تقييم الصالون بعد الزيارة، حتى أساعد الآخرين في اختيار أفضل الخدمات

#### Acceptance Criteria

1. WHEN booking is completed, THEN THE System SHALL prompt User to rate and review
2. THE System SHALL allow User to give rating from 1 to 5 stars
3. THE System SHALL allow User to write text review with minimum 10 characters
4. THE System SHALL allow User to upload photos with review
5. WHEN User submits review, THEN THE System SHALL validate rating and review text
6. WHEN validation passes, THEN THE System SHALL save review to Firebase_Service
7. THE System SHALL display shop average rating calculated from all reviews
8. THE System SHALL display recent reviews on shop details screen
9. THE System SHALL use Repository Pattern for review operations

### Requirement 21: Payment Integration

**User Story:** كمستخدم، أريد دفع قيمة الحجز أو المنتجات بشكل آمن، حتى أكمل عملية الشراء

#### Acceptance Criteria

1. THE System SHALL integrate payment gateway for online payments
2. THE System SHALL support credit card payments
3. THE System SHALL support debit card payments
4. THE System SHALL support cash on arrival payment option
5. WHEN User selects payment method, THEN THE System SHALL validate payment details
6. WHEN payment succeeds, THEN THE System SHALL confirm booking or order
7. WHEN payment fails, THEN THE System SHALL display error message and retry option
8. THE System SHALL store payment transaction history in Firebase_Service
9. THE System SHALL use secure HTTPS connections for all payment operations

### Requirement 22: Shop Details Display

**User Story:** كمستخدم، أريد رؤية تفاصيل الصالون بشكل كامل، حتى أتخذ قرار مدروس بالحجز

#### Acceptance Criteria

1. THE System SHALL display shop photos in scrollable gallery
2. THE System SHALL display shop name, rating, and total reviews count
3. THE System SHALL display shop address with map preview
4. THE System SHALL display shop working hours
5. THE System SHALL display list of available services with prices
6. THE System SHALL display shop phone number with call button
7. THE System SHALL display shop amenities and features
8. THE System SHALL display recent customer reviews
9. WHEN User taps call button, THEN THE System SHALL initiate phone call
10. WHEN User taps map preview, THEN THE System SHALL open full map view

### Requirement 23: Cart Management

**User Story:** كمستخدم، أريد إضافة منتجات إلى السلة، حتى أشتري عدة منتجات في طلب واحد

#### Acceptance Criteria

1. THE System SHALL allow User to add products to cart from store
2. THE System SHALL display cart icon with item count badge
3. THE System SHALL allow User to increase or decrease product quantity in cart
4. THE System SHALL allow User to remove product from cart
5. THE System SHALL calculate and display subtotal for each product
6. THE System SHALL calculate and display total cart amount
7. THE System SHALL persist cart data locally when User closes app
8. THE System SHALL use Repository Pattern for cart operations
9. THE System SHALL use Cubit to manage cart state

### Requirement 24: Order Tracking

**User Story:** كمستخدم، أريد تتبع حالة طلبي من المتجر، حتى أعرف موعد وصوله

#### Acceptance Criteria

1. WHEN User places order, THEN THE System SHALL assign unique order number
2. THE System SHALL display order status as "Processing", "Out for Delivery", or "Delivered"
3. THE System SHALL send notification when order status changes
4. THE System SHALL allow User to view order history
5. WHEN User taps on order, THEN THE System SHALL display order details with items and total
6. THE System SHALL display estimated delivery time
7. THE System SHALL use Firebase_Service to track order status in real-time

### Requirement 25: Promo Codes

**User Story:** كمستخدم، أريد استخدام رمز ترويجي للحصول على خصم، حتى أوفر في المال

#### Acceptance Criteria

1. THE System SHALL provide promo code input field at checkout
2. WHEN User enters promo code, THEN THE System SHALL validate code with backend
3. WHEN code is valid, THEN THE System SHALL apply discount to total amount
4. WHEN code is invalid or expired, THEN THE System SHALL display error message
5. THE System SHALL display applied discount amount separately
6. THE System SHALL allow only one promo code per order
7. THE System SHALL store promo code usage in Firebase_Service to prevent reuse

### Requirement 26: Error Handling

**User Story:** كمطور، أريد معالجة الأخطاء بشكل مناسب، حتى يحصل المستخدم على تجربة سلسة

#### Acceptance Criteria

1. WHEN network error occurs, THEN THE System SHALL display user-friendly error message
2. WHEN server error occurs, THEN THE System SHALL display "Try again later" message
3. WHEN validation error occurs, THEN THE System SHALL highlight invalid field with error text
4. THE System SHALL log all errors to Firebase Crashlytics for debugging
5. THE System SHALL provide retry button for recoverable errors
6. THE System SHALL prevent app crash by catching unhandled exceptions
7. THE System SHALL use Either type from dartz package to handle operation results

### Requirement 27: Loading States

**User Story:** كمستخدم، أريد رؤية مؤشرات التحميل، حتى أعرف أن التطبيق يعمل

#### Acceptance Criteria

1. WHEN data is loading, THEN THE System SHALL display shimmer loading placeholder
2. THE System SHALL use shimmer effect that matches content layout
3. WHEN operation is processing, THEN THE System SHALL display loading overlay with indicator
4. THE System SHALL disable user interaction during critical operations
5. WHEN loading takes longer than 10 seconds, THEN THE System SHALL show "Taking longer than usual" message
6. THE System SHALL use consistent loading indicators across all screens

### Requirement 28: Image Handling

**User Story:** كمطور، أريد معالجة الصور بكفاءة، حتى يعمل التطبيق بسلاسة

#### Acceptance Criteria

1. THE System SHALL compress images before uploading to reduce size
2. THE System SHALL cache downloaded images to improve performance
3. THE System SHALL display placeholder image while loading
4. WHEN image fails to load, THEN THE System SHALL display error placeholder
5. THE System SHALL use cached_network_image package for image display
6. THE System SHALL upload images to Supabase_Service storage
7. THE System SHALL limit uploaded image size to maximum 5MB

### Requirement 29: Dependency Injection Setup

**User Story:** كمطور، أريد إعداد Dependency Injection باستخدام GetIt، حتى أتمكن من إدارة التبعيات بكفاءة

#### Acceptance Criteria

1. THE System SHALL register all services in GetIt container during app initialization
2. THE System SHALL register all repositories in GetIt container
3. THE System SHALL register all cubits as factories in GetIt container
4. THE System SHALL register NavigatorKey as singleton in GetIt container
5. THE System SHALL provide get_it_service.dart file in core/services directory
6. THE System SHALL initialize GetIt before running app in main.dart

### Requirement 30: Theme and Styling

**User Story:** كمستخدم، أريد تطبيقاً بتصميم جميل ومتناسق، حتى أستمتع بالاستخدام

#### Acceptance Criteria

1. THE System SHALL define color palette in core/utils/color_manager.dart
2. THE System SHALL define text styles in core/utils/text_styles.dart
3. THE System SHALL use consistent colors throughout app
4. THE System SHALL use consistent spacing and padding values
5. THE System SHALL use custom fonts defined in pubspec.yaml
6. THE System SHALL support light theme with modern design
7. THE System SHALL use rounded corners for cards and buttons
8. THE System SHALL provide visual feedback for tap interactions
