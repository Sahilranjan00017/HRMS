# 🎯 HRMS Database - Quick Reference Card

## 📍 File Locations

```
Schema & Data:
  📄 /workspaces/HRMS/database/complete_hrms_schema.sql
  📄 /workspaces/HRMS/database/init_data.sql

Documentation:
  📖 /workspaces/HRMS/COMPLETE_SETUP_SUMMARY.md
  📖 /workspaces/HRMS/DATABASE_SETUP_GUIDE.md
  📖 /workspaces/HRMS/DATABASE_ERD.md
  📖 /workspaces/HRMS/DATABASE_SCHEMA_SUMMARY.md
  📖 /workspaces/HRMS/DATABASE_FILES_INDEX.md
  📖 /workspaces/HRMS/IMPLEMENTATION_CHECKLIST.md ← START HERE
```

---

## ⚡ 3-Minute Quick Start

### Step 1️⃣ Execute Schema (2 minutes)
```
1. Open Supabase SQL Editor
2. Copy: /database/complete_hrms_schema.sql
3. Paste & Run in SQL Editor
4. Wait for completion ✅
```

### Step 2️⃣ Initialize Data (1 minute)
```
1. Get org ID: SELECT id FROM organizations LIMIT 1;
2. Edit: /database/init_data.sql
3. Replace 'YOUR_ORG_ID' with actual UUID
4. Copy & Paste & Run in SQL Editor ✅
```

### Step 3️⃣ Verify (Instant)
```
Run: SELECT COUNT(*) FROM information_schema.tables 
     WHERE table_schema='public';
Expected: 50+ tables ✅
```

---

## 🎯 Complete Workflow

```
READ (5 min)
    ↓
  Start with: COMPLETE_SETUP_SUMMARY.md
    ↓
IMPLEMENT (10 min)
    ↓
  Follow: DATABASE_SETUP_GUIDE.md
    ↓
VERIFY (2 min)
    ↓
  Use: DATABASE_FILES_INDEX.md validation queries
    ↓
DEPLOY ✅
```

---

## 📦 What You Have

| Item | Count | Status |
|------|-------|--------|
| **Tables** | 50+ | ✅ |
| **Modules** | 19 | ✅ |
| **Foreign Keys** | 80+ | ✅ |
| **Permissions** | 60+ | ✅ |
| **Roles** | 6 | ✅ |
| **Documentation** | 6 files | ✅ |

---

## 🔑 Key Credentials

```
Supabase: https://app.supabase.com
Frontend Port: 3000
Auth Service Port: 3001
```

---

## 🚀 Quick Commands

### View all tables
```sql
SELECT * FROM information_schema.tables 
WHERE table_schema='public' ORDER BY table_name;
```

### Get Organization ID
```sql
SELECT id, name FROM organizations;
```

### Check all users
```sql
SELECT id, email, created_at FROM users;
```

### View roles & permissions
```sql
SELECT r.name, COUNT(p.id) as permissions
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
LEFT JOIN permissions p ON rp.permission_id = p.id
GROUP BY r.name;
```

### Check employee data
```sql
SELECT e.employee_code, e.first_name, e.last_name, 
       e.designation, e.department
FROM employees e;
```

### View payroll runs
```sql
SELECT pr.id, pr.month, pr.status, COUNT(pc.id) as components
FROM payroll_runs pr
LEFT JOIN payroll_components pc ON pr.id = pc.payroll_run_id
GROUP BY pr.id;
```

---

## 📋 Module Checklist

