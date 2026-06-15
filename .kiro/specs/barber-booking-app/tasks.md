# Implementation Plan: Barber Booking App

## Overview

تنفيذ تطبيق حجز حلاقة متكامل باستخدام Flutter مع Clean Architecture والنمط Feature-First. التطبيق يدمج Firebase للمصادقة والبيانات الفورية، وSupabase لتخزين الملفات. التنفيذ سيبدأ بإعداد البنية الأساسية والخدمات الأساسية، ثم تنفيذ الميزات بالتدريج.

## Tasks

- [x] 1. إعداد المشروع والبنية الأساسية (Project Setup & Core Structure)
  - [x] 1.1 إنشاء هيكل المجلدات للـ Clean Architecture
    - إنشاء مجلدات core/ (entities, models, repos, services, utils, widgets, errors)
    - إنشاء مجلدات features/ حسب التصميم
    - إنشاء مجلد config/ للـ routes و themes
    - _Requirements: 1.1, 1.5, 1.6, 1.7, 1.8, 1.9, 1.10, 1.11_

  - [x] 1.2 إضافة Dependencies في pubspec.yaml
    - إضافة flutter_bloc, get_it, dartz, firebase_core, firebase_auth
    - إضافة cloud_firestore, firebase_storage, firebase_messaging
    - إضافة supabase_flutter, cached_network_image, easy_localization
    - إضافة flutter_screenutil, image_picker, geolocator
    - _Requirements: 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 2. إعداد Core Services والخدمات الأساسية
  - [x] 2.1 إنشاء Error Handling System
    - إنشاء lib/core/errors/failures.dart مع Failure classes
    - إنشاء lib/core/errors/exceptions.dart مع Exception classes
    - _Requirements: 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7_

  - [x] 2.2 إنشاء Firebase Auth Service
    - إنشاء lib/core/services/firebase_auth_service.dart
    - تنفيذ signInWithEmail, signInWithPhone, verifyOTP
    - تنفيذ signInWithGoogle, signOut, getCurrentUser, authStateChanges
    - _Requirements: 2.1, 12.1, 12.2, 12.3, 12.4, 12.5_

  - [x] 2.3 إنشاء Firestore Service
    - إنشاء lib/core/services/firestore_service.dart
    - تنفيذ addDocument, getDocument, getDocuments, updateDocument, deleteDocument
    - تنفيذ streamCollection للبيانات الفورية
    - _Requirements: 2.2, 1.2_

  - [x] 2.4 إنشاء Supabase Storage Service
    - إنشاء lib/core/services/supabase_storage_service.dart
    - تنفيذ initSupabase, uploadImage, deleteImage, getPublicUrl
    - _Requirements: 2.4, 2.5, 2.7, 28.6_

  - [x] 2.5 إنشاء Navigation Service
    - إنشاء lib/core/services/navigation_service.dart
    - تنفيذ navigateTo, navigateAndReplace, navigateAndRemoveUntil, goBack
    - _Requirements: 1.4_

  - [~] 2.6 إنشاء FCM Service (Firebase Cloud Messaging)
    - إنشاء lib/core/services/fcm_service.dart
    - تنفيذ init, _requestPermission, _handleForegroundMessage, _handleNotificationTap
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 17.6, 17.7_

  - [~] 2.7 إنشاء Notification Service
    - إنشاء lib/core/services/notification_service.dart
    - تنفيذ إشعارات محلية مع flutter_local_notifications
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_

  - [~] 2.8 إنشاء Location Service
    - إنشاء lib/core/services/location_service.dart
    - تنفيذ getCurrentLocation, requestPermission, calculateDistance
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5_

- [ ] 3. إعداد GetIt Dependency Injection
  - [~] 3.1 إنشاء GetIt Service وتسجيل Dependencies
    - إنشاء lib/core/services/get_it_service.dart
    - تسجيل جميع Services كـ Singletons
    - تسجيل NavigatorKey كـ Singleton
    - تسجيل Cubits كـ Factories
    - _Requirements: 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 1.4_

