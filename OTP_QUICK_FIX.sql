-- HRMS OTP Setup - Quick Fix Script
-- Run ALL of these queries in Supabase SQL Editor

-- ============================================
-- 1. VERIFY TABLES EXIST
-- ============================================

-- Check if all required tables exist
SELECT 
  COUNT(*) as total_tables,
  STRING_AGG(tablename, ', ') as table_list
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('users', 'otp_codes', 'organizations');

-- ============================================
-- 2. CREATE TEST USER (If doesn't exist)
-- ============================================

-- Insert the user if they don't already exist
INSERT INTO public.users (
  email,
  full_name,
  status
) VALUES (
  'Sahilranjan017@gmail.com',
  'Sahil Ranjan',
  'active'
)
ON CONFLICT (email) DO UPDATE 
SET status = 'active', updated_at = now()
RETURNING id, email, full_name, status;

-- ============================================
-- 3. VERIFY USER WAS CREATED
-- ============================================

-- Check if user exists now
SELECT 
  id,
  email,
  full_name,
  status,
  created_at
FROM public.users
WHERE email = 'Sahilranjan017@gmail.com';

-- ============================================
-- 4. CHECK OTP CODES TABLE
-- ============================================

-- Count existing OTP codes
SELECT COUNT(*) as total_otps FROM public.otp_codes;

-- List recent OTP codes (if any)
SELECT 
  id,
  otp_code,
  sent_to,
  is_used,
  expires_at,
  created_at
FROM public.otp_codes
ORDER BY created_at DESC
LIMIT 5;

-- ============================================
-- 5. VERIFY TABLE STRUCTURE
-- ============================================

-- Check otp_codes table structure
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'otp_codes'
ORDER BY ordinal_position;

-- ============================================
-- 6. CLEANUP (Optional - Remove test data)
-- ============================================

-- Uncomment below to delete old test OTPs (older than 1 hour)
-- DELETE FROM public.otp_codes 
-- WHERE created_at < NOW() - INTERVAL '1 hour';

-- ============================================
-- SUCCESS INDICATORS
-- ============================================

-- Summary check
SELECT 
  'users' as table_name,
  COUNT(*) as record_count
FROM public.users
UNION ALL
SELECT 
  'otp_codes' as table_name,
  COUNT(*) as record_count
FROM public.otp_codes
UNION ALL
SELECT 
  'organizations' as table_name,
  COUNT(*) as record_count
FROM public.organizations;

-- ✅ If all queries run successfully, your database is ready!
-- ✅ User 'Sahilranjan017@gmail.com' has been created
-- ✅ OTP system is ready to use
