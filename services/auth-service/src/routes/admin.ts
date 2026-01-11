import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { supabase } from '../config/database';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

// Create new user (Admin only)
router.post('/create-user', async (req: Request, res: Response) => {
  try {
    const { email, full_name, phone, role_code, org_id } = req.body;

    if (!email || !full_name || !role_code || !org_id) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // Check if user already exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .single();

    if (existingUser) {
      return res.status(409).json({ success: false, message: 'User already exists' });
    }

    // Get role ID
    const { data: role } = await supabase
      .from('roles')
      .select('id')
      .eq('role_code', role_code)
      .eq('org_id', org_id)
      .single();

    if (!role) {
      return res.status(404).json({ success: false, message: 'Role not found' });
    }

    // Create user
    const userId = uuidv4();
    const { error: createError } = await supabase
      .from('users')
      .insert({
        id: userId,
        org_id,
        email,
        full_name,
        phone,
        status: 'pending',
        is_email_verified: false,
      });

    if (createError) {
      return res.status(500).json({ success: false, message: 'Failed to create user' });
    }

    // Assign role to user
    await supabase
      .from('user_roles')
      .insert({
        user_id: userId,
        role_id: role.id,
        is_active: true,
      });

    // Log audit
    await supabase
      .from('auth_audit_log')
      .insert({
        org_id,
        user_id: userId,
        event_type: 'user_created',
        event_category: 'admin',
        action: 'User created by admin',
        status: 'success',
      });

    return res.status(201).json({
      success: true,
      message: 'User created successfully. Admin will set password.',
      userId,
    });
  } catch (error) {
    console.error('Error creating user:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Set password for user (Admin sets initial password)
router.post('/set-user-password', async (req: Request, res: Response) => {
  try {
    const { userId, password } = req.body;

    if (!userId || !password) {
      return res.status(400).json({ success: false, message: 'User ID and password are required' });
    }

    if (password.length < 8) {
      return res.status(400).json({ success: false, message: 'Password must be at least 8 characters' });
    }

    const hashedPassword = await bcrypt.hash(password, parseInt(process.env.BCRYPT_ROUNDS || '10'));

    const { error } = await supabase
      .from('users')
      .update({
        password_hash: hashedPassword,
        status: 'active',
        must_change_password: true,
      })
      .eq('id', userId);

    if (error) {
      return res.status(500).json({ success: false, message: 'Failed to set password' });
    }

    return res.status(200).json({ success: true, message: 'Password set successfully' });
  } catch (error) {
    console.error('Error setting password:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get all users (Admin only)
router.get('/users', async (req: Request, res: Response) => {
  try {
    const { org_id } = req.query;

    if (!org_id) {
      return res.status(400).json({ success: false, message: 'Organization ID is required' });
    }

    const { data: users, error } = await supabase
      .from('users')
      .select('id, email, full_name, phone, status, created_at')
      .eq('org_id', org_id);

    if (error) {
      return res.status(500).json({ success: false, message: 'Failed to fetch users' });
    }

    return res.status(200).json({ success: true, data: users });
  } catch (error) {
    console.error('Error fetching users:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get user permissions
router.get('/user-permissions/:userId', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;

    const { data: userRoles } = await supabase
      .from('user_roles')
      .select('roles(id, role_code)')
      .eq('user_id', userId)
      .eq('is_active', true);

    const roleIds = userRoles?.map((ur: any) => ur.roles.id) || [];

    if (roleIds.length === 0) {
      return res.status(200).json({ success: true, permissions: [] });
    }

    const { data: permissions } = await supabase
      .from('role_permissions')
      .select('permissions(permission_code, module, category)')
      .in('role_id', roleIds);

    const uniquePermissions = Array.from(
      new Map(
        permissions?.map((p: any) => [p.permissions.permission_code, p.permissions]) || []
      ).values()
    );

    return res.status(200).json({ success: true, permissions: uniquePermissions });
  } catch (error) {
    console.error('Error fetching permissions:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
