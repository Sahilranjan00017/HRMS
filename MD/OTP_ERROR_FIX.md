# OTP Error Debugging Checklist

## ❌ Error: "Error sending OTP" - Complete Fix

Follow these steps IN ORDER:

---

## ✅ Step 1: Verify User Exists in Supabase

**Action:** Run in Supabase SQL Editor

```sql
-- Create/update test user
INSERT INTO public.users (email, full_name, status)
VALUES ('Sahilranjan017@gmail.com', 'Sahil Ranjan', 'active')
ON CONFLICT (email) DO UPDATE 
SET status = 'active'
RETURNING id, email, full_name, status;
```

**Expected:** 1 row returned with user ID

---

## ✅ Step 2: Stop All Services

Kill everything running:

```bash
# Kill all node processes
killall node 2>/dev/null
sleep 2
```

---

## ✅ Step 3: Clean & Install Auth Service

Terminal 1:

```bash
cd /workspaces/HRMS/services/auth-service
rm -rf node_modules package-lock.json
npm install
npm run dev
```

**Wait for:**
```
Auth service running on port 3001
Environment: development
```

---

## ✅ Step 4: Test Auth Service API

Terminal 2:

```bash
curl -X POST http://localhost:3001/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"Sahilranjan017@gmail.com"}'
```

**Expected Response (SUCCESS):**
```json
{
  "success": true,
  "message": "OTP sent successfully to Sahilranjan017@gmail.com"
}
```

**If you get ERROR, copy the response here and tell me.**

---

## ✅ Step 5: Start Frontend

Terminal 3:

```bash
cd /workspaces/HRMS/HRMS
npm run dev
```

**Wait for:**
```
▲ Next.js 14.2.35
- Local:        http://localhost:3000
```

---

## ✅ Step 6: Test in Browser

1. Open: **http://localhost:3000/login-otp**
2. Enter email: **Sahilranjan017@gmail.com**
3. Click **"Send OTP"**
4. Should say: **"OTP sent to your email"** ✅

---

## 🔍 If Still Getting Error

Check **browser console** (F12 → Console tab):
- Look for red error messages
- Copy the exact error and tell me

Check **Terminal 1 (Auth Service)** logs:
- Look for error messages
- Copy them and tell me

---

## 📊 Verification Checklist

- [ ] User exists in Supabase
- [ ] Auth service running on port 3001
- [ ] curl test returns SUCCESS
- [ ] Frontend running on port 3000
- [ ] No errors in browser console
- [ ] No errors in auth service terminal
- [ ] OTP received in Gmail inbox
- [ ] Can enter OTP and login

---

## 💡 Key Points

| Component | Port | Must Be Running |
|-----------|------|-----------------|
| Auth Service | 3001 | ✅ YES |
| Frontend | 3000 | ✅ YES |
| Supabase | Online | ✅ YES |

If any port is wrong, OTP will fail.
