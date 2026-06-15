import React, { useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../firebase';
import { Mail, Lock, Eye, EyeOff, Scissors, AlertCircle } from 'lucide-react';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      setError('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    try {
      setError('');
      setLoading(true);
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err) {
      console.error(err);
      if (err.code === 'auth/user-not-found' || err.code === 'auth/wrong-password' || err.code === 'auth/invalid-credential') {
        setError('بيانات الدخول غير صحيحة، يرجى التحقق وإعادة المحاولة');
      } else if (err.code === 'auth/too-many-requests') {
        setError('تم حظر المحاولات مؤقتاً بسبب تكرار الفشل. حاول لاحقاً');
      } else {
        setError('حدث خطأ أثناء تسجيل الدخول: ' + err.message);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-charcoal-950 flex items-center justify-center p-4 relative overflow-hidden">
      {/* Decorative Blur Backgrounds */}
      <div className="absolute top-[-10%] right-[-10%] w-[500px] h-[500px] rounded-full bg-gold-500/5 blur-[120px] pointer-events-none"></div>
      <div className="absolute bottom-[-10%] left-[-10%] w-[500px] h-[500px] rounded-full bg-gold-600/5 blur-[120px] pointer-events-none"></div>

      <div className="w-full max-w-md">
        {/* Logo and Header */}
        <div className="text-center mb-8">
          <div className="inline-flex p-4 bg-gradient-to-tr from-gold-600 to-gold-400 rounded-2xl text-charcoal-950 shadow-xl shadow-gold-500/10 mb-4 animate-pulse">
            <Scissors className="w-8 h-8" />
          </div>
          <h1 className="text-2xl font-black text-white mb-2">منصة حلاقة</h1>
          <p className="text-charcoal-400 text-sm">لوحة إدارة الصالون والمقدمين الحلاقين</p>
        </div>

        {/* Login Card */}
        <div className="glass-panel p-8 rounded-3xl shadow-2xl relative border border-charcoal-800">
          <h2 className="text-xl font-bold text-white mb-6 text-center">تسجيل الدخول</h2>

          {error && (
            <div className="mb-6 p-4 rounded-xl bg-red-950/20 border border-red-900/40 text-red-200 text-xs flex items-start gap-2.5">
              <AlertCircle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email Input */}
            <div>
              <label className="block text-xs font-semibold text-charcoal-300 mb-2">البريد الإلكتروني</label>
              <div className="relative">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@example.com"
                  className="w-full pl-4 pr-11 py-3.5 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-500 text-sm transition-all focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                  dir="ltr"
                  disabled={loading}
                />
                <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-charcoal-400">
                  <Mail className="w-5 h-5" />
                </div>
              </div>
            </div>

            {/* Password Input */}
            <div>
              <label className="block text-xs font-semibold text-charcoal-300 mb-2">كلمة المرور</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-12 pr-11 py-3.5 bg-charcoal-900 border border-charcoal-800 focus:border-gold-500 rounded-xl text-white placeholder-charcoal-500 text-sm transition-all focus:outline-none focus:ring-1 focus:ring-gold-500 font-inter text-right"
                  dir="ltr"
                  disabled={loading}
                />
                <div className="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-charcoal-400">
                  <Lock className="w-5 h-5" />
                </div>
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 left-0 pl-4 flex items-center text-charcoal-400 hover:text-gold-500 transition-colors"
                  disabled={loading}
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full py-4 bg-gradient-to-l from-gold-500 to-gold-400 hover:from-gold-600 hover:to-gold-500 text-charcoal-950 font-bold rounded-xl transition-all shadow-lg shadow-gold-500/10 active:scale-[0.98] flex items-center justify-center gap-2 mt-4"
            >
              {loading ? (
                <>
                  <div className="w-5 h-5 border-2 border-charcoal-950 border-t-transparent rounded-full animate-spin"></div>
                  <span>جاري تسجيل الدخول...</span>
                </>
              ) : (
                <span>تسجيل الدخول</span>
              )}
            </button>
          </form>
        </div>

        {/* Demo Credentials Alert */}
        <div className="mt-6 p-4 rounded-2xl bg-charcoal-900/50 border border-charcoal-800 text-center">
          <p className="text-xs text-charcoal-400 leading-relaxed">
            ملاحظة: يمكنك استخدام حساب المدير لإضافة الحلاقين، ثم تسجيل الدخول بحساب الحلاق لإدارة الخدمات والمواعيد والحجوزات.
          </p>
        </div>
      </div>
    </div>
  );
}
