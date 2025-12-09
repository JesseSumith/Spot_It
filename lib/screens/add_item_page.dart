import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../models/lost_item.dart';
import '../service/lost_item_service.dart';

class AddItemPage extends StatefulWidget {
  final void Function(LostItem) onSubmit;

  const AddItemPage({super.key, required this.onSubmit});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactMethodController = TextEditingController();

  DateTime? _selectedDate;
  String? _photoPath; // local path from gallery/camera
  final ImagePicker _picker = ImagePicker();

  String? _selectedType; // "lost" or "found"
  bool _isSubmitting = false;

  final LostItemService _service = LostItemService();

  @override
  void dispose() {
    _emailController.dispose();
    _itemNameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _contactNameController.dispose();
    _contactMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Add item'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottomInset + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Report a lost / found item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose whether the item is lost or found, then fill in the details.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),

                // TYPE + LOTTIE CARD (big buttons Lost / Found)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What are you reporting?',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _buildTypeSelector(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ITEM DETAILS CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item details',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField('Item name', _itemNameController),
                        _buildTextField('Location', _locationController),
                        _buildTextField(
                          'Details (color, brand, etc.)',
                          _detailsController,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // PHOTO CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photo (optional)',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        // Lottie hint above buttons when no image
                        if (_photoPath == null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SizedBox(
                              height: 90,
                              child: Opacity(
                                opacity: 0.9,
                                child: Lottie.asset(
                                  'assets/animations/camera.json',
                                  repeat: true,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        _buildPhotoPicker(context),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // DATE + CONTACT CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'When & contact',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField('Email', _emailController),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                prefixIcon: Icon(Icons.calendar_today),
                                hintText: 'dd-mm-yyyy',
                                filled: true,
                              ),
                              validator: (_) => _selectedDate == null
                                  ? 'Please select a date'
                                  : null,
                              controller: TextEditingController(
                                text: _selectedDate == null
                                    ? ''
                                    : '${_selectedDate!.day.toString().padLeft(2, '0')}-'
                                          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
                                          '${_selectedDate!.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField('Contact name', _contactNameController),
                        _buildTextField(
                          'Contact method (phone / email)',
                          _contactMethodController,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- WIDGET HELPERS ----------

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, filled: true),
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            },
      ),
    );
  }

  /// Big aesthetic Lost / Found buttons with Lottie animations.
  /// Sets `_selectedType` to exactly "lost" or "found"
  Widget _buildTypeSelector() {
    final lostSelected = _selectedType == 'lost';
    final foundSelected = _selectedType == 'found';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // LOST BUTTON
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() => _selectedType = 'lost');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: lostSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF5B5B), Color(0xFFFF8E8E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade900,
                              Colors.grey.shade800,
                            ],
                          ),
                    border: Border.all(
                      color: lostSelected
                          ? Colors.redAccent
                          : Colors.grey.shade700,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 70,
                        child: Lottie.asset(
                          'assets/animations/lost.json',
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Lost',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: lostSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You lost something',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: lostSelected ? Colors.white70 : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // FOUND BUTTON
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() => _selectedType = 'found');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: foundSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade900,
                              Colors.grey.shade800,
                            ],
                          ),
                    border: Border.all(
                      color: foundSelected
                          ? Colors.greenAccent
                          : Colors.grey.shade700,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 70,
                        child: Lottie.asset(
                          'assets/animations/found.json',
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: foundSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You found something',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: foundSelected
                              ? Colors.white70
                              : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedType == null)
          Text(
            'Please select Lost or Found',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.red.shade300),
          ),
      ],
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: _isSubmitting ? null : _pickFromGallery,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: _isSubmitting ? null : _pickFromCamera,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_photoPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.file(File(_photoPath!), fit: BoxFit.cover),
            ),
          )
        else
          Text(
            'No image selected',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
      ],
    );
  }

  // ---------- ACTIONS ----------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: now,
      builder: (context, child) {
        return Theme(data: ThemeData.dark(useMaterial3: true), child: child!);
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
      });
    }
  }

  Future<void> _submit() async {
    // avoid double taps
    if (_isSubmitting) return;

    // validate all form fields
    if (!_formKey.currentState!.validate()) return;

    // enforce lost / found selection
    if (_selectedType == null) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Lost or Found')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final tempId = DateTime.now().millisecondsSinceEpoch;

    final item = LostItem(
      id: tempId,
      email: _emailController.text.trim(),
      photoUrl: _photoPath ?? '',
      type: _selectedType!, // "lost" or "found"
      itemName: _itemNameController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      details: _detailsController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactMethod: _contactMethodController.text.trim(),
    );

    try {
      final hasImage = _photoPath != null && _photoPath!.isNotEmpty;
      print('🚀 SUBMIT: hasImage=$hasImage, path=$_photoPath');

      LostItem created;
      if (hasImage) {
        // multipart with file
        created = await _service.createItemWithImage(item, _photoPath!);
      } else {
        // plain JSON (no file)
        created = await _service.createItem(item);
      }

      print('✅ SUBMIT success, id=${created.id}, image=${created.photoUrl}');

      if (!mounted) return;
      widget.onSubmit(created);
      Navigator.pop(context);
    } catch (e, st) {
      // log full error to console, show friendly message in UI
      print('❌ SUBMIT error: $e');
      print(st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Please try again.')),
      );
      setState(() => _isSubmitting = false);
    }
  }
}
