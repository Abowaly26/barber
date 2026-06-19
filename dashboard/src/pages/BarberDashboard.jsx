import React, { useEffect, useRef, useState } from 'react';
import { Navigate, Routes, Route } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../App';
import { db } from '../firebase';
import { 
  collection, 
  getDoc,
  getDocs, 
  query, 
  where, 
  addDoc, 
  deleteDoc, 
  doc, 
  updateDoc, 
  onSnapshot 
} from 'firebase/firestore';
import { 
  Scissors, 
  Calendar, 
  Clock,
  DollarSign, 
  Plus,
  Trash2, 
  Check, 
  CheckCircle,
  X, 
  TrendingUp, 
  AlertCircle,
  Activity,
  FileText,
  Lock,
  Menu
} from 'lucide-react';
import ManageMessages from './ManageMessages';
import ManageStoreItems from './ManageStoreItems';

export default function BarberDashboard() {
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  return (
    <div className="flex bg-charcoal-950 min-h-screen">
      <Sidebar 
        isMobileOpen={isMobileSidebarOpen} 
        onMobileClose={() => setIsMobileSidebarOpen(false)} 
      />
      <main className="flex-1 p-4 lg:p-8 overflow-y-auto max-h-screen">
        {/* Mobile Header with Hamburger */}
        <div className="lg:hidden flex items-center justify-between mb-6">
          <button
            onClick={() => setIsMobileSidebarOpen(true)}
            className="p-2.5 rounded-xl bg-charcoal-900 border border-charcoal-800 text-charcoal-400 hover:text-white hover:border-charcoal-700 transition-all"
          >
            <Menu className="w-5 h-5" />
          </button>
          <div className="flex items-center gap-2">
            <div className="p-2 bg-gradient-to-tr from-gold-600 to-gold-400 rounded-lg text-charcoal-950">
              <Scissors className="w-4 h-4" />
            </div>
            <span className="font-bold text-white text-sm">منصة حلاقة</span>
          </div>
        </div>
        
        <Routes>
          <Route path="/" element={<BarberHome />} />
          <Route path="/store" element={<ManageStoreItems ownerScope="barber" />} />
          <Route path="/slots" element={<ManageSlots />} />
          <Route path="/bookings" element={<ManageBookings />} />
          <Route path="/messages" element={<ManageMessages />} />
          <Route path="*" element={<Navigate to="/barber" replace />} />
        </Routes>
      </main>
    </div>
  );
}

