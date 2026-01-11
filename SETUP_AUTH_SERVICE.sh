#!/bin/bash

# HRMS Complete Setup Guide - Auth Service + Frontend

echo "================================"
echo "HRMS OTP System - Complete Setup"
echo "================================"
echo ""

echo "✅ Step 1: Kill all existing services"
echo "Press Ctrl+C in all running terminals"
echo ""

echo "✅ Step 2: Install Auth Service Dependencies"
echo "Run in Terminal 1:"
echo "cd /workspaces/HRMS/services/auth-service"
echo "npm install"
echo ""

echo "✅ Step 3: Start Auth Service (Express API)"
echo "Same terminal:"
echo "npm run dev"
echo ""
echo "Expected: 'Auth service running on port 3001'"
echo ""

echo "✅ Step 4: Start Frontend (Next.js)"
echo "Run in Terminal 2:"
echo "cd /workspaces/HRMS/HRMS"
echo "npm run dev"
echo ""
echo "Expected: 'Local: http://localhost:3000'"
echo ""

echo "✅ Step 5: Test API (Terminal 3)"
echo "curl -X POST http://localhost:3001/api/auth/send-otp \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"email\":\"Sahil@gmail.com\"}'"
echo ""
echo "Expected Response:"
echo '{"success":true,"message":"OTP sent successfully to Sahil@gmail.com"}'
echo ""

echo "✅ Step 6: Test in Browser"
echo "1. Go to: http://localhost:3000/login-otp"
echo "2. Enter: Sahil@gmail.com"
echo "3. Click Send OTP"
echo "4. Should see 'OTP sent successfully'"
echo "5. Check Gmail inbox for 6-digit code"
echo "6. Enter OTP to login"
echo ""

echo "================================"
echo "Port Mapping:"
echo "  3001 = Auth Service (Express)"
echo "  3000 = Frontend (Next.js)"
echo "================================"
echo ""
echo "Start with Step 2 above!"
