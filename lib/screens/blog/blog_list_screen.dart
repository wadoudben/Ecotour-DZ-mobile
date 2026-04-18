import 'package:flutter/material.dart';

import '../../models/blog_post.dart';
import '../../models/blog_counts.dart';
import '../../services/api_service.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  static const primaryColor = Color(0xFFF15D30);

  final ApiService _api = ApiService();
  late Future<List<BlogPost>> _future;
  final Map<int, Future<BlogCounts>> _countsFutures = {};

  @override
  void initState() {
    super.initState();
    _future = _api.fetchBlogs();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchBlogs();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor, title: const Text('Blog')),
      body: FutureBuilder<List<BlogPost>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _retry);
          }

          final blogs = snapshot.data ?? [];
          if (blogs.isEmpty) {
            return const Center(child: Text('No blog posts found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final post = blogs[index];
              final countsFuture = _countsFutures.putIfAbsent(
                post.id,
                () => _api.fetchBlogCounts(post.id),
              );

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: SizedBox(
                    width: 64,
                    height: 64,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        post.excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(post.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<BlogCounts>(
                        future: countsFuture,
                        builder: (context, countSnapshot) {
                          final counts = countSnapshot.data;
                          return _BlogKpiRow(
                            comments: counts?.comments ?? 0,
                            likes: counts?.likeCount ?? 0,
                            eco: counts?.ecoCount ?? 0,
                            isLoading:
                                countSnapshot.connectionState ==
                                ConnectionState.waiting,
                          );
                        },
                      ),
                    ],
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
            },
          );
        },
      ),
    );
  }
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
          const Text('Failed to load blog posts.'),
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

class _BlogKpiRow extends StatelessWidget {
  final int comments;
  final int likes;
  final int eco;
  final bool isLoading;

  const _BlogKpiRow({
    required this.comments,
    required this.likes,
    required this.eco,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 11,
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = TextStyle(
      fontSize: 11,
      color: Colors.grey.shade800,
      fontWeight: FontWeight.w700,
    );

    if (isLoading) {
      return Text(
        'Loading engagement...',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      );
    }

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _KpiItem(
          icon: Icons.mode_comment_outlined,
          value: '$comments',
          label: 'Comments',
          valueStyle: valueStyle,
          labelStyle: labelStyle,
        ),
        _KpiItem(
          icon: Icons.thumb_up_alt_outlined,
          value: '$likes',
          label: 'Like',
          valueStyle: valueStyle,
          labelStyle: labelStyle,
        ),
        _KpiItem(
          icon: Icons.eco_outlined,
          value: '$eco',
          label: 'Eco',
          valueStyle: valueStyle,
          labelStyle: labelStyle,
        ),
      ],
    );
  }
}

class _KpiItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final TextStyle valueStyle;
  final TextStyle labelStyle;

  const _KpiItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.valueStyle,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(value, style: valueStyle),
        const SizedBox(width: 6),
        Text(label, style: labelStyle),
      ],
    );
  }
}
