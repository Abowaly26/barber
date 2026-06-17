import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../App';
import { 
  LayoutDashboard, 
  Scissors, 
  CalendarDays, 
  FolderHeart, 
  LogOut,
  UserCheck,
  TrendingUp,
  Sliders,
  MessageSquare,
  Menu,
  X
} from 'lucide-react';

export default function Sidebar({ isMobileOpen, onMobileClose }) {
  const { role, logout, user } = useAuth();

  const adminLinks = [
    { to: '/admin', label: 'الرئيسية والتقارير', icon: LayoutDashboard, end: true },
    { to: '/admin/barbers', label: 'إدارة الحلاقين', icon: Scissors },
  ];

  const barberLinks = [
    { to: '/barber', label: 'الرئيسية والإحصائيات', icon: LayoutDashboard, end: true },
    { to: '/barber/services', label: 'الخدمات والأسعار', icon: FolderHeart },
    { to: '/barber/slots', label: 'مواعيد الحجوزات', icon: CalendarDays },
    { to: '/barber/bookings', label: 'قائمة الحجوزات', icon: UserCheck },
    { to: '/barber/messages', label: 'الرسائل والمحادثات', icon: MessageSquare },
  ];


  const links = role === 'admin' ? adminLinks : barberLinks;

  return (
    <>
      {/* Mobile Overlay */}
      {isMobileOpen && (
        <div 
          className="fixed inset-0 bg-charcoal-950/80 backdrop-blur-sm z-40 lg:hidden"
          onClick={onMobileClose}
        />
      )}
      
      {/* Sidebar */}
      <aside className={`
        fixed lg:static inset-y-0 right-0 z-50
        w-72 bg-charcoal-900 border-l border-charcoal-800 
        flex flex-col min-h-screen text-charcoal-200
        transform transition-transform duration-300 ease-in-out
        ${isMobileOpen ? 'translate-x-0' : 'translate-x-full lg:translate-x-0'}
      `}>
        {/* Brand Logo */}
        <div className="p-8 border-b border-charcoal-800 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-gradient-to-tr from-gold-600 to-gold-400 rounded-xl text-charcoal-950 shadow-lg shadow-gold-500/10">
              <Scissors className="w-6 h-6" />
            </div>
            <div>
              <h1 className="font-extrabold text-lg text-white tracking-wide">منصة حلاقة</h1>
              <p className="text-xs text-gold-500 font-medium">لوحة تحكم الإدارة</p>
            </div>
          </div>
          {/* Mobile Close Button */}
          <button
            onClick={onMobileClose}
            className="lg:hidden p-2 rounded-lg bg-charcoal-800 hover:bg-charcoal-700 text-charcoal-400 hover:text-white transition-all"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

      {/* User Info Card */}
      <div className="p-6 border-b border-charcoal-800/50 bg-charcoal-950/30">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-full bg-gradient-to-tr from-charcoal-700 to-charcoal-800 border border-gold-500/20 flex items-center justify-center font-bold text-gold-500 overflow-hidden">
            {user?.photoURL ? (
              <img src={user.photoURL} alt={user.displayName} className="w-full h-full object-cover" />
            ) : (
              user?.email?.charAt(0).toUpperCase()
            )}
          </div>
          <div className="overflow-hidden">
            <h4 className="text-sm font-semibold text-white truncate">{user?.displayName || user?.email}</h4>
            <span className="inline-block mt-0.5 px-2 py-0.5 text-[10px] font-bold rounded-full bg-gold-500/10 text-gold-400 uppercase tracking-wider">
              {role === 'admin' ? 'مدير المنصة' : 'حلاق محترف'}
            </span>
          </div>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 px-4 py-6 space-y-1">
        {links.map((link) => {
          const Icon = link.icon;
          return (
            <NavLink
              key={link.to}
              to={link.to}
              end={link.end}
              className={({ isActive }) => `
                flex items-center gap-3 px-4 py-3.5 rounded-xl text-sm font-semibold transition-all duration-300
                ${isActive 
                  ? 'bg-gradient-to-l from-gold-500/10 to-gold-500/5 text-gold-400 border-r-4 border-gold-500' 
                  : 'hover:bg-charcoal-800/50 text-charcoal-400 hover:text-white'}
              `}
            >
              <Icon className="w-5 h-5" />
              <span>{link.label}</span>
            </NavLink>
          );
        })}
      </nav>

      {/* Logout Footer */}
      <div className="p-4 border-t border-charcoal-800">
        <button
          onClick={logout}
          className="w-full flex items-center justify-center gap-2.5 px-4 py-3 rounded-xl text-sm font-bold bg-charcoal-950 hover:bg-red-950/20 text-charcoal-400 hover:text-red-400 border border-charcoal-800 hover:border-red-900/30 transition-all duration-300"
        >
          <LogOut className="w-4 h-4" />
          <span>تسجيل الخروج</span>
        </button>
      </div>
    </aside>
    </>
  );
}
