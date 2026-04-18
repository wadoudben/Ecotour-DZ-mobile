import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/hotel.dart';
import '../../services/api_service.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  static const primaryColor = Color(0xFFF15D30);

  final ApiService _api = ApiService();
  late Future<List<Hotel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchHotels();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchHotels();
    });
  }

  Future<void> _openAffiliateLink(Hotel hotel) async {
    final rawLink = hotel.affiliateUrl.trim();
    if (rawLink.isEmpty) {
      _showSnackBar('Affiliate link not available.');
      return;
    }
    final uri = Uri.tryParse(rawLink);
    if (uri == null) {
      _showSnackBar('Invalid affiliate link.');
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        _showSnackBar('Cannot open affiliate link.');
      }
    } catch (_) {
      _showSnackBar('Cannot open affiliate link.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Hotels'),
      ),
      body: FutureBuilder<List<Hotel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _retry);
          }

          final hotels = snapshot.data ?? [];
          if (hotels.isEmpty) {
            return const Center(child: Text('No hotels found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];

              return GestureDetector(
                onTap: () => _openAffiliateLink(hotel),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: hotel.imageUrl.isEmpty
                                ? Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.hotel,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Image.asset(
                                    hotel.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.hotel,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hotel.city,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF15D30,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        hotel.ecoLevel,
                                        style: const TextStyle(
                                          fontSize: 11,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Failed to load hotels.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF15D30),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