- [ ] 4. إنشاء Core Utilities وHelpers
  - [x] 4.1 إنشاء Color Manager
    - إنشاء lib/core/utils/color_manager.dart
    - تعريف جميع ألوان التطبيق
    - _Requirements: 30.1, 30.3_

  - [x] 4.2 إنشاء Text Styles
    - إنشاء lib/core/utils/text_styles.dart
    - تعريف جميع أنماط النصوص (bold16, regular14, etc.)
    - _Requirements: 30.2, 30.5_

  - [~] 4.3 إنشاء Constants
    - إنشاء lib/core/utils/constants.dart
    - تعريف الثوابت مثل Spacing values, Animation durations
    - _Requirements: 30.4_

  - [x] 4.4 إنشاء Validators
    - إنشاء lib/core/utils/validators.dart
    - تنفيذ validateEmail, validatePhone, validatePassword
    - _Requirements: 12.7, 13.5_

  - [~] 4.5 إنشاء Date Formatter
    - إنشاء lib/core/utils/date_formatter.dart
    - تنفيذ formatDate, formatTime, formatDateTime
    - _Requirements: 11.3, 11.4_

  - [~] 4.6 إنشاء Image Compressor
    - إنشاء lib/core/utils/image_compressor.dart
    - تنفيذ compressImage لتقليل حجم الصور قبل الرفع
    - _Requirements: 28.1, 28.7_

- [ ] 5. إنشاء Core Widgets المشتركة
  - [x] 5.1 إنشاء Custom Button Widget
    - إنشاء lib/core/widgets/custom_button.dart
    - تنفيذ زر قابل لإعادة الاستخدام مع Loading state
    - _Requirements: 30.7, 30.8_

  - [x] 5.2 إنشاء Custom Text Field Widget
    - إنشاء lib/core/widgets/custom_text_field.dart
    - تنفيذ حقل نص مع Validation support
    - _Requirements: 26.3, 30.8_

  - [~] 5.3 إنشاء Loading Widget
    - إنشاء lib/core/widgets/loading_widget.dart
    - تنفيذ circular loading indicator مع overlay
    - _Requirements: 27.3, 27.4_

  - [~] 5.4 إنشاء Error Widget
    - إنشاء lib/core/widgets/error_widget.dart
    - تنفيذ عرض الأخطاء مع Retry button
    - _Requirements: 26.1, 26.2, 26.5_

  - [~] 5.5 إنشاء Shimmer Loading Widget
    - إنشاء lib/core/widgets/shimmer_loading.dart
    - تنفيذ Shimmer effect للـ placeholder loading
    - _Requirements: 27.1, 27.2_

  - [~] 5.6 إنشاء Cached Image Widget
    - إنشاء lib/core/widgets/cached_image_widget.dart
    - تنفيذ عرض صور مع Caching باستخدام cached_network_image
    - _Requirements: 28.2, 28.3, 28.4, 28.5_

  - [~] 5.7 إنشاء Rating Widget
    - إنشاء lib/core/widgets/rating_widget.dart
    - تنفيذ عرض التقييمات بالنجوم
    - _Requirements: 20.2, 20.7_

- [ ] 6. إنشاء Core Entities
  - [x] 6.1 إنشاء User Entity
    - إنشاء lib/core/entities/user_entity.dart
    - تعريف UserEntity مع جميع الحقول المطلوبة
    - _Requirements: 1.6, 12.6, 13.1_

  - [~] 6.2 إنشاء Shop Entity
    - إنشاء lib/core/entities/shop_entity.dart
    - تعريف ShopEntity مع ServiceCategory enum
    - _Requirements: 1.6, 5.2, 6.2, 7.2, 22.1, 22.2, 22.3, 22.4_

  - [~] 6.3 إنشاء Service Entity
    - إنشاء lib/core/entities/service_entity.dart
    - تعريف ServiceEntity للخدمات المقدمة
    - _Requirements: 1.6, 11.2, 22.5_

  - [~] 6.4 إنشاء Booking Entity
    - إنشاء lib/core/entities/booking_entity.dart
    - تعريف BookingEntity مع BookingStatus enum
    - _Requirements: 1.6, 11.7, 11.9, 24.1, 24.2_

- [ ] 7. إنشاء Core Models (Data Models)
  - [x] 7.1 إنشاء User Model
    - إنشاء lib/core/models/user_model.dart
    - تنفيذ fromJson, toJson, toEntity
    - _Requirements: 1.7, 12.6_

  - [~] 7.2 إنشاء Shop Model
    - إنشاء lib/core/models/shop_model.dart
    - تنفيذ fromJson, toJson, toEntity
    - _Requirements: 1.7_

  - [~] 7.3 إنشاء Service Model
    - إنشاء lib/core/models/service_model.dart
    - تنفيذ fromJson, toJson, toEntity
    - _Requirements: 1.7_

  - [~] 7.4 إنشاء Booking Model
    - إنشاء lib/core/models/booking_model.dart
    - تنفيذ fromJson, toJson, toEntity
    - _Requirements: 1.7_

