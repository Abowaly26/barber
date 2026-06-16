import React, { useEffect, useState } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import { db } from '../firebase';
import { 
  collection, 
  getDocs, 
  query, 
  where, 
  addDoc, 
  setDoc,
  doc, 
  deleteDoc, 
  updateDoc,
  orderBy,
  onSnapshot
} from 'firebase/firestore';
import { initializeApp } from 'firebase/app';
import { getAuth, createUserWithEmailAndPassword, signOut } from 'firebase/auth';
import { 
  Users, 
  Calendar, 
  DollarSign, 
  Plus, 
  Trash2, 
  Edit, 
  X, 
  Check, 
  User, 
  Scissors, 
  Phone,
  Mail,
  Lock,
  Activity,
  AlertCircle
} from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from 'recharts';

// Reuse firebase config for secondary auth creation
const firebaseConfig = {
  apiKey: "AIzaSyBYIvoEAaPyKHYH6YtW8lSmRtQGW8zysRc",
  authDomain: "barber-10ed3.firebaseapp.com",
  projectId: "barber-10ed3",
  storageBucket: "barber-10ed3.firebasestorage.app",
  messagingSenderId: "669260082445",
  appId: "1:669260082445:web:ae2b5f662783b356b45444",
};

export default function AdminDashboard() {
  return (
    <div className="flex bg-charcoal-950 min-h-screen">
      <Sidebar />
      <main className="flex-1 p-8 overflow-y-auto max-h-screen">
        <Routes>
          <Route path="/" element={<AdminHome />} />
          <Route path="/barbers" element={<ManageBarbers />} />
        </Routes>
      </main>
    </div>
  );
}

