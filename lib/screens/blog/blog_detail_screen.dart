import 'package:flutter/material.dart';

import '../../models/blog_post.dart';
import '../../models/blog_engagement.dart';
import '../../services/api_service.dart';
import '../../widgets/blog_engagement_section.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  static const primaryColor = Color(0xFFF15D30);

  final ApiService _api = ApiService();
  late Future<BlogPost> _future;
  late Future<BlogEngagement> _engagementFuture;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchBlogDetail(widget.blogId);
    _engagementFuture = _api.fetchBlogEngagement(widget.blogId);
  }

  void _retry() {
    setState(() {
      _future = _api.fetchBlogDetail(widget.blogId);
      _engagementFuture = _api.fetchBlogEngagement(widget.blogId);
    });
  }

  Future<void> _reloadEngagement() async {
    final future = _api.fetchBlogEngagement(widget.blogId);
    setState(() {
      _engagementFuture = future;
    });
    await future;
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
      body: FutureBuilder<BlogPost>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load blog post.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final post = snapshot.data;
          if (post == null) {
            return const Center(child: Text('Blog post not found.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: post.imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.menu_book, size: 40),
                        )
                      : Image.asset(
                          post.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.menu_book, size: 40),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(post.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<BlogEngagement>(
                        future: _engagementFuture,
                        builder: (context, engagementSnapshot) {
                          if (engagementSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (engagementSnapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Failed to load comments & reactions.',
                                  ),
                                  const SizedBox(height: 6),
                                  TextButton(
                                    onPressed: _retry,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final engagement = engagementSnapshot.data;
                          return BlogEngagementSection(
                            blogId: post.id,
                            accentColor: primaryColor,
                            initialLikeCount: engagement?.likeCount ?? 0,
                            initialEcoCount: engagement?.ecoCount ?? 0,
                            initialLikeActive: engagement?.userLike ?? false,
                            initialEcoActive: engagement?.userEco ?? false,
                            comments: engagement?.comments ?? const [],
                            reactions: engagement?.reactions ?? const [],
                            onRefresh: _reloadEngagement,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