- [ ] 8. إنشاء Core Repositories
  - [~] 8.1 إنشاء Booking Repo Interface
    - إنشاء lib/core/repos/booking_repo.dart
    - تعريف getBookings, getBookingById, createBooking, cancelBooking, getAvailableTimeSlots
    - _Requirements: 1.8, 1.2, 11.1, 11.6, 11.9, 11.10, 11.11_

- [ ] 9. إعداد App Router والـ Theme
  - [~] 9.1 إنشاء App Router
    - إنشاء lib/config/routes/app_router.dart
    - تعريف جميع Named Routes وonGenerateRoute
    - _Requirements: 1.4, 3.4, 4.8_

  - [~] 9.2 إنشاء App Theme
    - إنشاء lib/config/themes/app_theme.dart
    - تعريف lightTheme مع ColorScheme و TextTheme
    - _Requirements: 30.3, 30.5, 30.6, 30.7_

- [ ] 10. إعداد Localization (Multi-language Support)
  - [~] 10.1 إنشاء Translation Files
    - إنشاء assets/translations/ar.json
    - إنشاء assets/translations/en.json
    - إضافة جميع النصوص المطلوبة للتطبيق
    - _Requirements: 18.1, 18.2, 18.4, 18.8_

- [ ] 11. إعداد Firebase Configuration
  - [~] 11.1 إضافة Firebase Config Files
    - تشغيل firebase_options.dart باستخدام FlutterFire CLI
    - إضافة google-services.json للأندرويد
    - إضافة GoogleService-Info.plist للـ iOS
    - _Requirements: 2.1, 2.2, 2.6_

- [ ] 12. تنفيذ Main.dart وتهيئة التطبيق
  - [~] 12.1 إنشاء main.dart الرئيسي
    - تهيئة Firebase في main()
    - تهيئة Supabase في main()
    - استدعاء setupGetIt()
    - تهيئة EasyLocalization
    - إنشاء BarberBookingApp widget مع MaterialApp
    - _Requirements: 2.6, 2.7, 29.6, 18.3_

- [~] 13. Checkpoint - التحقق من البنية الأساسية
  - تأكد من أن المشروع يعمل بدون أخطاء compile
  - تأكد من أن Firebase وSupabase تم تهيئتهما بشكل صحيح
  - تأكد من أن GetIt تم إعداده بشكل صحيح
  - اسأل المستخدم إذا كانت هناك أي مشاكل

- [ ] 14. تنفيذ Splash Screen Feature
  - [~] 14.1 إنشاء Splash View
    - إنشاء lib/features/splash/presentation/views/splash_view.dart
    - تنفيذ UI مع Logo و Loading indicator
    - تنفيذ Navigation بعد 2-5 ثواني
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 15. تنفيذ Category Selection Screen
  - [~] 15.1 إنشاء Category Card Widget
    - إنشاء lib/features/category_selection/presentation/widgets/category_card.dart
    - تنفيذ UI للكارت مع Icon و Title و Subtitle
    - _Requirements: 4.9, 4.10_

  - [~] 15.2 إنشاء Category Selection View
    - إنشاء lib/features/category_selection/presentation/views/category_selection_view.dart
    - عرض 6 Category Cards (Men, Women, Kids, Store, Provider, AI Advisor)
    - تنفيذ Navigation لكل فئة
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.11_

- [ ] 16. تنفيذ Authentication Feature
  - [x] 16.1 إنشاء Auth Repo Implementation
    - إنشاء lib/features/auth/domain/repos/auth_repo.dart (interface)
    - إنشاء lib/features/auth/data/repos/auth_repo_impl.dart
    - تنفيذ signInWithEmail, signInWithPhone, verifyOTP, signInWithGoogle, signOut
    - _Requirements: 1.2, 12.1, 12.2, 12.3, 12.4, 12.5, 12.8, 12.9_

  - [x] 16.2 إنشاء Auth Cubit
    - إنشاء lib/features/auth/presentation/cubit/auth_cubit.dart
    - إنشاء lib/features/auth/presentation/cubit/auth_state.dart
    - تنفيذ States: Initial, Loading, Success, Error
    - تنفيذ Methods: signIn, signUp, verifyOTP, signInWithGoogle, signOut
    - _Requirements: 1.3, 12.7_

  - [~] 16.3 إنشاء Sign In View
    - إنشاء lib/features/auth/presentation/views/sign_in_view.dart
    - تنفيذ UI لـ Email/Password Sign In و Google Sign In
    - استخدام BlocProvider و BlocConsumer
    - _Requirements: 12.2, 12.3, 12.7_

  - [~] 16.4 إنشاء Phone Verification View
    - إنشاء lib/features/auth/presentation/views/phone_verification_view.dart
    - تنفيذ UI لإدخال رقم الهاتف و OTP
    - _Requirements: 12.1, 12.4, 12.5_

