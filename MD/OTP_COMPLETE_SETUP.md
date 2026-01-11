# Complete OTP Setup & Database Configuration Guide

## 🎯 Overview

Your HRMS system needs the `otp_codes` table to send and verify OTP emails. This guide will help you:
1. Set up all required database tables in Supabase
2. Fix the "Error sending OTP" issue
3. Test the complete OTP flow

---

## ⭐ The OTP_CODES Table (Critical Table)

This is the **main table** that stores all OTP codes sent to users:

```sql
CREATE TABLE public.otp_codes (
  id uuid PRIMARY KEY,                          -- Unique identifier
  user_id uuid REFERENCES users(id),            -- Which user requested OTP
  otp_code character varying NOT NULL,          -- The 6-digit code (e.g., "123456")
  otp_type character varying NOT NULL,          -- Type: 'login', 'email_verify', etc
  sent_to character varying NOT NULL,           -- Email address it was sent to
  delivery_method character varying,            -- How it was sent: 'email', 'sms', 'whatsapp'
  is_used boolean DEFAULT false,                -- Has this OTP been used?
  used_at timestamp,                            -- When was it used?
  expires_at timestamp NOT NULL,                -- When does it expire?
  attempts integer DEFAULT 0,                   -- How many times user tried
  max_attempts integer DEFAULT 3,               -- Maximum allowed tries
  created_at timestamp DEFAULT now(),           -- When OTP was created
  ip_address character varying,                 -- User's IP address (for security)
  user_agent text                               -- User's browser info (for security)
);
```

**What this table does:**
- Stores every OTP code generated
- Tracks when OTP was sent and when it expires
- Records verification attempts
- Prevents reuse (marks as used after verification)
- Stores security information for audit

---

## 📋 Step-by-Step Setup

### Step 1: Access Supabase SQL Editor

1. Go to https://app.supabase.com
2. Select your project
3. Go to **SQL Editor** (left sidebar)
4. Click **"New Query"**

### Step 2: Run the Complete SQL Schema

1. Copy the entire content from: `/workspaces/HRMS/database/complete_schema.sql`
2. Paste it into the Supabase SQL Editor
3. Click **"Run"** button
4. Wait for all queries to execute (should show ✅ success)

**Expected Output:**
```
✅ All tables have been created successfully!
✅ OTP system is ready to use
✅ All indexes created for performance
```

### Step 3: Verify Tables Were Created

In Supabase SQL Editor, run this query to verify:

```sql
-- Check if otp_codes table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('otp_codes', 'users', 'organizations');
```

Expected result:
```
otp_codes
users
organizations
```

---

## 🔍 Why "Error Sending OTP" Happens

The error occurs because:

| Issue | Cause | Fix |
|-------|-------|-----|
| Table doesn't exist | `otp_codes` table not in Supabase | Run SQL schema |
| Email service error | Invalid SMTP credentials | Check `.env.local` |
| Network issue | Can't connect to Gmail | Verify internet connection |
| Supabase connection | Wrong credentials in `.env` | Update Supabase keys |

---

## ✅ Fix Checklist

### 1. Database Setup
- [ ] Run `complete_schema.sql` in Supabase
- [ ] Verify `otp_codes` table exists
- [ ] Verify `users` table exists
- [ ] Check all tables created successfully

### 2. Environment Variables
- [ ] `SUPABASE_URL` is correct
- [ ] `SUPABASE_SERVICE_KEY` is valid (check in Supabase settings)
- [ ] `SUPABASE_ANON_KEY` is correct
- [ ] `SMTP_HOST=smtp.gmail.com`
- [ ] `SMTP_PORT=587`
- [ ] `SMTP_USER=your_email@gmail.com`
- [ ] `SMTP_PASSWORD=your_16_char_app_password` (from Google)
- [ ] `EMAIL_FROM` has your email

### 3. Test User Setup
Create a test user in Supabase first:

```sql
INSERT INTO public.users (
  email, 
  full_name, 
  status
) VALUES (
  'Sahilranjan0017@gmail.com',
  'Sahil Ranjan',
  'active'
);
```

### 4. Restart Services
```bash
# Stop current services (Ctrl+C)
# Then restart:

# Terminal 1: Auth Service
cd /workspaces/HRMS/services/auth-service
npm run dev

# Terminal 2: HRMS Frontend
cd /workspaces/HRMS
npm run dev
```

