import path from 'path';
import fs from 'fs';
import dotenv from 'dotenv';

// Try multiple possible locations for .env.local
const possiblePaths = [
  path.join(process.cwd(), '.env.local'),
  path.join(__dirname, '../../.env.local'),
  '/workspaces/HRMS/services/auth-service/.env.local',
];

let envLoaded = false;
for (const envPath of possiblePaths) {
  if (fs.existsSync(envPath)) {
    console.log(`Loading env from: ${envPath}`);
    dotenv.config({ path: envPath });
    envLoaded = true;
    break;
  }
}

if (!envLoaded) {
  console.warn('Warning: .env.local not found in any expected location');
  console.warn('Tried:', possiblePaths);
}

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase credentials:');
  console.error('SUPABASE_URL:', supabaseUrl ? '✓' : '✗', '=', supabaseUrl ? '***' : 'NOT SET');
  console.error('SUPABASE_SERVICE_KEY:', supabaseKey ? '✓' : '✗', '=', supabaseKey ? '***' : 'NOT SET');
  console.error('Current working directory:', process.cwd());
  console.error('Loaded env keys:', Object.keys(process.env).filter(k => k.includes('SUPABASE')));
  throw new Error('Missing Supabase credentials');
}

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

export interface User {
  id: string;
  org_id: string;
  email: string;
  phone?: string;
  full_name: string;
  status: 'active' | 'inactive' | 'suspended' | 'pending';
  created_at: string;
}

export interface OTPCode {
  id: string;
  user_id: string;
  otp_code: string;
  otp_type: string;
  sent_to: string;
  is_used: boolean;
  expires_at: string;
  attempts: number;
}
