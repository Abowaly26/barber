import { createClient } from '@supabase/supabase-js';

const fallbackSupabaseUrl = 'https://pruhqikzledorijgtyns.supabase.co';
const fallbackSupabaseAnonKey =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBydWhxaWt6bGVkb3Jpamd0eW5zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2OTY1ODEsImV4cCI6MjA5NzI3MjU4MX0.vq8psu4pp6MCMNdYZ0brUuzcbnLRsxgzvndHZ6khDAw';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || fallbackSupabaseUrl;
const supabaseAnonKey =
  import.meta.env.VITE_SUPABASE_ANON_KEY || fallbackSupabaseAnonKey;

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
