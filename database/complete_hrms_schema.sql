-- ============================================================================
-- HRMS Complete Database Schema
-- ============================================================================
-- This schema includes all modules: Attendance, Leave, Payroll, Directory,
-- Performance, Recruitment, Learning, Benefits, Onboarding, Recognition,
-- My Goals, Travel, Expenses, Analytics, Compliance, Roles, Configuration,
-- Profile, and HR Connect
-- ============================================================================

-- ============================================================================
-- CORE TABLES (Foundation)
-- ============================================================================

-- Organizations Table
CREATE TABLE IF NOT EXISTS public.organizations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  entity_code character varying NOT NULL UNIQUE,
  state_code character varying NOT NULL DEFAULT 'MH'::character varying,
  country_code character varying NOT NULL DEFAULT 'IN'::character varying,
  registration_number character varying,
  pan character varying,
  gst_number character varying,
  address text,
  city character varying,
  state character varying,
  postal_code character varying,
  phone character varying,
  email character varying,
  website character varying,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  admin_email character varying,
  admin_phone character varying,
  subscription_tier character varying DEFAULT 'basic'::character varying,
  subscription_expires_at timestamp without time zone,
  logo_url text,
  CONSTRAINT organizations_pkey PRIMARY KEY (id)
);

-- Users Table
CREATE TABLE IF NOT EXISTS public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid,
  email character varying NOT NULL UNIQUE,
  phone character varying,
  password_hash text,
  is_email_verified boolean DEFAULT false,
  is_phone_verified boolean DEFAULT false,
  full_name character varying NOT NULL,
  employee_id character varying,
  avatar_url text,
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text, 'suspended'::character varying::text, 'pending'::character varying::text])),
  is_first_login boolean DEFAULT true,
  must_change_password boolean DEFAULT false,
  last_login_at timestamp without time zone,
  last_login_ip character varying,
  failed_login_attempts integer DEFAULT 0,
  locked_until timestamp without time zone,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT users_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);

-- Roles Table
CREATE TABLE IF NOT EXISTS public.roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid,
  role_name character varying NOT NULL,
  role_code character varying NOT NULL,
  description text,
  is_system_role boolean DEFAULT false,
  is_custom_role boolean DEFAULT true,
  hierarchy_level integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT roles_pkey PRIMARY KEY (id),
  CONSTRAINT roles_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT roles_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);

-- Permissions Table
CREATE TABLE IF NOT EXISTS public.permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  permission_name character varying NOT NULL,
  permission_code character varying NOT NULL UNIQUE,
  description text,
  module character varying NOT NULL,
  category character varying,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT permissions_pkey PRIMARY KEY (id)
);

-- Role Permissions Table
CREATE TABLE IF NOT EXISTS public.role_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  role_id uuid,
  permission_id uuid,
  can_view boolean DEFAULT true,
  can_create boolean DEFAULT false,
  can_update boolean DEFAULT false,
  can_delete boolean DEFAULT false,
  can_approve boolean DEFAULT false,
  scope character varying,
  conditions jsonb,
  created_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT role_permissions_pkey PRIMARY KEY (id),
  CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id),
  CONSTRAINT role_permissions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);

-- User Roles Table
CREATE TABLE IF NOT EXISTS public.user_roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  role_id uuid,
  assigned_by uuid,
  assigned_at timestamp without time zone DEFAULT now(),
  valid_from timestamp without time zone DEFAULT now(),
  valid_until timestamp without time zone,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT user_roles_pkey PRIMARY KEY (id),
  CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id)
);

-- ============================================================================
-- AUTHENTICATION & SECURITY TABLES
-- ============================================================================

-- OTP Codes Table
CREATE TABLE IF NOT EXISTS public.otp_codes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  otp_code character varying NOT NULL,
  otp_type character varying NOT NULL CHECK (otp_type::text = ANY (ARRAY['login'::character varying::text, 'email_verify'::character varying::text, 'phone_verify'::character varying::text, 'password_reset'::character varying::text])),
  sent_to character varying NOT NULL,
  delivery_method character varying CHECK (delivery_method::text = ANY (ARRAY['email'::character varying::text, 'sms'::character varying::text, 'whatsapp'::character varying::text])),
  is_used boolean DEFAULT false,
  used_at timestamp without time zone,
  expires_at timestamp without time zone NOT NULL,
  attempts integer DEFAULT 0,
  max_attempts integer DEFAULT 3,
  created_at timestamp without time zone DEFAULT now(),
  ip_address character varying,
  user_agent text,
  CONSTRAINT otp_codes_pkey PRIMARY KEY (id),
  CONSTRAINT otp_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Password Reset Tokens Table
