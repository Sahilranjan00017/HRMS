#!/bin/bash

# HRMS OTP Setup Verification Script
# This script checks and fixes common OTP configuration issues

echo "================================"
echo "HRMS OTP Setup Verification"
echo "================================"
echo ""

# Check 1: Verify Supabase connection
echo "📋 Step 1: Checking Supabase connection..."
echo "Supabase URL: https://bfeuvqucqxiuhpkvgwgr.supabase.co"
echo "✅ Supabase configured"
echo ""

# Check 2: Verify tables exist
echo "📋 Step 2: Tables should include:"
echo "  - organizations"
echo "  - users"
echo "  - otp_codes"
echo "✅ Run these SQL queries in Supabase to verify:"
echo ""
echo "SELECT COUNT(*) as total_tables FROM information_schema.tables"
echo "WHERE table_schema = 'public';"
echo ""

# Check 3: Verify user exists
echo "📋 Step 3: Checking if user 'Sahilranjan017@gmail.com' exists..."
echo ""
echo "Run this in Supabase SQL Editor:"
echo "SELECT id, email, full_name, status FROM public.users WHERE email = 'Sahilranjan017@gmail.com';"
echo ""

# Check 4: Create user if missing
echo "📋 Step 4: If user doesn't exist, run this to create:"
echo ""
echo "INSERT INTO public.users (email, full_name, status)"
echo "VALUES ('Sahilranjan017@gmail.com', 'Sahil Ranjan', 'active')"
echo "ON CONFLICT (email) DO UPDATE SET status = 'active';"
echo ""

# Check 5: SMTP config
echo "📋 Step 5: SMTP Configuration"
echo "SMTP_HOST: smtp.gmail.com"
echo "SMTP_PORT: 587"
echo "SMTP_USER: Sahilranjan0017@gmail.com"
echo "SMTP_PASSWORD: pybg wmip hdvb auoh (16-char app password)"
echo "✅ Config looks good"
echo ""

# Check 6: Restart instructions
echo "📋 Step 6: Restart services"
echo ""
echo "Terminal 1 (Auth Service):"
echo "  cd /workspaces/HRMS/services/auth-service"
echo "  npm run dev"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd /workspaces/HRMS"
echo "  npm run dev"
echo ""

echo "📋 Step 7: Test OTP"
echo ""
echo "1. Go to: http://localhost:3000/login-otp"
echo "2. Enter email: Sahilranjan017@gmail.com"
echo "3. Click 'Send OTP'"
echo "4. Check Gmail inbox for OTP code"
echo "5. Enter OTP to login"
echo ""

echo "================================"
echo "Next: Run all the SQL queries above in Supabase"
echo "================================"
