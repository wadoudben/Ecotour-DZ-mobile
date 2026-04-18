import 'package:flutter/material.dart';

import '../../models/hotel.dart';
import '../../services/api_service.dart';

class AdminEditHotelScreen extends StatefulWidget {
  final Hotel hotel;

  const AdminEditHotelScreen({super.key, required this.hotel});

  @override
  State<AdminEditHotelScreen> createState() => _AdminEditHotelScreenState();
}

class _AdminEditHotelScreenState extends State<AdminEditHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _ecoLevelController;
  late TextEditingController _priceRangeController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel.name);
    _cityController = TextEditingController(text: widget.hotel.city);
    _ecoLevelController = TextEditingController(text: widget.hotel.ecoLevel);
    _priceRangeController = TextEditingController(
      text: widget.hotel.priceRange,
    );
    _descriptionController = TextEditingController(
      text: widget.hotel.description,
    );
    _imageUrlController = TextEditingController(text: widget.hotel.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _ecoLevelController.dispose();
    _priceRangeController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updated = await _api.updateAdminHotel(
        id: widget.hotel.id,
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        ecoLevel: _ecoLevelController.text.trim(),
        priceRange: _priceRangeController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hotel updated.')));
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: const Text('Edit hotel'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.check),
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Hotel name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'City',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration('City'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Eco level',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ecoLevelController,
                decoration: _inputDecoration('Eco level'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Eco level is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Price range',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceRangeController,
                decoration: _inputDecoration('Price range'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price range is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Description'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Image URL (optional)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _imageUrlController,
                decoration: _inputDecoration('https://example.com/image.jpg'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text(
                    'Save changes',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
