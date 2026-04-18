class BlogCounts {
  final int blogId;
  final int comments;
  final int likeCount;
  final int ecoCount;

  const BlogCounts({
    required this.blogId,
    required this.comments,
    required this.likeCount,
    required this.ecoCount,
  });

  factory BlogCounts.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'];
    return BlogCounts(
      blogId: _toInt(json['blog_id']),
      comments: _toInt(json['comments']),
      likeCount: reactions is Map ? _toInt(reactions['like']) : 0,
      ecoCount: reactions is Map ? _toInt(reactions['eco']) : 0,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
