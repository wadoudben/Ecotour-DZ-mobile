class Conversation {
  final int id;
  final String title;
  final String lastMessage;
  final DateTime? updatedAt;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String userName;
  final String userEmail;
  final String status;

  const Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.userName,
    required this.userEmail,
    required this.status,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final last = json['last_message'];
    final lastContent = last is Map ? last['content']?.toString() : null;
    final updatedRaw =
        json['updated_at']?.toString() ??
        json['updatedAt']?.toString() ??
        (last is Map ? last['created_at']?.toString() : null) ??
        '';
    final lastMessageRaw =
        json['last_message_at']?.toString() ??
        json['lastMessageAt']?.toString() ??
        '';
    return Conversation(
      id: _toInt(json['id']),
      title:
          json['title']?.toString() ??
          json['name']?.toString() ??
          json['subject']?.toString() ??
          'Conversation',
      lastMessage:
          lastContent ??
          json['last_message']?.toString() ??
          json['lastMessage']?.toString() ??
          '',
      updatedAt: updatedRaw.isEmpty ? null : DateTime.tryParse(updatedRaw),
      lastMessageAt: lastMessageRaw.isEmpty
          ? null
          : DateTime.tryParse(lastMessageRaw),
      unreadCount: _toInt(json['unread_count'] ?? json['unreadCount']),
      userName: user is Map ? user['name']?.toString() ?? '' : '',
      userEmail: user is Map ? user['email']?.toString() ?? '' : '',
      status: json['status']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
