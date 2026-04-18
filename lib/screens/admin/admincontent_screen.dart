import 'package:flutter/material.dart';

import '../author/authoreditblog_screen.dart';
import '../blog/blog_list_screen.dart';
import 'admin_create_destination_screen.dart';
import 'admin_create_hotel_screen.dart';
import 'admindestinations_screen.dart';
import 'adminhotels_screen.dart';

class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: const Text('Content management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage eco content',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Create and update destinations, hotels and blog posts for Eco Sahara DZ.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),

            const SizedBox(height: 20),

            // DESTINATIONS SECTION
            const Text(
              'Destinations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create, edit and delete eco destinations across Algeria.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            _ContentCard(
              icon: Icons.public,
              title: 'View all destinations',
              subtitle: 'See and edit all existing destinations.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminDestinationsScreen(),
                  ),
                );
              },
            ),
            _ContentCard(
              icon: Icons.add_location_alt,
              title: 'Add new destination',
              subtitle: 'Create a new eco destination.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminCreateDestinationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // HOTELS SECTION
            const Text(
              'Hotels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage eco-friendly hotels and affiliate links.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            _ContentCard(
              icon: Icons.hotel,
              title: 'View all hotels',
              subtitle: 'Update details of eco hotels.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminHotelsScreen()),
                );
              },
            ),
            _ContentCard(
              icon: Icons.add_business,
              title: 'Add new hotel',
              subtitle: 'Register a new eco hotel.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminCreateHotelScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Blog posts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Review and manage eco travel articles.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            _ContentCard(
              icon: Icons.menu_book,
              title: 'View all blog posts',
              subtitle: 'Moderate and manage articles.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BlogListScreen()),
                );
              },
            ),
            _ContentCard(
              icon: Icons.edit_note,
              title: 'Create blog post',
              subtitle: 'Write a new eco travel article.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BlogEditScreen()),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Reusable content card for each action
class _ContentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

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
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.1),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
