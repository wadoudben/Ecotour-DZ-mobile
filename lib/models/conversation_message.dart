class ConversationMessage {
  final int id;
  final String content;
  final int? senderId;
  final DateTime? createdAt;

  const ConversationMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    final createdRaw =
        json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '';
    return ConversationMessage(
      id: _toInt(json['id']),
      content:
          json['content']?.toString() ??
          json['message']?.toString() ??
          json['body']?.toString() ??
          '',
      senderId: _toIntNullable(json['sender_id'] ?? json['user_id']),
      createdAt: createdRaw.isEmpty ? null : DateTime.tryParse(createdRaw),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
