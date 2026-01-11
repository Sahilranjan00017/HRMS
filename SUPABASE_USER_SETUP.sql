-- HRMS OTP Fix - Run ALL queries in Supabase SQL Editor

-- ============================================
-- 1. CREATE BOTH TEST USERS
-- ============================================

-- Create/Update first user
INSERT INTO public.users (email, full_name, status)
VALUES ('Sahilranjan017@gmail.com', 'Sahil Ranjan', 'active')
ON CONFLICT (email) DO UPDATE 
SET status = 'active', updated_at = now()
RETURNING id, email, full_name, status;

-- Create/Update second user (the one you're testing with)
INSERT INTO public.users (email, full_name, status)
VALUES ('Sahil@gmail.com', 'Sahil Test User', 'active')
ON CONFLICT (email) DO UPDATE 
SET status = 'active', updated_at = now()
RETURNING id, email, full_name, status;

-- ============================================
-- 2. VERIFY BOTH USERS EXIST
-- ============================================

SELECT id, email, full_name, status, created_at 
FROM public.users
WHERE email IN ('Sahilranjan017@gmail.com', 'Sahil@gmail.com')
ORDER BY created_at DESC;

-- ============================================
-- 3. CHECK ALL REQUIRED TABLES
-- ============================================

SELECT COUNT(*) as users_count FROM public.users;
SELECT COUNT(*) as otp_codes_count FROM public.otp_codes;
SELECT COUNT(*) as organizations_count FROM public.organizations;

-- ============================================
-- 4. DELETE EXPIRED OTPs (cleanup)
-- ============================================

DELETE FROM public.otp_codes 
WHERE expires_at < NOW();

-- ============================================
-- 5. FINAL STATUS CHECK
-- ============================================

SELECT 
  (SELECT COUNT(*) FROM public.users) as total_users,
  (SELECT COUNT(*) FROM public.otp_codes) as total_otps,
  'OTP System Ready' as status;

-- ✅ ALL DONE! Your database is ready