CREATE TABLE IF NOT EXISTS public.password_reset_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  reset_token text NOT NULL UNIQUE,
  is_used boolean DEFAULT false,
  used_at timestamp without time zone,
  expires_at timestamp without time zone NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  ip_address character varying,
  CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- User Sessions Table
CREATE TABLE IF NOT EXISTS public.user_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  session_token text NOT NULL UNIQUE,
  refresh_token text UNIQUE,
  device_name character varying,
  device_type character varying,
  browser character varying,
  os character varying,
  ip_address character varying,
  user_agent text,
  country character varying,
  city character varying,
  is_active boolean DEFAULT true,
  expires_at timestamp without time zone NOT NULL,
  last_activity_at timestamp without time zone DEFAULT now(),
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT user_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Auth Audit Log Table
CREATE TABLE IF NOT EXISTS public.auth_audit_log (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  org_id uuid,
  event_type character varying NOT NULL,
  event_category character varying,
  action character varying NOT NULL,
  description text,
  target_user_id uuid,
  target_role_id uuid,
  ip_address character varying,
  user_agent text,
  location jsonb,
  status character varying CHECK (status::text = ANY (ARRAY['success'::character varying::text, 'failure'::character varying::text, 'warning'::character varying::text])),
  error_message text,
  metadata jsonb,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT auth_audit_log_pkey PRIMARY KEY (id),
  CONSTRAINT auth_audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT auth_audit_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT auth_audit_log_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id),
  CONSTRAINT auth_audit_log_target_role_id_fkey FOREIGN KEY (target_role_id) REFERENCES public.roles(id)
);

-- ============================================================================
-- DIRECTORY & EMPLOYEE MANAGEMENT
-- ============================================================================

-- Employees Table (Directory Module)
CREATE TABLE IF NOT EXISTS public.employees (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  user_id uuid,
  employee_id character varying NOT NULL UNIQUE,
  first_name character varying NOT NULL,
  last_name character varying NOT NULL,
  email character varying NOT NULL,
  date_of_birth date,
  gender character varying,
  date_of_joining date NOT NULL,
  date_of_exit date,
  employment_status character varying DEFAULT 'active'::character varying CHECK (employment_status::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text, 'on_leave'::character varying::text, 'separated'::character varying::text])),
  department character varying,
  designation character varying,
  manager_id uuid,
  location character varying,
  personal_pan character varying,
  aadhaar_number character varying,
  passport_number character varying,
  bank_name character varying,
  bank_account_number character varying,
  bank_ifsc_code character varying,
  bank_account_holder_name character varying,
  phone_number character varying,
  personal_email character varying,
  emergency_contact_name character varying,
  emergency_contact_phone character varying,
  emergency_contact_relation character varying,
  marital_status character varying,
  blood_group character varying,
  address text,
  city character varying,
  state character varying,
  postal_code character varying,
  country character varying,
  profile_image_url text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  updated_by uuid,
  CONSTRAINT employees_pkey PRIMARY KEY (id),
  CONSTRAINT employees_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT employees_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employees(id)
);

-- Employee Qualifications
CREATE TABLE IF NOT EXISTS public.employee_qualifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  qualification_type character varying NOT NULL,
  institution_name character varying NOT NULL,
  field_of_study character varying,
  grade_or_percentage character varying,
  completion_year integer,
  description text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_qualifications_pkey PRIMARY KEY (id),
  CONSTRAINT employee_qualifications_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_qualifications_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- Employee Work Experience
CREATE TABLE IF NOT EXISTS public.employee_work_experience (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  company_name character varying NOT NULL,
  job_title character varying NOT NULL,
  start_date date NOT NULL,
  end_date date,
  description text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_work_experience_pkey PRIMARY KEY (id),
  CONSTRAINT employee_work_experience_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_work_experience_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- ============================================================================
-- ATTENDANCE MODULE
-- ============================================================================

-- Attendance Table
CREATE TABLE IF NOT EXISTS public.attendance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  attendance_date date NOT NULL,
  check_in_time time without time zone,
  check_out_time time without time zone,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['present'::character varying::text, 'absent'::character varying::text, 'late'::character varying::text, 'leave'::character varying::text, 'holiday'::character varying::text, 'half_day'::character varying::text])),
  attendance_type character varying,
  hours_worked numeric,
  overtime_hours numeric DEFAULT 0,
  notes text,
  approved_by uuid,
  approved_at timestamp without time zone,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT attendance_pkey PRIMARY KEY (id),
  CONSTRAINT attendance_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT attendance_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- Attendance Summary Table
