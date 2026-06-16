import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/chat/presentation/widgets/chat_input_field.dart';

class ChatRoomView extends StatefulWidget {
  static const String routeName = '/chat-room';

  final String? chatId;
  final String barberId;
  final String barberName;
  final Map<String, dynamic>? slotDetails;

  const ChatRoomView({
    super.key,
    this.chatId,
    required this.barberId,
    required this.barberName,
    this.slotDetails,
  });

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _chatId;
  bool _isBooking = false;
  Map<String, dynamic>? _currentSlot;

  @override
  void initState() {
    super.initState();
    final customerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _chatId = widget.chatId ?? '${customerId}_${widget.barberId}';
    _currentSlot = widget.slotDetails;
    _markAsRead();
  }

  void _markAsRead() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .update({'unreadByCustomer': 0})
        .catchError((_) {});
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return intl.DateFormat('hh:mm a').format(timestamp.toDate());
  }

  String _formatSlotDate(String? value) {
    if (value == null || value.isEmpty) return 'Not scheduled';
    try {
      final date = DateTime.parse(value);
      return intl.DateFormat('MMMM dd, yyyy').format(date);
    } catch (_) {
      return value.split('T').first;
    }
  }

  String _formatSlotTime(String? value) {
    if (value == null || value.isEmpty) return '--:--';
    try {
      final date = DateTime.parse(value);
      return intl.DateFormat('hh:mm a').format(date);
    } catch (_) {
      final parts = value.split('T');
      return parts.length > 1 ? parts[1].substring(0, 5) : value;
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final customerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Fetch sender profile name
    String senderName = 'Client';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .get();
      if (userDoc.exists) {
        senderName = userDoc.data()?['name'] ?? 'Client';
      }
    } catch (_) {}

    final timestamp = FieldValue.serverTimestamp();

    // Ensure chat doc exists
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'customerId': customerId,
      'customerName': senderName,
      'barberId': widget.barberId,
      'barberName': widget.barberName,
      'lastMessage': text,
      'lastMessageTime': timestamp,
      'unreadByBarber': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // Send Message
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
          'senderId': customerId,
          'senderName': senderName,
          'message': text,
          'timestamp': timestamp,
          'type': 'text',
        });

    _scrollToBottom();
  }

  Future<void> _bookSlot() async {
    if (_currentSlot == null) return;
    setState(() => _isBooking = true);

    try {
      final customerId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Fetch user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .get();
      final userData = userDoc.data() ?? {};
      final customerName =
          userData['name'] ??
          FirebaseAuth.instance.currentUser?.displayName ??
          'Customer';
      final customerPhone =
          userData['phoneNumber'] ??
          FirebaseAuth.instance.currentUser?.phoneNumber ??
          '';

      final slotId = _currentSlot!['id'] ?? '';
      final slotTimeStr = _currentSlot!['dateTime'] ?? '';

      // Update appointment status to booked
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(slotId)
          .update({
            'status': 'booked',
            'customerId': customerId,
            'customerName': customerName,
            'customerPhone': customerPhone,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Post System message in chat
      final dateStr = _formatSlotDate(slotTimeStr);
      final timeStr = _formatSlotTime(slotTimeStr);
      final systemMessage = '📅 تم حجز الموعد بنجاح: $dateStr الساعة $timeStr';

      await FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
        'customerId': customerId,
        'customerName': customerName,
        'barberId': widget.barberId,
        'barberName': widget.barberName,
        'lastMessage': '📅 تم حجز الموعد بنجاح',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadByBarber': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add({
            'senderId': 'system',
            'senderName': 'System',
            'message': systemMessage,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'system_booking',
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حجز الموعد بنجاح!',
            style: TextStyle(fontFamily: 'Outfit'),
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );

      setState(() {
        _currentSlot = null; // hide active slot banner
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء الحجز: $e',
            style: const TextStyle(fontFamily: 'Outfit'),
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    } finally {
      setState(() => _isBooking = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.barberName,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Professional Barber',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Available slot booking banner
          if (_currentSlot != null) _buildSlotBookingBanner(),

          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                // Trigger scroll to bottom on load/update
                _scrollToBottom();

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 52.w,
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'ابدأ المحادثة الآن مع ${widget.barberName}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'أرسل رسالة للبدء',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textGrey.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData = messages[index].data();
                    final senderId = msgData['senderId'] ?? '';
                    final message = msgData['message'] ?? '';
                    final timestamp = msgData['timestamp'] as Timestamp?;
                    final isSystem = senderId == 'system';
                    final isMe = senderId == customerId;

                    if (isSystem) {
                      return _buildSystemMessage(message);
                    }

                    return _buildMessageBubble(message, isMe, timestamp);
                  },
                );
              },
            ),
          ),

          // Message input bar
          ChatInputField(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildSlotBookingBanner() {
    final dateStr = _formatSlotDate(_currentSlot!['dateTime']);
    final timeStr = _formatSlotTime(_currentSlot!['dateTime']);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: AppColors.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل ترغب في حجز هذا الموعد؟',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$dateStr • $timeStr',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _isBooking ? null : _bookSlot,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: _isBooking
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'احجز الآن',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFF1F8E9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFC8E6C9).withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, Timestamp? timestamp) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 0.72.sw),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMe ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomLeft: isMe ? Radius.circular(20.r) : Radius.circular(6.r),
                bottomRight: isMe
                    ? Radius.circular(6.r)
                    : Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: isMe
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isMe ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: isMe
                  ? null
                  : Border.all(
                      color: AppColors.borderGrey.withOpacity(0.6),
                      width: 1,
                    ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: isMe ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
                height: 1.4,
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatTime(timestamp),
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
