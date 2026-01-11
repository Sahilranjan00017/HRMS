#!/bin/bash
cd /workspaces/HRMS/services/auth-service

echo "Installing dependencies..."
npm install

echo ""
echo "Starting auth service..."
npm run dev
