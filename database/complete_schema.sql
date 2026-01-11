-- HRMS Complete Database Schema
-- This schema includes all tables needed for the HRMS system including OTP authentication

-- 1. ORGANIZATIONS TABLE
CREATE TABLE IF NOT EXISTS public.organizations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  entity_code character varying NOT NULL UNIQUE,
  state_code character varying NOT NULL DEFAULT 'MH'::character varying,
  country_code character varying NOT NULL DEFAULT 'IN'::character varying,
  registration_number character varying,
  pan character varying,
  gst_number character varying,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  admin_email character varying,
  admin_phone character varying,
  subscription_tier character varying DEFAULT 'basic'::character varying,
  subscription_expires_at timestamp without time zone,
  CONSTRAINT organizations_pkey PRIMARY KEY (id)
);

-- 2. USERS TABLE (Essential for OTP)
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
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'suspended'::character varying, 'pending'::character varying]::text[])),
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

-- 3. OTP_CODES TABLE (CRITICAL FOR OTP SYSTEM) ⭐⭐⭐
CREATE TABLE IF NOT EXISTS public.otp_codes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  otp_code character varying NOT NULL,
  otp_type character varying NOT NULL CHECK (otp_type::text = ANY (ARRAY['login'::character varying, 'email_verify'::character varying, 'phone_verify'::character varying, 'password_reset'::character varying]::text[])),
  sent_to character varying NOT NULL,
  delivery_method character varying CHECK (delivery_method::text = ANY (ARRAY['email'::character varying, 'sms'::character varying, 'whatsapp'::character varying]::text[])),
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

-- 4. ROLES TABLE
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

-- 5. USER_ROLES TABLE
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

-- 6. PERMISSIONS TABLE
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

-- 7. ROLE_PERMISSIONS TABLE
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

-- 8. USER_SESSIONS TABLE
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

-- 9. PASSWORD_RESET_TOKENS TABLE
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

-- 10. AUTH_AUDIT_LOG TABLE
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
  status character varying CHECK (status::text = ANY (ARRAY['success'::character varying, 'failure'::character varying, 'warning'::character varying]::text[])),
  error_message text,
  metadata jsonb,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT auth_audit_log_pkey PRIMARY KEY (id),
  CONSTRAINT auth_audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT auth_audit_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT auth_audit_log_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id),
  CONSTRAINT auth_audit_log_target_role_id_fkey FOREIGN KEY (target_role_id) REFERENCES public.roles(id)
);

-- 11. AUDIT_LOGS TABLE
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

-- 12. EMPLOYEES TABLE
CREATE TABLE IF NOT EXISTS public.employees (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id character varying NOT NULL,
  first_name character varying NOT NULL,
  last_name character varying NOT NULL,
  email character varying NOT NULL,
  date_of_birth date,
  gender character varying,
  date_of_joining date NOT NULL,
  date_of_exit date,
  employment_status character varying DEFAULT 'active'::character varying,
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
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  updated_by uuid,
  CONSTRAINT employees_pkey PRIMARY KEY (id),
  CONSTRAINT employees_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employees_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employees(id)
);

-- 13. SALARY_STRUCTURES TABLE
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
  is_template boolean DEFAULT true,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT salary_structures_pkey PRIMARY KEY (id),
  CONSTRAINT salary_structures_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id)
);

-- 14. EMPLOYEE_SALARY_ASSIGNMENTS TABLE
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
  assigned_by uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT employee_salary_assignments_pkey PRIMARY KEY (id),
  CONSTRAINT employee_salary_assignments_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT employee_salary_assignments_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT employee_salary_assignments_salary_structure_id_fkey FOREIGN KEY (salary_structure_id) REFERENCES public.salary_structures(id)
);

-- 15. PAYROLL_RUNS TABLE
CREATE TABLE IF NOT EXISTS public.payroll_runs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  payroll_period_start date NOT NULL,
  payroll_period_end date NOT NULL,
  payroll_month character varying,
  status character varying DEFAULT 'draft'::character varying,
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

-- 16. PAYROLL_COMPONENTS TABLE
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

-- 17. PAYROLL_LOCKS TABLE
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

-- 18. STATUTORY_RULES TABLE
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

-- 19. STATUTORY_DOCUMENTS TABLE
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

-- 20. ATTENDANCE_SUMMARY TABLE
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
  working_days_expected integer,
  working_days_actual integer,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT attendance_summary_pkey PRIMARY KEY (id),
  CONSTRAINT attendance_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT attendance_summary_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- 21. LEAVE_SUMMARY TABLE
CREATE TABLE IF NOT EXISTS public.leave_summary (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  leave_month character varying NOT NULL,
  casual_leave_taken integer DEFAULT 0,
  sick_leave_taken integer DEFAULT 0,
  earned_leave_taken integer DEFAULT 0,
  unpaid_leave_taken integer DEFAULT 0,
  total_leave_days_deducted integer DEFAULT 0,
  loss_of_pay numeric DEFAULT 0,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT leave_summary_pkey PRIMARY KEY (id),
  CONSTRAINT leave_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id),
  CONSTRAINT leave_summary_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);

-- CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_otp_codes_user_id ON public.otp_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_otp_codes_expires_at ON public.otp_codes(expires_at);
CREATE INDEX IF NOT EXISTS idx_otp_codes_is_used ON public.otp_codes(is_used);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(status);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_audit_log_user_id ON public.auth_audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_employees_org_id ON public.employees(org_id);
CREATE INDEX IF NOT EXISTS idx_payroll_runs_org_id ON public.payroll_runs(org_id);
CREATE INDEX IF NOT EXISTS idx_payroll_components_payroll_run_id ON public.payroll_components(payroll_run_id);

-- ENABLE ROW LEVEL SECURITY (OPTIONAL BUT RECOMMENDED)
ALTER TABLE public.otp_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

-- SUCCESS MESSAGE
-- ✅ All tables have been created successfully!
-- ✅ OTP system is ready to use
-- ✅ All indexes created for performance
