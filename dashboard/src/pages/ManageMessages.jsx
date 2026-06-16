import React, { useEffect, useState, useRef } from 'react';
import { useAuth } from '../App';
import { db } from '../firebase';
import { 
  collection, 
  query, 
  where, 
  orderBy, 
  onSnapshot, 
  addDoc, 
  updateDoc, 
  doc, 
  setDoc,
  serverTimestamp,
  increment
} from 'firebase/firestore';
import { 
  Send, 
  MessageSquare, 
  Calendar, 
  User, 
  Lock, 
  Check, 
  Search, 
  AlertCircle 
} from 'lucide-react';

export default function ManageMessages() {
  const { user } = useAuth();
  const [chats, setChats] = useState([]);
  const [activeChat, setActiveChat] = useState(null);
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState('');
  const [slots, setSlots] = useState([]);
  const [loadingChats, setLoadingChats] = useState(true);
  const [loadingMessages, setLoadingMessages] = useState(false);
  const messagesEndRef = useRef(null);

  // 1. Fetch barber's chat list in real-time
  useEffect(() => {
    if (!user) return;

    const chatsQuery = query(
      collection(db, 'chats'),
      where('barberId', '==', user.uid)
    );

    const unsubscribe = onSnapshot(chatsQuery, (snapshot) => {
      const list = [];
      snapshot.forEach(docSnap => {
        list.push({ id: docSnap.id, ...docSnap.data() });
      });
      // Sort client-side to avoid Firestore index requirement
      list.sort((a, b) => {
        const aTime = a.lastMessageTime?.toDate ? a.lastMessageTime.toDate() : new Date(a.lastMessageTime || 0);
        const bTime = b.lastMessageTime?.toDate ? b.lastMessageTime.toDate() : new Date(b.lastMessageTime || 0);
        return bTime - aTime;
      });
      setChats(list);
      setLoadingChats(false);
    }, (err) => {
      console.error("Error fetching chats:", err);
      setLoadingChats(false);
    });

    return () => unsubscribe();
  }, [user]);

  // 2. Fetch available slots of the barber in real-time
  useEffect(() => {
    if (!user) return;

    const slotsQuery = query(
      collection(db, 'appointments'),
      where('barberId', '==', user.uid),
      where('status', '==', 'available')
    );

    const unsubscribe = onSnapshot(slotsQuery, (snapshot) => {
      const list = [];
      snapshot.forEach(docSnap => {
        list.push({ id: docSnap.id, ...docSnap.data() });
      });
      // Sort slots by dateTime
      list.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));
      setSlots(list);
    });

    return () => unsubscribe();
  }, [user]);

  // 3. Listen to messages for the active chat
  useEffect(() => {
    if (!activeChat) {
      setMessages([]);
      return;
    }

    setLoadingMessages(true);
    const messagesQuery = query(
      collection(db, 'chats', activeChat.id, 'messages'),
      orderBy('timestamp', 'asc')
    );

    const unsubscribe = onSnapshot(messagesQuery, (snapshot) => {
      const list = [];
      snapshot.forEach(docSnap => {
        list.push({ id: docSnap.id, ...docSnap.data() });
      });
      setMessages(list);
      setLoadingMessages(false);
      
      // Mark as read
      updateDoc(doc(db, 'chats', activeChat.id), {
        unreadByBarber: 0
      }).catch(err => console.error("Error clearing unread:", err));

    }, (err) => {
      console.error("Error fetching messages:", err);
      setLoadingMessages(false);
    });

    return () => unsubscribe();
  }, [activeChat]);

  // Auto-scroll to bottom when messages load
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!text.trim() || !activeChat) return;

    const textMsg = text.trim();
    setText('');

    try {
      const messageData = {
        senderId: user.uid,
        senderName: activeChat.barberName || 'Barber',
        message: textMsg,
        timestamp: serverTimestamp(),
        type: 'text'
      };

      // Set last message in chat document
      await setDoc(doc(db, 'chats', activeChat.id), {
        lastMessage: textMsg,
        lastMessageTime: serverTimestamp(),
        unreadByCustomer: increment(1)
      }, { merge: true });

      // Add to messages subcollection
      await addDoc(collection(db, 'chats', activeChat.id, 'messages'), messageData);

    } catch (err) {
      console.error("Error sending message:", err);
    }
  };

  const handleCloseSlot = async (slotId) => {
    const customerName = window.prompt('أدخل اسم العميل للحجز اليدوي (اختياري - اتركه فارغاً للإغلاق فقط):');
    if (customerName === null) return;

    try {
      if (customerName.trim()) {
        await updateDoc(doc(db, 'appointments', slotId), {
          status: 'booked',
          customerName: customerName.trim(),
          customerPhone: 'حجز يدوي',
          serviceName: 'حجز يدوي من الداش بورد',
          price: 0,
          updatedAt: new Date().toISOString()
        });

        // If active chat exists, send a booking message in the chat!
        if (activeChat) {
          const systemMsg = `📅 تم حجز موعد يدوي للعميل: ${customerName.trim()}`;
          
          await setDoc(doc(db, 'chats', activeChat.id), {
            lastMessage: '📅 تم حجز موعد يدوي',
            lastMessageTime: serverTimestamp(),
            unreadByCustomer: increment(1)
          }, { merge: true });

          await addDoc(collection(db, 'chats', activeChat.id, 'messages'), {
            senderId: 'system',
            senderName: 'System',
            message: systemMsg,
            timestamp: serverTimestamp(),
            type: 'system_booking'
          });
        }
      } else {
        await updateDoc(doc(db, 'appointments', slotId), {
          status: 'cancelled',
          customerName: 'ملغي (مغلق من الصالون)',
          updatedAt: new Date().toISOString()
        });
      }
    } catch (err) {
      alert('خطأ أثناء إغلاق الموعد: ' + err.message);
    }
  };

  const formatTime = (timestamp) => {
    if (!timestamp) return '';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const formatSlotDateTime = (dateTimeStr) => {
    if (!dateTimeStr) return '';
    const [d, t] = dateTimeStr.split('T');
    return `${d} • ${t ? t.substring(0, 5) : ''}`;
  };

  return (
    <div className="animate-fade-in h-[calc(100vh-4rem)] flex flex-col">
      {/* AppBar-style Header */}
      <div className="flex items-center justify-center bg-charcoal-950 border-b border-charcoal-800 px-6 py-4 shrink-0">
        <h1 className="text-lg font-bold text-white tracking-wide">Messages</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 flex-1 overflow-hidden min-h-0 p-6">
        
        {/* RIGHT PANE: Chat List */}
        <div className="lg:col-span-4 glass-panel border border-charcoal-800 rounded-2xl flex flex-col overflow-hidden bg-charcoal-900/40">
          <div className="p-4 border-b border-charcoal-800 bg-charcoal-950/20">
            <h3 className="text-md font-bold text-white mb-3 flex items-center gap-2">
              <MessageSquare className="w-5 h-5 text-gold-500" />
              <span>قائمة المحادثات</span>
            </h3>
          </div>

          <div className="flex-1 overflow-y-auto divide-y divide-charcoal-800/40">
            {loadingChats ? (
              <div className="h-full flex items-center justify-center py-20">
                <div className="w-8 h-8 border-2 border-gold-500 border-t-transparent rounded-full animate-spin"></div>
              </div>
            ) : chats.length > 0 ? (
              chats.map((chat) => {
                const isActive = activeChat?.id === chat.id;
                const unread = chat.unreadByBarber || 0;
                return (
                  <button
                    key={chat.id}
                    onClick={() => setActiveChat(chat)}
                    className={`w-full text-right p-4 transition-all flex items-start gap-3 hover:bg-charcoal-800/40 ${
                      isActive ? 'bg-gradient-to-l from-gold-500/10 to-gold-500/5 text-gold-400 border-r-4 border-gold-500' : ''
                    }`}
                  >
                    <div className="w-10 h-10 rounded-xl bg-charcoal-800 border border-charcoal-700 flex items-center justify-center text-charcoal-400 font-bold shrink-0">
                      <User className="w-5 h-5" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex justify-between items-center">
                        <span className="font-bold text-white truncate text-sm">{chat.customerName}</span>
                        {chat.lastMessageTime && (
                          <span className="text-[10px] text-charcoal-500 font-inter">
                            {formatTime(chat.lastMessageTime)}
                          </span>
                        )}
                      </div>
                      <p className="text-xs text-charcoal-400 truncate mt-1">{chat.lastMessage}</p>
                    </div>
                    {unread > 0 && (
                      <span className="bg-gold-500 text-charcoal-950 font-black text-[10px] px-1.5 py-0.5 rounded-full shrink-0">
                        {unread}
                      </span>
                    )}
                  </button>
                );
              })
            ) : (
              <div className="text-center py-20 text-charcoal-500 text-sm">
                لا توجد محادثات نشطة حالياً
              </div>
            )}
          </div>
        </div>

        {/* CENTER PANE: Chat Messages */}
        <div className="lg:col-span-5 glass-panel border border-charcoal-800 rounded-2xl flex flex-col overflow-hidden bg-charcoal-950/20">
          {activeChat ? (
            <>
              {/* Chat Header */}
              <div className="p-4 border-b border-charcoal-800 bg-charcoal-900/60 flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-charcoal-800 flex items-center justify-center text-gold-500 shrink-0 font-bold border border-charcoal-700">
                  {activeChat.customerName.charAt(0).toUpperCase()}
                </div>
                <div>
                  <h4 className="font-bold text-white text-sm">{activeChat.customerName}</h4>
                  <p className="text-[10px] text-green-400 flex items-center gap-1 mt-0.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-green-400"></span>
                    <span>نشط الآن</span>
                  </p>
                </div>
              </div>

              {/* Message List */}
              <div className="flex-1 overflow-y-auto p-4 space-y-4">
                {loadingMessages ? (
                  <div className="h-full flex items-center justify-center">
                    <div className="w-6 h-6 border-2 border-gold-500 border-t-transparent rounded-full animate-spin"></div>
                  </div>
                ) : messages.length > 0 ? (
                  messages.map((msg) => {
                    const isSystem = msg.senderId === 'system';
                    const isMe = msg.senderId === user.uid;

                    if (isSystem) {
                      return (
                        <div key={msg.id} className="flex justify-center my-2">
                          <div className="bg-green-950/30 border border-green-900/40 text-green-300 text-xs px-4 py-2 rounded-xl text-center">
                            {msg.message}
                          </div>
                        </div>
                      );
                    }

                    return (
                      <div
                        key={msg.id}
                        className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}
                      >
                        <div
                          className={`max-w-[80%] rounded-2xl px-4 py-2.5 text-sm ${
                            isMe
                              ? 'bg-gradient-to-tr from-gold-600 to-gold-500 text-charcoal-950 font-medium rounded-br-none'
                              : 'bg-charcoal-900 text-white border border-charcoal-800 rounded-bl-none'
                          }`}
                        >
                          <p className="leading-relaxed">{msg.message}</p>
                          <span className="block text-[9px] text-right mt-1 opacity-70 font-inter">
                            {formatTime(msg.timestamp)}
                          </span>
                        </div>
                      </div>
                    );
                  })
                ) : (
                  <div className="text-center py-20 text-charcoal-600 text-sm">
                    ابدأ التراسل، أرسل رسالة ترحيبية للعميل
                  </div>
                )}
                <div ref={messagesEndRef} />
              </div>

              {/* Message Input */}
              <form onSubmit={handleSendMessage} className="p-4 border-t border-charcoal-800 bg-charcoal-900/60 flex items-center gap-3">
                <input
                  type="text"
                  value={text}
                  onChange={(e) => setText(e.target.value)}
                  placeholder="اكتب رسالة..."
                  className="flex-1 px-4 py-3 bg-charcoal-950 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500"
                />
                <button
                  type="submit"
                  className="p-3 bg-gradient-to-l from-gold-500 to-gold-400 hover:from-gold-600 hover:to-gold-500 text-charcoal-950 rounded-xl transition-all shadow-md active:scale-95"
                >
                  <Send className="w-4 h-4" />
                </button>
              </form>
            </>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center text-charcoal-500 py-20">
              <MessageSquare className="w-16 h-16 text-charcoal-800 mb-4" />
              <p className="text-sm">اختر محادثة من القائمة الجانبية لبدء التراسل</p>
            </div>
          )}
        </div>

        {/* LEFT PANE: Quick Slot Management */}
        <div className="lg:col-span-3 glass-panel border border-charcoal-800 rounded-2xl flex flex-col overflow-hidden bg-charcoal-900/40">
          <div className="p-4 border-b border-charcoal-800 bg-charcoal-950/20">
            <h3 className="text-md font-bold text-white flex items-center gap-2">
              <Calendar className="w-5 h-5 text-gold-500" />
              <span>إغلاق موعد متاح</span>
            </h3>
            <p className="text-[10px] text-charcoal-400 mt-1 font-medium">احجز أو أغلق الموعد مباشرة أثناء المحادثة</p>
          </div>

          <div className="flex-1 overflow-y-auto p-4 space-y-3">
            {slots.length > 0 ? (
              slots.map((slot) => (
                <div key={slot.id} className="p-3.5 rounded-xl bg-charcoal-950/50 border border-charcoal-800/80 flex flex-col justify-between gap-3">
                  <div>
                    <span className="text-[10px] font-bold text-gold-500 bg-gold-500/10 px-2 py-0.5 rounded-full">متاح للجميع</span>
                    <div className="text-xs font-bold text-white font-inter mt-2">
                      {formatSlotDateTime(slot.dateTime)}
                    </div>
                  </div>
                  <button
                    onClick={() => handleCloseSlot(slot.id)}
                    className="w-full flex items-center justify-center gap-1.5 py-2 px-3 bg-charcoal-900 hover:bg-gold-500 text-charcoal-400 hover:text-charcoal-950 border border-charcoal-800 hover:border-gold-500 font-bold rounded-lg text-xs transition-all active:scale-98"
                  >
                    <Lock className="w-3.5 h-3.5" />
                    <span>إغلاق الموعد / حجز يدوي</span>
                  </button>
                </div>
              ))
            ) : (
              <div className="text-center py-12 text-charcoal-600 text-xs">
                لا توجد مواعيد متاحة حالياً لجدولتها
              </div>
            )}
          </div>
        </div>

      </div>
    </div>
  );
}
