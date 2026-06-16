import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/chat/presentation/views/chat_room_view.dart';

class ChatsListView extends StatefulWidget {
  const ChatsListView({super.key});

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  final Map<String, Future<Map<String, dynamic>>> _barberCache = {};

  Future<Map<String, dynamic>> _getBarber(String? barberId) {
    if (barberId == null || barberId.isEmpty) return Future.value({});
    return _barberCache.putIfAbsent(barberId, () async {
      final doc = await FirebaseFirestore.instance.collection('users').doc(barberId).get();
      return doc.data() ?? {};
    });
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return intl.DateFormat('hh:mm a').format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return intl.DateFormat('MMM dd').format(date);
    }
  }

  Widget _buildInfoState({
    required IconData icon,
    required String title,
    required String message,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40.w,
                color: (color ?? AppColors.primary).withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: color ?? AppColors.textDark,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textGrey,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          title: const Text(
            'Bookings',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            Expanded(child: _buildInfoState(
              icon: Icons.lock_outline_rounded,
              title: 'Sign in required',
              message: 'Sign in to view and manage your chats with barbers.',
            )),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('customerId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildInfoState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load chats',
              message: snapshot.error.toString(),
              color: AppColors.dangerRed,
            );
          }

          final chatDocs = snapshot.data?.docs ?? [];
          if (chatDocs.isEmpty) {
            return _buildInfoState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No chats yet',
              message: 'Select an available appointment slot to start chatting with a barber.',
            );
          }

          // Sort client-side to avoid Firestore index requirement
          final sortedDocs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(chatDocs);
          sortedDocs.sort((a, b) {
            final aTime = a.data()['lastMessageTime'] as Timestamp?;
            final bTime = b.data()['lastMessageTime'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // descending order
          });

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: sortedDocs.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final chatData = sortedDocs[index].data();
              final chatId = sortedDocs[index].id;
              final barberId = chatData['barberId'] ?? '';
              final lastMessage = chatData['lastMessage'] ?? 'No messages yet';
              final lastTime = chatData['lastMessageTime'] as Timestamp?;
              final unreadCount = chatData['unreadByCustomer'] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.borderGrey.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FutureBuilder<Map<String, dynamic>>(
                              future: _getBarber(barberId),
                              builder: (context, snapshot) {
                                final barberData = snapshot.data ?? {};
                                final salonName = barberData['salonName'] as String?;
                                final displayName = salonName ?? barberData['name'] as String? ?? 'Barber Stylist';
                                
                                return ChatRoomView(
                                  chatId: chatId,
                                  barberId: barberId,
                                  barberName: displayName,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      leading: Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 24.w,
                        ),
                      ),
                      title: FutureBuilder<Map<String, dynamic>>(
                        future: _getBarber(barberId),
                        builder: (context, snapshot) {
                          final barberData = snapshot.data ?? {};
                          final salonName = barberData['salonName'] as String?;
                          final displayName = salonName ?? barberData['name'] as String? ?? 'Barber Stylist';
                          
                          return Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          );
                        },
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textGrey,
                            fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDateTime(lastTime),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
          ),
        ],
      ),
    );
  }
}