CREATE TABLE IF NOT EXISTS public.attendance_summary (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  attendance_month character varying NOT NULL,
  total_days_in_month integer DEFAULT 30,
  present_days integer DEFAULT 0,
  absent_days integer DEFAULT 0,
  leave_days integer DEFAULT 0,
  holiday_days integer DEFAULT 0,
  late_arrivals integer DEFAULT 0,
  half_days integer DEFAULT 0,
  working_days_expected integer,
  working_days_actual integer,
  attendance_percentage numeric,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT attendance_summary_pkey PRIMARY KEY (id),
  CONSTRAINT attendance_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT attendance_summary_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- ============================================================================
-- LEAVE MODULE
-- ============================================================================

-- Leave Types Table
CREATE TABLE IF NOT EXISTS public.leave_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  leave_type_name character varying NOT NULL,
  leave_type_code character varying NOT NULL UNIQUE,
  description text,
  days_per_year integer,
  is_paid boolean DEFAULT true,
  requires_approval boolean DEFAULT true,
  requires_medical_certificate boolean DEFAULT false,
  carryforward_days integer DEFAULT 0,
  expiry_days integer,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT leave_types_pkey PRIMARY KEY (id),
  CONSTRAINT leave_types_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Leave Allocation Table
CREATE TABLE IF NOT EXISTS public.leave_allocation (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  leave_type_id uuid NOT NULL,
  allocation_year integer NOT NULL,
  total_days integer NOT NULL,
  used_days integer DEFAULT 0,
  available_days integer,
  pending_days integer DEFAULT 0,
  carryforward_days integer DEFAULT 0,
  allocated_by uuid,
  allocated_at timestamp without time zone DEFAULT now(),
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT leave_allocation_pkey PRIMARY KEY (id),
  CONSTRAINT leave_allocation_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT leave_allocation_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT leave_allocation_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES public.leave_types(id)
);

-- Leave Requests Table
CREATE TABLE IF NOT EXISTS public.leave_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  leave_type_id uuid NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  total_days integer NOT NULL,
  reason text NOT NULL,
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text, 'cancelled'::character varying::text])),
  medical_certificate_url text,
  comments text,
  approved_by uuid,
  approved_at timestamp without time zone,
  rejection_reason text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT leave_requests_pkey PRIMARY KEY (id),
  CONSTRAINT leave_requests_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT leave_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT leave_requests_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES public.leave_types(id)
);

