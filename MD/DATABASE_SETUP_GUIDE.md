# HRMS Complete Database Schema Guide

## 📋 Overview

This schema covers all 19 HRMS modules with complete table structures, relationships, and constraints.

### Modules Included:
✅ Attendance  
✅ Leave  
✅ Payroll  
✅ Directory  
✅ Performance  
✅ Recruitment  
✅ Learning  
✅ Benefits  
✅ Onboarding  
✅ Recognition  
✅ My Goals  
✅ Travel  
✅ Expenses  
✅ Analytics  
✅ Compliance  
✅ Roles & Permissions  
✅ Configuration  
✅ Profile  
✅ HR Connect  

---

## 🚀 How to Apply the Schema

### Option 1: Using Supabase Dashboard (Recommended)

1. **Login to Supabase:**
   - Go to https://app.supabase.com
   - Select your project (bfeuvqucqxiuhpkvgwgr)

2. **Open SQL Editor:**
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Copy & Paste the Schema:**
   - Open: `/workspaces/HRMS/database/complete_hrms_schema.sql`
   - Copy all the SQL
   - Paste into the Supabase SQL editor

4. **Execute the Schema:**
   - Click the "Run" button (or press Ctrl+Enter)
   - Wait for all tables to be created

5. **Verify Tables:**
   - Go to "Table Editor"
   - You should see all new tables listed

### Option 2: Using psql (Command Line)

```bash
# If you have PostgreSQL installed locally
psql -h bfeuvqucqxiuhpkvgwgr.supabase.co \
     -U postgres \
     -d postgres \
     < /workspaces/HRMS/database/complete_hrms_schema.sql
```

### Option 3: Using Supabase CLI

```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Push the schema
supabase db push
```

---

## 📊 Database Tables Structure

### Core Tables (Foundation)
- **organizations** - Company information
- **users** - User accounts
- **roles** - Role definitions
- **permissions** - Permission codes
- **role_permissions** - Role-permission mappings
- **user_roles** - User-role assignments

### Authentication & Security
- **otp_codes** - OTP verification
- **password_reset_tokens** - Password reset
- **user_sessions** - Active sessions
- **auth_audit_log** - Authentication audit trail

### Employee Management (Directory)
- **employees** - Employee records
- **employee_qualifications** - Education history
- **employee_work_experience** - Work history

### Attendance Module
- **attendance** - Daily attendance records
- **attendance_summary** - Monthly attendance summary

### Leave Module
- **leave_types** - Leave types (Casual, Sick, Earned)
- **leave_allocation** - Leave balance allocation
- **leave_requests** - Leave requests
- **leave_summary** - Monthly leave summary

### Payroll Module
- **salary_structures** - Salary templates
- **employee_salary_assignments** - Salary assignment
- **statutory_rules** - Payroll rules by state
- **payroll_runs** - Monthly payroll processing
- **payroll_components** - Salary calculations
- **payroll_locks** - Payroll locking
- **statutory_documents** - Generated documents (F-forms, 12BA)

### Performance Module
- **performance_reviews** - Annual/periodic reviews
- **performance_criteria** - Review rating criteria

### Recruitment Module
- **job_openings** - Job vacancies
- **job_applications** - Applicant submissions

### Learning Module
- **training_programs** - Training courses
- **training_enrollments** - Employee participation

### Benefits Module
- **benefits_types** - Insurance, PF, ESI types
- **employee_benefits** - Employee benefit enrollment

### Onboarding Module
- **onboarding_checklists** - Onboarding tasks
- **onboarding_tasks** - Individual tasks

### Recognition Module
- **employee_recognition** - Awards and recognition

### Goals Module
- **employee_goals** - Personal and organizational goals
- **goal_progress** - Goal tracking

### Travel Module
- **travel_requests** - Travel approvals

### Expenses Module
- **expense_categories** - Expense types
- **expense_reports** - Expense claims
- **expense_details** - Line items

### Compliance Module
- **compliance_requirements** - Regulatory requirements
- **employee_compliance** - Document verification

### HR Connect Module
- **hr_messages** - Internal communications
- **hr_announcements** - Broadcasts

### Configuration Module
- **system_configuration** - System settings

### Analytics Module
- **analytics_data** - Metrics and analytics

### Audit Module
- **audit_logs** - All data changes

---

## 🔗 Key Relationships

