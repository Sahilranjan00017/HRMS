-- ============================================================================
-- HRMS Database - Initial Data Setup
-- ============================================================================
-- Run this after the complete_hrms_schema.sql to populate default data
-- ============================================================================

-- ============================================================================
-- STEP 1: Create Default Organization (Update with your company details)
-- ============================================================================

INSERT INTO public.organizations (
  name,
  entity_code,
  state_code,
  country_code,
  registration_number,
  pan,
  gst_number,
  is_active,
  admin_email,
  subscription_tier
) VALUES (
  'Your Company Name',
  'YOUR_COMPANY',
  'MH',
  'IN',
  'REG123456',
  'ABCDE1234F',
  '27AABDE1234H1Z5',
  true,
  'admin@yourcompany.com',
  'premium'
) RETURNING id;

-- Store the org_id from the result above
-- Replace 'YOUR_ORG_ID' with the actual UUID in subsequent queries

-- ============================================================================
-- STEP 2: Create Default Roles
-- ============================================================================

INSERT INTO public.roles (
  org_id,
  role_name,
  role_code,
  description,
  is_system_role,
  is_custom_role,
  hierarchy_level,
  is_active
) VALUES
  ('YOUR_ORG_ID', 'System Administrator', 'ADMIN', 'Full system access', true, false, 1, true),
  ('YOUR_ORG_ID', 'HR Manager', 'HR_MANAGER', 'HR management and employee admin', true, false, 2, true),
  ('YOUR_ORG_ID', 'Finance Manager', 'FINANCE_MANAGER', 'Payroll and finance management', true, false, 2, true),
  ('YOUR_ORG_ID', 'Department Manager', 'MANAGER', 'Department and team management', true, false, 3, true),
  ('YOUR_ORG_ID', 'Employee', 'EMPLOYEE', 'Regular employee access', true, false, 4, true),
  ('YOUR_ORG_ID', 'Intern', 'INTERN', 'Intern level access', true, false, 5, true);

-- ============================================================================
-- STEP 3: Create Module Permissions
-- ============================================================================

-- ATTENDANCE PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Attendance', 'ATTENDANCE_VIEW', 'Attendance', true),
  ('Create Attendance', 'ATTENDANCE_CREATE', 'Attendance', true),
  ('Edit Attendance', 'ATTENDANCE_EDIT', 'Attendance', true),
  ('Approve Attendance', 'ATTENDANCE_APPROVE', 'Attendance', true);

-- LEAVE PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Leave', 'LEAVE_VIEW', 'Leave', true),
  ('Create Leave Request', 'LEAVE_CREATE', 'Leave', true),
  ('Approve Leave', 'LEAVE_APPROVE', 'Leave', true),
  ('Manage Leave Types', 'LEAVE_MANAGE_TYPES', 'Leave', true);

-- PAYROLL PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Payroll', 'PAYROLL_VIEW', 'Payroll', true),
  ('Process Payroll', 'PAYROLL_PROCESS', 'Payroll', true),
  ('Lock Payroll', 'PAYROLL_LOCK', 'Payroll', true),
  ('Approve Payroll', 'PAYROLL_APPROVE', 'Payroll', true),
  ('Release Salary', 'PAYROLL_RELEASE', 'Payroll', true);

-- EMPLOYEE DIRECTORY PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Directory', 'DIRECTORY_VIEW', 'Directory', true),
  ('Create Employee', 'EMPLOYEE_CREATE', 'Directory', true),
  ('Edit Employee', 'EMPLOYEE_EDIT', 'Directory', true),
  ('Delete Employee', 'EMPLOYEE_DELETE', 'Directory', true);

-- PERFORMANCE PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Performance', 'PERFORMANCE_VIEW', 'Performance', true),
  ('Create Review', 'PERFORMANCE_CREATE', 'Performance', true),
  ('Submit Review', 'PERFORMANCE_SUBMIT', 'Performance', true),
  ('Approve Review', 'PERFORMANCE_APPROVE', 'Performance', true);

-- RECRUITMENT PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Recruitment', 'RECRUITMENT_VIEW', 'Recruitment', true),
  ('Create Job Opening', 'RECRUITMENT_CREATE', 'Recruitment', true),
  ('Manage Applications', 'RECRUITMENT_MANAGE', 'Recruitment', true);

-- LEARNING PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Learning', 'LEARNING_VIEW', 'Learning', true),
  ('Create Training', 'LEARNING_CREATE', 'Learning', true),
  ('Manage Training', 'LEARNING_MANAGE', 'Learning', true);

