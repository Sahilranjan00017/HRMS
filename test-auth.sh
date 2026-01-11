#!/bin/bash
set -x
ls -la /workspaces/HRMS/services/auth-service/.env.local
cat /workspaces/HRMS/services/auth-service/.env.local | grep SUPABASE_URL
cd /workspaces/HRMS/services/auth-service
npm run dev
