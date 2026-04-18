import 'package:flutter/material.dart';

import '../../models/author_comment.dart';
import '../../services/api_service.dart';

class AuthorCommentsScreen extends StatefulWidget {
  const AuthorCommentsScreen({super.key});

  @override
  State<AuthorCommentsScreen> createState() => _AuthorCommentsScreenState();
}

class _AuthorCommentsScreenState extends State<AuthorCommentsScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<AuthorComment> _comments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _api.fetchAuthorComments();
      if (!mounted) return;
      setState(() {
        _comments = items;
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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    final q = _searchController.text.trim().toLowerCase();
    final filtered = _comments.where((c) {
      if (q.isEmpty) return true;
      return c.content.toLowerCase().contains(q) ||
          c.blogTitle.toLowerCase().contains(q) ||
          c.authorName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search comments...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
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
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : filtered.isEmpty
                ? const Center(child: Text('No comments found.'))
                : RefreshIndicator(
                    onRefresh: _loadComments,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final comment = filtered[index];
                        return _CommentCard(comment: comment);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final AuthorComment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.blogTitle.isEmpty ? 'Blog post' : comment.blogTitle,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(comment.content, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            comment.authorName.isEmpty
                ? comment.authorEmail
                : comment.authorName,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
