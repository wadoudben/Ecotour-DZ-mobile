import 'package:flutter/material.dart';

class BlogEditScreen extends StatefulWidget {
  final BlogPost? initialPost; // null = create mode, not null = edit mode

  const BlogEditScreen({super.key, this.initialPost});

  @override
  State<BlogEditScreen> createState() => _BlogEditScreenState();
}

// Simple local model for demonstration
class BlogPost {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String status; // 'draft' or 'published'
  final String imageUrl; // optional

  BlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.status,
    required this.imageUrl,
  });
}

class _BlogEditScreenState extends State<BlogEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _excerptController;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  String _status = 'draft'; // default

  bool get isEditMode => widget.initialPost != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.initialPost?.title ?? '',
    );
    _excerptController = TextEditingController(
      text: widget.initialPost?.excerpt ?? '',
    );
    _contentController = TextEditingController(
      text: widget.initialPost?.content ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.initialPost?.imageUrl ?? '',
    );
    _status = widget.initialPost?.status ?? 'draft';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final excerpt = _excerptController.text.trim();
    final content = _contentController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    // - if isEditMode: PUT /api/blogs/{id}
    // - else: POST /api/blogs

    // For now, just pop with result
    Navigator.pop(context, {
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'status': _status,
      'image_url': imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(isEditMode ? 'Edit blog post' : 'New blog post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onSave,
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
              // TITLE
              const Text(
                'Title',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Enter blog title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // EXCERPT
              const Text(
                'Short excerpt',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _excerptController,
                maxLines: 3,
                decoration: _inputDecoration('Short summary for preview'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Excerpt is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CONTENT
              const Text(
                'Content',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: _inputDecoration('Write your article here'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // IMAGE URL
              const Text(
                'Cover image URL (optional)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _imageUrlController,
                decoration: _inputDecoration('https://example.com/image.jpg'),
              ),
              const SizedBox(height: 16),

              // STATUS DROPDOWN
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(
                        value: 'published',
                        child: Text('Published'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _status = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SAVE BUTTON (bottom)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(
                    isEditMode ? 'Save changes' : 'Create post',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (isEditMode)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: confirm & call DELETE API
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Delete post',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
}
