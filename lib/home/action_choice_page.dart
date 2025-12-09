import 'dart:io';

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:image_picker/image_picker.dart';

import 'package:spot_it/service/lost_item_service.dart';
import 'items_page.dart';
import 'package:spot_it/models/lost_item.dart';

class ActionChoicePage extends StatefulWidget {
  const ActionChoicePage({super.key});

  @override
  State<ActionChoicePage> createState() => _ActionChoicePageState();
}

class _ActionChoicePageState extends State<ActionChoicePage> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    // simple fade-in for the row of cards
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _show = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('What would you like to do?'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Campus Lost & Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an action',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),

            // HORIZONTAL CARDS WITH CONTAINER TRANSFORM
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _show ? 1 : 0,
              child: Row(
                children: [
                  // REPORT CARD
                  Expanded(
                    child: OpenContainer(
                      closedElevation: 0,
                      openElevation: 0,
                      closedColor: const Color(0xFF151515),
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      transitionDuration: const Duration(milliseconds: 450),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      openBuilder: (context, _) => const ReportItemPage(),
                      closedBuilder: (context, openContainer) {
                        return _ActionCard(
                          icon: Icons.report_gmailerrorred_outlined,
                          title: 'Report',
                          subtitle: 'Lost / found item',
                          onTap: openContainer,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),

                  // CLAIM CARD
                  Expanded(
                    child: OpenContainer(
                      closedElevation: 0,
                      openElevation: 0,
                      closedColor: const Color(0xFF151515),
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      transitionDuration: const Duration(milliseconds: 450),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      openBuilder: (context, _) => const ItemsPage(),
                      closedBuilder: (context, openContainer) {
                        return _ActionCard(
                          icon: Icons.search_outlined,
                          title: 'Claim',
                          subtitle: 'Find your item',
                          onTap: openContainer,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PURE CONTENT CARD – tap is handled by OpenContainer
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== FULL-SCREEN REPORT PAGE =====================

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  final LostItemService _service = LostItemService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _typeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactMethodController = TextEditingController();

  DateTime? _selectedDate;
  String? _photoPath;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _typeController.dispose();
    _itemNameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _contactNameController.dispose();
    _contactMethodController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(LostItem item) async {
    setState(() => _isSubmitting = true);

    try {
      await _service.createItem(item);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item reported successfully')),
      );

      Navigator.pop(context); // go back to action/items page
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = DateTime.now().millisecondsSinceEpoch;

    final item = LostItem(
      id: id,
      email: _emailController.text.trim(),
      // store local path if image picked, otherwise placeholder
      photoUrl: _photoPath ?? 'https://via.placeholder.com/150',
      type: _typeController.text.trim(),
      itemName: _itemNameController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      details: _detailsController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactMethod: _contactMethodController.text.trim(),
    );

    _handleSubmit(item);
  }

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

  Widget _buildPhotoPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo (optional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: _pickFromGallery,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: _pickFromCamera,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_photoPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 150,
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Report item')),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: bottomInset + 24, // make sure button stays visible
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Email', _emailController),
                    const SizedBox(height: 8),
                    _buildPhotoPicker(context),
                    const SizedBox(height: 8),
                    _buildTextField('Type (Lost / Found)', _typeController),
                    _buildTextField('Item name', _itemNameController),
                    _buildTextField('Location', _locationController),
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
                    _buildTextField('Details', _detailsController, maxLines: 2),
                    _buildTextField('Contact name', _contactNameController),
                    _buildTextField(
                      'Contact method (phone / email)',
                      _contactMethodController,
                    ),
                    const SizedBox(height: 24),
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
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
