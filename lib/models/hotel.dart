class Hotel {
  final int id;
  final String name;
  final String city;
  final String ecoLevel;
  final String priceRange;
  final String description;
  final String imageUrl;
  final String affiliateUrl;

  const Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.ecoLevel,
    required this.priceRange,
    required this.description,
    required this.imageUrl,
    required this.affiliateUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      ecoLevel:
          json['eco_level']?.toString() ?? json['ecoLevel']?.toString() ?? '',
      priceRange:
          json['price_range']?.toString() ??
          json['priceRange']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
      imageUrl: _resolveImagePath(
        json['image_url']?.toString() ??
            json['imageUrl']?.toString() ??
            json['image']?.toString() ??
            '',
      ),
      affiliateUrl:
          json['affiliate_url']?.toString() ??
          json['affiliate_link']?.toString() ??
          json['affiliateUrl']?.toString() ??
          json['booking_url']?.toString() ??
          json['bookingUrl']?.toString() ??
          json['link']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'eco_level': ecoLevel,
      'price_range': priceRange,
      'description': description,
      'image_url': imageUrl,
      'affiliate_url': affiliateUrl,
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
