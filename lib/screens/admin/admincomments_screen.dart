import 'package:flutter/material.dart';

import '../../models/admin_comment.dart';
import '../../services/api_service.dart';

class AdminCommentsScreen extends StatefulWidget {
  const AdminCommentsScreen({super.key});

  @override
  State<AdminCommentsScreen> createState() => _AdminCommentsScreenState();
}

class _AdminCommentsScreenState extends State<AdminCommentsScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<AdminComment> _comments = [];
  bool _isLoading = true;
  String? _error;

  String _statusFilter = 'All';

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
      final status = _statusFilter == 'All'
          ? null
          : _statusFilter.toLowerCase();
      final items = await _api.fetchAdminComments(
        search: _searchController.text,
        status: status,
      );
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

  Future<void> _approve(AdminComment comment) async {
    try {
      final updated = await _api.approveAdminComment(comment.id);
      if (!mounted) return;
      setState(() {
        _comments = _comments
            .map((item) => item.id == comment.id ? updated : item)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Approve failed: $e')));
    }
  }

  Future<void> _delete(AdminComment comment) async {
    try {
      await _api.deleteAdminComment(comment.id);
      if (!mounted) return;
      setState(() {
        _comments = _comments.where((item) => item.id != comment.id).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search comments, users, blog titles',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _loadComments();
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _loadComments(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label: 'All',
                    selected: _statusFilter == 'All',
                    onTap: () {
                      setState(() => _statusFilter = 'All');
                      _loadComments();
                    },
                  ),
                  _StatusChip(
                    label: 'pending',
                    selected: _statusFilter == 'pending',
                    onTap: () {
                      setState(() => _statusFilter = 'pending');
                      _loadComments();
                    },
                  ),
                  _StatusChip(
                    label: 'approved',
                    selected: _statusFilter == 'approved',
                    onTap: () {
                      setState(() => _statusFilter = 'approved');
                      _loadComments();
                    },
                  ),
                  _StatusChip(
                    label: 'rejected',
                    selected: _statusFilter == 'rejected',
                    onTap: () {
                      setState(() => _statusFilter = 'rejected');
                      _loadComments();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _comments.isEmpty
                ? const Center(
                    child: Text('No comments found for this filter.'),
                  )
                : RefreshIndicator(
                    onRefresh: _loadComments,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _CommentCard(
                          comment: comment,
                          onApprove: comment.status == 'approved'
                              ? null
                              : () => _approve(comment),
                          onDelete: () => _delete(comment),
                        );
                      },
                    ),
                  ),
          ),
        ],
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
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label[0].toUpperCase() + label.substring(1)),
        selected: selected,
        selectedColor: color.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected ? color : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final AdminComment comment;
  final VoidCallback? onApprove;
  final VoidCallback onDelete;

  const _CommentCard({
    required this.comment,
    required this.onApprove,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (comment.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel() {
    switch (comment.status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

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
                  comment.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
                  _statusLabel(),
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.menu_book, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  comment.blogTitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(comment.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onApprove,
                icon: const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
                label: const Text(
                  'Approve',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
