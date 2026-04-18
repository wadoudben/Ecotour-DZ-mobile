class AuthorComment {
  final int id;
  final String content;
  final String authorName;
  final String authorEmail;
  final String blogTitle;
  final DateTime? createdAt;

  const AuthorComment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.authorEmail,
    required this.blogTitle,
    required this.createdAt,
  });

  factory AuthorComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final blog = json['blog'];
    return AuthorComment(
      id: _toInt(json['id']),
      content: json['content']?.toString() ?? '',
      authorName: user is Map ? user['name']?.toString() ?? '' : '',
      authorEmail: user is Map ? user['email']?.toString() ?? '' : '',
      blogTitle: blog is Map ? blog['title']?.toString() ?? '' : '',
      createdAt: _parseDate(json['created_at']),
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
