import 'package:flutter/material.dart';

import '../../models/conversation_message.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String conversationTitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _messageController = TextEditingController();

  List<ConversationMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await _api.fetchProfile();
      _currentUserId = profile.id;
    } catch (_) {
      // ignore profile failure for now
    }
    try {
      final items = await _api.fetchConversationMessages(widget.conversationId);
      if (!mounted) return;
      setState(() {
        _messages = items;
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final sent = await _api.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(sent);
        _messageController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Send failed: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.conversationTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe =
                          _currentUserId != null &&
                          msg.senderId == _currentUserId;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _MessageBubble(message: msg, isMe: isMe),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: const Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _isSending ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSending ? Colors.grey : primaryColor,
                      ),
                      child: const Icon(
                        Icons.send,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ConversationMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    final bgColor = isMe ? primaryColor : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
    );

    String timeLabel() {
      final dt = message.createdAt ?? DateTime.now();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 60 : 8,
        right: isMe ? 8 : 60,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  color: Colors.black.withOpacity(0.08),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 13, height: 1.3),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeLabel(),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