```
organizations (1) ──→ (Many) users
         ├──→ employees
         ├──→ roles
         └──→ permissions

users (1) ──→ (Many) user_roles ──→ (1) roles

employees (1) ──→ (Many) attendance
          ├──→ leave_requests
          ├──→ performance_reviews
          ├──→ training_enrollments
          ├──→ employee_goals
          ├──→ expense_reports
          └──→ travel_requests

payroll_runs (1) ──→ (Many) payroll_components
                         ├──→ employees
                         └──→ salary_structures
```

---

## 📝 Important Constraints

### Status Fields (Enums)
```sql
-- User Status
CHECK (status IN ('active', 'inactive', 'suspended', 'pending'))

-- Employment Status
CHECK (employment_status IN ('active', 'inactive', 'on_leave', 'separated'))

-- Payroll Status
CHECK (status IN ('draft', 'processing', 'locked', 'approved', 'released'))

-- Leave Status
CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled'))
```

### Foreign Key Constraints
All tables include proper foreign key relationships:
- Prevents orphaned records
- Cascading updates/deletes where appropriate
- Referential integrity maintained

---

## 🎯 Sample Queries After Setup

### 1. Get Employee Directory
```sql
SELECT 
  e.employee_id,
  e.first_name,
  e.last_name,
  e.email,
  e.designation,
  e.department
FROM employees e
WHERE e.org_id = 'your-org-id'
ORDER BY e.first_name;
```

### 2. Get Attendance Summary
```sql
SELECT 
  e.first_name,
  a.attendance_month,
  a.present_days,
  a.absent_days,
  a.attendance_percentage
FROM attendance_summary a
JOIN employees e ON a.employee_id = e.id
WHERE a.org_id = 'your-org-id'
  AND a.attendance_month = '2025-01';
```

### 3. Get Payroll Components
```sql
SELECT 
  e.employee_id,
  e.first_name,
  pc.basic_pay,
  pc.dearness_allowance,
  pc.gross_amount,
  pc.net_pay
FROM payroll_components pc
JOIN employees e ON pc.employee_id = e.id
WHERE pc.payroll_run_id = 'run-id';
```

### 4. Get Leave Requests
```sql
SELECT 
  e.first_name,
  lt.leave_type_name,
  lr.start_date,
  lr.end_date,
  lr.total_days,
  lr.status
FROM leave_requests lr
JOIN employees e ON lr.employee_id = e.id
JOIN leave_types lt ON lr.leave_type_id = lt.id
WHERE lr.status = 'pending'
ORDER BY lr.created_at DESC;
```

---

## ✅ Verification Checklist

After applying the schema, verify:

- [ ] All 50+ tables are created
- [ ] Foreign keys are in place
- [ ] Indexes are created for performance
- [ ] Users table has sample data
- [ ] Roles table has default roles
- [ ] Permissions table has module permissions
- [ ] Organizations table is populated
- [ ] Can insert test data into each module

---

## 🔐 Data Integrity Features

1. **Foreign Key Constraints:** Prevents invalid data relationships
2. **Check Constraints:** Validates enum values
3. **Unique Constraints:** Prevents duplicate records
4. **Default Values:** Auto-populates timestamps
5. **NOT NULL:** Ensures required fields
6. **Audit Trail:** All changes logged in audit_logs

---

## 📈 Performance Features

1. **Indexes:** Created on frequently queried columns
2. **UUID Primary Keys:** Distributed unique identification
3. **Partitioning Ready:** Structure supports time-based partitioning
4. **JSONB Columns:** Flexible data storage for metadata

---

## 🛠️ Post-Schema Setup Tasks

After the schema is created:

### 1. Create Default Roles
```sql
INSERT INTO roles (org_id, role_name, role_code, is_system_role)
VALUES 
  (org_id, 'Admin', 'ADMIN', true),
  (org_id, 'Manager', 'MANAGER', true),
  (org_id, 'Employee', 'EMPLOYEE', true),
  (org_id, 'HR', 'HR', true);
```

### 2. Create Module Permissions
```sql
INSERT INTO permissions (permission_name, permission_code, module)
VALUES 
  ('View Attendance', 'ATTENDANCE_VIEW', 'Attendance'),
  ('Approve Leave', 'LEAVE_APPROVE', 'Leave'),
  ('Process Payroll', 'PAYROLL_PROCESS', 'Payroll'),
  -- ... more permissions
```

### 3. Create Admin User
```sql
INSERT INTO users (org_id, email, full_name, status)
VALUES (org_id, 'admin@company.com', 'Admin User', 'active');
```

---

## 📞 Support

For schema-related issues:
1. Check foreign key constraints
2. Verify all tables are created
3. Run sample queries to test
4. Check Supabase logs for errors

File: `/workspaces/HRMS/database/complete_hrms_schema.sql`
