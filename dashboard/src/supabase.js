import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase =
  supabaseUrl && supabaseAnonKey ? createClient(supabaseUrl, supabaseAnonKey) : null;

export const productImagesBucket =
  import.meta.env.VITE_SUPABASE_PRODUCT_IMAGES_BUCKET || 'product_images';

export function getStorageErrorMessage(error) {
  const message = error?.message || '';
  const normalizedMessage = message.toLowerCase();

  if (normalizedMessage.includes('bucket not found')) {
    return `Supabase bucket "${productImagesBucket}" غير موجود. أنشئه من Supabase Storage أو غيّر VITE_SUPABASE_PRODUCT_IMAGES_BUCKET لاسم الـ bucket الصحيح.`;
  }

  if (normalizedMessage.includes('row-level security')) {
    return `صلاحيات Supabase Storage لا تسمح بالرفع داخل bucket "${productImagesBucket}". راجع Storage policies لهذا الـ bucket.`;
  }

  return message || 'حدث خطأ أثناء رفع الصورة على Supabase Storage.';
}
