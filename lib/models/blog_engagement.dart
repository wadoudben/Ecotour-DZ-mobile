class BlogEngagement {
  final int blogId;
  final List<BlogComment> comments;
  final List<BlogReaction> reactions;
  final int likeCount;
  final int ecoCount;
  final bool userLike;
  final bool userEco;

  const BlogEngagement({
    required this.blogId,
    required this.comments,
    required this.reactions,
    required this.likeCount,
    required this.ecoCount,
    required this.userLike,
    required this.userEco,
  });

  factory BlogEngagement.fromJson(Map<String, dynamic> json) {
    final commentsRaw = json['comments'];
    final reactionsRaw = json['reactions'];
    final reactionCounts = json['reaction_counts'];
    final userReactions = json['user_reactions'];

    return BlogEngagement(
      blogId: _toInt(json['blog_id']),
      comments: commentsRaw is List
          ? commentsRaw
                .map(
                  (item) => BlogComment.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : const [],
      reactions: reactionsRaw is List
          ? reactionsRaw
                .map(
                  (item) => BlogReaction.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : const [],
      likeCount: reactionCounts is Map ? _toInt(reactionCounts['like']) : 0,
      ecoCount: reactionCounts is Map ? _toInt(reactionCounts['eco']) : 0,
      userLike: userReactions is Map ? userReactions['like'] == true : false,
      userEco: userReactions is Map ? userReactions['eco'] == true : false,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class BlogComment {
  final int id;
  final String content;
  final String userName;
  final DateTime? createdAt;
  final int likeCount;
  final int ecoCount;
  final List<BlogComment> replies;

  const BlogComment({
    required this.id,
    required this.content,
    required this.userName,
    required this.createdAt,
    required this.likeCount,
    required this.ecoCount,
    required this.replies,
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final reactions = json['reactions'];
    final repliesRaw = json['replies'];

    var likeCount = 0;
    var ecoCount = 0;
    if (reactions is List) {
      for (final item in reactions) {
        if (item is Map) {
          final type = item['type']?.toString();
          if (type == 'like') {
            likeCount += 1;
          } else if (type == 'eco') {
            ecoCount += 1;
          }
        }
      }
    }

    return BlogComment(
      id: _toInt(json['id']),
      content: json['content']?.toString() ?? '',
      userName: _readUserName(user) ?? json['user_name']?.toString() ?? 'User',
      createdAt: _parseDate(json['created_at']),
      likeCount: likeCount,
      ecoCount: ecoCount,
      replies: repliesRaw is List
          ? repliesRaw
                .map(
                  (item) => BlogComment.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : const [],
    );
  }

  static String? _readUserName(dynamic user) {
    if (user is Map) {
      return user['name']?.toString();
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class BlogReaction {
  final int id;
  final String type;
  final String userName;
  final DateTime? createdAt;

  const BlogReaction({
    required this.id,
    required this.type,
    required this.userName,
    required this.createdAt,
  });

  factory BlogReaction.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return BlogReaction(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      userName: _readUserName(user) ?? json['user_name']?.toString() ?? 'User',
      createdAt: _parseDate(json['created_at']),
    );
  }

  static String? _readUserName(dynamic user) {
    if (user is Map) {
      return user['name']?.toString();
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
