import 'package:flutter/material.dart';

import '../storage/secure_storage.dart';
import '../main_nav_scaffold.dart';
import 'destinations/destinations_screen.dart';
import 'home/home_screen.dart';
import 'hotels/hotels_screen.dart';
import 'role_nav_wrappers.dart';
import 'user/messagelist_screen.dart';

class MainNavContainer extends StatefulWidget {
  final String? role;
  final int? initialIndex;

  const MainNavContainer({super.key, this.role, this.initialIndex});

  @override
  State<MainNavContainer> createState() => _MainNavContainerState();
}

class _MainNavContainerState extends State<MainNavContainer> {
  late Future<String> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = _loadRole();
  }

  Future<String> _loadRole() async {
    if (widget.role != null && widget.role!.trim().isNotEmpty) {
      return _normalizeRole(widget.role!);
    }
    final stored = await const SecureStorage().getRole();
    return _normalizeRole(stored);
  }

  String _normalizeRole(String? role) {
    final value = (role ?? 'user').trim().toLowerCase();
    if (value.contains('admin')) return 'admin';
    if (value.contains('author')) return 'author';
    return 'user';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final role = snapshot.data ?? 'user';
        if (_normalizeRole(role) == 'user') {
          return const MainNavScaffold();
        }
        return RoleBasedBottomNav(
          role: role,
          initialIndex: widget.initialIndex,
        );
      },
    );
  }
}

class RoleBasedBottomNav extends StatefulWidget {
  final String role;
  final int? initialIndex;

  const RoleBasedBottomNav({super.key, required this.role, this.initialIndex});

  @override
  State<RoleBasedBottomNav> createState() => _RoleBasedBottomNavState();
}

class _RoleBasedBottomNavState extends State<RoleBasedBottomNav> {
  static const primaryColor = Color(0xFFF15D30);

  int _index = 0;
  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _items;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;
  late List<WidgetBuilder> _tabBuilders;
  bool _useNestedNavigator = false;

  @override
  void initState() {
    super.initState();
    _configureForRole(widget.role);
    final role = _normalizeRole(widget.role);
    final defaultIndex = role == 'admin' || role == 'author' ? 1 : 0;
    _index = _normalizeIndex(widget.initialIndex ?? defaultIndex);
  }

  @override
  void didUpdateWidget(covariant RoleBasedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _configureForRole(widget.role);
      setState(() {
        _index = 0;
      });
    }
  }

  void _configureForRole(String role) {
    switch (_normalizeRole(role)) {
      case 'admin':
        _useNestedNavigator = true;
        _tabBuilders = [
          (_) => const HomeScreen(),
          (_) => const DashboardScreen(role: 'admin'),
          (_) => const ContentsScreen(),
          (_) => const UsersScreen(),
          (_) => const CommentsScreen(),
          (_) => const ProfileScreen(),
        ];
        _navigatorKeys = List.generate(
          _tabBuilders.length,
          (_) => GlobalKey<NavigatorState>(),
        );
        _items = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.comment), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ];
        break;
      case 'author':
        _useNestedNavigator = true;
        _tabBuilders = [
          (_) => const HomeScreen(),
          (_) => const DashboardScreen(role: 'author'),
          (_) => const MyBlogsScreen(),
          (_) => const ProfileScreen(),
        ];
        _navigatorKeys = List.generate(
          _tabBuilders.length,
          (_) => GlobalKey<NavigatorState>(),
        );
        _items = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
        break;
      default:
        _useNestedNavigator = false;
        _screens = [
          const HomeScreen(),
          DestinationsScreen(),
          const HotelsScreen(),
          const BlogsScreen(),
          const MessagesListScreen(),
        ];
        _items = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Destinations',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hotels'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Blogs'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
        ];
    }
  }

  int _normalizeIndex(int? value) {
    if (value == null) return 0;
    final max = _useNestedNavigator
        ? _tabBuilders.length - 1
        : _screens.length - 1;
    if (value < 0) return 0;
    if (value > max) return max;
    return value;
  }

  String _normalizeRole(String? role) {
    final value = (role ?? 'user').trim().toLowerCase();
    if (value.contains('admin')) return 'admin';
    if (value.contains('author')) return 'author';
    return 'user';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _useNestedNavigator
            ? List.generate(_tabBuilders.length, _buildTabNavigator)
            : _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: _normalizeRole(widget.role) != 'admin',
        showUnselectedLabels: _normalizeRole(widget.role) != 'admin',
        onTap: (index) {
          final role = _normalizeRole(widget.role);
          if ((role == 'admin' || role == 'author') && index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
            return;
          }
          if (_useNestedNavigator && index == _index) {
            _navigatorKeys[index].currentState?.popUntil(
              (route) => route.isFirst,
            );
            return;
          }
          setState(() => _index = index);
        },
        items: _items,
      ),
    );
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: _tabBuilders[index], settings: settings),
    );
  }
}
