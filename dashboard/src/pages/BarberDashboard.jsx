import React, { useEffect, useState } from 'react';
import { Routes, Route } from 'react-router-dom';
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
  DollarSign, 
  Plus, 
  Trash2, 
  Check, 
  X, 
  FolderHeart, 
  Clock, 
  TrendingUp, 
  AlertCircle,
  Activity,
  FileText,
  Lock,
  Menu
} from 'lucide-react';
import ManageMessages from './ManageMessages';

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
          <Route path="/services" element={<ManageServices />} />
          <Route path="/slots" element={<ManageSlots />} />
          <Route path="/bookings" element={<ManageBookings />} />
          <Route path="/messages" element={<ManageMessages />} />
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
    myServices: 0,
    myRevenue: 0,
  });
  const [todaySchedule, setTodaySchedule] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!user) return;

    // Real-time listener for services by this barber
    const servicesQuery = query(collection(db, 'services'), where('barberId', '==', user.uid));
    const unsubscribeServices = onSnapshot(servicesQuery, (snapshot) => {
      setStats(prev => ({ ...prev, myServices: snapshot.size }));
    }, (err) => {
      console.error("Error fetching services:", err);
      setError("حدث خطأ أثناء جلب البيانات: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

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
      unsubscribeServices();
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
          <p className="mt-2 text-xs text-charcoal-400">تأكد من تفعيل صلاحيات القراءة والكتابة لكولكشن الـ services و appointments في قواعد حماية Firestore.</p>
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
    { title: 'خدماتي المتاحة', value: stats.myServices, icon: FolderHeart, color: 'from-purple-500/10 to-purple-600/5', iconColor: 'text-purple-400' },
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
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
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

// 2. MANAGE SERVICES SCREEN
function ManageServices() {
  const { user } = useAuth();
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [error, setError] = useState('');
  const [fetchError, setFetchError] = useState(null);
  const [submitLoading, setSubmitLoading] = useState(false);

  // Form Fields
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [duration, setDuration] = useState('30');
  const [description, setDescription] = useState('');

  useEffect(() => {
    if (!user) return;

    const q = query(collection(db, 'services'), where('barberId', '==', user.uid));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = [];
      snapshot.forEach(docSnap => {
        list.push({ id: docSnap.id, ...docSnap.data() });
      });
      setServices(list);
      setLoading(false);
    }, (err) => {
      console.error("Error fetching services:", err);
      setFetchError("حدث خطأ أثناء تحميل الخدمات: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user]);

  const handleAddService = async (e) => {
    e.preventDefault();
    if (!name || !price || !duration) {
      setError('الرجاء ملء جميع الحقول المطلوبة');
      return;
    }

    setSubmitLoading(true);
    setError('');

    try {
      await addDoc(collection(db, 'services'), {
        name,
        price: Number(price),
        duration: Number(duration),
        description: description || '',
        barberId: user.uid,
        createdAt: new Date().toISOString(),
      });

      setName('');
      setPrice('');
      setDuration('30');
      setDescription('');
      setIsModalOpen(false);
    } catch (err) {
      setError('حدث خطأ أثناء إضافة الخدمة: ' + err.message);
    } finally {
      setSubmitLoading(false);
    }
  };

  const handleDeleteService = async (serviceId) => {
    if (window.confirm('هل أنت متأكد من حذف هذه الخدمة؟')) {
      try {
        await deleteDoc(doc(db, 'services', serviceId));
      } catch (err) {
        alert('خطأ أثناء حذف الخدمة: ' + err.message);
      }
    }
  };

  if (fetchError) {
    return (
      <div className="p-6 rounded-2xl bg-red-950/20 border border-red-900/40 text-red-200 text-sm flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
        <div>
          <h4 className="font-bold text-red-400 mb-1">فشل تحميل الخدمات</h4>
          <p>{fetchError}</p>
          <p className="mt-2 text-xs text-charcoal-400">تأكد من تفعيل صلاحيات القراءة والكتابة لكولكشن الـ services في قواعد حماية Firestore.</p>
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
    <div className="space-y-8 animate-fade-in relative">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-black text-white">الخدمات والأسعار</h1>
          <p className="text-charcoal-400 mt-1 text-sm font-medium">قائمة الخدمات التي تقدمها للعملاء وتكلفتها ومدتها</p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 px-5 py-3.5 bg-gradient-to-l from-gold-500 to-gold-400 hover:from-gold-600 hover:to-gold-500 text-charcoal-950 font-bold rounded-xl transition-all shadow-lg shadow-gold-500/10 active:scale-95"
        >
          <Plus className="w-5 h-5" />
          <span>إضافة خدمة جديدة</span>
        </button>
      </div>

      {/* Services Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {services.length > 0 ? (
          services.map((service) => (
            <div key={service.id} className="glass-panel p-6 rounded-2xl border border-charcoal-800 flex flex-col justify-between">
              <div>
                <div className="flex items-start justify-between">
                  <h4 className="text-lg font-bold text-white truncate max-w-[80%]">{service.name}</h4>
                  <span className="text-gold-400 font-extrabold text-lg font-inter shrink-0">{service.price} ج.م</span>
                </div>
                <div className="flex items-center gap-1.5 text-xs text-charcoal-400 mt-2 font-inter">
                  <Clock className="w-3.5 h-3.5" />
                  <span>{service.duration} دقيقة</span>
                </div>
                <p className="text-xs text-charcoal-400 mt-3.5 leading-relaxed">{service.description || 'لا يوجد وصف متاح للخدمة'}</p>
              </div>

              <div className="pt-6 mt-6 border-t border-charcoal-800/80 flex items-center justify-end">
                <button
                  onClick={() => handleDeleteService(service.id)}
                  className="p-2.5 rounded-lg bg-charcoal-900 hover:bg-red-950/20 text-charcoal-400 hover:text-red-400 border border-charcoal-800 hover:border-red-900/30 transition-all"
                  title="حذف الخدمة"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))
        ) : (
          <div className="col-span-full text-center py-20 text-charcoal-500">
            <FolderHeart className="w-12 h-12 mx-auto mb-4 text-charcoal-700" />
            <p>لم تقم بإضافة أي خدمة بعد</p>
          </div>
        )}
      </div>

      {/* Add Service Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-charcoal-950/80 backdrop-blur-sm animate-fade-in">
          <div className="glass-panel w-full max-w-lg rounded-3xl p-8 border border-charcoal-800 shadow-2xl relative max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-6 pb-4 border-b border-charcoal-800">
              <h3 className="text-xl font-bold text-white">إضافة خدمة جديدة</h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1.5 rounded-lg bg-charcoal-900 border border-charcoal-800 hover:bg-charcoal-800 text-charcoal-400 hover:text-white transition-all"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {error && (
              <div className="mb-6 p-4 rounded-xl bg-red-950/20 border border-red-900/40 text-red-200 text-xs flex items-start gap-2">
                <AlertCircle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
                <span>{error}</span>
              </div>
            )}

            <form onSubmit={handleAddService} className="space-y-5">
              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">اسم الخدمة *</label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="مثال: قص شعر ملكي / تحديد ذقن بالخيط"
                  className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-charcoal-300 mb-2">السعر (ج.م) *</label>
                  <input
                    type="number"
                    required
                    value={price}
                    onChange={(e) => setPrice(e.target.value)}
                    placeholder="150"
                    className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                    dir="ltr"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-charcoal-300 mb-2">المدة (بالدقائق) *</label>
                  <select
                    value={duration}
                    onChange={(e) => setDuration(e.target.value)}
                    className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500"
                  >
                    <option value="15">15 دقيقة</option>
                    <option value="30">30 دقيقة</option>
                    <option value="45">45 دقيقة</option>
                    <option value="60">60 دقيقة</option>
                    <option value="90">90 دقيقة</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">الوصف والتفاصيل</label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows="4"
                  placeholder="اكتب وصفاً قصيراً للخدمة والمواد المستخدمة إن وجدت..."
                  className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500"
                ></textarea>
              </div>

              <div className="pt-4 flex items-center gap-4">
                <button
                  type="submit"
                  disabled={submitLoading}
                  className="flex-1 py-3.5 bg-gradient-to-l from-gold-500 to-gold-400 hover:from-gold-600 hover:to-gold-500 text-charcoal-950 font-bold rounded-xl transition-all shadow-lg shadow-gold-500/10 flex items-center justify-center gap-2"
                >
                  {submitLoading ? (
                    <>
                      <div className="w-4 h-4 border-2 border-charcoal-950 border-t-transparent rounded-full animate-spin"></div>
                      <span>جاري الحفظ...</span>
                    </>
                  ) : (
                    <span>حفظ الخدمة</span>
                  )}
                </button>
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-6 py-3.5 bg-charcoal-900 border border-charcoal-800 hover:bg-charcoal-800 text-charcoal-300 hover:text-white font-bold rounded-xl transition-all"
                >
                  إلغاء
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

// 3. MANAGE SLOTS (WORKING HOURS) SCREEN
function ManageSlots() {
  const { user } = useAuth();
  const [slots, setSlots] = useState([]);
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

  const handleDeleteSlot = async (slotId) => {
    if (window.confirm('هل تريد حذف هذا الموعد المتاح؟')) {
      try {
        await deleteDoc(doc(db, 'appointments', slotId));
      } catch (err) {
        alert('خطأ أثناء الحذف: ' + err.message);
      }
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
              <input
                type="date"
                required
                value={date}
                onChange={(e) => setDate(e.target.value)}
                min={new Date().toISOString().split('T')[0]}
                className="w-full px-4 py-2.5 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">من الساعة *</label>
                <input
                  type="time"
                  required
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  className="w-full px-4 py-2.5 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">إلى الساعة *</label>
                <input
                  type="time"
                  required
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                  className="w-full px-4 py-2.5 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                />
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
          <h3 className="text-lg font-bold text-white mb-6">الأوقات المتاحة الحالية ({slots.length})</h3>

          {slots.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-h-[500px] overflow-y-auto pr-1">
              {slots.map((slot) => {
                const [d, t] = slot.dateTime ? slot.dateTime.split('T') : ['', ''];
                return (
                  <div key={slot.id} className="p-4 rounded-xl bg-charcoal-900/60 border border-charcoal-800/60 flex items-center justify-between">
                    <div>
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
              <p>لم تقم بإضافة مواعيد متاحة حالياً</p>
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
