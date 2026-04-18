class AuthorBlog {
  final int id;
  final String title;
  final String excerpt;
  final String status;
  final DateTime? createdAt;
  final int commentsCount;

  const AuthorBlog({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.status,
    required this.createdAt,
    required this.commentsCount,
  });

  factory AuthorBlog.fromJson(Map<String, dynamic> json) {
    final createdRaw =
        json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '';
    final statusRaw =
        json['status']?.toString() ?? json['state']?.toString() ?? '';
    final published = json['published'];
    String status = statusRaw.isEmpty ? '' : statusRaw.toLowerCase();
    if (status.isEmpty && published is bool) {
      status = published ? 'published' : 'draft';
    }
    if (status.isEmpty) {
      status = 'draft';
    }
    final comments = json['comments_count'] ?? json['commentsCount'];

    return AuthorBlog(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      status: status,
      createdAt: createdRaw.isEmpty ? null : DateTime.tryParse(createdRaw),
      commentsCount: _toInt(comments),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