-- Leave Summary Table
CREATE TABLE IF NOT EXISTS public.leave_summary (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  leave_month character varying NOT NULL,
  casual_leave_taken integer DEFAULT 0,
  sick_leave_taken integer DEFAULT 0,
  earned_leave_taken integer DEFAULT 0,
  unpaid_leave_taken integer DEFAULT 0,
  other_leave_taken integer DEFAULT 0,
  total_leave_days_deducted integer DEFAULT 0,
  loss_of_pay numeric DEFAULT 0,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT leave_summary_pkey PRIMARY KEY (id),
  CONSTRAINT leave_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT leave_summary_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- ============================================================================
-- PAYROLL & SALARY MODULE
-- ============================================================================

-- Salary Structures Table
CREATE TABLE IF NOT EXISTS public.salary_structures (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  effective_from date NOT NULL,
  effective_till date,
  annual_ctc numeric,
  monthly_basic numeric NOT NULL,
  monthly_da numeric DEFAULT 0,
  monthly_hra numeric DEFAULT 0,
  monthly_allowance numeric DEFAULT 0,
  other_allowances jsonb,
  deductions jsonb,
  is_template boolean DEFAULT true,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT salary_structures_pkey PRIMARY KEY (id),
  CONSTRAINT salary_structures_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Employee Salary Assignments Table
CREATE TABLE IF NOT EXISTS public.employee_salary_assignments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  salary_structure_id uuid NOT NULL,
  effective_from date NOT NULL,
  effective_till date,
  override_monthly_basic numeric,
  override_monthly_da numeric,
  override_monthly_hra numeric,
  override_monthly_allowance numeric,
  override_annual_ctc numeric,
  assigned_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_salary_assignments_pkey PRIMARY KEY (id),
  CONSTRAINT employee_salary_assignments_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_salary_assignments_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT employee_salary_assignments_salary_structure_id_fkey FOREIGN KEY (salary_structure_id) REFERENCES public.salary_structures(id)
);

-- Statutory Rules Table
CREATE TABLE IF NOT EXISTS public.statutory_rules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid,
  rule_type character varying NOT NULL,
  state_code character varying,
  effective_from date NOT NULL,
  effective_till date,
  pf_employee_rate numeric,
  pf_employer_rate numeric,
  pf_ceiling numeric,
  esi_employee_rate numeric,
  esi_employer_rate numeric,
  esi_wage_ceiling numeric,
  esi_threshold_salary numeric,
  pt_slab_min numeric,
  pt_slab_max numeric,
  pt_amount numeric,
  tds_slab_min numeric,
  tds_slab_max numeric,
  tds_rate numeric,
  gratuity_rate_per_year numeric,
  gratuity_completion_months integer,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT statutory_rules_pkey PRIMARY KEY (id),
  CONSTRAINT statutory_rules_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Payroll Runs Table
CREATE TABLE IF NOT EXISTS public.payroll_runs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  payroll_period_start date NOT NULL,
  payroll_period_end date NOT NULL,
  payroll_month character varying,
  status character varying DEFAULT 'draft'::character varying CHECK (status::text = ANY (ARRAY['draft'::character varying::text, 'processing'::character varying::text, 'locked'::character varying::text, 'approved'::character varying::text, 'released'::character varying::text])),
  dry_run_count integer DEFAULT 0,
  total_employees integer DEFAULT 0,
  total_gross_amount numeric,
  total_deductions numeric,
  total_net_amount numeric,
  total_pf_employee numeric,
  total_pf_employer numeric,
  total_esi_employee numeric,
  total_esi_employer numeric,
  total_pt numeric,
  total_tds numeric,
  locked_at timestamp without time zone,
  locked_by uuid,
  approved_at timestamp without time zone,
  approved_by uuid,
  released_at timestamp without time zone,
  released_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  notes text,
  CONSTRAINT payroll_runs_pkey PRIMARY KEY (id),
  CONSTRAINT payroll_runs_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Payroll Components Table
CREATE TABLE IF NOT EXISTS public.payroll_components (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  payroll_run_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  salary_structure_id uuid,
  days_worked integer DEFAULT 0,
  days_absent integer DEFAULT 0,
  days_leave integer DEFAULT 0,
  days_in_month integer DEFAULT 30,
  basic_pay numeric,
  dearness_allowance numeric,
  house_rent_allowance numeric,
  other_allowances numeric,
  gross_amount numeric,
  pf_employee numeric DEFAULT 0,
  pf_employer numeric DEFAULT 0,
  esi_employee numeric DEFAULT 0,
  esi_employer numeric DEFAULT 0,
  professional_tax numeric DEFAULT 0,
  tds numeric DEFAULT 0,
  advance_recovery numeric DEFAULT 0,
  loan_recovery numeric DEFAULT 0,
  other_deductions numeric DEFAULT 0,
  total_deductions numeric,
  net_pay numeric,
  is_validated boolean DEFAULT false,
  validation_errors text,
  is_locked boolean DEFAULT false,
  locked_at timestamp without time zone,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT payroll_components_pkey PRIMARY KEY (id),
  CONSTRAINT payroll_components_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT payroll_components_payroll_run_id_fkey FOREIGN KEY (payroll_run_id) REFERENCES public.payroll_runs(id),
  CONSTRAINT payroll_components_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT payroll_components_salary_structure_id_fkey FOREIGN KEY (salary_structure_id) REFERENCES public.salary_structures(id)
);

-- Payroll Locks Table
CREATE TABLE IF NOT EXISTS public.payroll_locks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  payroll_run_id uuid NOT NULL UNIQUE,
  locked_at timestamp without time zone DEFAULT now(),
  locked_by uuid,
  lock_reason character varying,
  is_active boolean DEFAULT true,
  CONSTRAINT payroll_locks_pkey PRIMARY KEY (id),
  CONSTRAINT payroll_locks_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT payroll_locks_payroll_run_id_fkey FOREIGN KEY (payroll_run_id) REFERENCES public.payroll_runs(id)
);

