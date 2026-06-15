import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/core/models/user_model.dart';

/// Provider for managing user profile state and operations
class ProfileProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isNavigatingOut = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isNavigatingOut => _isNavigatingOut;
  String? get error => _error;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final StreamSubscription<User?> _authSubscription;

  ProfileProvider() {
    _initializeUser();
    // Listen for auth state changes - re-fetch profile when user logs in
    _authSubscription = _auth.authStateChanges().listen((user) async {
      if (user != null && _currentUser == null) {
        await fetchUserProfile(user.uid);
      } else if (user == null) {
        clearUser();
      }
    });
  }

  /// Initialize user data on provider creation
  Future<void> _initializeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await fetchUserProfile(user.uid);
    }
  }

  /// Fetch user profile from Firestore
  Future<void> fetchUserProfile(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          _currentUser = UserModel.fromJson({'id': docSnapshot.id, ...data});

          // Self-healing: Sync Google profile image & name to Firestore
          final firebaseUser = _auth.currentUser;
          if (firebaseUser != null) {
            final isGoogleUser = firebaseUser.providerData.any(
              (info) => info.providerId == 'google.com',
            );

            if (isGoogleUser) {
              bool needsUpdate = false;
              String? newPhotoUrl = _currentUser!.photoUrl;
              String? newName = _currentUser!.name;

              // Sync Google photo URL if missing in Firestore
              if (firebaseUser.photoURL != null &&
                  (_currentUser!.photoUrl == null ||
                      _currentUser!.photoUrl!.isEmpty)) {
                newPhotoUrl = firebaseUser.photoURL;
                needsUpdate = true;
                debugPrint('🔄 Syncing Google profile image to Firestore');
              }

              // Sync Google display name if missing in Firestore
              if (firebaseUser.displayName != null &&
                  firebaseUser.displayName!.isNotEmpty &&
                  (_currentUser!.name.isEmpty)) {
                newName = firebaseUser.displayName;
                needsUpdate = true;
                debugPrint('🔄 Syncing Google display name to Firestore');
              }

              if (needsUpdate) {
                _currentUser = _currentUser!.copyWith(
                  photoUrl: newPhotoUrl,
                  name: newName ?? _currentUser!.name,
                );
                await _firestore
                    .collection('users')
                    .doc(_currentUser!.id)
                    .set(_currentUser!.toJson(), SetOptions(merge: true));
              }
            }
          }
        }
      } else {
        // If user document doesn't exist in Firestore, create from Firebase Auth
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          _currentUser = UserModel.fromFirebaseUser(firebaseUser);
          // Save to Firestore
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(_currentUser!.toJson());
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error fetching user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updatedUser.toJson());

      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error updating user profile: $e');
    }
  }

  /// Set navigating out state (for loading overlay)
  void setNavigatingOut(bool value) {
    _isNavigatingOut = value;
    notifyListeners();
  }

  /// Listen to user profile changes in real-time
  void listenToUserProfile(String userId) {
    _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen(
          (docSnapshot) {
            if (docSnapshot.exists) {
              final data = docSnapshot.data();
              if (data != null) {
                _currentUser = UserModel.fromJson({
                  'id': docSnapshot.id,
                  ...data,
                });
                notifyListeners();
              }
            }
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
            debugPrint('❌ Error listening to user profile: $error');
          },
        );
  }

  /// Clear user data (on logout)
  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    _isNavigatingOut = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  /// Refresh user profile
  Future<void> refreshUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      await fetchUserProfile(user.uid);
    }
  }
}
