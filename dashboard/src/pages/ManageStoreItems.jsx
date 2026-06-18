import React, { useEffect, useMemo, useState } from 'react';
import { collection, deleteDoc, doc, onSnapshot, setDoc, updateDoc } from 'firebase/firestore';
import { AlertCircle, CheckCircle2, ImagePlus, Loader2, Package, Plus, Power, Trash2 } from 'lucide-react';
import { db } from '../firebase';
import { getStorageErrorMessage, productImagesBucket, supabase } from '../supabase';

const itemTypes = [
  { value: 'product', label: 'منتج' },
  { value: 'offer', label: 'عرض' },
  { value: 'service', label: 'خدمة تجميل' },
];

const initialForm = {
  type: 'product',
  title: '',
  brand: 'QUTI Store',
  category: 'All',
  description: '',
  price: '',
  oldPrice: '',
  rating: '4.8',
  badge: '',
};

export default function ManageStoreItems() {
  const [items, setItems] = useState([]);
  const [form, setForm] = useState(initialForm);
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(db, 'store_items'),
      (snapshot) => {
        const nextItems = snapshot.docs.map((itemDoc) => ({
          id: itemDoc.id,
          ...itemDoc.data(),
        }));

        nextItems.sort((a, b) => getTime(b.createdAt) - getTime(a.createdAt));
        setItems(nextItems);
        setLoading(false);
      },
      (err) => {
        console.error('Error loading store items:', err);
        setError('فشل تحميل عناصر المتجر. راجع Firestore Rules لكولكشن store_items.');
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  const counts = useMemo(() => {
    return items.reduce(
      (acc, item) => ({ ...acc, [item.type]: (acc[item.type] || 0) + 1 }),
      { product: 0, offer: 0, service: 0 }
    );
  }, [items]);

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
  };

  const handleImageChange = (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setSuccess('');

    if (!supabase) {
      setError('أضف VITE_SUPABASE_URL و VITE_SUPABASE_ANON_KEY في Environment Variables على Vercel.');
      return;
    }

    if (!imageFile) {
      setError('اختار صورة للعنصر قبل الحفظ.');
      return;
    }

    setSaving(true);

    try {
      const itemRef = doc(collection(db, 'store_items'));
      const extension = imageFile.name.split('.').pop() || 'jpg';
      const storagePath = `${itemRef.id}/${Date.now()}_store_item.${extension}`;

      const { error: uploadError } = await supabase.storage
        .from(productImagesBucket)
        .upload(storagePath, imageFile, {
          cacheControl: '3600',
          upsert: true,
          contentType: imageFile.type,
        });

      if (uploadError) throw uploadError;

      const { data } = supabase.storage.from(productImagesBucket).getPublicUrl(storagePath);
      const now = new Date().toISOString();

      await setDoc(itemRef, {
        title: form.title.trim(),
        brand: form.brand.trim() || 'QUTI Store',
        category: form.category.trim() || 'All',
        description: form.description.trim(),
        price: Number(form.price),
        oldPrice: form.oldPrice ? Number(form.oldPrice) : null,
        rating: form.rating ? Number(form.rating) : 4.8,
        badge: form.badge.trim() || null,
        imageUrl: data.publicUrl,
        type: form.type,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      });

      setForm(initialForm);
      setImageFile(null);
      setImagePreview('');
      setSuccess('تمت إضافة العنصر ورفعه على Supabase بنجاح.');
    } catch (err) {
      console.error('Error saving store item:', err);
      setError(getStorageErrorMessage(err));
    } finally {
      setSaving(false);
    }
  };

  const toggleActive = async (item) => {
    await updateDoc(doc(db, 'store_items', item.id), {
      isActive: item.isActive === false,
      updatedAt: new Date().toISOString(),
    });
  };

  const deleteItem = async (itemId) => {
    if (!confirm('هل تريد حذف هذا العنصر من Firestore؟')) return;
    await deleteDoc(doc(db, 'store_items', itemId));
  };

  return (
    <div className="space-y-8 animate-fade-in" dir="rtl">
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-black text-white">إدارة متجر QUTI</h1>
          <p className="text-charcoal-400 mt-1 text-sm">إضافة المنتجات والعروض وخدمات التجميل التي تظهر مباشرة داخل تطبيق Flutter.</p>
        </div>
        <div className="grid grid-cols-3 gap-3 min-w-[280px]">
          <CounterCard label="منتجات" value={counts.product} />
          <CounterCard label="عروض" value={counts.offer} />
          <CounterCard label="خدمات" value={counts.service} />
        </div>
      </div>

      {(error || success) && (
        <div className={`p-4 rounded-2xl border flex items-start gap-3 text-sm ${error ? 'bg-red-950/20 border-red-900/40 text-red-200' : 'bg-green-950/20 border-green-900/40 text-green-200'}`}>
          {error ? <AlertCircle className="w-5 h-5 text-red-400 shrink-0" /> : <CheckCircle2 className="w-5 h-5 text-green-400 shrink-0" />}
          <p>{error || success}</p>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
        <form onSubmit={handleSubmit} className="xl:col-span-1 glass-panel p-6 rounded-2xl border border-charcoal-800 space-y-4">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-3 rounded-xl bg-gold-500/10 text-gold-400 border border-gold-500/20">
              <Plus className="w-5 h-5" />
            </div>
            <div>
              <h2 className="font-bold text-white">إضافة عنصر جديد</h2>
              <p className="text-xs text-charcoal-500">الصورة ترفع على Supabase والرابط يحفظ في Firebase.</p>
            </div>
          </div>

          <label className="block cursor-pointer rounded-2xl border border-dashed border-charcoal-700 bg-charcoal-900/50 hover:border-gold-500/50 transition overflow-hidden">
            {imagePreview ? (
              <img src={imagePreview} alt="Preview" className="h-48 w-full object-cover" />
            ) : (
              <div className="h-48 flex flex-col items-center justify-center text-charcoal-400 gap-3">
                <ImagePlus className="w-10 h-10 text-gold-400" />
                <span className="text-sm font-semibold">اختار صورة العنصر</span>
              </div>
            )}
            <input type="file" accept="image/*" className="hidden" onChange={handleImageChange} />
          </label>

          <div className="grid grid-cols-3 gap-2">
            {itemTypes.map((type) => (
              <button
                key={type.value}
                type="button"
                onClick={() => setForm((current) => ({ ...current, type: type.value }))}
                className={`py-2.5 rounded-xl text-sm font-bold transition ${form.type === type.value ? 'bg-gold-500 text-charcoal-950' : 'bg-charcoal-900 text-charcoal-400 border border-charcoal-800 hover:text-white'}`}
              >
                {type.label}
              </button>
            ))}
          </div>

          <Input name="title" label="اسم المنتج / الخدمة" value={form.title} onChange={handleChange} required />
          <Input name="brand" label="البراند" value={form.brand} onChange={handleChange} />
          <Input name="category" label="التصنيف" value={form.category} onChange={handleChange} />
          <Textarea name="description" label="الوصف" value={form.description} onChange={handleChange} required />

          <div className="grid grid-cols-2 gap-3">
            <Input name="price" label="السعر" type="number" min="0" step="0.01" value={form.price} onChange={handleChange} required />
            <Input name="oldPrice" label="السعر قبل الخصم" type="number" min="0" step="0.01" value={form.oldPrice} onChange={handleChange} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Input name="rating" label="التقييم" type="number" min="0" max="5" step="0.1" value={form.rating} onChange={handleChange} />
            <Input name="badge" label="بادج" value={form.badge} onChange={handleChange} placeholder="Best Seller" />
          </div>

          <button
            type="submit"
            disabled={saving}
            className="w-full h-12 rounded-xl bg-gradient-to-l from-gold-600 to-gold-400 text-charcoal-950 font-black flex items-center justify-center gap-2 disabled:opacity-60"
          >
            {saving ? <Loader2 className="w-5 h-5 animate-spin" /> : <Plus className="w-5 h-5" />}
            {saving ? 'جاري الحفظ...' : 'إضافة للمتجر'}
          </button>
        </form>

        <div className="xl:col-span-2 glass-panel rounded-2xl border border-charcoal-800 overflow-hidden">
          <div className="p-6 border-b border-charcoal-800 flex items-center justify-between">
            <h2 className="font-bold text-white">العناصر الحالية</h2>
            <span className="text-xs text-charcoal-500">{items.length} عنصر</span>
          </div>

          {loading ? (
            <div className="h-72 flex items-center justify-center">
              <Loader2 className="w-8 h-8 text-gold-400 animate-spin" />
            </div>
          ) : items.length === 0 ? (
            <div className="h-72 flex flex-col items-center justify-center text-charcoal-500 gap-3">
              <Package className="w-10 h-10" />
              <p>لا توجد عناصر في المتجر بعد.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 p-6">
              {items.map((item) => (
                <StoreItemCard key={item.id} item={item} onToggle={() => toggleActive(item)} onDelete={() => deleteItem(item.id)} />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function CounterCard({ label, value }) {
  return (
    <div className="rounded-2xl border border-charcoal-800 bg-charcoal-900/60 p-4 text-center">
      <div className="text-xl font-black text-white font-inter">{value}</div>
      <div className="text-xs text-charcoal-500 mt-1">{label}</div>
    </div>
  );
}

function StoreItemCard({ item, onToggle, onDelete }) {
  const typeLabel = itemTypes.find((type) => type.value === item.type)?.label || 'عنصر';

  return (
    <div className={`rounded-2xl border p-4 bg-charcoal-900/50 ${item.isActive === false ? 'border-red-900/40 opacity-70' : 'border-charcoal-800'}`}>
      <div className="flex gap-4">
        <img src={item.imageUrl} alt={item.title} className="w-24 h-24 rounded-xl object-cover bg-charcoal-800" />
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-3">
            <div className="min-w-0">
              <h3 className="text-white font-bold truncate">{item.title}</h3>
              <p className="text-xs text-charcoal-500 mt-1">{item.brand || 'QUTI Store'} · {typeLabel}</p>
            </div>
            <span className="shrink-0 text-gold-400 font-black font-inter">${Number(item.price || 0).toFixed(2)}</span>
          </div>
          <p className="text-xs text-charcoal-400 mt-3 line-clamp-2">{item.description || 'لا يوجد وصف'}</p>
          <div className="flex flex-wrap items-center gap-2 mt-4">
            {item.badge && <span className="px-2 py-1 rounded-lg bg-gold-500/10 text-gold-400 text-[11px] font-bold">{item.badge}</span>}
            <span className={`px-2 py-1 rounded-lg text-[11px] font-bold ${item.isActive === false ? 'bg-red-500/10 text-red-400' : 'bg-green-500/10 text-green-400'}`}>
              {item.isActive === false ? 'مخفي' : 'ظاهر'}
            </span>
          </div>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-3 mt-4">
        <button onClick={onToggle} className="h-10 rounded-xl bg-charcoal-950 border border-charcoal-800 text-charcoal-300 hover:text-white text-sm font-bold flex items-center justify-center gap-2">
          <Power className="w-4 h-4" />
          {item.isActive === false ? 'إظهار' : 'إخفاء'}
        </button>
        <button onClick={onDelete} className="h-10 rounded-xl bg-red-950/20 border border-red-900/40 text-red-300 hover:text-red-200 text-sm font-bold flex items-center justify-center gap-2">
          <Trash2 className="w-4 h-4" />
          حذف
        </button>
      </div>
    </div>
  );
}

function Input({ label, ...props }) {
  return (
    <label className="block">
      <span className="block text-xs font-bold text-charcoal-400 mb-2">{label}</span>
      <input
        {...props}
        className="w-full h-11 rounded-xl bg-charcoal-950 border border-charcoal-800 px-4 text-white text-sm outline-none focus:border-gold-500/60 transition"
      />
    </label>
  );
}

function Textarea({ label, ...props }) {
  return (
    <label className="block">
      <span className="block text-xs font-bold text-charcoal-400 mb-2">{label}</span>
      <textarea
        {...props}
        rows={4}
        className="w-full rounded-xl bg-charcoal-950 border border-charcoal-800 p-4 text-white text-sm outline-none focus:border-gold-500/60 transition resize-none"
      />
    </label>
  );
}

function getTime(value) {
  if (!value) return 0;
  if (typeof value?.toDate === 'function') return value.toDate().getTime();
  return new Date(value).getTime() || 0;
}
