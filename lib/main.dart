import 'package:flutter/material.dart';

import 'main_nav_scaffold.dart';
import 'screens/role_based_nav.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/user/profile_entry_screen.dart';
import 'services/api_service.dart';
import 'storage/secure_storage.dart';

void main() {
  runApp(const EcoSaharaApp());
}

class EcoSaharaApp extends StatelessWidget {
  const EcoSaharaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return MaterialApp(
      title: 'Eco Sahara DZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        useMaterial3: false,
        fontFamily: 'Poppins', // if you add it
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        appBarTheme: const AppBarTheme(),
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainNavScaffold(),
        '/main': (_) => const MainNavContainer(),
        '/admin': (_) => const MainNavContainer(role: 'admin'),
        '/author': (_) => const MainNavContainer(role: 'author'),
        '/profile': (_) => const ProfileEntryScreen(),
      },
      home: const _BootstrapScreen(),
    );
  }
}

class _BootstrapScreen extends StatefulWidget {
  const _BootstrapScreen();

  @override
  State<_BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<_BootstrapScreen> {
  late final Future<_BootstrapResult> _bootstrapFuture = _bootstrap();

  Future<_BootstrapResult> _bootstrap() async {
    final storage = const SecureStorage();
    final api = ApiService(storage: storage);
    final token = await storage.readToken();
    final storedRole = await storage.readRole();

    if (token == null || token.isEmpty) {
      return const _BootstrapResult.unauthenticated();
    }

    try {
      final user = await api.getCurrentUser(token: token);
      final role = (user.role ?? storedRole ?? 'user').toLowerCase();
      await storage.saveAuth(token: token, role: role);
      return _BootstrapResult.authenticated(role);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await storage.clearAuth();
        return const _BootstrapResult.unauthenticated();
      }
      final role = (storedRole ?? 'user').toLowerCase();
      return _BootstrapResult.authenticated(role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapResult>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const LoginScreen();
        }

        final result = snapshot.data;
        if (result == null || !result.isAuthenticated) {
          return const LoginScreen();
        }

        return const MainNavScaffold();
      },
    );
  }
}

class _BootstrapResult {
  final bool isAuthenticated;
  final String? role;

  const _BootstrapResult._(this.isAuthenticated, this.role);

  const _BootstrapResult.unauthenticated() : this._(false, null);

  const _BootstrapResult.authenticated(String role) : this._(true, role);
}
