import 'package:flutter/material.dart';

import '../../models/author_blog.dart';
import '../../services/api_service.dart';
import 'authoreditblog_screen.dart';

class AuthorMyBlogsScreen extends StatefulWidget {
  const AuthorMyBlogsScreen({super.key});

  @override
  State<AuthorMyBlogsScreen> createState() => _AuthorMyBlogsScreenState();
}

class _AuthorMyBlogsScreenState extends State<AuthorMyBlogsScreen> {
  final ApiService _api = ApiService();

  List<AuthorBlog> _allBlogs = [];
  bool _isLoading = true;
  String? _error;

  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _api.fetchAuthorBlogs();
      if (!mounted) return;
      setState(() {
        _allBlogs = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlogEditScreen()),
    );
    if (result is Map) {
      setState(() {
        _allBlogs.insert(
          0,
          AuthorBlog(
            id: DateTime.now().millisecondsSinceEpoch,
            title: result['title']?.toString() ?? 'Untitled',
            excerpt: result['excerpt']?.toString() ?? '',
            status: result['status']?.toString() ?? 'draft',
            createdAt: DateTime.now(),
            commentsCount: 0,
          ),
        );
      });
    }
  }

  void _openEdit(AuthorBlog blog) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlogEditScreen(
          initialPost: BlogPost(
            id: blog.id,
            title: blog.title,
            excerpt: blog.excerpt,
            content: '',
            status: blog.status,
            imageUrl: '',
          ),
        ),
      ),
    );
    if (result is Map) {
      setState(() {
        final index = _allBlogs.indexWhere((b) => b.id == blog.id);
        if (index != -1) {
          _allBlogs[index] = AuthorBlog(
            id: blog.id,
            title: result['title']?.toString() ?? blog.title,
            excerpt: result['excerpt']?.toString() ?? blog.excerpt,
            status: result['status']?.toString() ?? blog.status,
            createdAt: DateTime.now(),
            commentsCount: blog.commentsCount,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    final filtered = _allBlogs.where((b) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.excerpt.toLowerCase().contains(q);

      final matchesStatus = _statusFilter == 'All'
          ? true
          : b.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('My blog posts'),
      ),
      body: Column(
        children: [
          // SEARCH + FILTER ROW
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusChip(
                          label: 'All',
                          selected: _statusFilter == 'All',
                          onTap: () => setState(() => _statusFilter = 'All'),
                        ),
                        _StatusChip(
                          label: 'published',
                          selected: _statusFilter == 'published',
                          onTap: () =>
                              setState(() => _statusFilter = 'published'),
                        ),
                        _StatusChip(
                          label: 'draft',
                          selected: _statusFilter == 'draft',
                          onTap: () => setState(() => _statusFilter = 'draft'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : filtered.isEmpty
                ? const Center(child: Text('No posts found.'))
                : RefreshIndicator(
                    onRefresh: _loadBlogs,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final blog = filtered[index];
                        return _BlogCard(
                          blog: blog,
                          onEdit: () {
                            _openEdit(blog);
                          },
                          onDelete: () {
                            // TODO: confirm & call API, then update list
                            setState(() {
                              _allBlogs.removeWhere((b) => b.id == blog.id);
                            });
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  Color _statusColor() {
    switch (label) {
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
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label[0].toUpperCase() + label.substring(1)),
        selected: selected,
        selectedColor: color.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected ? color : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final AuthorBlog blog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BlogCard({
    required this.blog,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (blog.status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final date = blog.createdAt ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  blog.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  blog.status[0].toUpperCase() + blog.status.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            blog.excerpt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(date),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.red,
                ),
                label: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
