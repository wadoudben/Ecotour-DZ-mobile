import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/hotel.dart';
import '../../services/api_service.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  static const primaryColor = Color(0xFFF15D30);

  final ApiService _api = ApiService();
  late Future<Hotel> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchHotelDetail(widget.hotelId);
  }

  void _retry() {
    setState(() {
      _future = _api.fetchHotelDetail(widget.hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor, title: const Text('Hotel')),
      body: FutureBuilder<Hotel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load hotel.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final hotel = snapshot.data;
          if (hotel == null) {
            return const Center(child: Text('Hotel not found.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: hotel.imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.hotel, size: 40),
                        )
                      : Image.asset(
                          hotel.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.hotel, size: 40),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hotel.city,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (hotel.ecoLevel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF15D30,
                                ).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                hotel.ecoLevel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFF15D30),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            hotel.priceRange,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Affiliate link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AffiliateLinkSection(
                        affiliateUrl: hotel.affiliateUrl,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AffiliateLinkSection extends StatelessWidget {
  final String affiliateUrl;
  final Color primaryColor;

  const _AffiliateLinkSection({
    required this.affiliateUrl,
    required this.primaryColor,
  });

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(affiliateUrl);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid affiliate link.')));
      return;
    }
    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open affiliate link.')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (affiliateUrl.trim().isEmpty) {
      return Text(
        'Affiliate link not available.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          affiliateUrl,
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openUrl(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Book via affiliate link'),
          ),
        ),
      ],
    );
  }
}