-- Statutory Documents Table
CREATE TABLE IF NOT EXISTS public.statutory_documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  payroll_run_id uuid,
  document_type character varying NOT NULL,
  employee_id uuid,
  file_name character varying,
  file_path text,
  file_size integer,
  generated_at timestamp without time zone DEFAULT now(),
  generated_by uuid,
  is_generated boolean DEFAULT false,
  is_filed boolean DEFAULT false,
  filed_at timestamp without time zone,
  metadata jsonb,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT statutory_documents_pkey PRIMARY KEY (id),
  CONSTRAINT statutory_documents_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT statutory_documents_payroll_run_id_fkey FOREIGN KEY (payroll_run_id) REFERENCES public.payroll_runs(id),
  CONSTRAINT statutory_documents_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- ============================================================================
-- PERFORMANCE MANAGEMENT MODULE
-- ============================================================================

-- Performance Reviews Table
CREATE TABLE IF NOT EXISTS public.performance_reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  reviewer_id uuid NOT NULL,
  review_period_start date NOT NULL,
  review_period_end date NOT NULL,
  overall_rating numeric,
  comments text,
  strengths text,
  areas_for_improvement text,
  goals_achieved text,
  status character varying DEFAULT 'draft'::character varying CHECK (status::text = ANY (ARRAY['draft'::character varying::text, 'submitted'::character varying::text, 'approved'::character varying::text])),
  submitted_at timestamp without time zone,
  approved_at timestamp without time zone,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT performance_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT performance_reviews_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT performance_reviews_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT performance_reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.employees(id)
);

-- Performance Criteria Table
CREATE TABLE IF NOT EXISTS public.performance_criteria (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  performance_review_id uuid NOT NULL,
  criteria_name character varying NOT NULL,
  rating numeric,
  weight numeric DEFAULT 1.0,
  comments text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT performance_criteria_pkey PRIMARY KEY (id),
  CONSTRAINT performance_criteria_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT performance_criteria_performance_review_id_fkey FOREIGN KEY (performance_review_id) REFERENCES public.performance_reviews(id)
);

-- ============================================================================
-- RECRUITMENT MODULE
-- ============================================================================

-- Job Openings Table
CREATE TABLE IF NOT EXISTS public.job_openings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  job_title character varying NOT NULL,
  job_code character varying NOT NULL UNIQUE,
  department character varying NOT NULL,
  location character varying NOT NULL,
  description text,
  requirements text,
  salary_range_min numeric,
  salary_range_max numeric,
  job_type character varying,
  status character varying DEFAULT 'open'::character varying CHECK (status::text = ANY (ARRAY['draft'::character varying::text, 'open'::character varying::text, 'closed'::character varying::text, 'on_hold'::character varying::text])),
  created_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  published_date date,
  closing_date date,
  CONSTRAINT job_openings_pkey PRIMARY KEY (id),
  CONSTRAINT job_openings_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Job Applications Table
CREATE TABLE IF NOT EXISTS public.job_applications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  job_opening_id uuid NOT NULL,
  applicant_name character varying NOT NULL,
  applicant_email character varying NOT NULL,
  applicant_phone character varying NOT NULL,
  resume_url text,
  portfolio_url text,
  cover_letter text,
  current_company character varying,
  current_designation character varying,
  years_of_experience integer,
  status character varying DEFAULT 'applied'::character varying CHECK (status::text = ANY (ARRAY['applied'::character varying::text, 'shortlisted'::character varying::text, 'interviewed'::character varying::text, 'selected'::character varying::text, 'rejected'::character varying::text, 'offer_accepted'::character varying::text, 'offer_rejected'::character varying::text])),
  applied_date timestamp without time zone DEFAULT now(),
  screening_notes text,
  interview_date timestamp without time zone,
  interview_notes text,
  final_rating numeric,
  final_decision text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT job_applications_pkey PRIMARY KEY (id),
  CONSTRAINT job_applications_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT job_applications_job_opening_id_fkey FOREIGN KEY (job_opening_id) REFERENCES public.job_openings(id)
);

-- ============================================================================
-- LEARNING & DEVELOPMENT MODULE
-- ============================================================================