-- BENEFITS PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Benefits', 'BENEFITS_VIEW', 'Benefits', true),
  ('Manage Benefits', 'BENEFITS_MANAGE', 'Benefits', true);

-- ONBOARDING PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Onboarding', 'ONBOARDING_VIEW', 'Onboarding', true),
  ('Create Onboarding', 'ONBOARDING_CREATE', 'Onboarding', true),
  ('Manage Onboarding', 'ONBOARDING_MANAGE', 'Onboarding', true);

-- RECOGNITION PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Recognition', 'RECOGNITION_VIEW', 'Recognition', true),
  ('Give Recognition', 'RECOGNITION_CREATE', 'Recognition', true);

-- GOALS PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Goals', 'GOALS_VIEW', 'My Goals', true),
  ('Create Goal', 'GOALS_CREATE', 'My Goals', true),
  ('Update Goal Progress', 'GOALS_UPDATE', 'My Goals', true);

-- TRAVEL PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Travel', 'TRAVEL_VIEW', 'Travel', true),
  ('Create Travel Request', 'TRAVEL_CREATE', 'Travel', true),
  ('Approve Travel', 'TRAVEL_APPROVE', 'Travel', true);

-- EXPENSE PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Expenses', 'EXPENSE_VIEW', 'Expenses', true),
  ('Create Expense', 'EXPENSE_CREATE', 'Expenses', true),
  ('Approve Expense', 'EXPENSE_APPROVE', 'Expenses', true);

-- COMPLIANCE PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Compliance', 'COMPLIANCE_VIEW', 'Compliance', true),
  ('Manage Compliance', 'COMPLIANCE_MANAGE', 'Compliance', true);

-- ANALYTICS PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Analytics', 'ANALYTICS_VIEW', 'Analytics', true),
  ('Export Reports', 'ANALYTICS_EXPORT', 'Analytics', true);

-- CONFIGURATION PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Configuration', 'CONFIG_VIEW', 'Configuration', true),
  ('Edit Configuration', 'CONFIG_EDIT', 'Configuration', true);

-- HR CONNECT PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Messages', 'HRCONNECT_VIEW', 'HR Connect', true),
  ('Send Message', 'HRCONNECT_SEND', 'HR Connect', true),
  ('Post Announcement', 'HRCONNECT_ANNOUNCE', 'HR Connect', true);

-- PROFILE PERMISSIONS
INSERT INTO public.permissions (permission_name, permission_code, module, is_active) VALUES
  ('View Profile', 'PROFILE_VIEW', 'Profile', true),
  ('Edit Profile', 'PROFILE_EDIT', 'Profile', true);

-- ============================================================================
-- STEP 4: Assign Permissions to Roles
-- ============================================================================

-- Admin: All permissions
INSERT INTO public.role_permissions (role_id, permission_id, can_view, can_create, can_update, can_delete, can_approve)
SELECT r.id, p.id, true, true, true, true, true
FROM public.roles r, public.permissions p
WHERE r.role_code = 'ADMIN' AND r.org_id = 'YOUR_ORG_ID'
ON CONFLICT DO NOTHING;

-- HR Manager: HR-related permissions
INSERT INTO public.role_permissions (role_id, permission_id, can_view, can_create, can_update, can_delete, can_approve)
SELECT r.id, p.id, true, true, true, true, true
FROM public.roles r, public.permissions p
WHERE r.role_code = 'HR_MANAGER' AND r.org_id = 'YOUR_ORG_ID'
AND p.module IN ('Attendance', 'Leave', 'Directory', 'Recruitment', 'Onboarding', 'Compliance')
ON CONFLICT DO NOTHING;

-- Finance Manager: Payroll-related permissions
INSERT INTO public.role_permissions (role_id, permission_id, can_view, can_create, can_update, can_delete, can_approve)
SELECT r.id, p.id, true, true, true, false, true
FROM public.roles r, public.permissions p
WHERE r.role_code = 'FINANCE_MANAGER' AND r.org_id = 'YOUR_ORG_ID'
AND p.module IN ('Payroll', 'Expenses')
ON CONFLICT DO NOTHING;

