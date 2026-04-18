import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../storage/secure_storage.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_screen.dart';

class ProfileEntryScreen extends StatefulWidget {
  const ProfileEntryScreen({super.key});

  @override
  State<ProfileEntryScreen> createState() => _ProfileEntryScreenState();
}

class _ProfileEntryScreenState extends State<ProfileEntryScreen> {
  final ApiService _api = ApiService();

  late Future<UserProfile> _profileFuture;
  String? _storedRole;

  String _normalizeRole(String? role) {
    final value = (role ?? 'user').trim().toLowerCase();
    if (value.contains('admin')) return 'admin';
    if (value.contains('author')) return 'author';
    return 'user';
  }

  @override
  void initState() {
    super.initState();
    _profileFuture = _api.fetchProfile();
    _loadStoredRole();
  }

  Future<void> _loadStoredRole() async {
    final role = await const SecureStorage().readRole();
    if (!mounted) return;
    setState(() {
      _storedRole = role;
    });
  }

  Future<void> _logout() async {
    await const SecureStorage().clearAuth();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _openDashboard(String role) {
    if (role == 'admin') {
      Navigator.pushNamed(context, '/admin');
    } else if (role == 'author') {
      Navigator.pushNamed(context, '/author');
    }
  }

  Future<void> _openEditProfile(UserProfile user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialName: user.name ?? '',
          initialEmail: user.email ?? '',
        ),
      ),
    );
    if (!mounted) return;
    if (result is UserProfile) {
      setState(() {
        _profileFuture = Future.value(result);
      });
    }
  }

  Future<void> _openChangePassword(UserProfile user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(
          name: user.name ?? '',
          email: user.email ?? '',
        ),
      ),
    );
    if (!mounted) return;
    if (result is UserProfile) {
      setState(() {
        _profileFuture = Future.value(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          if (error is ApiException && error.statusCode == 401) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return FutureBuilder<String?>(
            future: const SecureStorage().readRole(),
            builder: (context, roleSnapshot) {
              final role = _normalizeRole(roleSnapshot.data ?? _storedRole);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Profile data unavailable. Showing cached view.',
                    ),
                  ),
                );
              });
              return ProfileScreen(
                name: 'User',
                email: 'user@example.com',
                role: role,
                inDashboardMode: false,
                onToggleDashboard: () => _openDashboard(role),
                onLogout: _logout,
                onEditProfile: () {},
                onChangePassword: () {},
              );
            },
          );
        }

        final user = snapshot.data;
        final role = _normalizeRole(user?.role ?? _storedRole);

        return ProfileScreen(
          name: user?.name ?? 'User',
          email: user?.email ?? 'user@example.com',
          role: role,
          inDashboardMode: false,
          onToggleDashboard: () => _openDashboard(role),
          onLogout: _logout,
          onEditProfile: () {
            if (user != null) _openEditProfile(user);
          },
          onChangePassword: () {
            if (user != null) _openChangePassword(user);
          },
        );
      },
    );
  }
}
