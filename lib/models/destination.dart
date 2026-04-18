class Destination {
  final int id;
  final String name;
  final String region;
  final String type;
  final String shortDescription;
  final String imageUrl;

  const Destination({
    required this.id,
    required this.name,
    required this.region,
    required this.type,
    required this.shortDescription,
    required this.imageUrl,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      shortDescription:
          json['short_description']?.toString() ??
          json['shortDescription']?.toString() ??
          '',
      imageUrl: _resolveImagePath(
        json['image_url']?.toString() ??
            json['imageUrl']?.toString() ??
            json['image']?.toString() ??
            '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'type': type,
      'short_description': shortDescription,
      'image_url': imageUrl,
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
