import 'package:flutter/material.dart';

import '../../models/author_blog.dart';
import '../../services/api_service.dart';
import 'authoreditblog_screen.dart';
import 'authormyblog_screen.dart';
import 'author_comments_screen.dart';

class AuthorDashboardScreen extends StatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  State<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends State<AuthorDashboardScreen> {
  final ApiService _api = ApiService();

  late Future<List<AuthorBlog>> _blogsFuture;

  @override
  void initState() {
    super.initState();
    _blogsFuture = _api.fetchAuthorBlogs();
  }

  void _retry() {
    setState(() {
      _blogsFuture = _api.fetchAuthorBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Author Dashboard'),
      ),
      body: FutureBuilder<List<AuthorBlog>>(
        future: _blogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _retry);
          }

          final blogs = snapshot.data ?? [];
          final stats = _AuthorStats.fromBlogs(blogs);
          final recentPosts = _recentPostsFrom(blogs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GREETING
                const Text(
                  'Hello, Author',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Write and manage eco travel articles for Eco Sahara DZ.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),

                const SizedBox(height: 16),

                // STATS GRID
                const Text(
                  'Your activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatCard(
                      icon: Icons.article,
                      label: 'My posts',
                      value: '${stats.total}',
                    ),
                    _StatCard(
                      icon: Icons.check_circle,
                      label: 'Published',
                      value: '${stats.published}',
                    ),
                    _StatCard(
                      icon: Icons.drafts,
                      label: 'Drafts',
                      value: '${stats.drafts}',
                    ),
                    _StatCard(
                      icon: Icons.comment,
                      label: 'Comments',
                      value: '${stats.comments}',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // QUICK ACTIONS
                const Text(
                  'Quick actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _QuickActionCard(
                  icon: Icons.edit_note,
                  title: 'Write new blog post',
                  subtitle: 'Create a new eco travel article.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BlogEditScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.menu_book,
                  title: 'Manage my posts',
                  subtitle: 'View, edit or delete your articles.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AuthorMyBlogsScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.comment,
                  title: 'Review comments',
                  subtitle: 'Check comments on your posts.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AuthorCommentsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // RECENT POSTS
                const Text(
                  'Recent posts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (recentPosts.isEmpty)
                  const Text('No posts yet.')
                else
                  for (final p in recentPosts) _RecentPostTile(post: p),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

// SMALL CARD FOR STATS (similar to admin)
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
              child: Icon(icon, color: Colors.white, size: 18),
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

// QUICK ACTION CARD (same style as admin)
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

// MODEL FOR RECENT POST (local)
class _RecentPost {
  final String title;
  final String status; // Published / Draft
  final String dateLabel;

  const _RecentPost({
    required this.title,
    required this.status,
    required this.dateLabel,
  });
}

// TILE FOR RECENT POST
class _RecentPostTile extends StatelessWidget {
  final _RecentPost post;

  const _RecentPostTile({required this.post});

  Color _statusColor() {
    switch (post.status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          post.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          post.dateLabel,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.status,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: open BlogEditScreen in edit mode
        },
      ),
    );
  }
}

class _AuthorStats {
  final int total;
  final int published;
  final int drafts;
  final int comments;

  const _AuthorStats({
    required this.total,
    required this.published,
    required this.drafts,
    required this.comments,
  });

  factory _AuthorStats.fromBlogs(List<AuthorBlog> blogs) {
    var published = 0;
    var drafts = 0;
    var comments = 0;
    for (final blog in blogs) {
      if (blog.status == 'published') {
        published++;
      } else {
        drafts++;
      }
      comments += blog.commentsCount;
    }
    return _AuthorStats(
      total: blogs.length,
      published: published,
      drafts: drafts,
      comments: comments,
    );
  }
}

List<_RecentPost> _recentPostsFrom(List<AuthorBlog> blogs) {
  final sorted = [...blogs];
  sorted.sort((a, b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });
  return sorted.take(3).map((blog) {
    return _RecentPost(
      title: blog.title,
      status: _labelForStatus(blog.status),
      dateLabel: _formatDate(blog.createdAt),
    );
  }).toList();
}

String _labelForStatus(String status) {
  switch (status.toLowerCase()) {
    case 'published':
      return 'Published';
    case 'draft':
      return 'Draft';
    default:
      return status.isEmpty ? 'Draft' : status;
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '--/--/----';
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  return '$day/$month/$year';
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Failed to load dashboard data.'),
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