// 1. BARBER HOME SCREEN
function BarberHome() {
  const { user } = useAuth();
  const [stats, setStats] = useState({
    myBookings: 0,
    myRevenue: 0,
  });
  const [todaySchedule, setTodaySchedule] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!user) return;

    // Real-time listener for appointments (bookings) of this barber
    const appointmentsQuery = query(collection(db, 'appointments'), where('barberId', '==', user.uid));
    const unsubscribeAppointments = onSnapshot(appointmentsQuery, (snapshot) => {
      let revenue = 0;
      let bookingsCount = 0;
      const todayList = [];
      const todayDateStr = new Date().toISOString().split('T')[0];

      snapshot.forEach((docSnap) => {
        const data = docSnap.data();
        if (data.status !== 'available') {
          bookingsCount++;
          if (data.status === 'completed' || data.status === 'booked') {
            revenue += Number(data.price || 0);
          }

          // Filter today's schedule
          const apptDateStr = data.dateTime ? data.dateTime.split('T')[0] : '';
          if (apptDateStr === todayDateStr) {
            todayList.push({ id: docSnap.id, ...data });
          }
        }
      });

      // Sort today's schedule by time
      todayList.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));

      setStats(prev => ({
        ...prev,
        myBookings: bookingsCount,
        myRevenue: revenue
      }));
      setTodaySchedule(todayList);
      setLoading(false);
    }, (err) => {
      console.error("Error fetching appointments:", err);
      setError("حدث خطأ أثناء جلب البيانات: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

    return () => {
      unsubscribeAppointments();
    };
  }, [user]);

  if (error) {
    return (
      <div className="p-6 rounded-2xl bg-red-950/20 border border-red-900/40 text-red-200 text-sm flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
        <div>
          <h4 className="font-bold text-red-400 mb-1">فشل تحميل البيانات</h4>
          <p>{error}</p>
          <p className="mt-2 text-xs text-charcoal-400">تأكد من تفعيل صلاحيات القراءة والكتابة لكولكشن الـ appointments في قواعد حماية Firestore.</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="w-10 h-10 border-2 border-gold-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  const statCards = [
    { title: 'حجوزاتي المؤكدة', value: stats.myBookings, icon: Calendar, color: 'from-blue-500/10 to-blue-600/5', iconColor: 'text-blue-400' },
    { title: 'إجمالي أرباحي', value: `${stats.myRevenue} ج.م`, icon: DollarSign, color: 'from-gold-500/10 to-gold-600/5', iconColor: 'text-gold-400' },
  ];

  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-black text-white">الرئيسية والإحصائيات</h1>
        <p className="text-charcoal-400 mt-1 text-sm">متابعة إيراداتك ومواعيد حجوزاتك لليوم</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {statCards.map((card, idx) => {
          const Icon = card.icon;
          return (
            <div key={idx} className={`glass-panel bg-gradient-to-tr ${card.color} p-6 rounded-2xl border border-charcoal-800`}>
              <div className="flex items-center justify-between">
                <div>
                  <span className="text-xs font-semibold text-charcoal-400">{card.title}</span>
                  <h3 className="text-2xl font-bold text-white mt-2 font-inter">{card.value}</h3>
                </div>
                <div className={`p-3 rounded-xl bg-charcoal-900 border border-charcoal-800 ${card.iconColor}`}>
                  <Icon className="w-6 h-6" />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Today Schedule Timeline */}
      <div className="glass-panel p-6 rounded-2xl border border-charcoal-800">
        <h3 className="text-lg font-bold text-white mb-6">جدول مواعيد اليوم</h3>
        <div className="relative border-r border-charcoal-800 mr-4 pr-6 space-y-6">
          {todaySchedule.length > 0 ? (
            todaySchedule.map((appt) => (
              <div key={appt.id} className="relative">
                {/* Dot */}
                <div className={`absolute top-1.5 right-[-29px] w-2.5 h-2.5 rounded-full border-2 ${
                  appt.status === 'completed' ? 'bg-green-500 border-green-500' :
                  appt.status === 'booked' ? 'bg-blue-500 border-blue-500' : 'bg-charcoal-600 border-charcoal-600'
                }`}></div>
                {/* Content */}
                <div className="p-4 rounded-xl bg-charcoal-900/60 border border-charcoal-800 max-w-xl flex items-center justify-between">
                  <div>
                    <span className="text-xs text-gold-500 font-bold font-inter">{appt.dateTime?.split('T')[1].substring(0, 5)}</span>
                    <h4 className="text-sm font-bold text-white mt-1">{appt.customerName}</h4>
                    <p className="text-xs text-charcoal-400 mt-0.5">{appt.serviceName} - {appt.price} ج.م</p>
                  </div>
                  <span className={`px-2.5 py-1 text-[10px] font-bold rounded-full ${
                    appt.status === 'completed' ? 'bg-green-500/10 text-green-400' :
                    appt.status === 'booked' ? 'bg-blue-500/10 text-blue-400' : 'bg-red-500/10 text-red-400'
                  }`}>
                    {appt.status === 'completed' ? 'مكتمل' :
                     appt.status === 'booked' ? 'مؤكد' : 'ملغي'}
                  </span>
                </div>
              </div>
            ))
          ) : (
            <div className="text-charcoal-500 text-sm py-8 mr-[-10px]">
              لا توجد مواعيد محجوزة لليوم
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// 2. MANAGE SLOTS (WORKING HOURS) SCREEN
function ManageSlots() {
  const { user } = useAuth();
  const dateInputRef = useRef(null);
  const startTimeInputRef = useRef(null);
  const endTimeInputRef = useRef(null);
  const [slots, setSlots] = useState([]);
  const [selectedDateFilter, setSelectedDateFilter] = useState('all');
  const [selectedSlotIds, setSelectedSlotIds] = useState([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState(null);

  // Form Fields
  const [date, setDate] = useState('');
  const [startTime, setStartTime] = useState('10:00');
  const [endTime, setEndTime] = useState('22:00');
  const [duration, setDuration] = useState('30');
  const [error, setError] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  useEffect(() => {
    if (!user) return;

    // Fetch all available slots
    const q = query(
      collection(db, 'appointments'), 
      where('barberId', '==', user.uid),
      where('status', '==', 'available')
    );
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = [];
      snapshot.forEach(docSnap => {
        list.push({ id: docSnap.id, ...docSnap.data() });
      });
      // Sort slots by dateTime
      list.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));
      setSlots(list);
      setSelectedSlotIds((current) => current.filter((id) => list.some((slot) => slot.id === id)));
      setLoading(false);
    }, (err) => {
      console.error("Error fetching slots:", err);
      setFetchError("حدث خطأ أثناء تحميل مواعيد الحجوزات: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user]);

  const handleGenerateSlots = async (e) => {
    e.preventDefault();
    if (!date || !startTime || !endTime || !duration) {
      setError('الرجاء تعبئة جميع الحقول');
      return;
    }

    try {
      setError('');
      setSuccessMsg('');
      const barberDoc = await getDoc(doc(db, 'users', user.uid));
      const barberData = barberDoc.exists() ? barberDoc.data() : {};

      const startSplit = startTime.split(':');
      const endSplit = endTime.split(':');
      let startMins = parseInt(startSplit[0]) * 60 + parseInt(startSplit[1]);
      let endMins = parseInt(endSplit[0]) * 60 + parseInt(endSplit[1]);
      const dur = parseInt(duration);

      if (endMins <= startMins) {
        setError('وقت الانتهاء يجب أن يكون بعد وقت البدء');
        return;
      }

      let addedCount = 0;
      let dupCount = 0;

      for (let m = startMins; m < endMins; m += dur) {
        const h = Math.floor(m / 60).toString().padStart(2, '0');
        const mins = (m % 60).toString().padStart(2, '0');
        const dateTimeStr = `${date}T${h}:${mins}:00`;

        const duplicate = slots.some(slot => slot.dateTime === dateTimeStr);
        if (duplicate) {
          dupCount++;
          continue;
        }

        await addDoc(collection(db, 'appointments'), {
          barberId: user.uid,
          barberName: barberData.name || user.email || '',
          barberAddress: barberData.address || '',
          dateTime: dateTimeStr,
          status: 'available',
          customerName: '',
          customerPhone: '',
          price: 0,
          createdAt: new Date().toISOString(),
        });
        addedCount++;
      }

      setSuccessMsg(`تم إضافة ${addedCount} موعد بنجاح! ${dupCount > 0 ? `(تم تجاهل ${dupCount} موعد مضاف مسبقاً)` : ''}`);
    } catch (err) {
      setError('حدث خطأ أثناء الإضافة: ' + err.message);
    }
  };

  const openNativePicker = (inputRef) => {
    const input = inputRef.current;
    if (!input) return;

    input.focus();
    if (typeof input.showPicker === 'function') {
      input.showPicker();
    }
  };

  const handleDeleteSlot = async (slotId) => {
    if (window.confirm('هل تريد حذف هذا الموعد المتاح؟')) {
      try {
        await deleteDoc(doc(db, 'appointments', slotId));
      } catch (err) {
        alert('خطأ أثناء الحذف: ' + err.message);
      }
    }
  };

  const slotDate = (slot) => slot.dateTime ? slot.dateTime.split('T')[0] : '';
  const availableDates = Array.from(new Set(slots.map(slotDate).filter(Boolean))).sort();
  const filteredSlots = selectedDateFilter === 'all'
    ? slots
    : slots.filter((slot) => slotDate(slot) === selectedDateFilter);
  const selectedSlots = slots.filter((slot) => selectedSlotIds.includes(slot.id));
  const allFilteredSelected = filteredSlots.length > 0 && filteredSlots.every((slot) => selectedSlotIds.includes(slot.id));

  const toggleSlotSelection = (slotId) => {
    setSelectedSlotIds((current) => current.includes(slotId)
      ? current.filter((id) => id !== slotId)
      : [...current, slotId]
    );
  };

  const toggleFilteredSelection = () => {
    setSelectedSlotIds((current) => {
      const filteredIds = filteredSlots.map((slot) => slot.id);
      if (filteredIds.length === 0) return current;

      if (filteredIds.every((id) => current.includes(id))) {
        return current.filter((id) => !filteredIds.includes(id));
      }

      return Array.from(new Set([...current, ...filteredIds]));
    });
  };

  const deleteSlotsByIds = async (slotIds, confirmMessage) => {
    if (slotIds.length === 0) return;
    if (!window.confirm(confirmMessage)) return;

    try {
      await Promise.all(slotIds.map((slotId) => deleteDoc(doc(db, 'appointments', slotId))));
      setSelectedSlotIds((current) => current.filter((id) => !slotIds.includes(id)));
    } catch (err) {
      alert('حدث خطأ أثناء حذف المواعيد: ' + err.message);
    }
  };

  const handleDeleteSelectedSlots = () => {
    deleteSlotsByIds(selectedSlotIds, `هل تريد حذف ${selectedSlotIds.length} موعد محدد؟`);
  };

  const handleDeleteFilteredDaySlots = () => {
    if (selectedDateFilter === 'all') {
      alert('اختار يوم محدد أولاً لحذف مواعيد اليوم فقط.');
      return;
    }

    deleteSlotsByIds(
      filteredSlots.map((slot) => slot.id),
      `هل تريد حذف كل مواعيد يوم ${selectedDateFilter}؟`
    );
  };

  const handleDeleteAllSlots = () => {
    deleteSlotsByIds(slots.map((slot) => slot.id), `هل تريد حذف كل المواعيد المتاحة (${slots.length})؟`);
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

  if (fetchError) {
    return (
      <div className="p-6 rounded-2xl bg-red-950/20 border border-red-900/40 text-red-200 text-sm flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
        <div>
          <h4 className="font-bold text-red-400 mb-1">فشل تحميل مواعيد الحجوزات</h4>
          <p>{fetchError}</p>
          <p className="mt-2 text-xs text-charcoal-400">تأكد من تفعيل صلاحيات القراءة والكتابة لكولكشن الـ appointments في قواعد حماية Firestore.</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="w-10 h-10 border-2 border-gold-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-black text-white">مواعيد الحجوزات</h1>
        <p className="text-charcoal-400 mt-1 text-sm font-medium">قم بإضافة الأوقات المتاحة لديك ليتمكن العملاء من حجزها عبر الموبايل</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Creator Panel */}
        <div className="glass-panel p-6 rounded-2xl border border-charcoal-800 h-fit">
          <h3 className="text-lg font-bold text-white mb-6">إضافة موعد متاح</h3>

          {error && (
            <div className="mb-4 p-3 rounded-lg bg-red-950/20 border border-red-900/40 text-red-200 text-xs flex items-start gap-2">
              <AlertCircle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          {successMsg && (
            <div className="mb-4 p-3 rounded-lg bg-green-950/20 border border-green-900/40 text-green-200 text-xs flex items-start gap-2">
              <CheckCircle className="w-4 h-4 text-green-400 shrink-0 mt-0.5" />
              <span>{successMsg}</span>
            </div>
          )}

          <form onSubmit={handleGenerateSlots} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-charcoal-300 mb-2">التاريخ *</label>
              <div className="relative group">
                <input
                  ref={dateInputRef}
                  type="date"
                  required
                  value={date}
                  onClick={() => openNativePicker(dateInputRef)}
                  onChange={(e) => setDate(e.target.value)}
                  min={new Date().toISOString().split('T')[0]}
                  className="w-full cursor-pointer px-4 pl-14 py-2.5 bg-charcoal-900 border border-charcoal-800 hover:border-gold-500/70 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right transition"
                />
                <span
                  className="pointer-events-none absolute left-2 top-1/2 -translate-y-1/2 h-9 w-9 rounded-lg bg-gold-500/15 text-gold-400 border border-gold-500/30 group-hover:bg-gold-500 group-hover:text-charcoal-950 transition flex items-center justify-center"
                  title="اختيار التاريخ"
                >
                  <Calendar className="w-4 h-4" />
                </span>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">من الساعة *</label>
                <div className="relative group">
                  <input
                    ref={startTimeInputRef}
                    type="time"
                    required
                    value={startTime}
                    onClick={() => openNativePicker(startTimeInputRef)}
                    onChange={(e) => setStartTime(e.target.value)}
                    className="w-full cursor-pointer px-4 pl-12 py-2.5 bg-charcoal-900 border border-charcoal-800 hover:border-gold-500/70 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right transition"
                  />
                  <span
                    className="pointer-events-none absolute left-2 top-1/2 -translate-y-1/2 h-8 w-8 rounded-lg bg-gold-500/15 text-gold-400 border border-gold-500/30 group-hover:bg-gold-500 group-hover:text-charcoal-950 transition flex items-center justify-center"
                    title="اختيار وقت البداية"
                  >
                    <Clock className="w-4 h-4" />
                  </span>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">إلى الساعة *</label>
                <div className="relative group">
                  <input
                    ref={endTimeInputRef}
                    type="time"
                    required
                    value={endTime}
                    onClick={() => openNativePicker(endTimeInputRef)}
                    onChange={(e) => setEndTime(e.target.value)}
                    className="w-full cursor-pointer px-4 pl-12 py-2.5 bg-charcoal-900 border border-charcoal-800 hover:border-gold-500/70 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right transition"
                  />
                  <span
                    className="pointer-events-none absolute left-2 top-1/2 -translate-y-1/2 h-8 w-8 rounded-lg bg-gold-500/15 text-gold-400 border border-gold-500/30 group-hover:bg-gold-500 group-hover:text-charcoal-950 transition flex items-center justify-center"
                    title="اختيار وقت النهاية"
                  >
                    <Clock className="w-4 h-4" />
                  </span>
                </div>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-charcoal-300 mb-2">مدة كل حجز (بالدقائق) *</label>
              <select
                value={duration}
                onChange={(e) => setDuration(e.target.value)}
                className="w-full px-4 py-2.5 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 text-right appearance-none"
              >
                <option value="15">15 دقيقة</option>
                <option value="30">30 دقيقة</option>
                <option value="45">45 دقيقة</option>
                <option value="60">ساعة (60 دقيقة)</option>
              </select>
            </div>

            <button
              type="submit"
              className="w-full py-3.5 mt-2 bg-gradient-to-l from-gold-500 to-gold-400 hover:from-gold-600 hover:to-gold-500 text-charcoal-950 font-bold rounded-xl transition-all shadow-lg shadow-gold-500/10 flex items-center justify-center gap-2"
            >
              <Plus className="w-5 h-5" />
              <span>توليد المواعيد</span>
            </button>
          </form>
        </div>

        {/* Display List */}
        <div className="lg:col-span-2 glass-panel p-6 rounded-2xl border border-charcoal-800">
          <div className="mb-6 space-y-4">
            <div className="flex flex-col gap-3 xl:flex-row xl:items-center xl:justify-between">
              <div>
                <h3 className="text-lg font-bold text-white">الأوقات المتاحة الحالية ({filteredSlots.length})</h3>
                <p className="mt-1 text-xs text-charcoal-500">
                  إجمالي المتاح: {slots.length} · المحدد: {selectedSlotIds.length}
                </p>
              </div>
              <div className="flex flex-wrap items-center gap-2">
                <select
                  value={selectedDateFilter}
                  onChange={(event) => {
                    setSelectedDateFilter(event.target.value);
                    setSelectedSlotIds([]);
                  }}
                  className="h-10 min-w-[160px] rounded-xl border border-charcoal-800 bg-charcoal-950 px-3 text-sm font-bold text-white outline-none transition focus:border-gold-500"
                >
                  <option value="all">كل الأيام</option>
                  {availableDates.map((day) => (
                    <option key={day} value={day}>{day}</option>
                  ))}
                </select>
                <button
                  type="button"
                  onClick={toggleFilteredSelection}
                  disabled={filteredSlots.length === 0}
                  className="h-10 rounded-xl border border-charcoal-800 bg-charcoal-950 px-3 text-xs font-black text-charcoal-300 transition hover:border-gold-500 hover:text-gold-400 disabled:cursor-not-allowed disabled:opacity-40"
                >
                  {allFilteredSelected ? 'إلغاء تحديد الظاهر' : 'تحديد الظاهر'}
                </button>
              </div>
            </div>

            <div className="grid grid-cols-1 gap-2 md:grid-cols-3">
              <button
                type="button"
                onClick={handleDeleteSelectedSlots}
                disabled={selectedSlotIds.length === 0}
                className="rounded-xl border border-red-900/40 bg-red-950/20 px-3 py-2.5 text-xs font-black text-red-200 transition hover:bg-red-500 hover:text-white disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:bg-red-950/20 disabled:hover:text-red-200"
              >
                حذف المحدد ({selectedSlotIds.length})
              </button>
              <button
                type="button"
                onClick={handleDeleteFilteredDaySlots}
                disabled={selectedDateFilter === 'all' || filteredSlots.length === 0}
                className="rounded-xl border border-red-900/40 bg-red-950/20 px-3 py-2.5 text-xs font-black text-red-200 transition hover:bg-red-500 hover:text-white disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:bg-red-950/20 disabled:hover:text-red-200"
              >
                حذف مواعيد اليوم
              </button>
              <button
                type="button"
                onClick={handleDeleteAllSlots}
                disabled={slots.length === 0}
                className="rounded-xl border border-red-900/40 bg-red-950/20 px-3 py-2.5 text-xs font-black text-red-200 transition hover:bg-red-600 hover:text-white disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:bg-red-950/20 disabled:hover:text-red-200"
              >
                حذف كل المواعيد
              </button>
            </div>
          </div>

          {filteredSlots.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-h-[500px] overflow-y-auto pr-1">
              {filteredSlots.map((slot) => {
                const [d, t] = slot.dateTime ? slot.dateTime.split('T') : ['', ''];
                const isSelected = selectedSlotIds.includes(slot.id);
                return (
                  <div key={slot.id} className={`p-4 rounded-xl border flex items-center justify-between transition ${isSelected ? 'border-gold-500/70 bg-gold-500/10' : 'bg-charcoal-900/60 border-charcoal-800/60'}`}>
                    <div>
                      <label className="mb-2 flex cursor-pointer items-center gap-2 text-xs font-black text-charcoal-400">
                        <input
                          type="checkbox"
                          checked={isSelected}
                          onChange={() => toggleSlotSelection(slot.id)}
                          className="h-4 w-4 cursor-pointer accent-gold-500"
                        />
                        تحديد
                      </label>
                      <div className="text-sm font-bold text-white font-inter">{d}</div>
                      <div className="text-xs text-gold-400 font-semibold font-inter mt-1">{t.substring(0, 5)}</div>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => handleCloseSlot(slot.id)}
                        className="p-2 rounded-lg bg-charcoal-950 hover:bg-gold-500/20 text-charcoal-400 hover:text-gold-400 border border-charcoal-800 hover:border-gold-500/30 transition-all"
                        title="إغلاق الموعد / حجز يدوي"
                      >
                        <Lock className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteSlot(slot.id)}
                        className="p-2 rounded-lg bg-charcoal-950 hover:bg-red-950/20 text-charcoal-400 hover:text-red-400 border border-charcoal-800 hover:border-red-900/30 transition-all"
                        title="إزالة الموعد"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="text-center py-20 text-charcoal-500">
              <Calendar className="w-12 h-12 mx-auto mb-4 text-charcoal-700" />
              <p>{slots.length === 0 ? 'لم تقم بإضافة مواعيد متاحة حالياً' : 'لا توجد مواعيد في اليوم المحدد'}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// 4. MANAGE BOOKINGS SCREEN
function ManageBookings() {
  const { user } = useAuth();
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState(null);

  useEffect(() => {
    if (!user) return;

    // Fetch appointments that are booked, completed, or cancelled (NOT available)
    const q = query(
      collection(db, 'appointments'), 
      where('barberId', '==', user.uid)
    );
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = [];
      snapshot.forEach(docSnap => {
        const data = docSnap.data();
        if (data.status !== 'available') {
          list.push({ id: docSnap.id, ...data });
        }
      });
      // Sort bookings by dateTime descending
      list.sort((a, b) => new Date(b.dateTime) - new Date(a.dateTime));
      setBookings(list);
      setLoading(false);
    }, (err) => {
      console.error("Error fetching bookings:", err);
      setFetchError("حدث خطأ أثناء تحميل الحجوزات: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user]);

  const handleUpdateStatus = async (bookingId, newStatus) => {
    try {
      await updateDoc(doc(db, 'appointments', bookingId), {
        status: newStatus,
        updatedAt: new Date().toISOString()
      });
    } catch (err) {
      alert('حدث خطأ أثناء تعديل حالة الحجز: ' + err.message);
    }
  };

  if (fetchError) {
    return (
      <div className="p-6 rounded-2xl bg-red-950/20 border border-red-900/40 text-red-200 text-sm flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
        <div>
          <h4 className="font-bold text-red-400 mb-1">فشل تحميل الحجوزات</h4>
          <p>{fetchError}</p>
          <p className="mt-2 text-xs text-charcoal-400">تأكد من تفعيل صلاحيات القراءة والكتابة لكولكشن الـ appointments في قواعد حماية Firestore.</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="w-10 h-10 border-2 border-gold-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-black text-white">قائمة الحجوزات</h1>
        <p className="text-charcoal-400 mt-1 text-sm font-medium">متابعة الحجوزات الواردة من تطبيق الهاتف وتحديث حالتها</p>
      </div>

      {/* Bookings Table */}
      <div className="glass-panel rounded-2xl border border-charcoal-800 overflow-hidden">
        {bookings.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full text-right border-collapse">
              <thead>
                <tr className="border-b border-charcoal-800 bg-charcoal-900/40 text-xs font-bold text-charcoal-400">
                  <th className="p-5">العميل</th>
                  <th className="p-5">الخدمة المطلوبة</th>
                  <th className="p-5">التاريخ والوقت</th>
                  <th className="p-5">السعر</th>
                  <th className="p-5">الحالة</th>
                  <th className="p-5 text-left">الإجراءات</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-charcoal-800/50 text-sm">
                {bookings.map((booking) => (
                  <tr key={booking.id} className="hover:bg-charcoal-900/30 transition-colors">
                    <td className="p-5">
                      <div className="font-bold text-white">{booking.customerName || 'عميل مجهول'}</div>
                      <div className="text-xs text-charcoal-400 mt-1 font-inter">{booking.customerPhone || 'بدون رقم هاتف'}</div>
                    </td>
                    <td className="p-5 font-medium text-white">{booking.serviceName || 'خدمة حلاقة'}</td>
                    <td className="p-5 text-charcoal-300 font-inter">
                      {booking.dateTime ? booking.dateTime.replace('T', ' ').substring(0, 16) : 'غير محدد'}
                    </td>
                    <td className="p-5 text-gold-400 font-bold font-inter">{booking.price || 0} ج.م</td>
                    <td className="p-5">
                      <span className={`px-2.5 py-1 text-[10px] font-bold rounded-full ${
                        booking.status === 'completed' ? 'bg-green-500/10 text-green-400' :
                        booking.status === 'booked' ? 'bg-blue-500/10 text-blue-400' :
                        booking.status === 'cancelled' ? 'bg-red-500/10 text-red-400' :
                        'bg-charcoal-800 text-charcoal-400'
                      }`}>
                        {booking.status === 'completed' ? 'مكتمل' :
                         booking.status === 'booked' ? 'مؤكد' :
                         booking.status === 'cancelled' ? 'ملغي' : booking.status}
                      </span>
                    </td>
                    <td className="p-5 text-left">
                      {booking.status === 'booked' && (
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => handleUpdateStatus(booking.id, 'completed')}
                            className="p-2 rounded-lg bg-green-500/10 hover:bg-green-500/20 text-green-400 border border-green-900/30 transition-all"
                            title="تحديد كمكتمل"
                          >
                            <Check className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleUpdateStatus(booking.id, 'cancelled')}
                            className="p-2 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-900/30 transition-all"
                            title="إلغاء الحجز"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </div>
                      )}
                      {booking.status !== 'booked' && (
                        <span className="text-xs text-charcoal-500 italic">لا توجد إجراءات</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-20 text-charcoal-500">
            <FileText className="w-12 h-12 mx-auto mb-4 text-charcoal-700" />
            <p>لا توجد حجوزات واردة بعد</p>
          </div>
        )}
      </div>
    </div>
  );
}
