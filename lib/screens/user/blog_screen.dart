import 'package:flutter/material.dart';

import '../../models/blog_post.dart';
import '../../models/blog_counts.dart';
import '../../models/blog_engagement.dart';
import '../../services/api_service.dart';
import '../../widgets/blog_engagement_section.dart';

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return const _BlogListBody(primaryColor: primaryColor);
  }
}

class _BlogListBody extends StatefulWidget {
  final Color primaryColor;

  const _BlogListBody({required this.primaryColor});

  @override
  State<_BlogListBody> createState() => _BlogListBodyState();
}

class _BlogListBodyState extends State<_BlogListBody> {
  final ApiService _api = ApiService();
  late Future<List<BlogPost>> _futurePosts;
  final Map<int, Future<BlogCounts>> _countsFutures = {};

  @override
  void initState() {
    super.initState();
    _futurePosts = _api.fetchBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.primaryColor,
        title: const Text('Eco Travel Blog'),
      ),
      body: FutureBuilder<List<BlogPost>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = [...(snapshot.data ?? [])]
            ..sort((a, b) {
              final aDate =
                  a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bDate =
                  b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bDate.compareTo(aDate);
            });

          if (posts.isEmpty) {
            return const Center(child: Text('No blog posts found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final p = posts[index];
              final countsFuture = _countsFutures.putIfAbsent(
                p.id,
                () => _api.fetchBlogCounts(p.id),
              );
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlogDetailScreen(post: p),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: p.imageUrl.isEmpty
                              ? Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.menu_book, size: 40),
                                  ),
                                )
                              : Image.asset(
                                  p.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.menu_book, size: 40),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(p.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.excerpt,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 6),
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
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Read more',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: widget.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: widget.primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatDate(DateTime? dt) {
  if (dt == null) return '--/--/----';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
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
      spacing: 1,
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

class BlogDetailScreen extends StatefulWidget {
  final BlogPost post;

  const BlogDetailScreen({super.key, required this.post});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final ApiService _api = ApiService();
  late Future<BlogEngagement> _engagementFuture;

  @override
  void initState() {
    super.initState();
    _engagementFuture = _api.fetchBlogEngagement(widget.post.id);
  }

  Future<void> _reloadEngagement() async {
    final future = _api.fetchBlogEngagement(widget.post.id);
    setState(() {
      _engagementFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.post.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: widget.post.imageUrl.isEmpty
                  ? Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.menu_book, size: 40),
                      ),
                    )
                  : Image.asset(
                      widget.post.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.menu_book, size: 40),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(widget.post.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _buildContentText(widget.post.content),
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
                                onPressed: _reloadEngagement,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final engagement = engagementSnapshot.data;
                      return BlogEngagementSection(
                        blogId: widget.post.id,
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
      ),
    );
  }

  Widget _buildContentText(String content) {
    final paragraphs = content.trim().isEmpty
        ? <String>[]
        : content.trim().split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final para in paragraphs) ...[
          Text(para, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