- [~] 17. Checkpoint - التحقق من Authentication
  - تأكد من أن الـ Authentication يعمل بشكل صحيح
  - اختبر Sign In بالـ Email/Password
  - اختبر Phone Verification مع OTP
  - اختبر Google Sign In
  - اسأل المستخدم إذا كانت هناك أي مشاكل

- [ ] 18. تنفيذ Profile Management Feature
  - [~] 18.1 إنشاء Profile Cubit
    - إنشاء lib/features/profile/presentation/cubit/profile_cubit.dart
    - إنشاء lib/features/profile/presentation/cubit/profile_state.dart
    - تنفيذ Methods: loadProfile, updateProfile, uploadProfilePhoto
    - _Requirements: 1.3, 13.8, 13.9_

  - [~] 18.2 إنشاء Profile View
    - إنشاء lib/features/profile/presentation/views/profile_view.dart
    - عرض user name, email, phone, photo
    - إضافة زر Edit Profile
    - _Requirements: 13.1_

  - [~] 18.3 إنشاء Edit Profile View
    - إنشاء lib/features/profile/presentation/views/edit_profile_view.dart
    - تنفيذ تحديث Name, Email, Profile Photo
    - _Requirements: 13.2, 13.3, 13.4, 13.5, 13.6, 13.7_

- [ ] 19. تنفيذ Men Services Feature
  - [~] 19.1 إنشاء Barbershop Entity
    - إنشاء lib/features/men_services/domain/entities/barbershop_entity.dart
    - استخدام ShopEntity من core/entities
    - _Requirements: 5.2_

  - [~] 19.2 إنشاء Barbershop Model
    - إنشاء lib/features/men_services/data/models/barbershop_model.dart
    - تنفيذ fromJson, toJson, toEntity
    - _Requirements: 1.7, 5.7_

  - [~] 19.3 إنشاء Barbershop Repo
    - إنشاء lib/features/men_services/domain/repos/barbershop_repo.dart
    - إنشاء lib/features/men_services/data/repos/barbershop_repo_impl.dart
    - تنفيذ getBarbershops, searchBarbershops, filterBarbershops
    - _Requirements: 1.2, 5.7, 5.8_

  - [~] 19.4 إنشاء Barbershop Cubit
    - إنشاء lib/features/men_services/presentation/cubit/barbershop_cubit.dart
    - إنشاء lib/features/men_services/presentation/cubit/barbershop_state.dart
    - تنفيذ loadBarbershops, searchBarbershops, filterBarbershops
    - _Requirements: 1.3, 5.8_

  - [~] 19.5 إنشاء Barbershop Card Widget
    - إنشاء lib/features/men_services/presentation/widgets/barbershop_card.dart
    - عرض name, rating, distance
    - _Requirements: 5.3_

  - [~] 19.6 إنشاء Men Services View
    - إنشاء lib/features/men_services/presentation/views/men_services_view.dart
    - عرض قائمة Barbershops
    - إضافة Search و Filter
    - _Requirements: 5.1, 5.2, 5.5, 5.6_

  - [~] 19.7 إنشاء Barbershop Details View
    - إنشاء lib/features/men_services/presentation/views/barbershop_details_view.dart
    - عرض صور الصالون، التقييمات، العنوان، الخدمات
    - إضافة زر Book Now
    - _Requirements: 5.4, 22.1, 22.2, 22.3, 22.4, 22.5, 22.6, 22.7, 22.8, 22.9, 22.10_

- [ ] 20. تنفيذ Women Services Feature (Similar to Men Services)
  - [~] 20.1 إنشاء Salon Repo وModel وCubit
    - نسخ نفس البنية من Men Services مع تعديل للـ Women
    - _Requirements: 6.2, 6.7, 6.8_

  - [~] 20.2 إنشاء Women Services View وSalon Details View
    - تنفيذ UI مشابه للـ Men Services
    - _Requirements: 6.1, 6.3, 6.4, 6.5, 6.6_