-- Training Programs Table
CREATE TABLE IF NOT EXISTS public.training_programs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  program_name character varying NOT NULL,
  description text,
  program_type character varying,
  duration_days integer,
  start_date date NOT NULL,
  end_date date NOT NULL,
  trainer_name character varying,
  location character varying,
  max_participants integer,
  current_participants integer DEFAULT 0,
  status character varying DEFAULT 'scheduled'::character varying CHECK (status::text = ANY (ARRAY['scheduled'::character varying::text, 'ongoing'::character varying::text, 'completed'::character varying::text, 'cancelled'::character varying::text])),
  cost_per_employee numeric,
  budget numeric,
  created_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT training_programs_pkey PRIMARY KEY (id),
  CONSTRAINT training_programs_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Training Enrollments Table
CREATE TABLE IF NOT EXISTS public.training_enrollments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  training_program_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  enrollment_date date NOT NULL,
  completion_date date,
  status character varying DEFAULT 'enrolled'::character varying,
  feedback_rating numeric,
  feedback_comments text,
  certificate_url text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT training_enrollments_pkey PRIMARY KEY (id),
  CONSTRAINT training_enrollments_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT training_enrollments_training_program_id_fkey FOREIGN KEY (training_program_id) REFERENCES public.training_programs(id),
  CONSTRAINT training_enrollments_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- ============================================================================
-- BENEFITS MODULE
-- ============================================================================

-- Benefits Types Table
CREATE TABLE IF NOT EXISTS public.benefits_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  benefit_name character varying NOT NULL,
  benefit_code character varying NOT NULL UNIQUE,
  benefit_type character varying,
  description text,
  provider_name character varying,
  coverage_amount numeric,
  premium_amount numeric,
  is_taxable boolean DEFAULT false,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT benefits_types_pkey PRIMARY KEY (id),
  CONSTRAINT benefits_types_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Employee Benefits Table
CREATE TABLE IF NOT EXISTS public.employee_benefits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  benefit_type_id uuid NOT NULL,
  benefit_start_date date NOT NULL,
  benefit_end_date date,
  coverage_status character varying,
  enrolled_at timestamp without time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_benefits_pkey PRIMARY KEY (id),
  CONSTRAINT employee_benefits_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_benefits_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT employee_benefits_benefit_type_id_fkey FOREIGN KEY (benefit_type_id) REFERENCES public.benefits_types(id)
);

-- ============================================================================
-- ONBOARDING MODULE
-- ============================================================================

-- Onboarding Checklists Table
CREATE TABLE IF NOT EXISTS public.onboarding_checklists (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  checklist_name character varying NOT NULL,
  assigned_to_user_id uuid,
  assigned_date date NOT NULL,
  due_date date NOT NULL,
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying::text, 'in_progress'::character varying::text, 'completed'::character varying::text, 'skipped'::character varying::text])),
  completion_date timestamp without time zone,
  notes text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT onboarding_checklists_pkey PRIMARY KEY (id),
  CONSTRAINT onboarding_checklists_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT onboarding_checklists_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- Onboarding Tasks Table
CREATE TABLE IF NOT EXISTS public.onboarding_tasks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  onboarding_checklist_id uuid NOT NULL,
  task_name character varying NOT NULL,
  description text,
  task_order integer,
  status character varying DEFAULT 'pending'::character varying,
  completed_at timestamp without time zone,
  completed_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT onboarding_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT onboarding_tasks_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT onboarding_tasks_onboarding_checklist_id_fkey FOREIGN KEY (onboarding_checklist_id) REFERENCES public.onboarding_checklists(id)
);

-- ============================================================================
-- RECOGNITION MODULE
-- ============================================================================

-- Employee Recognition Table
CREATE TABLE IF NOT EXISTS public.employee_recognition (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  recognized_employee_id uuid NOT NULL,
  recognized_by_user_id uuid NOT NULL,
  recognition_type character varying NOT NULL,
  title character varying NOT NULL,
  description text,
  award_category character varying,
  awarded_on date,
  points_awarded integer DEFAULT 0,
  visibility character varying DEFAULT 'public'::character varying,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_recognition_pkey PRIMARY KEY (id),
  CONSTRAINT employee_recognition_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_recognition_recognized_employee_id_fkey FOREIGN KEY (recognized_employee_id) REFERENCES public.employees(id),
  CONSTRAINT employee_recognition_recognized_by_user_id_fkey FOREIGN KEY (recognized_by_user_id) REFERENCES public.users(id)
);

