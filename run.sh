#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HRMS System - Complete Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Start Auth Service
echo -e "${YELLOW}Step 1: Starting Auth Service on port 3001...${NC}"
cd /workspaces/HRMS/services/auth-service

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing auth service dependencies..."
    npm install
fi

# Start auth service in background
npm run dev > /tmp/auth-service.log 2>&1 &
AUTH_PID=$!
echo -e "${GREEN}✓ Auth Service started (PID: $AUTH_PID)${NC}"
echo "  Logs: /tmp/auth-service.log"
echo ""

# Wait for auth service to be ready
echo -e "${YELLOW}Waiting for auth service to start...${NC}"
sleep 4

# Check if auth service is running
if curl -s http://localhost:3001/api/auth/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Auth Service is responding on http://localhost:3001${NC}"
else
    echo -e "${YELLOW}⚠ Auth Service might not be ready yet, but continuing...${NC}"
fi
echo ""

# Step 2: Start Frontend
echo -e "${YELLOW}Step 2: Starting Next.js Frontend on port 3000...${NC}"
cd /workspaces/HRMS/HRMS

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

echo -e "${GREEN}✓ Starting development server...${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HRMS System Ready!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Frontend:${NC}  http://localhost:3000"
echo -e "${GREEN}Auth API:${NC}  http://localhost:3001/api"
echo ""
echo -e "${YELLOW}Shortcuts:${NC}"
echo "  • Home Page:   http://localhost:3000/home"
echo "  • Login:       http://localhost:3000/login-otp"
echo "  • Profile:     http://localhost:3000/profile"
echo ""
echo -e "${YELLOW}To stop the services:${NC}"
echo "  • Press CTRL+C in the terminal"
echo "  • Then run: kill $AUTH_PID"
echo ""

# Start the frontend (this will run in the foreground)
npm run dev