---

## 🧪 Testing OTP Flow

### Test Step 1: Send OTP
```bash
curl -X POST http://localhost:3001/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "Sahilranjan0017@gmail.com"}'
```

Expected response:
```json
{
  "success": true,
  "message": "OTP sent successfully to Sahilranjan0017@gmail.com"
}
```

### Test Step 2: Check Email Inbox
- Look for email from: `HRMS System <Sahilranjan0017@gmail.com>`
- Subject: `Your HRMS Login OTP`
- Get the 6-digit code

### Test Step 3: Verify OTP
```bash
curl -X POST http://localhost:3001/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"email": "Sahilranjan0017@gmail.com", "otp": "123456"}'
```

Expected response (with real OTP):
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "accessToken": "...",
  "refreshToken": "..."
}
```

---

## 📊 Database Tables Reference

| Table | Purpose |
|-------|---------|
| `users` | User accounts and login info |
| `otp_codes` | **OTP storage and verification** |
| `organizations` | Company/organization info |
| `roles` | User roles (admin, employee, etc) |
| `user_roles` | Assign roles to users |
| `employees` | Employee details |
| `payroll_runs` | Salary processing |
| `attendance_summary` | Attendance records |

---

## 🐛 Common Issues & Solutions

### Issue 1: "Couldn't find any pages or app directory"
**Solution**: Run `npm run dev` from correct directory
```bash
cd /workspaces/HRMS
npm run dev
```

### Issue 2: "Email sending failed"
**Solution**: Verify SMTP settings
```bash
# Check environment variables are set:
cat /workspaces/HRMS/services/auth-service/.env.local
```

Should show:
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=Sahilranjan0017@gmail.com
SMTP_PASSWORD=pybg wmip hdvb auoh
```

### Issue 3: "OTP_CODES table doesn't exist"
**Solution**: Run the SQL schema in Supabase
1. Go to Supabase SQL Editor
2. Copy `/workspaces/HRMS/database/complete_schema.sql`
3. Run the entire script

### Issue 4: "Couldn't find user"
**Solution**: Create a test user first
```sql
INSERT INTO public.users (email, full_name, status) 
VALUES ('test@example.com', 'Test User', 'active');
```

### Issue 5: "Invalid credentials" error
**Solution**: Check Supabase keys
1. Go to https://app.supabase.com → Project Settings
2. Find API Keys section
3. Copy the correct `anon` and `service role` keys
4. Update in `.env.local` files

---

## 🚀 Complete Flow Diagram

```
User Requests OTP
      ↓
Check if user exists in DB ← (users table)
      ↓
Generate random 6-digit code
      ↓
Save OTP to database ← (otp_codes table) ⭐
      ↓
Send email via Gmail SMTP
      ↓
User receives OTP email
      ↓
User enters OTP
      ↓
Verify in database ← (otp_codes table) ⭐
      ↓
Mark OTP as used
      ↓
Generate login tokens
      ↓
Login successful ✅
```

---

## 📁 File Locations

| File | Purpose |
|------|---------|
| `/workspaces/HRMS/database/complete_schema.sql` | **Complete SQL schema (USE THIS)** |
| `/workspaces/HRMS/services/auth-service/.env.local` | Auth service config |
| `/workspaces/HRMS/HRMS/.env.local` | Frontend config |
| `/workspaces/HRMS/services/auth-service/src/utils/otpService.ts` | OTP generation logic |
| `/workspaces/HRMS/services/auth-service/src/utils/emailService.ts` | Email sending logic |

---

## ✨ Next Steps

1. ✅ Run the `complete_schema.sql` in Supabase
2. ✅ Verify all tables created
3. ✅ Check environment variables
4. ✅ Restart both services
5. ✅ Test OTP login at `/login-otp`
6. ✅ Check inbox for OTP email
7. ✅ Enter OTP to verify login

---

## 📞 Support

If you still get errors:
1. Check server logs in terminal
2. Verify Supabase connection works
3. Ensure SMTP password is correct (16 characters with spaces)
4. Check that user exists in `users` table
5. Verify `otp_codes` table has the OTP record

**You're all set! Your OTP system should work now.** 🎉