-- ============================================================================
-- GOALS MODULE (MY GOALS)
-- ============================================================================

-- Employee Goals Table
CREATE TABLE IF NOT EXISTS public.employee_goals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  goal_title character varying NOT NULL,
  description text,
  goal_category character varying,
  start_date date NOT NULL,
  end_date date NOT NULL,
  target_value character varying,
  progress_percentage numeric DEFAULT 0,
  status character varying DEFAULT 'in_progress'::character varying CHECK (status::text = ANY (ARRAY['draft'::character varying::text, 'in_progress'::character varying::text, 'completed'::character varying::text, 'cancelled'::character varying::text])),
  priority character varying DEFAULT 'medium'::character varying,
  created_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_goals_pkey PRIMARY KEY (id),
  CONSTRAINT employee_goals_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_goals_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- Goal Progress Table
CREATE TABLE IF NOT EXISTS public.goal_progress (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  goal_id uuid NOT NULL,
  progress_date date NOT NULL,
  progress_percentage numeric,
  comments text,
  updated_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT goal_progress_pkey PRIMARY KEY (id),
  CONSTRAINT goal_progress_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT goal_progress_goal_id_fkey FOREIGN KEY (goal_id) REFERENCES public.employee_goals(id)
);

-- ============================================================================
-- TRAVEL MODULE
-- ============================================================================

-- Travel Requests Table
CREATE TABLE IF NOT EXISTS public.travel_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  trip_purpose character varying NOT NULL,
  trip_type character varying NOT NULL,
  departure_date date NOT NULL,
  return_date date NOT NULL,
  source_location character varying NOT NULL,
  destination_location character varying NOT NULL,
  estimated_budget numeric,
  actual_budget numeric,
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text, 'completed'::character varying::text, 'cancelled'::character varying::text])),
  approved_by uuid,
  approval_comments text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT travel_requests_pkey PRIMARY KEY (id),
  CONSTRAINT travel_requests_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT travel_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- ============================================================================
-- EXPENSES MODULE
-- ============================================================================

-- Expense Categories Table
CREATE TABLE IF NOT EXISTS public.expense_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  category_name character varying NOT NULL,
  category_code character varying NOT NULL UNIQUE,
  description text,
  budget_limit numeric,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT expense_categories_pkey PRIMARY KEY (id),
  CONSTRAINT expense_categories_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Expense Reports Table
CREATE TABLE IF NOT EXISTS public.expense_reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  expense_month character varying NOT NULL,
  report_title character varying NOT NULL,
  description text,
  total_amount numeric DEFAULT 0,
  status character varying DEFAULT 'draft'::character varying CHECK (status::text = ANY (ARRAY['draft'::character varying::text, 'submitted'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text, 'paid'::character varying::text])),
  submitted_at timestamp without time zone,
  approved_by uuid,
  approval_date timestamp without time zone,
  paid_at timestamp without time zone,
  rejection_reason text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT expense_reports_pkey PRIMARY KEY (id),
  CONSTRAINT expense_reports_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT expense_reports_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- Expense Details Table
CREATE TABLE IF NOT EXISTS public.expense_details (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  expense_report_id uuid NOT NULL,
  expense_category_id uuid NOT NULL,
  expense_date date NOT NULL,
  description character varying NOT NULL,
  amount numeric NOT NULL,
  currency character varying DEFAULT 'INR',
  receipt_url text,
  notes text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT expense_details_pkey PRIMARY KEY (id),
  CONSTRAINT expense_details_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT expense_details_expense_report_id_fkey FOREIGN KEY (expense_report_id) REFERENCES public.expense_reports(id),
  CONSTRAINT expense_details_expense_category_id_fkey FOREIGN KEY (expense_category_id) REFERENCES public.expense_categories(id)
);

-- ============================================================================
-- COMPLIANCE MODULE
-- ============================================================================

-- Compliance Requirements Table
CREATE TABLE IF NOT EXISTS public.compliance_requirements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  requirement_name character varying NOT NULL,
  requirement_code character varying NOT NULL UNIQUE,
  description text,
  requirement_type character varying,
  frequency character varying,
  due_date date,
  responsible_department character varying,
  status character varying DEFAULT 'pending'::character varying,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT compliance_requirements_pkey PRIMARY KEY (id),
  CONSTRAINT compliance_requirements_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Employee Compliance Table
