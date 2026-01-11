import { supabase } from '../config/database';
import { sendEmail, getOTPEmailTemplate } from './emailService';

const OTP_LENGTH = parseInt(process.env.OTP_LENGTH || '6');
const OTP_EXPIRY_MINUTES = parseInt(process.env.OTP_EXPIRY_MINUTES || '10');
const OTP_MAX_ATTEMPTS = parseInt(process.env.OTP_MAX_ATTEMPTS || '3');

export function generateOTP(): string {
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < OTP_LENGTH; i++) {
    otp += digits[Math.floor(Math.random() * 10)];
  }
  return otp;
}

export async function sendOTPEmail(
  userId: string,
  email: string,
  userName: string,
  otpType: string = 'login',
  ipAddress?: string,
  userAgent?: string
): Promise<{ success: boolean; message: string }> {
  try {
    const otpCode = generateOTP();
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + OTP_EXPIRY_MINUTES);

    const { error: insertError } = await supabase
      .from('otp_codes')
      .insert({
        user_id: userId,
        otp_code: otpCode,
        otp_type: otpType,
        sent_to: email,
        delivery_method: 'email',
        expires_at: expiresAt.toISOString(),
        ip_address: ipAddress,
        user_agent: userAgent,
      });

    if (insertError) {
      console.error('Error storing OTP:', insertError);
      return { success: false, message: 'Failed to generate OTP' };
    }

    const emailSent = await sendEmail({
      to: email,
      subject: 'Your HRMS Login OTP',
      html: getOTPEmailTemplate(otpCode, userName),
    });

    if (!emailSent) {
      return { success: false, message: 'Failed to send OTP email' };
    }

    return {
      success: true,
      message: `OTP sent successfully to ${email}`,
    };
  } catch (error) {
    console.error('Error in sendOTPEmail:', error);
    return { success: false, message: 'Internal server error' };
  }
}

export async function verifyOTP(
  email: string,
  otpCode: string,
  otpType: string = 'login'
): Promise<{ success: boolean; message: string; userId?: string }> {
  try {
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, status, locked_until')
      .eq('email', email)
      .single();

    if (userError || !user) {
      return { success: false, message: 'User not found' };
    }

    if (user.locked_until && new Date(user.locked_until) > new Date()) {
      return {
        success: false,
        message: 'Account is temporarily locked. Please try again later.',
      };
    }

    if (user.status !== 'active') {
      return { success: false, message: 'Account is not active' };
    }

    const { data: otpRecord, error: otpError } = await supabase
      .from('otp_codes')
      .select('*')
      .eq('user_id', user.id)
      .eq('otp_code', otpCode)
      .eq('otp_type', otpType)
      .eq('is_used', false)
      .gt('expires_at', new Date().toISOString())
      .single();

    if (otpError || !otpRecord) {
      // Increment attempts
      const { data: attemptRecord } = await supabase
        .from('otp_codes')
        .select('attempts, max_attempts')
        .eq('user_id', user.id)
        .eq('otp_type', otpType)
        .eq('is_used', false)
        .single();

      if (attemptRecord && attemptRecord.attempts >= OTP_MAX_ATTEMPTS - 1) {
        return { success: false, message: 'Maximum OTP attempts exceeded. Please request a new OTP.' };
      }

      return { success: false, message: 'Invalid or expired OTP' };
    }

    // Mark OTP as used
    await supabase
      .from('otp_codes')
      .update({ is_used: true, used_at: new Date().toISOString() })
      .eq('id', otpRecord.id);

    // Update last login
    await supabase
      .from('users')
      .update({ last_login_at: new Date().toISOString() })
      .eq('id', user.id);

    return {
      success: true,
      message: 'OTP verified successfully',
      userId: user.id,
    };
  } catch (error) {
    console.error('Error in verifyOTP:', error);
    return { success: false, message: 'Internal server error' };
  }
}
