# HRMS System - Quick Start Guide

## 🚀 Start the System

Run both services with one command:

```bash
bash /workspaces/HRMS/run.sh
```

This will:
1. Install dependencies (if needed)
2. Start Auth Service on port 3001
3. Start Next.js Frontend on port 3000
4. Display useful shortcuts and info

## 📍 Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | http://localhost:3000 | Main HRMS Dashboard |
| Home Page | http://localhost:3000/home | Dashboard with modules |
| Login | http://localhost:3000/login-otp | OTP Login |
| Profile | http://localhost:3000/profile | User Profile |
| Auth API | http://localhost:3001/api | Backend API |

## 🔄 Start Services Separately

### Frontend Only
```bash
cd /workspaces/HRMS/HRMS
npm run dev
```
Frontend runs on: **http://localhost:3000**

### Auth Service Only
```bash
cd /workspaces/HRMS/services/auth-service
npm install  # Only needed first time
npm run dev
```
Auth API runs on: **http://localhost:3001/api**

## 🔐 Login Flow

1. Go to http://localhost:3000
2. You'll be redirected to `/login-otp` if not logged in
3. Enter your email
4. Click "Send OTP"
5. Check your email for the 6-digit code
6. Enter the OTP and click "Verify OTP"
7. You'll be redirected to the home page

## ⚙️ Configuration

### Frontend Environment
File: `/workspaces/HRMS/HRMS/.env.local`
```
NEXT_PUBLIC_AUTH_API=http://localhost:3001/api
```

### Auth Service Environment
File: `/workspaces/HRMS/services/auth-service/.env.local`
```
SUPABASE_URL=https://bfeuvqucqxiuhpkvgwgr.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
NODEMAILER_EMAIL=sahilranjan0017@gmail.com
NODEMAILER_PASSWORD=pybgwmiphdvbauoh
PORT=3001
```

## 🛑 Stop Services

1. **In Terminal:** Press `CTRL+C`
2. **Kill Auth Service:** 
   ```bash
   pkill -f "ts-node"
   ```

## 📊 Home Page Modules

Available modules on the home page:
- 📋 Attendance
- 🏖️ Leave
- 💰 Payroll
- 👥 Directory
- 📊 Performance
- 🎯 Recruitment
- 📚 Learning
- 🎁 Benefits
- 🚀 Onboarding
- ⭐ Recognition
- 🎯 My Goals
- ✈️ Travel
- 💳 Expenses
- 📈 Analytics
- ✅ Compliance
- 🔐 Roles
- ⚙️ Configuration
- 👤 Profile
- 💬 HR Connect

## 🐛 Troubleshooting

### Port Already in Use
If port 3000 or 3001 is in use:
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

### Dependencies Missing
```bash
# Frontend
cd /workspaces/HRMS/HRMS && npm install

# Auth Service
cd /workspaces/HRMS/services/auth-service && npm install
```

### Environment Variables Not Loading
Verify `.env.local` files exist in:
- `/workspaces/HRMS/HRMS/.env.local`
- `/workspaces/HRMS/services/auth-service/.env.local`

### OTP Email Not Sending
Check auth service logs:
```bash
tail -f /tmp/auth-service.log
```

Verify Nodemailer configuration:
- Email: sahilranjan0017@gmail.com
- App Password: pybgwmiphdvbauoh

## 📝 Project Structure

```
/workspaces/HRMS/
├── HRMS/                          # Next.js Frontend
│   ├── app/                       # Pages & routes
│   │   ├── home/                  # Home dashboard
│   │   ├── login-otp/             # Login page
│   │   ├── profile/               # User profile
│   │   └── [other modules]/
│   └── .env.local                 # Frontend config
│
├── services/auth-service/         # Express.js Auth Backend
│   ├── src/
│   │   ├── routes/                # API endpoints
│   │   ├── config/                # Database config
│   │   ├── utils/                 # OTP & Email utilities
│   │   └── server.ts              # Entry point
│   └── .env.local                 # Auth config
│
└── run.sh                         # Start both services
```

## ✅ System Requirements

- Node.js v24.11.1+
- npm or yarn
- Internet connection (for Gmail SMTP)
- Supabase account (already configured)

## 📞 Support

For issues, check:
1. Terminal error messages
2. `/tmp/auth-service.log` for backend errors
3. Browser console for frontend errors
4. Network tab in DevTools to check API calls
