import { useEffect, useState, useRef } from 'react';
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
  Lock, 
  Clock,
  Sparkles
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
      return;
    }

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

  const totalUnread = chats.reduce((sum, chat) => sum + Number(chat.unreadByBarber || 0), 0);
  const activeInitial = activeChat?.customerName?.charAt(0)?.toUpperCase() || 'U';

  return (
    <div className="animate-fade-in h-auto min-h-[calc(100vh-4rem)] lg:h-[calc(100vh-4rem)] flex flex-col overflow-hidden">
      <div className="shrink-0 rounded-[28px] border border-gold-500/10 bg-gradient-to-br from-charcoal-900 via-charcoal-950 to-black p-4 sm:p-6 shadow-2xl shadow-black/30">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <div className="mb-3 inline-flex items-center gap-2 rounded-full border border-gold-500/20 bg-gold-500/10 px-3 py-1 text-xs font-bold text-gold-300">
              <Sparkles className="h-3.5 w-3.5" />
              <span>مركز التواصل</span>
            </div>
            <h1 className="text-2xl font-black tracking-tight text-white sm:text-3xl">Messages</h1>
            <p className="mt-2 max-w-2xl text-sm leading-6 text-charcoal-400">
              تابع محادثات العملاء، رد بسرعة، واقفل المواعيد المتاحة من نفس الشاشة.
            </p>
          </div>

          <div className="grid grid-cols-3 gap-2 sm:gap-3 lg:min-w-[360px]">
            <div className="rounded-2xl border border-charcoal-800 bg-black/30 p-3 text-center">
              <div className="text-xl font-black text-white">{chats.length}</div>
              <div className="mt-1 text-[10px] font-bold text-charcoal-500">محادثات</div>
            </div>
            <div className="rounded-2xl border border-charcoal-800 bg-black/30 p-3 text-center">
              <div className="text-xl font-black text-gold-400">{totalUnread}</div>
              <div className="mt-1 text-[10px] font-bold text-charcoal-500">غير مقروء</div>
            </div>
            <div className="rounded-2xl border border-charcoal-800 bg-black/30 p-3 text-center">
              <div className="text-xl font-black text-white">{slots.length}</div>
              <div className="mt-1 text-[10px] font-bold text-charcoal-500">مواعيد متاحة</div>
            </div>
          </div>
        </div>
      </div>

      <div className="grid flex-1 grid-cols-1 gap-4 overflow-visible py-4 lg:min-h-0 lg:grid-cols-12 lg:overflow-hidden">
        <aside className="glass-panel order-1 flex min-h-[320px] flex-col overflow-hidden rounded-[28px] border border-charcoal-800 bg-charcoal-900/60 lg:col-span-4 lg:min-h-0">
          <div className="shrink-0 border-b border-charcoal-800/80 p-4 sm:p-5">
            <div className="flex items-center justify-between gap-3">
              <h2 className="flex items-center gap-2 text-base font-black text-white">
                <MessageSquare className="h-5 w-5 text-gold-500" />
                <span>قائمة المحادثات</span>
              </h2>
              {totalUnread > 0 && (
                <span className="rounded-full bg-gold-500 px-2.5 py-1 text-xs font-black text-charcoal-950">
                  {totalUnread} جديد
                </span>
              )}
            </div>
            <p className="mt-2 text-xs font-medium text-charcoal-500">اختار عميل لعرض المحادثة كاملة.</p>
          </div>

          <div className="flex-1 space-y-3 overflow-y-auto p-3 sm:p-4">
            {loadingChats ? (
              <div className="flex h-48 items-center justify-center">
                <div className="h-8 w-8 animate-spin rounded-full border-2 border-gold-500 border-t-transparent"></div>
              </div>
            ) : chats.length > 0 ? (
              chats.map((chat) => {
                const isActive = activeChat?.id === chat.id;
                const unread = chat.unreadByBarber || 0;
                const initial = chat.customerName?.charAt(0)?.toUpperCase() || 'U';

                return (
                  <button
                    key={chat.id}
                    onClick={() => {
                      setLoadingMessages(true);
                      setActiveChat(chat);
                    }}
                    className={`group w-full rounded-2xl border p-4 text-right transition-all ${
                      isActive
                        ? 'border-gold-500/60 bg-gradient-to-l from-gold-500/15 to-charcoal-900 shadow-lg shadow-gold-950/20'
                        : 'border-charcoal-800 bg-charcoal-950/70 hover:border-gold-500/30 hover:bg-charcoal-900'
                    }`}
                  >
                    <div className="flex items-start gap-3">
                      <div className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl border font-black ${
                        isActive
                          ? 'border-gold-500/40 bg-gold-500 text-charcoal-950'
                          : 'border-charcoal-700 bg-charcoal-900 text-gold-400'
                      }`}>
                        {initial}
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center justify-between gap-3">
                          <span className="truncate text-sm font-black text-white">{chat.customerName || 'عميل بدون اسم'}</span>
                          {chat.lastMessageTime && (
                            <span className="shrink-0 text-[11px] font-semibold text-charcoal-500">
                              {formatTime(chat.lastMessageTime)}
                            </span>
                          )}
                        </div>
                        <p className="mt-1 truncate text-xs leading-5 text-charcoal-400">{chat.lastMessage || 'لا توجد رسائل بعد'}</p>
                      </div>
                      {unread > 0 && (
                        <span className="shrink-0 rounded-full bg-gold-500 px-2 py-0.5 text-[10px] font-black text-charcoal-950">
                          {unread}
                        </span>
                      )}
                    </div>
                  </button>
                );
              })
            ) : (
              <div className="flex h-48 flex-col items-center justify-center rounded-2xl border border-dashed border-charcoal-800 text-center text-sm text-charcoal-500">
                <MessageSquare className="mb-3 h-8 w-8 text-charcoal-700" />
                لا توجد محادثات نشطة حالياً
              </div>
            )}
          </div>
        </aside>

        <section className="glass-panel order-2 flex min-h-[560px] flex-col overflow-hidden rounded-[28px] border border-charcoal-800 bg-charcoal-950/70 lg:col-span-5 lg:min-h-0">
          {activeChat ? (
            <>
              <div className="shrink-0 border-b border-charcoal-800 bg-charcoal-900/80 p-4 sm:p-5">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl border border-gold-500/30 bg-gold-500/15 text-lg font-black text-gold-300">
                    {activeInitial}
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="truncate text-base font-black text-white">{activeChat.customerName || 'عميل بدون اسم'}</h3>
                    <p className="mt-1 flex items-center gap-2 text-xs font-bold text-green-400">
                      <span className="h-2 w-2 rounded-full bg-green-400 shadow-[0_0_12px_rgba(74,222,128,0.8)]"></span>
                      جاهز للرد والمتابعة
                    </p>
                  </div>
                </div>
              </div>

              <div className="flex-1 space-y-4 overflow-y-auto bg-[radial-gradient(circle_at_top_right,rgba(212,162,63,0.08),transparent_35%)] p-4 sm:p-5">
                {loadingMessages ? (
                  <div className="flex h-full items-center justify-center">
                    <div className="h-7 w-7 animate-spin rounded-full border-2 border-gold-500 border-t-transparent"></div>
                  </div>
                ) : messages.length > 0 ? (
                  messages.map((msg) => {
                    const isSystem = msg.senderId === 'system';
                    const isMe = msg.senderId === user.uid;

                    if (isSystem) {
                      return (
                        <div key={msg.id} className="flex justify-center">
                          <div className="max-w-[90%] rounded-2xl border border-green-500/20 bg-green-500/10 px-4 py-2 text-center text-xs font-bold leading-5 text-green-300">
                            {msg.message}
                          </div>
                        </div>
                      );
                    }

                    return (
                      <div key={msg.id} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                        <div className={`max-w-[86%] rounded-3xl px-4 py-3 text-sm leading-6 shadow-lg sm:max-w-[78%] ${
                          isMe
                            ? 'rounded-br-md bg-gradient-to-br from-gold-400 to-gold-600 font-bold text-charcoal-950 shadow-gold-950/30'
                            : 'rounded-bl-md border border-charcoal-800 bg-charcoal-900 text-charcoal-100 shadow-black/20'
                        }`}>
                          <p className="whitespace-pre-wrap break-words">{msg.message}</p>
                          <span className={`mt-1 block text-[10px] font-semibold ${isMe ? 'text-charcoal-800/70' : 'text-charcoal-500'}`}>
                            {formatTime(msg.timestamp)}
                          </span>
                        </div>
                      </div>
                    );
                  })
                ) : (
                  <div className="flex h-full flex-col items-center justify-center text-center text-charcoal-500">
                    <MessageSquare className="mb-4 h-14 w-14 text-charcoal-800" />
                    <p className="text-sm font-bold text-charcoal-400">ابدأ المحادثة برسالة واضحة للعميل</p>
                    <p className="mt-2 text-xs">الرسائل الجديدة ستظهر هنا مباشرة.</p>
                  </div>
                )}
                <div ref={messagesEndRef} />
              </div>

              <form onSubmit={handleSendMessage} className="shrink-0 border-t border-charcoal-800 bg-charcoal-900/90 p-3 sm:p-4">
                <div className="flex items-center gap-2 rounded-2xl border border-charcoal-800 bg-black/40 p-2 focus-within:border-gold-500/70 focus-within:ring-2 focus-within:ring-gold-500/10">
                  <input
                    type="text"
                    value={text}
                    onChange={(e) => setText(e.target.value)}
                    placeholder="اكتب رسالة واضحة للعميل..."
                    className="min-w-0 flex-1 bg-transparent px-3 py-2.5 text-sm text-white placeholder-charcoal-600 outline-none"
                  />
                  <button
                    type="submit"
                    disabled={!text.trim()}
                    className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-gold-400 to-gold-600 text-charcoal-950 shadow-lg shadow-gold-950/30 transition-all hover:scale-105 disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:scale-100"
                  >
                    <Send className="h-4 w-4" />
                  </button>
                </div>
              </form>
            </>
          ) : (
            <div className="flex flex-1 flex-col items-center justify-center p-8 text-center">
              <div className="mb-5 flex h-20 w-20 items-center justify-center rounded-[28px] border border-charcoal-800 bg-charcoal-900 text-gold-500">
                <MessageSquare className="h-9 w-9" />
              </div>
              <h3 className="text-lg font-black text-white">اختار محادثة</h3>
              <p className="mt-2 max-w-sm text-sm leading-6 text-charcoal-500">اختار عميل من قائمة المحادثات لعرض الرسائل والرد عليه بشكل مباشر.</p>
            </div>
          )}
        </section>

        <aside className="glass-panel order-3 flex min-h-[360px] flex-col overflow-hidden rounded-[28px] border border-charcoal-800 bg-charcoal-900/60 lg:col-span-3 lg:min-h-0">
          <div className="shrink-0 border-b border-charcoal-800/80 p-4 sm:p-5">
            <h2 className="flex items-center gap-2 text-base font-black text-white">
              <Calendar className="h-5 w-5 text-gold-500" />
              <span>إغلاق موعد متاح</span>
            </h2>
            <p className="mt-2 text-xs leading-5 text-charcoal-500">اقفل أو احجز موعد يدوي أثناء المحادثة بدون الخروج من الصفحة.</p>
          </div>

          <div className="flex-1 space-y-3 overflow-y-auto p-3 sm:p-4">
            {slots.length > 0 ? (
              slots.map((slot) => (
                <div key={slot.id} className="rounded-2xl border border-charcoal-800 bg-charcoal-950/70 p-4 transition-all hover:border-gold-500/30">
                  <div className="mb-3 flex items-center justify-between gap-3">
                    <span className="rounded-full bg-gold-500/10 px-2.5 py-1 text-[10px] font-black text-gold-400">متاح للجميع</span>
                    <Clock className="h-4 w-4 text-charcoal-600" />
                  </div>
                  <div className="mb-4 text-sm font-black text-white font-inter">
                    {formatSlotDateTime(slot.dateTime)}
                  </div>
                  <button
                    onClick={() => handleCloseSlot(slot.id)}
                    className="flex w-full items-center justify-center gap-2 rounded-xl border border-charcoal-800 bg-charcoal-900 px-3 py-2.5 text-xs font-black text-charcoal-300 transition-all hover:border-gold-500 hover:bg-gold-500 hover:text-charcoal-950"
                  >
                    <Lock className="h-4 w-4" />
                    <span>إغلاق الموعد / حجز يدوي</span>
                  </button>
                </div>
              ))
            ) : (
              <div className="flex h-48 flex-col items-center justify-center rounded-2xl border border-dashed border-charcoal-800 text-center text-xs text-charcoal-600">
                <Calendar className="mb-3 h-8 w-8 text-charcoal-700" />
                لا توجد مواعيد متاحة حالياً لجدولتها
              </div>
            )}
          </div>
        </aside>
      </div>
    </div>
  );
}
