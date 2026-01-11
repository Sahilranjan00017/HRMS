#!/bin/bash

# Start auth service in background
echo "Starting auth service on port 3001..."
cd /workspaces/HRMS/services/auth-service
npm install > /dev/null 2>&1
npm run dev > /tmp/auth-service.log 2>&1 &
AUTH_PID=$!
echo "Auth service started with PID: $AUTH_PID"

# Wait for auth service to start
sleep 3

# Start Next.js frontend
echo "Starting Next.js frontend on port 3000..."
cd /workspaces/HRMS/HRMS
npm run dev
