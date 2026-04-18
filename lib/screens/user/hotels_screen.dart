import 'package:flutter/material.dart';

import '../../models/hotel.dart';
import '../../services/api_service.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final ApiService _api = ApiService();
  late Future<List<Hotel>> _futureHotels;
  String _selectedCity = 'All';
  String _selectedEco = 'All';

  @override
  void initState() {
    super.initState();
    _futureHotels = _api.fetchHotels();
  }

  List<String> _citiesFrom(List<Hotel> hotels) {
    final allCities = hotels.map((h) => h.city).toSet().toList()..sort();
    return ['All', ...allCities];
  }

  List<String> _ecoLevelsFrom(List<Hotel> hotels) {
    final allEco = hotels.map((h) => h.ecoLevel).toSet().toList()..sort();
    return ['All', ...allEco];
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Eco Hotels'),
      ),
      body: FutureBuilder<List<Hotel>>(
        future: _futureHotels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final all = snapshot.data ?? [];
          final cities = _citiesFrom(all);
          final ecoLevels = _ecoLevelsFrom(all);

          if (!cities.contains(_selectedCity)) {
            _selectedCity = 'All';
          }
          if (!ecoLevels.contains(_selectedEco)) {
            _selectedEco = 'All';
          }

          final filteredHotels = all.where((h) {
            final cityOk = _selectedCity == 'All' || h.city == _selectedCity;
            final ecoOk = _selectedEco == 'All' || h.ecoLevel == _selectedEco;
            return cityOk && ecoOk;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _DropdownFilter(
                        label: 'City',
                        value: _selectedCity,
                        items: cities,
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownFilter(
                        label: 'Eco level',
                        value: _selectedEco,
                        items: ecoLevels,
                        onChanged: (value) {
                          setState(() {
                            _selectedEco = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredHotels.isEmpty
                    ? const Center(child: Text('No hotels found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filteredHotels.length,
                        itemBuilder: (context, index) {
                          final h = filteredHotels[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HotelDetailScreen(hotel: h),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: SizedBox(
                                      height: 250,
                                      width: double.infinity,
                                      child: h.imageUrl.isEmpty
                                          ? Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.hotel,
                                                  size: 40,
                                                ),
                                              ),
                                            )
                                          : Image.asset(
                                              h.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.hotel,
                                                      size: 40,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      10,
                                      12,
                                      12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                h.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 14,
                                                    color: Colors.orange,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    h.city,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Eco: ${h.ecoLevel}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Price: ${h.priceRange}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: items
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor, title: Text(hotel.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: hotel.imageUrl.isEmpty
                  ? Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.hotel, size: 40)),
                    )
                  : Image.asset(
                      hotel.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.hotel, size: 40),
                          ),
                        );
                      },
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
                  const SizedBox(height: 4),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Eco level: ${hotel.ecoLevel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Price: ${hotel.priceRange}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About this hotel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hotel.description,
                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Eco Practices',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '- Reduced plastic use and better waste management.\n'
                    '- Support for local communities and products.\n'
                    '- Encouraging low-impact activities such as walking and guided visits.\n'
                    '- Energy and water-saving policies where possible.',
                    style: TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
