import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AdminCreateDestinationScreen extends StatefulWidget {
  const AdminCreateDestinationScreen({super.key});

  @override
  State<AdminCreateDestinationScreen> createState() =>
      _AdminCreateDestinationScreenState();
}

class _AdminCreateDestinationScreenState
    extends State<AdminCreateDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _typeController.dispose();
    _shortDescriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _api.createAdminDestination(
        name: _nameController.text.trim(),
        region: _regionController.text.trim(),
        type: _typeController.text.trim(),
        shortDescription: _shortDescriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Destination created.')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
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
        title: const Text('New destination'),
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
                decoration: _inputDecoration('Destination name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Region',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _regionController,
                decoration: _inputDecoration('Region'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Region is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _typeController,
                decoration: _inputDecoration('Type'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Type is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Short description',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _shortDescriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Short description'),
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
                    'Create destination',
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
