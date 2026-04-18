import 'package:flutter/material.dart';

import '../models/blog_engagement.dart';
import '../services/api_service.dart';

class BlogEngagementSection extends StatefulWidget {
  final int blogId;
  final Color accentColor;
  final int initialLikeCount;
  final int initialEcoCount;
  final bool initialLikeActive;
  final bool initialEcoActive;
  final List<BlogComment> comments;
  final List<BlogReaction> reactions;
  final Future<void> Function()? onRefresh;

  const BlogEngagementSection({
    super.key,
    required this.blogId,
    required this.accentColor,
    this.initialLikeCount = 0,
    this.initialEcoCount = 0,
    this.initialLikeActive = false,
    this.initialEcoActive = false,
    this.comments = const [],
    this.reactions = const [],
    this.onRefresh,
  });

  @override
  State<BlogEngagementSection> createState() => _BlogEngagementSectionState();
}

class _BlogEngagementSectionState extends State<BlogEngagementSection> {
  final ApiService _api = ApiService();
  final TextEditingController _commentController = TextEditingController();

  bool _submittingComment = false;
  bool _reactingLike = false;
  bool _reactingEco = false;

  late int _likeCount;
  late int _ecoCount;
  bool _likeActive = false;
  bool _ecoActive = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount;
    _ecoCount = widget.initialEcoCount;
    _likeActive = widget.initialLikeActive;
    _ecoActive = widget.initialEcoActive;
  }

  @override
  void didUpdateWidget(covariant BlogEngagementSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLikeCount != widget.initialLikeCount ||
        oldWidget.initialEcoCount != widget.initialEcoCount) {
      _likeCount = widget.initialLikeCount;
      _ecoCount = widget.initialEcoCount;
    }
    if (oldWidget.initialLikeActive != widget.initialLikeActive ||
        oldWidget.initialEcoActive != widget.initialEcoActive) {
      _likeActive = widget.initialLikeActive;
      _ecoActive = widget.initialEcoActive;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showSnackBar('Write a comment first.');
      return;
    }
    if (_submittingComment) return;
    FocusScope.of(context).unfocus();
    setState(() => _submittingComment = true);
    try {
      await _api.createComment(blogId: widget.blogId, content: content);
      if (!mounted) return;
      _commentController.clear();
      _showSnackBar('Comment submitted for review.');
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Failed to submit comment.');
    } finally {
      if (mounted) {
        setState(() => _submittingComment = false);
      }
    }
  }

  Future<void> _toggleReaction(String type) async {
    if (type == 'like' && _reactingLike) return;
    if (type == 'eco' && _reactingEco) return;

    setState(() {
      if (type == 'like') {
        _reactingLike = true;
      } else {
        _reactingEco = true;
      }
    });

    try {
      final result = await _api.toggleReaction(
        type: type,
        blogId: widget.blogId,
      );
      if (!mounted) return;
      setState(() {
        _likeCount = result.likeCount;
        _ecoCount = result.ecoCount;
        if (type == 'like') {
          _likeActive = result.active;
        } else {
          _ecoActive = result.active;
        }
      });
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Failed to update reaction.');
    } finally {
      if (mounted) {
        setState(() {
          if (type == 'like') {
            _reactingLike = false;
          } else {
            _reactingEco = false;
          }
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        const Text(
          'Reactions',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ReactionButton(
              label: 'Like',
              count: _likeCount,
              isActive: _likeActive,
              isLoading: _reactingLike,
              color: widget.accentColor,
              icon: Icons.thumb_up_alt_outlined,
              onTap: () => _toggleReaction('like'),
            ),
            const SizedBox(width: 12),
            _ReactionButton(
              label: 'Eco',
              count: _ecoCount,
              isActive: _ecoActive,
              isLoading: _reactingEco,
              color: widget.accentColor,
              icon: Icons.eco_outlined,
              onTap: () => _toggleReaction('eco'),
            ),
          ],
        ),
        if (widget.reactions.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Recent reactions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...widget.reactions.map(
            (reaction) => _ReactionRow(reaction: reaction),
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Add a comment',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 3,
          minLines: 1,
          maxLength: 2000,
          decoration: InputDecoration(
            hintText: 'Share your thoughts...',
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _submittingComment ? null : _submitComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: _submittingComment
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, size: 16),
            label: Text(_submittingComment ? 'Posting...' : 'Post'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Comments',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (widget.comments.isEmpty)
          Text(
            'No comments yet.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          )
        else
          ...widget.comments.map(
            (comment) => _CommentCard(
              comment: comment,
              accentColor: widget.accentColor,
              indent: 0,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final bool isLoading;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.label,
    required this.count,
    required this.isActive,
    required this.isLoading,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? color.withOpacity(0.12) : Colors.grey.shade200;
    final borderColor = isActive ? color : Colors.grey.shade300;
    final iconColor = isActive ? color : Colors.grey.shade700;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionRow extends StatelessWidget {
  final BlogReaction reaction;

  const _ReactionRow({required this.reaction});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '--/--/----';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final label = reaction.type == 'eco' ? 'Eco' : 'Like';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            reaction.type == 'eco'
                ? Icons.eco_outlined
                : Icons.thumb_up_alt_outlined,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${reaction.userName} · $label',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            _formatDate(reaction.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final BlogComment comment;
  final Color accentColor;
  final double indent;

  const _CommentCard({
    required this.comment,
    required this.accentColor,
    required this.indent,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '--/--/----';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bg = indent == 0 ? Colors.white : Colors.grey.shade100;
    final border = indent == 0 ? Colors.grey.shade200 : Colors.grey.shade300;

    return Container(
      margin: EdgeInsets.fromLTRB(indent, 0, 0, 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.userName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(comment.createdAt),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Text(
                '${comment.likeCount}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.eco_outlined, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Text(
                '${comment.ecoCount}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...comment.replies.map(
              (reply) => _CommentCard(
                comment: reply,
                accentColor: accentColor,
                indent: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
