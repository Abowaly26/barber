import React, { useEffect, useState } from 'react';
import { collection, deleteDoc, doc, getDoc, onSnapshot, updateDoc } from 'firebase/firestore';
import { AlertCircle, CheckCircle2, Loader2, Minus, Plus, ShoppingBag, Trash2, X } from 'lucide-react';
import { db } from '../firebase';

export default function ManageCart() {
  const [cartItems, setCartItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [selectedCart, setSelectedCart] = useState(null);
  const [deliveryFeeEgp, setDeliveryFeeEgp] = useState(0);

  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(db, 'carts'),
      async (snapshot) => {
        const carts = [];
        
        for (const cartDoc of snapshot.docs) {
          const cartData = cartDoc.data();
          const itemsWithDetails = [];
          
          if (cartData.items && Array.isArray(cartData.items)) {
            for (const item of cartData.items) {
              try {
                const productDoc = await getDoc(doc(db, 'store_items', item.productId));
                if (productDoc.exists()) {
                  itemsWithDetails.push({
                    ...item,
                    productDetails: productDoc.data()
                  });
                }
              } catch (err) {
                console.error('Error fetching product details:', err);
              }
            }
          }
          
          carts.push({
            id: cartDoc.id,
            ...cartData,
            items: itemsWithDetails
          });
        }
        
        setCartItems(carts);
        setLoading(false);
      },
      (err) => {
        console.error('Error loading carts:', err);
        setError('فشل تحميل السلات. راجع Firestore Rules لكولكشن carts.');
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const unsubscribe = onSnapshot(doc(db, 'app_settings', 'store'), (snapshot) => {
      setDeliveryFeeEgp(Number(snapshot.data()?.deliveryFeeEgp || 0));
    });

    return () => unsubscribe();
  }, []);

  const updateItemQuantity = async (cartId, productId, newQuantity) => {
    try {
      const cartRef = doc(db, 'carts', cartId);
      const cartDoc = await getDoc(cartRef);
      
      if (cartDoc.exists()) {
        const cartData = cartDoc.data();
        const updatedItems = cartData.items.map(item =>
          item.productId === productId ? { ...item, quantity: newQuantity } : item
        );
        
        await updateDoc(cartRef, {
          items: updatedItems,
          updatedAt: new Date().toISOString()
        });
        
        setSuccess('تم تحديث الكمية بنجاح');
        setTimeout(() => setSuccess(''), 3000);
      }
    } catch (err) {
      console.error('Error updating quantity:', err);
      setError('فشل تحديث الكمية');
    }
  };

  const removeItemFromCart = async (cartId, productId) => {
    if (!confirm('هل تريد حذف هذا المنتج من السلة؟')) return;
    
    try {
      const cartRef = doc(db, 'carts', cartId);
      const cartDoc = await getDoc(cartRef);
      
      if (cartDoc.exists()) {
        const cartData = cartDoc.data();
        const updatedItems = cartData.items.filter(item => item.productId !== productId);
        
        await updateDoc(cartRef, {
          items: updatedItems,
          updatedAt: new Date().toISOString()
        });
        
        setSuccess('تم حذف المنتج من السلة بنجاح');
        setTimeout(() => setSuccess(''), 3000);
      }
    } catch (err) {
      console.error('Error removing item:', err);
      setError('فشل حذف المنتج');
    }
  };

  const deleteCart = async (cartId) => {
    if (!confirm('هل تريد حذف هذه السلة بالكامل؟')) return;
    
    try {
      await deleteDoc(doc(db, 'carts', cartId));
      setSuccess('تم حذف السلة بنجاح');
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      console.error('Error deleting cart:', err);
      setError('فشل حذف السلة');
    }
  };

  const calculateCartTotals = (items) => {
    let subtotal = 0;
    items.forEach(item => {
      if (item.productDetails) {
        subtotal += (item.productDetails.price || 0) * (item.quantity || 1);
      }
    });
    
    const deliveryFee = subtotal > 0 ? deliveryFeeEgp : 0;
    const total = subtotal + deliveryFee;
    
    return { subtotal, deliveryFee, total };
  };

  return (
    <div className="space-y-8 animate-fade-in" dir="rtl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-black text-white">إدارة السلات</h1>
          <p className="text-charcoal-400 mt-1 text-sm">عرض وإدارة سلات المشترين وربطها بالمنتجات</p>
        </div>
        <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-charcoal-900 border border-charcoal-800">
          <ShoppingBag className="w-5 h-5 text-gold-400" />
          <span className="text-white font-bold">{cartItems.length} سلة</span>
        </div>
      </div>

      {(error || success) && (
        <div className={`p-4 rounded-2xl border flex items-start gap-3 text-sm ${error ? 'bg-red-950/20 border-red-900/40 text-red-200' : 'bg-green-950/20 border-green-900/40 text-green-200'}`}>
          {error ? <AlertCircle className="w-5 h-5 text-red-400 shrink-0" /> : <CheckCircle2 className="w-5 h-5 text-green-400 shrink-0" />}
          <p>{error || success}</p>
        </div>
      )}

      {loading ? (
        <div className="h-72 flex items-center justify-center">
          <Loader2 className="w-8 h-8 text-gold-400 animate-spin" />
        </div>
      ) : cartItems.length === 0 ? (
        <div className="h-72 flex flex-col items-center justify-center text-charcoal-500 gap-3">
          <ShoppingBag className="w-10 h-10" />
          <p>لا توجد سلات نشطة حالياً</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-6">
          {cartItems.map((cart) => {
            const { subtotal, deliveryFee, total } = calculateCartTotals(cart.items);
            
            return (
              <div key={cart.id} className="glass-panel rounded-2xl border border-charcoal-800 overflow-hidden">
                <div className="p-6 border-b border-charcoal-800 flex items-center justify-between">
                  <div>
                    <h3 className="text-white font-bold">سلة #{cart.id.slice(-6)}</h3>
                    <p className="text-xs text-charcoal-500 mt-1">
                      {cart.userId ? `المستخدم: ${cart.userId.slice(-8)}` : 'زائر'} · 
                      {cart.updatedAt ? ` آخر تحديث: ${new Date(cart.updatedAt).toLocaleDateString('ar-EG')}` : ''}
                    </p>
                  </div>
                  <button
                    onClick={() => deleteCart(cart.id)}
                    className="p-2 rounded-lg bg-red-950/20 border border-red-900/40 text-red-300 hover:text-red-200 transition"
                    title="حذف السلة"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>

                {cart.items && cart.items.length > 0 ? (
                  <div className="p-6 space-y-4">
                    {cart.items.map((item, index) => (
                      <div key={`${item.productId}-${index}`} className="flex gap-4 p-4 rounded-xl bg-charcoal-900/60 border border-charcoal-800/60">
                        <img
                          src={item.productDetails?.imageUrl || '/placeholder.png'}
                          alt={item.productDetails?.title || 'منتج'}
                          className="w-20 h-20 rounded-lg object-cover bg-charcoal-800"
                        />
                        <div className="flex-1 min-w-0">
                          <h4 className="text-white font-bold truncate">{item.productDetails?.title || 'منتج غير معروف'}</h4>
                          <p className="text-xs text-charcoal-500 mt-1">{item.productDetails?.brand || 'QUTI Store'}</p>
                          <p className="text-gold-400 font-bold mt-2 font-inter">
                            {(item.productDetails?.price || 0).toFixed(2)} EGP
                          </p>
                        </div>
                        <div className="flex flex-col items-end gap-2">
                          <div className="flex items-center gap-2">
                            <button
                              onClick={() => updateItemQuantity(cart.id, item.productId, Math.max(1, (item.quantity || 1) - 1))}
                              className="w-8 h-8 rounded-lg bg-charcoal-800 border border-charcoal-700 text-white hover:border-gold-500 transition flex items-center justify-center"
                            >
                              <Minus className="w-4 h-4" />
                            </button>
                            <span className="w-8 text-center text-white font-bold">{item.quantity || 1}</span>
                            <button
                              onClick={() => updateItemQuantity(cart.id, item.productId, (item.quantity || 1) + 1)}
                              className="w-8 h-8 rounded-lg bg-charcoal-800 border border-charcoal-700 text-white hover:border-gold-500 transition flex items-center justify-center"
                            >
                              <Plus className="w-4 h-4" />
                            </button>
                          </div>
                          <button
                            onClick={() => removeItemFromCart(cart.id, item.productId)}
                            className="text-xs text-red-400 hover:text-red-300 transition flex items-center gap-1"
                          >
                            <Trash2 className="w-3 h-3" />
                            حذف
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="p-6 text-center text-charcoal-500 text-sm">
                    السلة فارغة
                  </div>
                )}

                <div className="p-6 border-t border-charcoal-800 bg-charcoal-900/30">
                  <div className="space-y-3 text-sm">
                    <div className="flex justify-between text-charcoal-400">
                      <span>المجموع الفرعي</span>
                      <span className="text-white font-inter">{subtotal.toFixed(2)} EGP</span>
                    </div>
                    <div className="flex justify-between text-charcoal-400">
                      <span>رسوم التوصيل</span>
                      <span className="text-white font-inter">{deliveryFee.toFixed(2)} EGP</span>
                    </div>
                    <div className="flex justify-between text-lg font-bold text-white pt-3 border-t border-charcoal-800">
                      <span>الإجمالي</span>
                      <span className="text-gold-400 font-inter">{total.toFixed(2)} EGP</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
