import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../models/destination.dart';
import '../../services/api_service.dart';
import 'destination_detail_screen.dart';

class DestinationsMapScreen extends StatefulWidget {
  const DestinationsMapScreen({super.key});

  @override
  State<DestinationsMapScreen> createState() => _DestinationsMapScreenState();
}

class _DestinationsMapScreenState extends State<DestinationsMapScreen> {
  static const primaryColor = Color(0xFFF15D30);
  static const _googleApiKey = 'AIzaSyC9MthqfG16fjHR7SZaEr9Kn9muxyi2YG0';
  final ApiService _api = ApiService();
  final Set<Marker> _markers = {};
  final Map<int, LatLng> _coordCache = {};
  final Map<String, LatLng> _manualOverrides = {
    'asekram': LatLng(23.30550979215068, 6.323113957705458),
    'assekrem': LatLng(23.30550979215068, 6.323113957705458),
    'assekrem in ahaggar national park': LatLng(
      23.30550979215068,
      6.323113957705458,
    ),
    'assekrem in ahagar national park': LatLng(
      23.30550979215068,
      6.323113957705458,
    ),
  };

  bool _loading = true;
  String? _errorMessage;
  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(28.0339, 1.6596), // Algeria center
    zoom: 5.0,
  );

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _markers.clear();
      _coordCache.clear();
    });

    try {
      final destinations = await _api.fetchDestinations();
      if (!mounted) return;

      for (final destination in destinations) {
        final coord = await _geocodeDestination(destination);
        if (coord == null) continue;
        if (!mounted) return;

        _coordCache[destination.id] = coord;
        _markers.add(
          Marker(
            markerId: MarkerId('dest-${destination.id}'),
            position: coord,
            infoWindow: InfoWindow(
              title: destination.name,
              snippet: destination.region,
              onTap: () => _openDetail(destination.id),
            ),
            onTap: () => _openDetail(destination.id),
          ),
        );
        setState(() {});
      }

      if (_coordCache.isNotEmpty) {
        final first = _coordCache.values.first;
        _initialCamera = CameraPosition(target: first, zoom: 6.5);
      }
    } catch (_) {
      if (!mounted) return;
      _errorMessage = 'Failed to load destinations.';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<LatLng?> _geocodeDestination(Destination destination) async {
    final nameKey = destination.name.trim().toLowerCase();
    if (_manualOverrides.containsKey(nameKey)) {
      return _manualOverrides[nameKey];
    }
    if (nameKey.contains('assekrem') || nameKey.contains('asekrem')) {
      return _manualOverrides['assekrem'];
    }
    if (_coordCache.containsKey(destination.id)) {
      return _coordCache[destination.id];
    }
    final baseQuery = destination.region.isNotEmpty
        ? '${destination.name} ${destination.region}'
        : destination.name;
    final query = '$baseQuery Algeria'.trim();
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': query,
      'key': _googleApiKey,
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      if (decoded['status'] != 'OK') return null;
      final results = decoded['results'];
      if (results is! List || results.isEmpty) return null;
      final first = results.first;
      if (first is! Map) return null;
      final geometry = first['geometry'];
      if (geometry is! Map) return null;
      final location = geometry['location'];
      if (location is! Map) return null;
      final lat = location['lat'];
      final lng = location['lng'];
      if (lat is num && lng is num) {
        return LatLng(lat.toDouble(), lng.toDouble());
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void _openDetail(int destinationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(destinationId: destinationId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Destinations Map'),
        actions: [
          IconButton(
            onPressed: _loadDestinations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadDestinations)
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera,
                  markers: _markers,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                ),
                if (_loading)
                  const Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: _LoadingBanner(),
                  ),
              ],
            ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Loading destinations...',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
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
