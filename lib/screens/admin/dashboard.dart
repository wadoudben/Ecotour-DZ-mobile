import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'admindestinations_screen.dart';
import 'adminhotels_screen.dart';
import 'admincomments_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _api = ApiService();

  late Future<_AdminDashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_AdminDashboardStats> _loadStats() async {
    final results = await Future.wait<int>([
      _api.fetchAdminDestinationsTotal(),
      _api.fetchAdminHotelsTotal(),
      _api.fetchAdminCommentsTotal(),
      _api.fetchAdminUsersTotal(),
    ]);
    return _AdminDashboardStats(
      destinations: results[0],
      hotels: results[1],
      comments: results[2],
      users: results[3],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Admin Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final next = _loadStats();
          setState(() => _statsFuture = next);
          await next;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GREETING
              const Text(
                'Hello, Admin',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage Eco Sahara DZ content and users.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),

              const SizedBox(height: 16),

              // STATS GRID
              const Text(
                'Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              FutureBuilder<_AdminDashboardStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _StatsLoadingGrid();
                  }
                  if (snapshot.hasError) {
                    return _StatsError(
                      onRetry: () {
                        setState(() {
                          _statsFuture = _loadStats();
                        });
                      },
                    );
                  }
                  final stats = snapshot.data;
                  if (stats == null) {
                    return _StatsError(
                      onRetry: () {
                        setState(() {
                          _statsFuture = _loadStats();
                        });
                      },
                    );
                  }
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatCard(
                        icon: Icons.public,
                        label: 'Destinations',
                        value: '${stats.destinations}',
                      ),
                      _StatCard(
                        icon: Icons.hotel,
                        label: 'Hotels',
                        value: '${stats.hotels}',
                      ),
                      _StatCard(
                        icon: Icons.comment,
                        label: 'Comments',
                        value: '${stats.comments}',
                      ),
                      _StatCard(
                        icon: Icons.people,
                        label: 'Users',
                        value: '${stats.users}',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // QUICK ACTIONS
              const Text(
                'Quick actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                icon: Icons.public,
                title: 'Manage Destinations',
                subtitle: 'Create, edit and delete eco destinations.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDestinationsScreen(),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.hotel,
                title: 'Manage Hotels',
                subtitle: 'Update eco hotels and affiliate links.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminHotelsScreen(),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.comment,
                title: 'Review Comments',
                subtitle: 'Moderate blog comments from users.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminCommentsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // RECENT ACTIVITY
              const Text(
                'Recent activity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const _ActivityItem(
                icon: Icons.menu_book,
                title: 'New blog post published',
                subtitle: '"Eco Tips for the Sahara Desert" by Author A.',
                time: '2h ago',
              ),
              const _ActivityItem(
                icon: Icons.person_add,
                title: 'New user registered',
                subtitle: 'user@example.com',
                time: '5h ago',
              ),
              const _ActivityItem(
                icon: Icons.hotel,
                title: 'Hotel updated',
                subtitle: 'Eco Oasis Ghardaia information changed.',
                time: 'Yesterday',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminDashboardStats {
  final int destinations;
  final int hotels;
  final int comments;
  final int users;

  const _AdminDashboardStats({
    required this.destinations,
    required this.hotels,
    required this.comments,
    required this.users,
  });
}

class _StatsLoadingGrid extends StatelessWidget {
  const _StatsLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _StatCard(icon: Icons.public, label: 'Destinations', value: '...'),
        _StatCard(icon: Icons.hotel, label: 'Hotels', value: '...'),
        _StatCard(icon: Icons.comment, label: 'Comments', value: '...'),
        _StatCard(icon: Icons.people, label: 'Users', value: '...'),
      ],
    );
  }
}

class _StatsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _StatsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Failed to load stats.'),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

// SMALL CARD FOR STATS
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: const Icon(Icons.insights, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QUICK ACTION CARD
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
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

// RECENT ACTIVITY ITEM
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Icon(icon, size: 18, color: Colors.grey[800]),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}
