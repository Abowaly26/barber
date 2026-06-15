import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Helper class for testing ProfileProvider functionality
/// Use this to create test data in Firestore
class ProfileTestHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a test user document in Firestore
  /// Call this after user signs in for the first time
  static Future<void> createTestUserDocument() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      final userData = {
        'id': user.uid,
        'name': user.displayName ?? 'Test User',
        'email': user.email ?? 'test@example.com',
        'phoneNumber': user.phoneNumber,
        'photoUrl': user.photoURL,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      print('✅ Test user document created successfully');
      print('User ID: ${user.uid}');
      print('User Data: $userData');
    } catch (e) {
      print('❌ Error creating test user document: $e');
    }
  }

  /// Create test notifications for the current user
  static Future<void> createTestNotifications({int count = 3}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      final notificationsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications');

      for (int i = 0; i < count; i++) {
        await notificationsRef.add({
          'title': 'Test Notification ${i + 1}',
          'body': 'This is test notification number ${i + 1}',
          'read': false,
          'createdAt': DateTime.now().toIso8601String(),
          'type': 'test',
        });
      }

      print('✅ $count test notifications created successfully');
    } catch (e) {
      print('❌ Error creating test notifications: $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllNotificationsAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      final notificationsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications');

      final snapshot = await notificationsRef.get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'read': true});
      }

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking notifications as read: $e');
    }
  }

  /// Delete all test notifications
  static Future<void> deleteAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      final notificationsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications');

      final snapshot = await notificationsRef.get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ All notifications deleted');
    } catch (e) {
      print('❌ Error deleting notifications: $e');
    }
  }

  /// Update current user's profile
  static Future<void> updateTestUserProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(user.uid).update(updates);

      print('✅ User profile updated successfully');
      print('Updates: $updates');
    } catch (e) {
      print('❌ Error updating user profile: $e');
    }
  }

  /// Get current user data
  static Future<void> printCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        print('✅ Current user data:');
        print(doc.data());
      } else {
        print('❌ User document does not exist');
      }
    } catch (e) {
      print('❌ Error getting user data: $e');
    }
  }

  /// Get notification count
  static Future<void> printNotificationCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      final unreadSnapshot = await _firestore
          .collection('users/${user.uid}/notifications')
          .where('read', isEqualTo: false)
          .get();

      final totalSnapshot = await _firestore
          .collection('users/${user.uid}/notifications')
          .get();

      print('✅ Notification count:');
      print('Unread: ${unreadSnapshot.docs.length}');
      print('Total: ${totalSnapshot.docs.length}');
    } catch (e) {
      print('❌ Error getting notification count: $e');
    }
  }
}