- [ ] 21. تنفيذ Kids Services Feature (Similar to Men Services)
  - [~] 21.1 إنشاء Kids Shop Repo وModel وCubit
    - نسخ نفس البنية من Men Services مع تمييز Kid-Friendly
    - _Requirements: 7.2, 7.6, 7.7_

  - [~] 21.2 إنشاء Kids Services View وShop Details View
    - تنفيذ UI مع إبراز Kid-Friendly badge
    - _Requirements: 7.1, 7.3, 7.4, 7.5_

- [~] 22. Checkpoint - التحقق من Services Features
  - تأكد من أن Men, Women, Kids Services تعمل بشكل صحيح
  - اختبر عرض الصالونات والبحث والفلترة
  - اختبر Shop Details View
  - اسأل المستخدم إذا كانت هناك أي مشاكل

- [ ] 23. تنفيذ Booking Management Feature
  - [~] 23.1 إنشاء Booking Repo Implementation
    - إنشاء lib/features/booking/data/repos/booking_repo_impl.dart
    - تنفيذ createBooking, getBookings, cancelBooking, getAvailableTimeSlots
    - _Requirements: 11.7, 11.9, 11.10, 11.11, 11.12_

  - [~] 23.2 إنشاء Booking Cubit
    - إنشاء lib/features/booking/presentation/cubit/booking_cubit.dart
    - إنشاء lib/features/booking/presentation/cubit/booking_state.dart
    - تنفيذ loadAvailableTimeSlots, createBooking, loadBookings, cancelBooking
    - _Requirements: 1.3, 11.12_

  - [~] 23.3 إنشاء Booking View
    - إنشاء lib/features/booking/presentation/views/booking_view.dart
    - عرض التقويم لاختيار التاريخ
    - عرض Available time slots
    - عرض قائمة الخدمات مع الأسعار
    - إضافة زر Confirm Booking
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8_

  - [~] 23.4 إنشاء Booking History View
    - إنشاء lib/features/booking/presentation/views/booking_history_view.dart
    - عرض قائمة الحجوزات السابقة
    - إضافة خيار Cancel Booking
    - _Requirements: 11.9, 11.10_

- [ ] 24. تنفيذ Store Feature (QUTI Store)
  - [~] 24.1 إنشاء Product Entity وModel
    - إنشاء lib/features/store/domain/entities/product_entity.dart
    - إنشاء lib/features/store/data/models/product_model.dart
    - _Requirements: 8.2, 8.8_

  - [~] 24.2 إنشاء Product Repo
    - إنشاء lib/features/store/domain/repos/product_repo.dart
    - إنشاء lib/features/store/data/repos/product_repo_impl.dart
    - تنفيذ getProducts, searchProducts, filterProducts
    - _Requirements: 8.8, 8.9_

  - [~] 24.3 إنشاء Product Cubit
    - إنشاء lib/features/store/presentation/cubit/product_cubit.dart
    - إنشاء lib/features/store/presentation/cubit/product_state.dart
    - تنفيذ loadProducts, searchProducts, filterProducts
    - _Requirements: 8.9_

  - [~] 24.4 إنشاء Product Card Widget
    - إنشاء lib/features/store/presentation/widgets/product_card.dart
    - عرض product image, name, price, rating
    - _Requirements: 8.3_

  - [~] 24.5 إنشاء Store View
    - إنشاء lib/features/store/presentation/views/store_view.dart
    - عرض قائمة المنتجات
    - إضافة Search و Filter
    - _Requirements: 8.1, 8.2, 8.6, 8.7_

  - [~] 24.6 إنشاء Product Details View
    - إنشاء lib/features/store/presentation/views/product_details_view.dart
    - عرض تفاصيل المنتج الكاملة
    - إضافة زر Add to Cart
    - _Requirements: 8.4, 8.5_

- [ ] 25. تنفيذ Cart Management Feature
  - [~] 25.1 إنشاء Cart Item Entity وModel
    - إنشاء lib/features/cart/domain/entities/cart_item_entity.dart
    - إنشاء lib/features/cart/data/models/cart_item_model.dart
    - _Requirements: 23.1, 23.8_

  - [~] 25.2 إنشاء Cart Repo
    - إنشاء lib/features/cart/domain/repos/cart_repo.dart
    - إنشاء lib/features/cart/data/repos/cart_repo_impl.dart
    - تنفيذ addToCart, removeFromCart, updateQuantity, getCartItems
    - استخدام Hive أو SharedPreferences للتخزين المحلي
    - _Requirements: 23.7, 23.8, 23.9_

  - [~] 25.3 إنشاء Cart Cubit
    - إنشاء lib/features/cart/presentation/cubit/cart_cubit.dart
    - إنشاء lib/features/cart/presentation/cubit/cart_state.dart
    - تنفيذ addToCart, removeItem, increaseQuantity, decreaseQuantity, calculateTotal
    - _Requirements: 23.9_

  - [~] 25.4 إنشاء Cart View
    - إنشاء lib/features/cart/presentation/views/cart_view.dart
    - عرض Cart items مع Quantity controls
    - عرض Subtotal و Total
    - إضافة زر Checkout
    - _Requirements: 23.1, 23.2, 23.3, 23.4, 23.5, 23.6_

