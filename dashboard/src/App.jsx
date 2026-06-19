import React, { createContext, useContext, useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from './firebase';
import Login from './pages/Login';
import AdminDashboard from './pages/AdminDashboard';
import BarberDashboard from './pages/BarberDashboard';

// Auth Context
const AuthContext = createContext({
  user: null,
  role: null,
  loading: true,
  logout: () => {},
});

export const useAuth = () => useContext(AuthContext);

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  );
}

function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [role, setRole] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let authRequestId = 0;

    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      const requestId = ++authRequestId;
      setLoading(true);

      if (currentUser) {
        const fallbackRole = currentUser.email === 'admin@barber.com' ? 'admin' : 'barber';

        try {
          const userDoc = await getDoc(doc(db, 'users', currentUser.uid));
          if (requestId !== authRequestId) return;

          setUser(currentUser);
          setRole(userDoc.exists() ? userDoc.data().role || fallbackRole : fallbackRole);
        } catch (error) {
          if (requestId !== authRequestId) return;

          console.error("Error fetching user role: ", error);
          setUser(currentUser);
          setRole(fallbackRole);
        }
      } else {
        if (requestId !== authRequestId) return;

        setUser(null);
        setRole(null);
      }

      if (requestId === authRequestId) {
        setLoading(false);
      }
    });

    return () => {
      authRequestId++;
      unsubscribe();
    };
  }, []);

  const logout = async () => {
    setLoading(true);
    try {
      await signOut(auth);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthContext.Provider value={{ user, role, loading, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

function AppRoutes() {
  const { user, role, loading } = useAuth();

  if (loading) {
    return <DashboardLoader />;
  }

  return (
    <Routes>
      <Route
        path="/login"
        element={user ? <Navigate to={defaultPathForRole(role)} replace /> : <Login />}
      />
      <Route
        path="/admin/*"
        element={<ProtectedRoute allowedRole="admin" element={<AdminDashboard />} />}
      />
      <Route
        path="/barber/*"
        element={<ProtectedRoute allowedRole="barber" element={<BarberDashboard />} />}
      />
      <Route
        path="*"
        element={user ? <Navigate to={defaultPathForRole(role)} replace /> : <Navigate to="/login" replace />}
      />
    </Routes>
  );
}

function ProtectedRoute({ allowedRole, element }) {
  const { user, role, loading } = useAuth();

  if (loading) return <DashboardLoader />;
  if (!user) return <Navigate to="/login" replace />;
  if (role !== allowedRole) return <Navigate to={defaultPathForRole(role)} replace />;

  return element;
}

function defaultPathForRole(role) {
  return role === 'admin' ? '/admin' : '/barber';
}

function DashboardLoader() {
  return (
    <div className="min-h-screen bg-charcoal-950 flex flex-col items-center justify-center">
      <div className="relative w-16 h-16">
        <div className="absolute top-0 left-0 w-full h-full border-4 border-gold-500/20 rounded-full"></div>
        <div className="absolute top-0 left-0 w-full h-full border-4 border-t-gold-500 border-r-transparent border-b-transparent border-l-transparent rounded-full animate-spin"></div>
      </div>
      <p className="mt-4 text-gold-400 font-medium tracking-wide">جاري تحميل البيانات...</p>
    </div>
  );
}
