import 'package:flutter/material.dart';

import '../../models/conversation.dart';
import '../../services/api_service.dart';
import 'chat_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Conversation> _allConversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _api.fetchConversations(
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _allConversations = items;
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
    final filtered = _allConversations.where((c) {
      return q.isEmpty || c.title.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
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
                ? const Center(child: Text('No conversations yet.'))
                : RefreshIndicator(
                    onRefresh: _loadConversations,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final convo = filtered[index];
                        return _ConversationTile(
                          conversation: convo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  conversationTitle: convo.title,
                                  conversationId: convo.id,
                                ),
                              ),
                            );
                          },
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

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _displayName(Conversation conversation) {
    if (conversation.userName.isNotEmpty) return conversation.userName;
    if (conversation.userEmail.isNotEmpty) return conversation.userEmail;
    return 'Unknown user';
  }

  @override
  Widget build(BuildContext context) {
    final initials = conversation.title.isNotEmpty
        ? conversation.title[0].toUpperCase()
        : '?';
    final timeLabel = _formatTime(
      conversation.lastMessageAt ?? conversation.updatedAt,
    );
    final sender = _displayName(conversation);
    final status = conversation.status.isEmpty
        ? null
        : conversation.status[0].toUpperCase() +
              conversation.status.substring(1);

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
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        title: Text(
          conversation.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            if (conversation.lastMessage.isNotEmpty)
              Text(
                conversation.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeLabel,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            if (status != null)
              Text(
                status,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            if (status != null) const SizedBox(height: 4),
            if (conversation.unreadCount > 0)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF15D30),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
