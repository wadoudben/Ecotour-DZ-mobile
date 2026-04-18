import 'package:flutter/material.dart';

import '../../models/blog_post.dart';
import '../../models/destination.dart';
import '../../models/hotel.dart';
import '../../services/api_service.dart';
import '../../storage/secure_storage.dart';
import '../blog/blog_detail_screen.dart';
import '../blog/blog_list_screen.dart';
import '../destinations/destination_detail_screen.dart';
import '../destinations/destinations_screen.dart';
import '../hotels/hotel_detail_screen.dart';
import '../hotels/hotels_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const primaryColor = Color.fromRGBO(241, 93, 48, 1);

  final ApiService _api = ApiService();

  late Future<List<Destination>> _destinationsFuture;
  late Future<List<Hotel>> _hotelsFuture;
  late Future<List<BlogPost>> _blogsFuture;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _destinationsFuture = _api.fetchDestinations();
    _hotelsFuture = _api.fetchHotels();
    _blogsFuture = _api.fetchBlogs();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role;
    try {
      final user = await _api.fetchProfile();
      role = user.role;
      if (role != null && role.isNotEmpty) {
        final token = await const SecureStorage().readToken();
        if (token != null && token.isNotEmpty) {
          await const SecureStorage().saveAuth(token: token, role: role);
        }
      }
    } catch (_) {
      // If API fails, fall back to stored role.
    }
    role ??= await const SecureStorage().readRole();
    if (!mounted) return;
    setState(() {
      _userRole = _normalizeRole(role);
    });
  }

  String _routeForRole(String role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'author':
        return '/author';
      default:
        return '/profile';
    }
  }

  String _normalizeRole(String? role) {
    final value = (role ?? 'user').trim().toLowerCase();
    if (value.contains('admin')) return 'admin';
    if (value.contains('author')) return 'author';
    return 'user';
  }

  Future<void> _handleProfileTap() async {
    String? role = await const SecureStorage().readRole();
    try {
      final user = await _api.fetchProfile();
      role = user.role ?? role;
    } catch (_) {
      // Fall back to stored role if the API call fails.
    }
    final normalized = _normalizeRole(role ?? _userRole);
    if (!mounted) return;
    if (normalized == 'admin') {
      Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      return;
    }
    if (normalized == 'author') {
      Navigator.pushNamedAndRemoveUntil(context, '/author', (route) => false);
      return;
    }
    final route = _routeForRole(normalized);
    Navigator.pushNamed(context, route);
  }

  void _retryDestinations() {
    setState(() {
      _destinationsFuture = _api.fetchDestinations();
    });
  }

  void _retryHotels() {
    setState(() {
      _hotelsFuture = _api.fetchHotels();
    });
  }

  void _retryBlogs() {
    setState(() {
      _blogsFuture = _api.fetchBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F7F7),
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  'images/logoo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),

                const Text(
                  "eco",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            Expanded(
              child: Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'EcoTour ',
                        style: TextStyle(fontSize: 25),
                      ),
                      TextSpan(
                        text: 'DZ',
                        style: TextStyle(color: primaryColor, fontSize: 25),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    _handleProfileTap();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userRole,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Popular Destinations',
                subtitle: 'Explore Algeria responsibly',
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DestinationsScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Destination>>(
                future: _destinationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingSection(height: 180);
                  }
                  if (snapshot.hasError) {
                    return _ErrorSection(
                      message: 'Failed to load destinations.',
                      onRetry: _retryDestinations,
                    );
                  }
                  final items = (snapshot.data ?? []).take(3).toList();
                  if (items.isEmpty) {
                    return const _EmptySection(message: 'No destinations yet.');
                  }
                  return _DestinationHorizontalList(items: items);
                },
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Eco Hotels',
                subtitle: 'Stays that respect nature',
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HotelsScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Hotel>>(
                future: _hotelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingSection(height: 260);
                  }
                  if (snapshot.hasError) {
                    return _ErrorSection(
                      message: 'Failed to load hotels.',
                      onRetry: _retryHotels,
                    );
                  }
                  final items = (snapshot.data ?? []).take(3).toList();
                  if (items.isEmpty) {
                    return const _EmptySection(message: 'No hotels yet.');
                  }
                  return _HotelHorizontalList(items: items);
                },
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Latest Articles',
                subtitle: 'Guides and tips for your trip',
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlogListScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<BlogPost>>(
                future: _blogsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingSection(height: 140);
                  }
                  if (snapshot.hasError) {
                    return _ErrorSection(
                      message: 'Failed to load blog posts.',
                      onRetry: _retryBlogs,
                    );
                  }
                  final items = (snapshot.data ?? []).take(3).toList();
                  if (items.isEmpty) {
                    return const _EmptySection(message: 'No articles yet.');
                  }
                  return _BlogPreviewList(items: items);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _DestinationHorizontalList extends StatelessWidget {
  final List<Destination> items;

  const _DestinationHorizontalList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final destination = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DestinationDetailScreen(destinationId: destination.id),
                ),
              );
            },
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                image: destination.imageUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: AssetImage(destination.imageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.25),
                          BlendMode.darken,
                        ),
                      ),
              ),
              child: destination.imageUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.landscape, color: Colors.grey),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              destination.region,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _HotelHorizontalList extends StatelessWidget {
  final List<Hotel> items;

  const _HotelHorizontalList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final hotel = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HotelDetailScreen(hotelId: hotel.id),
                ),
              );
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: hotel.imageUrl.isEmpty
                          ? Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.hotel, size: 20),
                              ),
                            )
                          : Image.asset(
                              hotel.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.hotel, size: 20),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hotel.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.city,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _EcoChip(label: hotel.ecoLevel),
                      Text(
                        hotel.priceRange,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlogPreviewList extends StatelessWidget {
  final List<BlogPost> items;

  const _BlogPreviewList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((post) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: SizedBox(
              width: 56,
              height: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: post.imageUrl.isEmpty
                    ? Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.menu_book, size: 20),
                      )
                    : Image.asset(
                        post.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.menu_book, size: 20),
                          );
                        },
                      ),
              ),
            ),
            title: Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              post.excerpt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlogDetailScreen(blogId: post.id),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _EcoChip extends StatelessWidget {
  final String label;

  const _EcoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF15D30).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFF15D30),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  final double height;

  const _LoadingSection({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorSection({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(message),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF15D30),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: Text(message)),
    );
  }
}
