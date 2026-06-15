import React, { createContext, useContext, useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useNavigate } from 'react-router-dom';
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
  const [user, setUser] = useState(null);
  const [role, setRole] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (currentUser) {
        setUser(currentUser);
        // Fetch user role from Firestore
        try {
          const userDoc = await getDoc(doc(db, 'users', currentUser.uid));
          if (userDoc.exists()) {
            setRole(userDoc.data().role || 'barber');
          } else {
            // Default role fallback
            setRole('barber');
          }
        } catch (error) {
          console.error("Error fetching user role: ", error);
          setRole('barber');
        }
      } else {
        setUser(null);
        setRole(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const logout = async () => {
    setLoading(true);
    await signOut(auth);
    setUser(null);
    setRole(null);
    setLoading(false);
  };

  if (loading) {
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

  return (
    <AuthContext.Provider value={{ user, role, loading, logout }}>
      <BrowserRouter>
        <Routes>
          {/* Public Route */}
          <Route 
            path="/login" 
            element={
              user ? (
                role === 'admin' ? <Navigate to="/admin" replace /> : <Navigate to="/barber" replace />
              ) : (
                <Login />
              )
            } 
          />

          {/* Admin Protected Routes */}
          <Route 
            path="/admin/*" 
            element={
              user && role === 'admin' ? <AdminDashboard /> : <Navigate to="/login" replace />
            } 
          />

          {/* Barber Protected Routes */}
          <Route 
            path="/barber/*" 
            element={
              user && role === 'barber' ? <BarberDashboard /> : <Navigate to="/login" replace />
            } 
          />

          {/* Fallback Redirect */}
          <Route 
            path="*" 
            element={
              user ? (
                role === 'admin' ? <Navigate to="/admin" replace /> : <Navigate to="/barber" replace />
              ) : (
                <Navigate to="/login" replace />
              )
            } 
          />
        </Routes>
      </BrowserRouter>
    </AuthContext.Provider>
  );
}