- [ ] 26. تنفيذ Favorites Management Feature
  - [~] 26.1 إنشاء Favorites Cubit
    - إنشاء lib/features/favorites/presentation/cubit/favorites_cubit.dart
    - إنشاء lib/features/favorites/presentation/cubit/favorites_state.dart
    - تنفيذ addToFavorites, removeFromFavorites, loadFavorites
    - استخدام Firestore لتخزين المفضلات
    - _Requirements: 14.1, 14.2, 14.5, 14.6, 14.7, 14.8_

  - [~] 26.2 إنشاء Favorites View
    - إنشاء lib/features/favorites/presentation/views/favorites_view.dart
    - عرض قائمة الصالونات المفضلة
    - _Requirements: 14.3, 14.4_

- [ ] 27. تنفيذ Search Functionality Feature
  - [~] 27.1 إنشاء Search Cubit
    - إنشاء lib/features/search/presentation/cubit/search_cubit.dart
    - إنشاء lib/features/search/presentation/cubit/search_state.dart
    - تنفيذ search method مع Real-time filtering
    - _Requirements: 15.2, 15.3, 15.7_

  - [~] 27.2 إنشاء Search View
    - إنشاء lib/features/search/presentation/views/search_view.dart
    - إضافة Search bar
    - عرض Search results
    - _Requirements: 15.1, 15.4, 15.5, 15.6_

- [ ] 28. تنفيذ Provider Registration Feature
  - [~] 28.1 إنشاء Provider Registration Cubit
    - إنشاء lib/features/provider_registration/presentation/cubit/provider_registration_cubit.dart
    - إنشاء lib/features/provider_registration/presentation/cubit/provider_registration_state.dart
    - تنفيذ submitRegistration method
    - _Requirements: 9.8, 9.9, 9.10_

  - [~] 28.2 إنشاء Provider Registration View
    - إنشاء lib/features/provider_registration/presentation/views/provider_registration_view.dart
    - إضافة Form لجمع بيانات المزود
    - إضافة Image picker للرخصة والصور
    - إضافة Map location picker للعنوان
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_

- [ ] 29. تنفيذ AI Hair Advisor Feature
  - [~] 29.1 إنشاء Hairstyle Suggestion Entity وModel
    - إنشاء lib/features/ai_advisor/domain/entities/hairstyle_suggestion_entity.dart
    - إنشاء lib/features/ai_advisor/data/models/hairstyle_suggestion_model.dart
    - _Requirements: 10.6, 10.9_

  - [~] 29.2 إنشاء AI Advisor Repo
    - إنشاء lib/features/ai_advisor/domain/repos/ai_advisor_repo.dart
    - إنشاء lib/features/ai_advisor/data/repos/ai_advisor_repo_impl.dart
    - تنفيذ getSuggestions method باستخدام Supabase
    - _Requirements: 10.9_

  - [~] 29.3 إنشاء AI Advisor Cubit
    - إنشاء lib/features/ai_advisor/presentation/cubit/ai_advisor_cubit.dart
    - إنشاء lib/features/ai_advisor/presentation/cubit/ai_advisor_state.dart
    - تنفيذ uploadPhoto, analyzeFace, getSuggestions
    - _Requirements: 10.5_

  - [~] 29.4 إنشاء AI Advisor View
    - إنشاء lib/features/ai_advisor/presentation/views/ai_advisor_view.dart
    - إضافة Image picker للصورة
    - إضافة Dropdowns لـ Face shape و Hair type
    - عرض Suggestions مع الصور
    - إضافة Save to Favorites option
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.8_

- [~] 30. Checkpoint - التحقق من جميع الـ Features الأساسية
  - تأكد من أن جميع الـ Features تعمل بشكل صحيح
  - اختبر Booking, Store, Cart, Favorites, Search, Provider Registration, AI Advisor
  - اسأل المستخدم إذا كانت هناك أي مشاكل

