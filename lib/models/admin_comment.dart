class AdminComment {
  final int id;
  final String content;
  final String status;
  final String authorName;
  final String authorEmail;
  final String blogTitle;
  final DateTime? createdAt;

  const AdminComment({
    required this.id,
    required this.content,
    required this.status,
    required this.authorName,
    required this.authorEmail,
    required this.blogTitle,
    required this.createdAt,
  });

  factory AdminComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final blog = json['blog'];
    return AdminComment(
      id: _toInt(json['id']),
      content: json['content']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      authorName: user is Map ? user['name']?.toString() ?? '' : '',
      authorEmail: user is Map ? user['email']?.toString() ?? '' : '',
      blogTitle: blog is Map ? blog['title']?.toString() ?? '' : '',
      createdAt: _parseDate(json['created_at']),
    );
  }

  AdminComment copyWith({String? status}) {
    return AdminComment(
      id: id,
      content: content,
      status: status ?? this.status,
      authorName: authorName,
      authorEmail: authorEmail,
      blogTitle: blogTitle,
      createdAt: createdAt,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
