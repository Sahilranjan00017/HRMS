import { Router, Request, Response } from 'express';
import { supabase } from '../config/database';
import { sendOTPEmail, verifyOTP, generateOTP } from '../utils/otpService';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from '../utils/jwtService';

const router = Router();

// Send OTP for login (No user validation - DB only)
router.post('/send-otp', async (req: Request, res: Response) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }

    // Generate OTP
    const otpCode = generateOTP();
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + parseInt(process.env.OTP_EXPIRY_MINUTES || '10'));

    // Store OTP in database
    const { error: insertError } = await supabase
      .from('otp_codes')
      .insert({
        user_id: null, // No user validation
        otp_code: otpCode,
        otp_type: 'login',
        sent_to: email,
        delivery_method: 'email',
        expires_at: expiresAt.toISOString(),
        ip_address: req.ip || 'unknown',
        user_agent: req.get('user-agent') || 'unknown',
      });

    if (insertError) {
      console.error('Error storing OTP:', insertError);
      return res.status(500).json({ success: false, message: 'Failed to generate OTP' });
    }

    // Send email
    const { sendEmail, getOTPEmailTemplate } = await import('../utils/emailService');
    const emailSent = await sendEmail({
      to: email,
      subject: 'Your HRMS Login OTP',
      html: getOTPEmailTemplate(otpCode, email.split('@')[0]),
    });

    if (!emailSent) {
      return res.status(500).json({ success: false, message: 'Failed to send OTP email' });
    }

    return res.status(200).json({
      success: true,
      message: `OTP sent successfully to ${email}`,
    });
  } catch (error) {
    console.error('Error in send-otp:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Verify OTP (simplified - no user validation)
router.post('/verify-otp', async (req: Request, res: Response) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }

    // Verify OTP from database
    const { data: otpRecord } = await supabase
      .from('otp_codes')
      .select('*')
      .eq('sent_to', email)
      .eq('otp_code', otp)
      .eq('is_used', false)
      .gt('expires_at', new Date().toISOString())
      .order('created_at', { ascending: false })
      .limit(1)
      .single();

    if (!otpRecord) {
      return res.status(401).json({ success: false, message: 'Invalid or expired OTP' });
    }

    // Mark OTP as used
    await supabase
      .from('otp_codes')
      .update({ is_used: true, used_at: new Date().toISOString() })
      .eq('id', otpRecord.id);

    // Generate simple token with email only (no user roles)
    const accessToken = generateAccessToken({
      userId: 'temp-' + Date.now(),
      email,
      roles: [],
    });

    const refreshToken = generateRefreshToken({
      userId: 'temp-' + Date.now(),
      email,
      roles: [],
    });

    // Return success with tokens (simplified - no user session tracking)
    return res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
      accessToken,
      refreshToken,
      email,
    });
  } catch (error) {
    console.error('Error in verify-otp:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Refresh token
router.post('/refresh-token', async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ success: false, message: 'Refresh token is required' });
    }

    const payload = verifyRefreshToken(refreshToken);

    if (!payload) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }

    const newAccessToken = generateAccessToken(payload);

    return res.status(200).json({
      success: true,
      accessToken: newAccessToken,
    });
  } catch (error) {
    console.error('Error in refresh-token:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Logout
router.post('/logout', async (req: Request, res: Response) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(400).json({ success: false, message: 'Token is required' });
    }

    await supabase
      .from('user_sessions')
      .update({ is_active: false })
      .eq('session_token', token);

    return res.status(200).json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    console.error('Error in logout:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