```
Core Modules:
  ✅ Authentication (OTP, JWT, Sessions)
  ✅ Users & Roles (RBAC, Permissions)
  ✅ Directory (Employees, Contacts)
  ✅ Attendance (Marking, Summary)
  
HR Modules:
  ✅ Leave (Types, Allocation, Requests)
  ✅ Performance (Reviews, Criteria)
  ✅ Recruitment (Jobs, Applications)
  ✅ Learning (Programs, Enrollments)
  
Benefits & Compliance:
  ✅ Benefits (Types, Assignments)
  ✅ Onboarding (Checklists, Tasks)
  ✅ Compliance (Requirements, Tracking)
  
Finance & Operations:
  ✅ Payroll (Structures, Runs, Components)
  ✅ Expenses (Categories, Reports)
  ✅ Travel (Requests)
  
Admin & Analytics:
  ✅ Recognition (Employee)
  ✅ My Goals (Tracking)
  ✅ Configuration (System Settings)
  ✅ Analytics (Reports)
  ✅ Audit Trail (All Changes)
```

---

## 🔐 Default Setup

```
Organization: Create/Update as needed
Roles: 6 default (Admin, HR Manager, Finance Manager, Manager, Employee, Intern)
Permissions: 60+ across all modules
Leave Types: 8 (Casual, Sick, Earned, Unpaid, Maternity, Paternity, Bereavement, Compensatory)
Salary Structures: 3 (Employee, Senior, Manager)
Statutory Rules: PF & ESI for Maharashtra
Benefit Types: 4 (Health, Life, PF, Gratuity)
System Configs: 10 (Office hours, Grace period, Payroll day, etc.)
```

---

## ⚠️ Important Notes

✅ **Before Running**
- Backup existing database
- Have Supabase ready
- Know your org ID

✅ **During Running**
- Execute schema first
- Initialize data second
- Don't run out of order

✅ **After Running**
- Run validation queries
- Verify all 50+ tables
- Check counts match expected

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Schema won't run | Check syntax, verify access |
| Data won't init | Ensure schema ran first |
| Tables not showing | Refresh dashboard |
| Permissions error | Check user roles |
| Slow queries | Check indexes created |

See: DATABASE_FILES_INDEX.md for detailed troubleshooting

---

## 📚 Which File to Use When

| Task | File |
|------|------|
| Overview | COMPLETE_SETUP_SUMMARY.md |
| How to setup | DATABASE_SETUP_GUIDE.md |
| Table relationships | DATABASE_ERD.md |
| Features & examples | DATABASE_SCHEMA_SUMMARY.md |
| File reference | DATABASE_FILES_INDEX.md |
| Implementation steps | IMPLEMENTATION_CHECKLIST.md |
| Quick reference | This file (QUICK_REFERENCE.md) |

---

## ✨ Success = All These Work

```
✅ 50+ tables created
✅ 6 roles available
✅ 60+ permissions assigned
✅ Admin user created
✅ Default data loaded
✅ Audit trail recording
✅ Payroll ready
✅ Leave management working
✅ Attendance tracking
✅ Employee directory complete
```

---

## 🎉 You're Ready When

You have successfully implemented HRMS when:
- ✅ All tables created
- ✅ Data initialized  
- ✅ Admin user created
- ✅ System configured
- ✅ Users trained
- ✅ First backup taken
- ✅ Testing completed
- ✅ Monitoring setup
- ✅ Documentation reviewed
- ✅ Users can login

---

## 📞 Getting Help

1. Check the appropriate documentation file
2. Run validation queries from DATABASE_FILES_INDEX.md
3. Review the troubleshooting section
4. Check Supabase logs for errors
5. Verify all FK relationships in DATABASE_ERD.md

---

## 🎯 Implementation Timeline

| Phase | Time | Task |
|-------|------|------|
| 1 | 5 min | Read COMPLETE_SETUP_SUMMARY.md |
| 2 | 2 min | Execute complete_hrms_schema.sql |
| 3 | 3 min | Edit and execute init_data.sql |
| 4 | 2 min | Run validation queries |
| 5 | 5 min | Create admin user |
| 6 | 10 min | Configure system settings |
| 7 | 10 min | Add test employees |
| 8 | 5 min | Setup payroll |
| 9 | 10 min | Test workflows |
| 10 | 10 min | Create backups |
| **Total** | **~1 hour** | **Full Implementation** |

---

**Print this page or bookmark it for quick reference during implementation!**

Last Updated: 2025