CREATE TABLE IF NOT EXISTS public.employee_compliance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  compliance_requirement_id uuid NOT NULL,
  completion_date date,
  status character varying DEFAULT 'pending'::character varying,
  document_url text,
  verified_by uuid,
  verified_at timestamp without time zone,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_compliance_pkey PRIMARY KEY (id),
  CONSTRAINT employee_compliance_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_compliance_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT employee_compliance_compliance_requirement_id_fkey FOREIGN KEY (compliance_requirement_id) REFERENCES public.compliance_requirements(id)
);

-- ============================================================================
-- HR CONNECT MODULE (Internal Communication)
-- ============================================================================

-- HR Messages Table
CREATE TABLE IF NOT EXISTS public.hr_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  sender_id uuid NOT NULL,
  recipient_id uuid,
  is_broadcast boolean DEFAULT false,
  subject character varying NOT NULL,
  message_body text NOT NULL,
  attachment_url text,
  is_read boolean DEFAULT false,
  read_at timestamp without time zone,
  status character varying DEFAULT 'sent'::character varying,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT hr_messages_pkey PRIMARY KEY (id),
  CONSTRAINT hr_messages_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT hr_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id),
  CONSTRAINT hr_messages_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id)
);

-- HR Announcements Table
CREATE TABLE IF NOT EXISTS public.hr_announcements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  created_by uuid NOT NULL,
  announcement_title character varying NOT NULL,
  announcement_body text NOT NULL,
  priority character varying DEFAULT 'normal'::character varying,
  valid_from date NOT NULL,
  valid_until date,
  recipient_roles character varying[],
  recipient_departments character varying[],
  is_published boolean DEFAULT true,
  view_count integer DEFAULT 0,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT hr_announcements_pkey PRIMARY KEY (id),
  CONSTRAINT hr_announcements_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT hr_announcements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);

-- ============================================================================
-- CONFIGURATION MODULE
-- ============================================================================

-- System Configuration Table
CREATE TABLE IF NOT EXISTS public.system_configuration (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  config_key character varying NOT NULL UNIQUE,
  config_value text,
  config_type character varying,
  description text,
  is_editable boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  updated_by uuid,
  CONSTRAINT system_configuration_pkey PRIMARY KEY (id),
  CONSTRAINT system_configuration_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- ============================================================================
-- ANALYTICS & AUDIT TABLES
-- ============================================================================

-- Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  entity_type character varying NOT NULL,
  entity_id uuid NOT NULL,
  action character varying NOT NULL,
  old_values jsonb,
  new_values jsonb,
  performed_by uuid,
  performed_at timestamp without time zone DEFAULT now(),
  ip_address inet,
  user_agent text,
  notes text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT audit_logs_pkey PRIMARY KEY (id),
  CONSTRAINT audit_logs_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- Analytics Dashboard Data Table
CREATE TABLE IF NOT EXISTS public.analytics_data (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  metric_name character varying NOT NULL,
  metric_value numeric,
  metric_date date NOT NULL,
  period character varying,
  dimension jsonb,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT analytics_data_pkey PRIMARY KEY (id),
  CONSTRAINT analytics_data_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_employees_org_id ON public.employees(org_id);
CREATE INDEX IF NOT EXISTS idx_employees_user_id ON public.employees(user_id);
CREATE INDEX IF NOT EXISTS idx_users_org_id ON public.users(org_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON public.user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_attendance_employee_id ON public.attendance(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON public.attendance(attendance_date);
CREATE INDEX IF NOT EXISTS idx_leave_requests_employee_id ON public.leave_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_payroll_runs_org_id ON public.payroll_runs(org_id);
CREATE INDEX IF NOT EXISTS idx_payroll_components_payroll_run_id ON public.payroll_components(payroll_run_id);
CREATE INDEX IF NOT EXISTS idx_performance_reviews_employee_id ON public.performance_reviews(employee_id);
CREATE INDEX IF NOT EXISTS idx_training_enrollments_employee_id ON public.training_enrollments(employee_id);
CREATE INDEX IF NOT EXISTS idx_employee_goals_employee_id ON public.employee_goals(employee_id);
CREATE INDEX IF NOT EXISTS idx_travel_requests_employee_id ON public.travel_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_expense_reports_employee_id ON public.expense_reports(employee_id);
CREATE INDEX IF NOT EXISTS idx_otp_codes_user_id ON public.otp_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_audit_log_user_id ON public.auth_audit_log(user_id);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