- [ ] 31. تنفيذ Rating and Review System
  - [~] 31.1 إنشاء Review Entity وModel
    - إنشاء review_entity.dart و review_model.dart
    - _Requirements: 20.2, 20.3_

  - [~] 31.2 إنشاء Review Repo وCubit
    - تنفيذ submitReview, getReviews methods
    - _Requirements: 20.1, 20.5, 20.6, 20.7, 20.8, 20.9_

  - [~] 31.3 إنشاء Review Dialog/View
    - إضافة UI لإدخال Rating و Review text
    - إضافة Image picker للصور
    - _Requirements: 20.2, 20.3, 20.4_

- [ ] 32. تنفيذ Payment Integration
  - [~] 32.1 إنشاء Payment Service
    - إنشاء lib/core/services/payment_service.dart
    - دمج Payment Gateway (Stripe أو PayPal أو محلي)
    - _Requirements: 21.1, 21.2, 21.3, 21.9_

  - [~] 32.2 إنشاء Payment View
    - إنشاء payment_view.dart لإدخال بيانات الدفع
    - إضافة خيار Cash on Arrival
    - _Requirements: 21.4, 21.5, 21.6, 21.7, 21.8_

- [ ] 33. تنفيذ Order Tracking (للمتجر)
  - [~] 33.1 إنشاء Order Entity وModel
    - تعريف Order مع Status enum
    - _Requirements: 24.1, 24.2_

  - [~] 33.2 إنشاء Order Tracking View
    - عرض Order status و Estimated delivery time
    - عرض Order history
    - _Requirements: 24.2, 24.3, 24.4, 24.5, 24.6, 24.7_

- [ ] 34. تنفيذ Promo Codes
  - [~] 34.1 إنشاء Promo Code Service
    - تنفيذ validatePromoCode, applyDiscount methods
    - _Requirements: 25.2, 25.3, 25.7_

  - [~] 34.2 إضافة Promo Code Input في Checkout
    - إضافة TextField لإدخال الكود
    - عرض الخصم المطبق
    - _Requirements: 25.1, 25.4, 25.5, 25.6_

- [ ] 35. تنفيذ Offline Support
  - [~] 35.1 إضافة Hive للتخزين المحلي
    - إعداد Hive في المشروع
    - إنشاء Boxes للـ Shops, Bookings, Favorites
    - _Requirements: 19.1, 19.2, 19.3_

  - [~] 35.2 تنفيذ Caching Logic في Repositories
    - تعديل Repos لحفظ البيانات محلياً
    - عرض Cached data عند عدم وجود إنترنت
    - _Requirements: 19.4, 19.5, 19.6, 19.7_

- [ ] 36. تنفيذ Location Services Integration
  - [~] 36.1 إضافة Location Permission Handling
    - طلب الإذن عند بدء التطبيق
    - _Requirements: 16.1, 16.2_

  - [~] 36.2 تنفيذ Distance Calculation
    - حساب المسافة بين المستخدم والصالونات
    - عرض Distance في الكروت
    - _Requirements: 16.3, 16.4_

  - [~] 36.3 إضافة Map View
    - دمج Google Maps
    - عرض الصالونات على الخريطة
    - _Requirements: 16.5, 16.6, 16.7_

- [ ] 37. إضافة Notifications Handling
  - [~] 37.1 تنفيذ Notification Handlers في FCM Service
    - معالجة Foreground و Background notifications
    - _Requirements: 17.2, 17.3, 17.4, 17.5_

  - [~] 37.2 إضافة Navigation عند الضغط على Notification
    - تنفيذ Deep linking للشاشات المختلفة
    - _Requirements: 17.7_

- [ ] 38. تنفيذ Multi-language Support Completion
  - [~] 38.1 إضافة جميع النصوص للـ Translation Files
    - إكمال ar.json و en.json
    - _Requirements: 18.1, 18.2_

  - [~] 38.2 إضافة Language Switcher في Settings
    - إضافة خيار تغيير اللغة
    - تطبيق RTL/LTR بناءً على اللغة
    - _Requirements: 18.4, 18.5, 18.6, 18.7_

- [ ] 39. Final Testing وPolishing
  - [~] 39.1 اختبار جميع الـ Features end-to-end
    - اختبر Complete booking flow
    - اختبر Store purchase flow
    - اختبر Authentication flows
    - _Requirements: جميع المتطلبات_

  - [~] 39.2 إضافة Error Handling شامل
    - تأكد من معالجة جميع الأخطاء المحتملة
    - إضافة User-friendly error messages
    - _Requirements: 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7_

  - [~] 39.3 تحسين Loading States
    - إضافة Shimmer loading في جميع الشاشات
    - إضافة "Taking longer than usual" message
    - _Requirements: 27.1, 27.2, 27.3, 27.4, 27.5, 27.6_

  - [~] 39.4 تحسين Image Handling
    - تأكد من Compression يعمل بشكل صحيح
    - تأكد من Caching يعمل بشكل صحيح
    - _Requirements: 28.1, 28.2, 28.3, 28.4, 28.5, 28.6, 28.7_

