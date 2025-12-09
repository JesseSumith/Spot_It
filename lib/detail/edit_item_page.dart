import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../service/lost_item_service.dart';

class EditItemPage extends StatefulWidget {
  final LostItem item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  final LostItemService _service = LostItemService();

  late TextEditingController _itemNameController;
  late TextEditingController _locationController;
  late TextEditingController _detailsController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactMethodController;
  String _type = 'Lost'; // dropdown value
  DateTime? _selectedDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.item.itemName);
    _locationController = TextEditingController(text: widget.item.location);
    _detailsController = TextEditingController(text: widget.item.details);
    _contactNameController = TextEditingController(
      text: widget.item.contactName,
    );
    _contactMethodController = TextEditingController(
      text: widget.item.contactMethod,
    );
    _type = widget.item.type; // "Lost" or "Found"
    _selectedDate = widget.item.date;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _contactNameController.dispose();
    _contactMethodController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final updated = LostItem(
      id: widget.item.id,
      email: widget.item.email,
      photoUrl: widget.item.photoUrl,
      type: _type,
      itemName: _itemNameController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      details: _detailsController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactMethod: _contactMethodController.text.trim(),
    );

    setState(() => _isSaving = true);

    try {
      final saved = await _service.updateItem(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item updated')));

      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit item'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type (Lost / Found)
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                  DropdownMenuItem(value: 'Found', child: Text('Found')),
                ],
                decoration: const InputDecoration(labelText: 'Type'),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Item name
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? _selectedDate!.toLocal().toString().substring(
                                0,
                                10,
                              )
                            : 'Select date',
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Details
              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
              const SizedBox(height: 16),

              // Contact name
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(labelText: 'Contact name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter contact name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact method
              TextFormField(
                controller: _contactMethodController,
                decoration: const InputDecoration(
                  labelText: 'Contact method (phone, WhatsApp, etc.)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter contact method';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save button (in case user misses app bar icon)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
