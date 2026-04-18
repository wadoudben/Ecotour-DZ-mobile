class BlogPost {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String imageUrl;
  final DateTime? createdAt;

  const BlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    final createdRaw =
        json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '';

    return BlogPost(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      imageUrl: _resolveImagePath(
        json['featured_image']?.toString() ??
            json['image_url']?.toString() ??
            json['imageUrl']?.toString() ??
            json['image']?.toString() ??
            '',
      ),
      createdAt: createdRaw.isEmpty ? null : DateTime.tryParse(createdRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _resolveImagePath(String raw) {
    if (raw.isEmpty) return '';
    final trimmed = raw.trim().replaceAll('\\', '/');
    final parts = trimmed.split('/');
    var fileName = parts.isNotEmpty ? parts.last : trimmed;
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }
    if (fileName.contains('#')) {
      fileName = fileName.split('#').first;
    }
    return fileName.isEmpty ? '' : 'images/$fileName';
  }
}
