#!/bin/bash

# Clean install and start auth service

echo "Cleaning old installation..."
rm -rf /workspaces/HRMS/services/auth-service/node_modules
rm -f /workspaces/HRMS/services/auth-service/package-lock.json

echo "Installing dependencies (this may take 2-3 minutes)..."
cd /workspaces/HRMS/services/auth-service
npm install --legacy-peer-deps

echo ""
echo "✅ Installation complete!"
echo ""
echo "Starting auth service..."
echo "npm run dev"
echo ""