- [~] 40. Final Checkpoint - المراجعة النهائية
  - تأكد من أن التطبيق يعمل بدون أخطاء
  - تأكد من أن جميع الـ Features مكتملة
  - اختبر التطبيق على أجهزة مختلفة
  - اسأل المستخدم للمراجعة النهائية والموافقة

## Notes

- التطبيق مبني باستخدام **Dart/Flutter** مع Clean Architecture
- جميع المهام تتبع النمط Feature-First مع فصل واضح للطبقات (Presentation, Domain, Data)
- Dependency Injection باستخدام **GetIt** لإدارة التبعيات
- State Management باستخدام **Cubit/Bloc** pattern
- Firebase للمصادقة والبيانات الفورية، Supabase للتخزين والملفات
- Checkpoints موجودة لضمان التحقق التدريجي من العمل
- المهام مرتبة بترتيب منطقي: Core → Features → Integration → Testing

## Task Dependency Graph

```json
{
  "waves": [
    {
      "id": 0,
      "tasks": ["1.1", "1.2"]
    },
    {
      "id": 1,
      "tasks": ["2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8"]
    },
    {
      "id": 2,
      "tasks": ["3.1", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6"]
    },
    {
      "id": 3,
      "tasks": ["5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "6.1", "6.2", "6.3", "6.4"]
    },
    {
      "id": 4,
      "tasks": ["7.1", "7.2", "7.3", "7.4", "8.1"]
    },
    {
      "id": 5,
      "tasks": ["9.1", "9.2", "10.1", "11.1"]
    },
    {
      "id": 6,
      "tasks": ["12.1"]
    },
    {
      "id": 7,
      "tasks": ["14.1"]
    },
    {
      "id": 8,
      "tasks": ["15.1"]
    },
    {
      "id": 9,
      "tasks": ["15.2"]
    },
    {
      "id": 10,
      "tasks": ["16.1", "16.2"]
    },
    {
      "id": 11,
      "tasks": ["16.3", "16.4"]
    },
    {
      "id": 12,
      "tasks": ["18.1", "19.1", "19.2"]
    },
    {
      "id": 13,
      "tasks": ["18.2", "18.3", "19.3", "19.4"]
    },
    {
      "id": 14,
      "tasks": ["19.5", "19.6", "19.7", "20.1"]
    },
    {
      "id": 15,
      "tasks": ["20.2", "21.1"]
    },
    {
      "id": 16,
      "tasks": ["21.2", "23.1", "23.2"]
    },
    {
      "id": 17,
      "tasks": ["23.3", "23.4", "24.1", "24.2"]
    },
    {
      "id": 18,
      "tasks": ["24.3", "24.4"]
    },
    {
      "id": 19,
      "tasks": ["24.5", "24.6", "25.1", "25.2"]
    },
    {
      "id": 20,
      "tasks": ["25.3"]
    },
    {
      "id": 21,
      "tasks": ["25.4", "26.1", "27.1"]
    },
    {
      "id": 22,
      "tasks": ["26.2", "27.2", "28.1"]
    },
    {
      "id": 23,
      "tasks": ["28.2", "29.1", "29.2"]
    },
    {
      "id": 24,
      "tasks": ["29.3"]
    },
    {
      "id": 25,
      "tasks": ["29.4", "31.1"]
    },
    {
      "id": 26,
      "tasks": ["31.2", "31.3", "32.1"]
    },
    {
      "id": 27,
      "tasks": ["32.2", "33.1"]
    },
    {
      "id": 28,
      "tasks": ["33.2", "34.1"]
    },
    {
      "id": 29,
      "tasks": ["34.2", "35.1"]
    },
    {
      "id": 30,
      "tasks": ["35.2", "36.1"]
    },
    {
      "id": 31,
      "tasks": ["36.2", "36.3", "37.1"]
    },
    {
      "id": 32,
      "tasks": ["37.2", "38.1"]
    },
    {
      "id": 33,
      "tasks": ["38.2"]
    },
    {
      "id": 34,
      "tasks": ["39.1", "39.2", "39.3", "39.4"]
    }
  ]
}
```