// 1. ADMIN HOME / STATS SCREEN
function AdminHome() {
  const [stats, setStats] = useState({
    totalBarbers: 0,
    totalBookings: 0,
    totalServices: 0,
    totalRevenue: 0,
  });
  const [recentBookings, setRecentBookings] = useState([]);
  const [chartData, setChartData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Real-time listener for users (barbers)
    const barbersQuery = query(collection(db, 'users'), where('role', '==', 'barber'));
    const unsubscribeBarbers = onSnapshot(barbersQuery, (snapshot) => {
      setStats(prev => ({ ...prev, totalBarbers: snapshot.size }));
    }, (err) => {
      console.error("Error fetching barbers:", err);
      setError("حدث خطأ أثناء جلب بيانات الحلاقين: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

    // Real-time listener for services
    const servicesQuery = collection(db, 'services');
    const unsubscribeServices = onSnapshot(servicesQuery, (snapshot) => {
      setStats(prev => ({ ...prev, totalServices: snapshot.size }));
    }, (err) => {
      console.error("Error fetching services:", err);
      setError("حدث خطأ أثناء جلب بيانات الخدمات: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

    // Real-time listener for appointments (bookings)
    const appointmentsQuery = collection(db, 'appointments');
    const unsubscribeAppointments = onSnapshot(appointmentsQuery, (snapshot) => {
      let revenue = 0;
      const bookingsList = [];
      const monthlyData = {};

      snapshot.forEach((docSnap) => {
        const data = docSnap.data();

        if (data.status === 'available') {
          return;
        }

        bookingsList.push({ id: docSnap.id, ...data });

        // Sum revenue for completed bookings
        if (data.status === 'completed' || data.status === 'booked') {
          revenue += Number(data.price || 0);
        }

        // Prepare chart data grouping by date
        const dateStr = data.dateTime ? data.dateTime.split('T')[0] : 'غير محدد';
        if (monthlyData[dateStr]) {
          monthlyData[dateStr] += 1;
        } else {
          monthlyData[dateStr] = 1;
        }
      });

      // Sort recent bookings
      bookingsList.sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
      setRecentBookings(bookingsList.slice(0, 5));

      // Set revenue and total count
      setStats(prev => ({
        ...prev,
        totalBookings: bookingsList.length,
        totalRevenue: revenue
      }));

      // Map chart data
      const mappedChart = Object.keys(monthlyData)
        .map(key => ({ date: key, الحجوزات: monthlyData[key] }))
        .sort((a, b) => new Date(a.date) - new Date(b.date))
        .slice(-7); // Last 7 days with bookings
      setChartData(mappedChart);
      setLoading(false);
    }, (err) => {
      console.error("Error fetching appointments:", err);
      setError("حدث خطأ أثناء جلب بيانات الحجوزات: يرجى التحقق من قواعد الحماية (Rules) في Firestore.");
      setLoading(false);
    });

    return () => {
      unsubscribeBarbers();
      unsubscribeServices();
      unsubscribeAppointments();
    };
  }, []);

  if (error) {
    return (
      <div className="p-6 rounded-2xl bg-red-950/20 border border-red-900/40 text-red-200 text-sm flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
        <div>
          <h4 className="font-bold text-red-400 mb-1">فشل تحميل بيانات لوحة التحكم</h4>
          <p>{error}</p>
          <p className="mt-2 text-xs text-charcoal-400">يرجى التأكد من إضافة صلاحيات القراءة والكتابة لكولكشن الـ users و services و appointments في قواعد حماية Firestore.</p>
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
    { title: 'إجمالي الحلاقين', value: stats.totalBarbers, icon: Scissors, color: 'from-blue-500/10 to-blue-600/5', iconColor: 'text-blue-400' },
    { title: 'إجمالي الحجوزات', value: stats.totalBookings, icon: Calendar, color: 'from-purple-500/10 to-purple-600/5', iconColor: 'text-purple-400' },
    { title: 'الخدمات النشطة', value: stats.totalServices, icon: Activity, color: 'from-green-500/10 to-green-600/5', iconColor: 'text-green-400' },
    { title: 'الإيرادات التقديرية', value: `${stats.totalRevenue} ج.م`, icon: DollarSign, color: 'from-gold-500/10 to-gold-600/5', iconColor: 'text-gold-400' },
  ];

  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-black text-white">الرئيسية والتقارير</h1>
        <p className="text-charcoal-400 mt-1 text-sm">مراقبة أداء منصة الحلاقة والتحليلات العامة</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
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

      {/* Charts & Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Chart Column */}
        <div className="lg:col-span-2 glass-panel p-6 rounded-2xl border border-charcoal-800 flex flex-col">
          <h3 className="text-lg font-bold text-white mb-6">حركة الحجوزات اليومية</h3>
          <div className="flex-1 min-h-[300px]">
            {chartData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="colorBookings" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#d4a23f" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#d4a23f" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#262626" />
                  <XAxis dataKey="date" stroke="#737373" style={{ fontSize: '11px', fontFamily: 'Inter' }} />
                  <YAxis stroke="#737373" style={{ fontSize: '11px', fontFamily: 'Inter' }} />
                  <Tooltip contentStyle={{ backgroundColor: '#171717', borderColor: '#262626', color: '#fff', fontFamily: 'Cairo', borderRadius: '8px' }} />
                  <Area type="monotone" dataKey="الحجوزات" stroke="#d4a23f" strokeWidth={2.5} fillOpacity={1} fill="url(#colorBookings)" />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-charcoal-500 text-sm">
                لا توجد بيانات كافية للرسم البياني حالياً
              </div>
            )}
          </div>
        </div>

        {/* Recent Bookings Column */}
        <div className="glass-panel p-6 rounded-2xl border border-charcoal-800">
          <h3 className="text-lg font-bold text-white mb-6">آخر الحجوزات المسجلة</h3>
          <div className="space-y-4">
            {recentBookings.length > 0 ? (
              recentBookings.map((booking) => (
                <div key={booking.id} className="p-4 rounded-xl bg-charcoal-900/60 border border-charcoal-800/60 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-charcoal-800 border border-charcoal-700 flex items-center justify-center text-gold-400 font-bold text-sm">
                      {booking.customerName ? booking.customerName.charAt(0) : 'ع'}
                    </div>
                    <div>
                      <h4 className="text-sm font-semibold text-white truncate max-w-[120px]">{booking.customerName || 'عميل مجهول'}</h4>
                      <p className="text-xs text-charcoal-400 mt-1 font-inter">{booking.dateTime?.replace('T', ' ').substring(0, 16)}</p>
                    </div>
                  </div>
                  <span className={`px-2.5 py-1 text-[10px] font-bold rounded-full ${
                    booking.status === 'completed' ? 'bg-green-500/10 text-green-400' :
                    booking.status === 'booked' ? 'bg-blue-500/10 text-blue-400' :
                    booking.status === 'cancelled' ? 'bg-red-500/10 text-red-400' :
                    'bg-charcoal-800 text-charcoal-400'
                  }`}>
                    {booking.status === 'completed' ? 'مكتمل' :
                     booking.status === 'booked' ? 'مؤكد' :
                     booking.status === 'cancelled' ? 'ملغي' : 'متاح'}
                  </span>
                </div>
              ))
            ) : (
              <div className="text-center py-12 text-charcoal-500 text-sm">
                لا توجد حجوزات مسجلة بعد
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// 2. MANAGE BARBERS SCREEN
function ManageBarbers() {
  const [barbers, setBarbers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [error, setError] = useState('');
  const [submitLoading, setSubmitLoading] = useState(false);

  // Form Fields
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [phone, setPhone] = useState('');
  const [specialty, setSpecialty] = useState('');
  const [barberType, setBarberType] = useState('men'); // men, women, unisex
  const [address, setAddress] = useState('');
  const [latitude, setLatitude] = useState('30.0444');
  const [longitude, setLongitude] = useState('31.2357');
  const [rating, setRating] = useState('4.8');

  useEffect(() => {
    // Query to fetch barbers
    const q = query(collection(db, 'users'), where('role', '==', 'barber'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = [];
      snapshot.forEach(docSnap => {
        list.push({ id: docSnap.id, ...docSnap.data() });
      });
      setBarbers(list);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleAddBarber = async (e) => {
    e.preventDefault();
    if (!name || !email || !password || !phone || !address) {
      setError('الرجاء ملء جميع الحقول المطلوبة');
      return;
    }

    setSubmitLoading(true);
    setError('');

    try {
      // 1. Initialize secondary Firebase app to register the barber in Firebase Auth 
      // without signing out the admin
      const secondaryApp = initializeApp(firebaseConfig, 'SecondaryApp');
      const secondaryAuth = getAuth(secondaryApp);

      // 2. Create the Auth User
      const userCredential = await createUserWithEmailAndPassword(secondaryAuth, email, password);
      const newUid = userCredential.user.uid;

      // Sign out from secondary app instance to clean up local storage
      await signOut(secondaryAuth);

      // 3. Save the Barber details in the 'users' collection in Firestore
      await setDoc(doc(db, 'users', newUid), {
        name,
        email,
        phoneNumber: phone,
        address,
        specialty: specialty || 'حلاقة شعر وذقن',
        barberType: barberType || 'men',
        role: 'barber',
        latitude: parseFloat(latitude) || 30.0444,
        longitude: parseFloat(longitude) || 31.2357,
        rating: parseFloat(rating) || 4.8,
        reviewsCount: Math.floor(Math.random() * 150) + 50,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      });

      // Clear Form and Close Modal
      setName('');
      setEmail('');
      setPassword('');
      setPhone('');
      setAddress('');
      setSpecialty('');
      setBarberType('men');
      setLatitude('30.0444');
      setLongitude('31.2357');
      setRating('4.8');
      setIsModalOpen(false);
    } catch (err) {
      console.error(err);
      if (err.code === 'auth/email-already-in-use') {
        setError('البريد الإلكتروني مستخدم بالفعل لحساب آخر');
      } else {
        setError('حدث خطأ أثناء إضافة الحلاق: ' + err.message);
      }
    } finally {
      setSubmitLoading(false);
    }
  };

  const handleDeleteBarber = async (barberId) => {
    if (window.confirm('هل أنت متأكد من حذف هذا الحلاق من النظام؟ (ملاحظة: هذا سيحذف بياناته من قاعدة البيانات)')) {
      try {
        await deleteDoc(doc(db, 'users', barberId));
      } catch (err) {
        alert('خطأ أثناء حذف الحلاق: ' + err.message);
      }
    }
  };

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
          <h1 className="text-3xl font-black text-white">إدارة الحلاقين</h1>
          <p className="text-charcoal-400 mt-1 text-sm font-medium">إضافة حلاقين جدد وتعديل بياناتهم وحذفهم من النظام</p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 px-5 py-3.5 bg-gradient-to-l from-gold-500 to-gold-400 hover:from-gold-600 hover:to-gold-500 text-charcoal-950 font-bold rounded-xl transition-all shadow-lg shadow-gold-500/10 active:scale-95"
        >
          <Plus className="w-5 h-5" />
          <span>إضافة حلاق جديد</span>
        </button>
      </div>

      {/* Barbers Table / Grid */}
      <div className="glass-panel rounded-2xl border border-charcoal-800 overflow-hidden">
        {barbers.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full text-right border-collapse">
              <thead>
                <tr className="border-b border-charcoal-800 bg-charcoal-900/40 text-xs font-bold text-charcoal-400">
                  <th className="p-5">الحلاق</th>
                  <th className="p-5">البريد الإلكتروني</th>
                  <th className="p-5">رقم الهاتف</th>
                  <th className="p-5">النوع</th>
                  <th className="p-5">التخصص</th>
                  <th className="p-5">العنوان التفصيلي</th>
                  <th className="p-5 text-left">الإجراءات</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-charcoal-800/50 text-sm">
                {barbers.map((barber) => (
                  <tr key={barber.id} className="hover:bg-charcoal-900/30 transition-colors">
                    <td className="p-5 flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-charcoal-800 border border-charcoal-700 flex items-center justify-center text-gold-500 font-bold">
                        {barber.name?.charAt(0)}
                      </div>
                      <span className="font-bold text-white">{barber.name}</span>
                    </td>
                    <td className="p-5 text-charcoal-300 font-inter">{barber.email}</td>
                    <td className="p-5 text-charcoal-300 font-inter">{barber.phoneNumber || barber.phone || 'غير مسجل'}</td>
                    <td className="p-5">
                      <span className={`px-2.5 py-1 text-[10px] font-bold rounded-full ${
                        barber.barberType === 'men' ? 'bg-blue-500/10 text-blue-400' :
                        barber.barberType === 'women' ? 'bg-pink-500/10 text-pink-400' :
                        barber.barberType === 'unisex' ? 'bg-purple-500/10 text-purple-400' :
                        'bg-charcoal-800 text-charcoal-400'
                      }`}>
                        {barber.barberType === 'men' ? 'رجال' :
                         barber.barberType === 'women' ? 'نساء' :
                         barber.barberType === 'unisex' ? 'مشترك' :
                         'غير محدد'}
                      </span>
                    </td>
                    <td className="p-5 text-gold-400 font-medium">{barber.specialty || 'حلاقة عامة'}</td>
                    <td className="p-5 text-charcoal-300 max-w-xs leading-relaxed">{barber.address || 'غير مسجل'}</td>
                    <td className="p-5 text-left">
                      <button
                        onClick={() => handleDeleteBarber(barber.id)}
                        className="p-2.5 rounded-lg bg-charcoal-900 hover:bg-red-950/20 text-charcoal-400 hover:text-red-400 border border-charcoal-800 hover:border-red-900/30 transition-all"
                        title="حذف الحلاق"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-20 text-charcoal-500">
            <Scissors className="w-12 h-12 mx-auto mb-4 text-charcoal-700" />
            <p>لا يوجد حلاقين مسجلين في النظام حالياً</p>
          </div>
        )}
      </div>

      {/* Add Barber Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-charcoal-950/80 backdrop-blur-sm animate-fade-in">
          <div className="glass-panel w-full max-w-lg rounded-3xl p-8 border border-charcoal-800 shadow-2xl relative max-h-[90vh] overflow-y-auto">
            {/* Modal Header */}
            <div className="flex items-center justify-between mb-6 pb-4 border-b border-charcoal-800">
              <h3 className="text-xl font-bold text-white">إضافة حلاق جديد للنظام</h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1.5 rounded-lg bg-charcoal-900 border border-charcoal-800 hover:bg-charcoal-800 text-charcoal-400 hover:text-white transition-all"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Error Message */}
            {error && (
              <div className="mb-6 p-4 rounded-xl bg-red-950/20 border border-red-900/40 text-red-200 text-xs flex items-start gap-2">
                <AlertCircle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
                <span>{error}</span>
              </div>
            )}

            {/* Form */}
            <form onSubmit={handleAddBarber} className="space-y-5">
              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">اسم الحلاق الكامل *</label>
                <div className="relative">
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="مثال: محمد أحمد علي"
                    className="w-full pr-11 pl-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500"
                  />
                  <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-charcoal-500">
                    <User className="w-4 h-4" />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">البريد الإلكتروني (لتسجيل الدخول) *</label>
                <div className="relative">
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="barber@example.com"
                    className="w-full pr-11 pl-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                    dir="ltr"
                  />
                  <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-charcoal-500">
                    <Mail className="w-4 h-4" />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">كلمة المرور المؤقتة *</label>
                <div className="relative">
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full pr-11 pl-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                    dir="ltr"
                  />
                  <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-charcoal-500">
                    <Lock className="w-4 h-4" />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">رقم الهاتف *</label>
                <div className="relative">
                  <input
                    type="tel"
                    required
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="01xxxxxxxxx"
                    className="w-full pr-11 pl-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                    dir="ltr"
                  />
                  <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-charcoal-500">
                    <Phone className="w-4 h-4" />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">التخصص (اختياري)</label>
                <div className="relative">
                  <input
                    type="text"
                    value={specialty}
                    onChange={(e) => setSpecialty(e.target.value)}
                    placeholder="مثال: أخصائي ذقن وبشرة / تسريحات حديثة"
                    className="w-full pr-11 pl-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500"
                  />
                  <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-charcoal-500">
                    <Scissors className="w-4 h-4" />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">نوع الحلاق *</label>
                <div className="grid grid-cols-3 gap-3">
                  <button
                    type="button"
                    onClick={() => setBarberType('men')}
                    className={`py-3 px-4 rounded-xl border-2 text-sm font-bold transition-all ${
                      barberType === 'men'
                        ? 'bg-blue-500/10 border-blue-500 text-blue-400'
                        : 'bg-charcoal-900 border-charcoal-800 text-charcoal-400 hover:border-charcoal-700'
                    }`}
                  >
                    رجال
                  </button>
                  <button
                    type="button"
                    onClick={() => setBarberType('women')}
                    className={`py-3 px-4 rounded-xl border-2 text-sm font-bold transition-all ${
                      barberType === 'women'
                        ? 'bg-pink-500/10 border-pink-500 text-pink-400'
                        : 'bg-charcoal-900 border-charcoal-800 text-charcoal-400 hover:border-charcoal-700'
                    }`}
                  >
                    نساء
                  </button>
                  <button
                    type="button"
                    onClick={() => setBarberType('unisex')}
                    className={`py-3 px-4 rounded-xl border-2 text-sm font-bold transition-all ${
                      barberType === 'unisex'
                        ? 'bg-purple-500/10 border-purple-500 text-purple-400'
                        : 'bg-charcoal-900 border-charcoal-800 text-charcoal-400 hover:border-charcoal-700'
                    }`}
                  >
                    مشترك
                  </button>
                </div>
                <p className="mt-2 text-[11px] text-charcoal-500">سيتم عرض الحلاق بناءً على هذا النوع في شاشة الحجز</p>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">العنوان التفصيلي *</label>
                <textarea
                  required
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  rows="3"
                  placeholder="مثال: 15 شارع التحرير، الدور الثاني، بجوار محطة المترو، الدقي، الجيزة"
                  className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 leading-relaxed"
                ></textarea>
                <p className="mt-2 text-[11px] text-charcoal-500">هذا العنوان سيظهر للعميل داخل تطبيق الهاتف مع المواعيد المتاحة.</p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-charcoal-300 mb-2">خط العرض (Latitude) *</label>
                  <input
                    type="number"
                    step="0.000001"
                    required
                    value={latitude}
                    onChange={(e) => setLatitude(e.target.value)}
                    placeholder="30.0444"
                    className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                    dir="ltr"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-charcoal-300 mb-2">خط الطول (Longitude) *</label>
                  <input
                    type="number"
                    step="0.000001"
                    required
                    value={longitude}
                    onChange={(e) => setLongitude(e.target.value)}
                    placeholder="31.2357"
                    className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                    dir="ltr"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-charcoal-300 mb-2">التقييم الافتراضي *</label>
                <input
                  type="number"
                  step="0.1"
                  min="1"
                  max="5"
                  required
                  value={rating}
                  onChange={(e) => setRating(e.target.value)}
                  placeholder="4.8"
                  className="w-full px-4 py-3 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-600 text-sm focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                  dir="ltr"
                />
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
                    <span>حفظ الحلاق</span>
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
