import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app/core/services/firebase_auth_service.dart';
import 'package:app/core/services/firestore_service.dart';
import 'package:app/core/services/supabase_storage_service.dart';
import 'package:app/core/services/navigation_service.dart';
import 'package:app/features/auth/data/repos/auth_repo_impl.dart';
import 'package:app/features/auth/domain/repos/auth_repo.dart';
import 'package:app/features/auth/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance;

/// Setup GetIt Dependency Injection
/// Registers all services, repositories, and cubits
void setupGetIt() {
  // Register Navigator Key (Singleton)
  getIt.registerSingleton<GlobalKey<NavigatorState>>(
    GlobalKey<NavigatorState>(),
  );

  // Register Core Services (Singletons)
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerLazySingleton<SupabaseStorageService>(
    () => SupabaseStorageService(),
  );
  getIt.registerSingleton<NavigationService>(NavigationService());

  // Register Repositories (Singletons)
  getIt.registerSingleton<AuthRepo>(
    AuthRepoImpl(
      firebaseAuthService: getIt<FirebaseAuthService>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );

  // Register Cubits (Factories - new instance each time)
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));
}
