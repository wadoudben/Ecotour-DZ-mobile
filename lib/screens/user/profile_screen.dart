import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String role; // 'user', 'author', 'admin'
  final bool inDashboardMode;
  final VoidCallback onToggleDashboard;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.inDashboardMode,
    required this.onToggleDashboard,
    required this.onLogout,
    required this.onEditProfile,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _RoleBadge(role: role),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACCOUNT SECTION
            const Text(
              'Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _ProfileTile(
              icon: Icons.person,
              title: 'Edit personal information',
              subtitle: 'Update your name, email or avatar.',
              onTap: () {
                onEditProfile();
              },
            ),
            _ProfileTile(
              icon: Icons.lock,
              title: 'Change password',
              subtitle: 'Update your account password.',
              onTap: () {
                onChangePassword();
              },
            ),

            const SizedBox(height: 24),

            // ROLE / DASHBOARD SECTION
            if (role == 'author' || role == 'admin') ...[
              const Text(
                'Role & tools',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onToggleDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Icon(
                    inDashboardMode
                        ? Icons.exit_to_app
                        : Icons.dashboard_customize,
                  ),
                  label: Text(
                    inDashboardMode
                        ? 'Exit dashboard (back to user mode)'
                        : 'Go to dashboard tools',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),

            // LOGOUT
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }
}

// Role badge chip
class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  Color _roleColor() {
    switch (role) {
      case 'admin':
        return Colors.redAccent;
      case 'author':
        return Colors.blueAccent;
      default:
        return Colors.green;
    }
  }

  String _roleLabel() {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'author':
        return 'Author';
      default:
        return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _roleLabel(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Reusable profile tile
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[800]),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
