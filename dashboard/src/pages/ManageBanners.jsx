import React, { useEffect, useMemo, useState } from 'react';
import { collection, deleteDoc, doc, onSnapshot, setDoc, updateDoc } from 'firebase/firestore';
import {
  AlertCircle,
  CheckCircle2,
  Edit,
  ImagePlus,
  Images,
  Loader2,
  Plus,
  Power,
  RotateCw,
  Trash2,
  X,
  ZoomIn,
  ZoomOut,
} from 'lucide-react';
import { db } from '../firebase';
import { getStorageErrorMessage, productImagesBucket, supabase } from '../supabase';
import { createEditedImageFile } from '../utils/imageEditor';

const placements = [
  { value: 'home', label: 'بنرات الرئيسية', hint: 'تظهر في Home فوق اختيار Men / Women / Kids' },
  { value: 'store', label: 'بنرات المتجر', hint: 'تظهر في QUTI Store أعلى التصنيفات' },
];

const initialForm = {
  name: '',
  placement: 'home',
  displayOrder: '1',
  tapTarget: '',
};

export default function ManageBanners() {
  const [banners, setBanners] = useState([]);
  const [form, setForm] = useState(initialForm);
  const [editingBanner, setEditingBanner] = useState(null);
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState('');
  const [zoomLevel, setZoomLevel] = useState(1);
  const [rotation, setRotation] = useState(0);
  const [imageOffsetX, setImageOffsetX] = useState(0);
  const [imageOffsetY, setImageOffsetY] = useState(0);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(db, 'app_banners'),
      (snapshot) => {
        const nextBanners = snapshot.docs.map((bannerDoc) => ({
          id: bannerDoc.id,
          ...bannerDoc.data(),
        }));

        nextBanners.sort((a, b) => {
          const placementCompare = String(a.placement || '').localeCompare(String(b.placement || ''));
          if (placementCompare !== 0) return placementCompare;
          return Number(a.displayOrder || 0) - Number(b.displayOrder || 0);
        });

        setBanners(nextBanners);
        setLoading(false);
      },
      (err) => {
        console.error('Error loading banners:', err);
        setError('فشل تحميل البنرات. راجع صلاحيات Firestore لكولكشن app_banners.');
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  const counts = useMemo(() => {
    return banners.reduce(
      (acc, banner) => ({ ...acc, [banner.placement]: (acc[banner.placement] || 0) + 1 }),
      { home: 0, store: 0 }
    );
  }, [banners]);

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
  };

  const handleImageChange = (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
    resetImageControls();
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setSuccess('');

    if (!supabase) {
      setError('أضف VITE_SUPABASE_URL و VITE_SUPABASE_ANON_KEY في Environment Variables.');
      return;
    }

    if (!editingBanner && !imageFile) {
      setError('اختار صورة للبنر قبل الحفظ.');
      return;
    }

    setSaving(true);

    try {
      const bannerRef = editingBanner
        ? doc(db, 'app_banners', editingBanner.id)
        : doc(collection(db, 'app_banners'));

      let imageUrl = editingBanner?.imageUrl || '';

      if (imageFile) {
        const uploadFile = await createEditedImageFile({
          file: imageFile,
          zoomLevel,
          rotation,
          offsetX: imageOffsetX,
          offsetY: imageOffsetY,
          outputName: `banner_${bannerRef.id}.${imageFile.name.split('.').pop() || 'jpg'}`,
        });
        const extension = uploadFile.name.split('.').pop() || 'jpg';
        const storagePath = `banners/${bannerRef.id}/${Date.now()}_banner.${extension}`;

        const { error: uploadError } = await supabase.storage
          .from(productImagesBucket)
          .upload(storagePath, uploadFile, {
            cacheControl: '3600',
            upsert: true,
            contentType: uploadFile.type,
          });

        if (uploadError) throw uploadError;

        const { data } = supabase.storage.from(productImagesBucket).getPublicUrl(storagePath);
        imageUrl = data.publicUrl;
      }

      const now = new Date().toISOString();
      const payload = {
        name: form.name.trim(),
        placement: form.placement,
        displayOrder: Number(form.displayOrder || 0),
        tapTarget: form.tapTarget.trim() || null,
        imageUrl,
        isActive: true,
        updatedAt: now,
      };

      if (editingBanner) {
        await updateDoc(bannerRef, payload);
        setSuccess('تم تعديل البنر بنجاح.');
      } else {
        await setDoc(bannerRef, {
          ...payload,
          createdAt: now,
        });
        setSuccess('تمت إضافة البنر بنجاح.');
      }

      resetForm();
    } catch (err) {
      console.error('Error saving banner:', err);
      setError(getStorageErrorMessage(err));
    } finally {
      setSaving(false);
    }
  };

  const startEdit = (banner) => {
    setEditingBanner(banner);
    setForm({
      name: banner.name || '',
      placement: banner.placement || 'home',
      displayOrder: String(banner.displayOrder ?? 1),
      tapTarget: banner.tapTarget || '',
    });
    setImageFile(null);
    setImagePreview(banner.imageUrl || '');
    resetImageControls();
    setError('');
    setSuccess('');
  };

  const toggleActive = async (banner) => {
    await updateDoc(doc(db, 'app_banners', banner.id), {
      isActive: banner.isActive === false,
      updatedAt: new Date().toISOString(),
    });
  };

  const deleteBanner = async (bannerId) => {
    if (!confirm('هل تريد حذف هذا البنر من لوحة الأدمن؟')) return;
    await deleteDoc(doc(db, 'app_banners', bannerId));
  };

  const resetImageControls = () => {
    setZoomLevel(1);
    setRotation(0);
    setImageOffsetX(0);
    setImageOffsetY(0);
  };

  const resetForm = () => {
    setForm(initialForm);
    setEditingBanner(null);
    setImageFile(null);
    setImagePreview('');
    resetImageControls();
  };

  return (
    <div className="space-y-8 animate-fade-in" dir="rtl">
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-black text-white">إدارة بنرات التطبيق</h1>
          <p className="text-charcoal-400 mt-1 text-sm">
            تحكم في صور بنرات الصفحة الرئيسية والمتجر من لوحة الأدمن فقط — غير ظاهرة للحلاقين.
          </p>
        </div>
        <div className="grid grid-cols-2 gap-3 min-w-[260px]">
          <CounterCard label="بنرات الرئيسية" value={counts.home} />
          <CounterCard label="بنرات المتجر" value={counts.store} />
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
          <div className="flex items-center justify-between gap-3 mb-2">
            <div className="flex items-center gap-3">
              <div className="p-3 rounded-xl bg-gold-500/10 text-gold-400 border border-gold-500/20">
                {editingBanner ? <Edit className="w-5 h-5" /> : <Plus className="w-5 h-5" />}
              </div>
              <div>
                <h2 className="font-bold text-white">{editingBanner ? 'تعديل بنر' : 'إضافة بنر جديد'}</h2>
                <p className="text-xs text-charcoal-500">الصورة تُرفع على Supabase والرابط يتحفظ في Firebase.</p>
              </div>
            </div>
            {editingBanner && (
              <button type="button" onClick={resetForm} className="p-2 rounded-lg bg-charcoal-900 text-charcoal-400 hover:text-white">
                <X className="w-4 h-4" />
              </button>
            )}
          </div>

          <label className="block cursor-pointer rounded-2xl border border-dashed border-charcoal-700 bg-charcoal-900/50 hover:border-gold-500/50 transition overflow-hidden">
            {imagePreview ? (
              <div className="relative">
                <div className="h-48 w-full overflow-hidden flex items-center justify-center bg-charcoal-800">
                  <img
                    src={imagePreview}
                    alt="Banner preview"
                    className="max-w-full max-h-full object-contain transition-transform duration-200"
                    style={{
                      transform: `translate(${imageOffsetX}px, ${imageOffsetY}px) scale(${zoomLevel}) rotate(${rotation}deg)`,
                    }}
                  />
                </div>
                <div className="absolute bottom-2 left-2 right-2 bg-charcoal-950/90 rounded-xl p-2 backdrop-blur-sm space-y-2">
                  <div className="flex items-center justify-center gap-2">
                    <IconButton title="تصغير" onClick={() => setZoomLevel(Math.max(0.5, zoomLevel - 0.1))} icon={<ZoomOut className="w-4 h-4" />} />
                    <span className="text-xs text-white min-w-[3rem] text-center font-mono">{Math.round(zoomLevel * 100)}%</span>
                    <IconButton title="تكبير" onClick={() => setZoomLevel(Math.min(3, zoomLevel + 0.1))} icon={<ZoomIn className="w-4 h-4" />} />
                    <div className="w-px h-6 bg-charcoal-700 mx-1" />
                    <IconButton title="تدوير" onClick={() => setRotation((rotation + 90) % 360)} icon={<RotateCw className="w-4 h-4" />} />
                    <button type="button" onClick={(event) => { event.preventDefault(); resetImageControls(); }} className="p-2 rounded-lg bg-charcoal-800 text-charcoal-400 hover:text-white transition text-xs font-bold">
                      إعادة
                    </button>
                  </div>
                </div>
              </div>
            ) : (
              <div className="h-48 flex flex-col items-center justify-center text-charcoal-400 gap-3">
                <ImagePlus className="w-10 h-10 text-gold-400" />
                <span className="text-sm font-semibold">اختار صورة البنر</span>
              </div>
            )}
            <input type="file" accept="image/*" className="hidden" onChange={handleImageChange} />
          </label>

          <Input name="name" label="اسم واضح للبنر" value={form.name} onChange={handleChange} placeholder="مثال: بنر الرئيسية - عروض الصيف" required />

          <div>
            <span className="block text-xs font-bold text-charcoal-400 mb-2">مكان ظهور البنر</span>
            <div className="grid grid-cols-1 gap-2">
              {placements.map((placement) => (
                <button
                  key={placement.value}
                  type="button"
                  onClick={() => setForm((current) => ({ ...current, placement: placement.value }))}
                  className={`p-3 rounded-xl text-right transition border ${form.placement === placement.value ? 'bg-gold-500 text-charcoal-950 border-gold-400' : 'bg-charcoal-900 text-charcoal-300 border-charcoal-800 hover:text-white'}`}
                >
                  <div className="font-black text-sm">{placement.label}</div>
                  <div className={`text-[11px] mt-1 ${form.placement === placement.value ? 'text-charcoal-800' : 'text-charcoal-500'}`}>{placement.hint}</div>
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Input name="displayOrder" label="الترتيب" type="number" min="0" step="1" value={form.displayOrder} onChange={handleChange} />
            <Input name="tapTarget" label="رابط/هدف الضغط" value={form.tapTarget} onChange={handleChange} placeholder="اختياري" />
          </div>

          <button
            type="submit"
            disabled={saving}
            className="w-full h-12 rounded-xl bg-gradient-to-l from-gold-600 to-gold-400 text-charcoal-950 font-black flex items-center justify-center gap-2 disabled:opacity-60"
          >
            {saving ? <Loader2 className="w-5 h-5 animate-spin" /> : editingBanner ? <Edit className="w-5 h-5" /> : <Plus className="w-5 h-5" />}
            {saving ? 'جاري الحفظ...' : editingBanner ? 'حفظ التعديل' : 'إضافة البنر'}
          </button>
        </form>

        <div className="xl:col-span-2 glass-panel rounded-2xl border border-charcoal-800 overflow-hidden">
          <div className="p-6 border-b border-charcoal-800 flex items-center justify-between">
            <h2 className="font-bold text-white">البنرات الحالية</h2>
            <span className="text-xs text-charcoal-500">{banners.length} بنر</span>
          </div>

          {loading ? (
            <div className="h-72 flex items-center justify-center">
              <Loader2 className="w-8 h-8 text-gold-400 animate-spin" />
            </div>
          ) : banners.length === 0 ? (
            <div className="h-72 flex flex-col items-center justify-center text-charcoal-500 gap-3">
              <Images className="w-10 h-10" />
              <p>لا توجد بنرات مضافة بعد.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 p-6">
              {banners.map((banner) => (
                <BannerCard
                  key={banner.id}
                  banner={banner}
                  onEdit={() => startEdit(banner)}
                  onToggle={() => toggleActive(banner)}
                  onDelete={() => deleteBanner(banner.id)}
                />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function BannerCard({ banner, onEdit, onToggle, onDelete }) {
  const placement = placements.find((item) => item.value === banner.placement)?.label || 'بنر';

  return (
    <div className={`rounded-2xl border p-4 bg-charcoal-900/50 ${banner.isActive === false ? 'border-red-900/40 opacity-70' : 'border-charcoal-800'}`}>
      <img src={banner.imageUrl} alt={banner.name} className="w-full h-36 rounded-xl object-cover bg-charcoal-800" />
      <div className="mt-4">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <h3 className="text-white font-bold truncate">{banner.name || 'بنر بدون اسم'}</h3>
            <p className="text-xs text-charcoal-500 mt-1">{placement} · ترتيب {Number(banner.displayOrder || 0)}</p>
          </div>
          <span className={`px-2 py-1 rounded-lg text-[11px] font-bold ${banner.isActive === false ? 'bg-red-500/10 text-red-400' : 'bg-green-500/10 text-green-400'}`}>
            {banner.isActive === false ? 'مخفي' : 'ظاهر'}
          </span>
        </div>
      </div>
      <div className="grid grid-cols-3 gap-2 mt-4">
        <button onClick={onEdit} className="h-10 rounded-xl bg-charcoal-950 border border-charcoal-800 text-charcoal-300 hover:text-white text-sm font-bold flex items-center justify-center gap-2">
          <Edit className="w-4 h-4" />
          تعديل
        </button>
        <button onClick={onToggle} className="h-10 rounded-xl bg-charcoal-950 border border-charcoal-800 text-charcoal-300 hover:text-white text-sm font-bold flex items-center justify-center gap-2">
          <Power className="w-4 h-4" />
          {banner.isActive === false ? 'إظهار' : 'إخفاء'}
        </button>
        <button onClick={onDelete} className="h-10 rounded-xl bg-red-950/20 border border-red-900/40 text-red-300 hover:text-red-200 text-sm font-bold flex items-center justify-center gap-2">
          <Trash2 className="w-4 h-4" />
          حذف
        </button>
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

function IconButton({ icon, onClick, title }) {
  return (
    <button
      type="button"
      onClick={(event) => {
        event.preventDefault();
        onClick();
      }}
      className="p-2 rounded-lg bg-charcoal-800 text-white hover:bg-gold-500 hover:text-charcoal-950 transition"
      title={title}
    >
      {icon}
    </button>
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
