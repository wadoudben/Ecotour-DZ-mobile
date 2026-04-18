import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'screens/destinations/destinations_screen.dart';
import 'screens/destinations/destinations_map_screen.dart';
import 'screens/hotels/hotels_screen.dart';
import 'screens/blog/blog_list_screen.dart';
import 'screens/user/messagelist_screen.dart';

class MainNavScaffold extends StatefulWidget {
  const MainNavScaffold({super.key});

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  static const primaryColor = Color(0xFFF15D30);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      DestinationsScreen(),
      const DestinationsMapScreen(),
      const HotelsScreen(),
      const BlogListScreen(),
      const MessagesListScreen(),
    ];
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // we use body only, each screen has its own AppBar (like Destinations/Hotels/Blog)
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  label: 'Home',
                  icon: Icons.home,
                  isActive: _selectedIndex == 0,
                  activeColor: primaryColor,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  index: 1,
                  label: 'Destinations',
                  icon: Icons.public,
                  isActive: _selectedIndex == 1,
                  activeColor: primaryColor,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  index: 2,
                  label: 'Map',
                  icon: Icons.map_outlined,
                  isActive: _selectedIndex == 2,
                  activeColor: primaryColor,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  index: 3,
                  label: 'Hotels',
                  icon: Icons.hotel,
                  isActive: _selectedIndex == 3,
                  activeColor: primaryColor,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  index: 4,
                  label: 'Blog',
                  icon: Icons.menu_book,
                  isActive: _selectedIndex == 4,
                  activeColor: primaryColor,
                  onTap: _onItemTapped,
                ),
                _NavItem(
                  index: 5,
                  label: 'Messages',
                  icon: Icons.mail,
                  isActive: _selectedIndex == 5,
                  activeColor: primaryColor,
                  onTap: _onItemTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? Colors.white : Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