-- Manager: Team management permissions
INSERT INTO public.role_permissions (role_id, permission_id, can_view, can_create, can_update)
SELECT r.id, p.id, true, true, true
FROM public.roles r, public.permissions p
WHERE r.role_code = 'MANAGER' AND r.org_id = 'YOUR_ORG_ID'
AND p.module IN ('Attendance', 'Leave', 'Performance', 'Travel')
ON CONFLICT DO NOTHING;

-- Employee: Self-service permissions
INSERT INTO public.role_permissions (role_id, permission_id, can_view, can_create)
SELECT r.id, p.id, true, true
FROM public.roles r, public.permissions p
WHERE r.role_code = 'EMPLOYEE' AND r.org_id = 'YOUR_ORG_ID'
AND (p.permission_code IN ('LEAVE_VIEW', 'LEAVE_CREATE', 'GOALS_VIEW', 'GOALS_CREATE', 
     'TRAVEL_VIEW', 'TRAVEL_CREATE', 'EXPENSE_VIEW', 'EXPENSE_CREATE', 
     'DIRECTORY_VIEW', 'PROFILE_VIEW', 'PROFILE_EDIT', 'HRCONNECT_VIEW', 'HRCONNECT_SEND',
     'RECOGNITION_VIEW', 'RECOGNITION_CREATE'))
ON CONFLICT DO NOTHING;

-- ============================================================================
-- STEP 5: Create Default Leave Types
-- ============================================================================

INSERT INTO public.leave_types (
  org_id,
  leave_type_name,
  leave_type_code,
  description,
  days_per_year,
  is_paid,
  requires_approval,
  requires_medical_certificate,
  carryforward_days,
  is_active
) VALUES
  ('YOUR_ORG_ID', 'Casual Leave', 'CL', 'Casual leave for personal reasons', 12, true, true, false, 3, true),
  ('YOUR_ORG_ID', 'Sick Leave', 'SL', 'Sick leave for medical reasons', 8, true, true, true, 0, true),
  ('YOUR_ORG_ID', 'Earned Leave', 'EL', 'Annual earned leave', 20, true, false, false, 5, true),
  ('YOUR_ORG_ID', 'Unpaid Leave', 'UL', 'Unpaid leave', 10, false, true, false, 0, true),
  ('YOUR_ORG_ID', 'Maternity Leave', 'ML', 'Maternity leave', 180, true, false, false, 0, true),
  ('YOUR_ORG_ID', 'Paternity Leave', 'PL', 'Paternity leave', 15, true, false, false, 0, true),
  ('YOUR_ORG_ID', 'Bereavement Leave', 'BL', 'Bereavement leave', 5, true, true, false, 0, true),
  ('YOUR_ORG_ID', 'Compensatory Off', 'CO', 'Compensatory off for overtime', 5, true, true, false, 2, true);

-- ============================================================================
-- STEP 6: Create Default Salary Structure
-- ============================================================================

INSERT INTO public.salary_structures (
  org_id,
  name,
  description,
  effective_from,
  annual_ctc,
  monthly_basic,
  monthly_da,
  monthly_hra,
  monthly_allowance,
  is_template,
  is_active
) VALUES
  ('YOUR_ORG_ID', 'Standard Employee', 'Standard salary structure for employees', CURRENT_DATE, 800000, 50000, 5000, 10000, 5000, true, true),
  ('YOUR_ORG_ID', 'Senior Employee', 'Salary structure for senior employees', CURRENT_DATE, 1500000, 80000, 8000, 15000, 10000, true, true),
  ('YOUR_ORG_ID', 'Manager', 'Salary structure for managers', CURRENT_DATE, 2000000, 100000, 10000, 20000, 15000, true, true);

-- ============================================================================
-- STEP 7: Create Default Statutory Rules (India - Maharashtra)
-- ============================================================================

INSERT INTO public.statutory_rules (
  org_id,
  rule_type,
  state_code,
  effective_from,
  pf_employee_rate,
  pf_employer_rate,
  pf_ceiling,
  esi_employee_rate,
  esi_employer_rate,
  esi_wage_ceiling,
  esi_threshold_salary,
  pt_slab_min,
  pt_slab_max,
  pt_amount,
  tds_slab_min,
  tds_slab_max,
  tds_rate,
  gratuity_rate_per_year,
  gratuity_completion_months,
  is_active
) VALUES
  ('YOUR_ORG_ID', 'EPF', 'MH', '2025-01-01', 12, 12, 15000, 0.75, 3.25, 21000, 21000, 0, 6500, 200, 0, 250000, 10, 4.33, 240, true),
  ('YOUR_ORG_ID', 'ESI', 'MH', '2025-01-01', 0.75, 3.25, 21000, 0.75, 3.25, 21000, 21000, 0, 6500, 200, 0, 250000, 10, 4.33, 240, true);

