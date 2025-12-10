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

  /// UI dropdown uses "Lost"/"Found"
  String _type = 'Lost';
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

    // backend model uses "lost"/"found", UI shows "Lost"/"Found"
    _type = widget.item.type.toLowerCase() == 'lost' ? 'Lost' : 'Found';
    _selectedDate = widget.item.date;

    print(
      '✏️ EditItemPage.initState: id=${widget.item.id}, type=${widget.item.type}, name=${widget.item.itemName}',
    );
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
      print('📅 EditItemPage: picked date=$_selectedDate');
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      print('⚠️ EditItemPage._saveChanges: form invalid');
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // Convert "Lost"/"Found" -> "lost"/"found"
    final normalizedType = _type.toLowerCase();

    final updated = LostItem(
      id: widget.item.id,
      email: widget.item.email,
      photoUrl: widget.item.photoUrl, // not changing image here
      type: normalizedType,
      itemName: _itemNameController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      details: _detailsController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactMethod: _contactMethodController.text.trim(),
    );

    print(
      '✏️ EditItemPage._saveChanges: '
      'id=${updated.id}, type=${updated.type}, name=${updated.itemName}',
    );

    try {
      // MUST match LostItemService signature
      final saved = await _service.updateItem(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item updated')));

      // send updated item back
      Navigator.pop(context, saved);
    } catch (e, st) {
      print('❌ EditItemPage update error: $e');
      print(st);
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
                    print('✏️ EditItemPage: type changed → $_type');
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select date',
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(labelText: 'Contact name'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactMethodController,
                decoration: const InputDecoration(labelText: 'Contact method'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

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