-- ============================================================================
-- STEP 8: Create System Configuration
-- ============================================================================

INSERT INTO public.system_configuration (
  org_id,
  config_key,
  config_value,
  config_type,
  description,
  is_editable
) VALUES
  ('YOUR_ORG_ID', 'ATTENDANCE_MARKING_TIME', '09:00', 'TIME', 'Default attendance marking time', true),
  ('YOUR_ORG_ID', 'LATE_ARRIVAL_GRACE_PERIOD', '15', 'MINUTES', 'Grace period for late arrivals in minutes', true),
  ('YOUR_ORG_ID', 'EARLY_CHECKOUT_THRESHOLD', '17:30', 'TIME', 'Time after which checkout counts as early', true),
  ('YOUR_ORG_ID', 'OVERTIME_CALCULATION_THRESHOLD', '9', 'HOURS', 'Hours after which overtime is calculated', true),
  ('YOUR_ORG_ID', 'PAYROLL_DAY_OF_MONTH', '28', 'DAY', 'Day of month for salary disbursement', true),
  ('YOUR_ORG_ID', 'FINANCIAL_YEAR_START_MONTH', '4', 'MONTH', 'Financial year start month (1-12)', true),
  ('YOUR_ORG_ID', 'MAX_ALLOWED_LOANS', '5', 'COUNT', 'Maximum concurrent loans per employee', true),
  ('YOUR_ORG_ID', 'EXPENSE_APPROVAL_THRESHOLD', '50000', 'AMOUNT', 'Amount above which manager approval needed', true),
  ('YOUR_ORG_ID', 'EMAIL_NOTIFICATIONS_ENABLED', 'true', 'BOOLEAN', 'Enable/disable email notifications', true),
  ('YOUR_ORG_ID', 'SMS_NOTIFICATIONS_ENABLED', 'false', 'BOOLEAN', 'Enable/disable SMS notifications', true);

-- ============================================================================
-- STEP 9: Create Sample Admin User
-- ============================================================================

-- Note: Use the auth service to create actual users with password hashing
-- This is a placeholder - replace with actual user creation via API

INSERT INTO public.users (
  org_id,
  email,
  full_name,
  status,
  is_email_verified,
  is_first_login,
  must_change_password
) VALUES
  ('YOUR_ORG_ID', 'admin@yourcompany.com', 'System Administrator', 'active', true, true, true);

-- Assign Admin Role
INSERT INTO public.user_roles (user_id, role_id, is_active)
SELECT u.id, r.id, true
FROM public.users u, public.roles r
WHERE u.email = 'admin@yourcompany.com'
AND r.role_code = 'ADMIN'
AND r.org_id = 'YOUR_ORG_ID'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- STEP 10: Create Default Benefit Types
-- ============================================================================

INSERT INTO public.benefits_types (
  org_id,
  benefit_name,
  benefit_code,
  benefit_type,
  description,
  provider_name,
  coverage_amount,
  premium_amount,
  is_taxable,
  is_active
) VALUES
  ('YOUR_ORG_ID', 'Health Insurance', 'HI', 'Insurance', 'Comprehensive health insurance coverage', 'XYZ Insurance', 500000, 2500, false, true),
  ('YOUR_ORG_ID', 'Life Insurance', 'LI', 'Insurance', 'Term life insurance', 'ABC Insurance', 5000000, 1000, false, true),
  ('YOUR_ORG_ID', 'Provident Fund', 'PF', 'Savings', 'Employee Provident Fund', 'EPFO', null, 0, false, true),
  ('YOUR_ORG_ID', 'Gratuity', 'GR', 'Gratuity', 'Post-employment gratuity', 'Internal', null, 0, false, true);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these to verify the setup:
-- SELECT COUNT(*) as total_roles FROM public.roles WHERE org_id = 'YOUR_ORG_ID';
-- SELECT COUNT(*) as total_permissions FROM public.permissions;
-- SELECT COUNT(*) as total_leave_types FROM public.leave_types WHERE org_id = 'YOUR_ORG_ID';
-- SELECT COUNT(*) as total_salary_structures FROM public.salary_structures WHERE org_id = 'YOUR_ORG_ID';

-- ============================================================================
-- END OF INITIAL DATA SETUP
-- ============================================================================
