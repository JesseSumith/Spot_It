import 'package:flutter/material.dart';

import '../models/lost_item.dart';

class EditItemPage extends StatefulWidget {
  final LostItem item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _typeController;
  late TextEditingController _itemNameController;
  late TextEditingController _locationController;
  late TextEditingController _detailsController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactMethodController;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _typeController = TextEditingController(text: item.type);
    _itemNameController = TextEditingController(text: item.itemName);
    _locationController = TextEditingController(text: item.location);
    _detailsController = TextEditingController(text: item.details);
    _contactNameController = TextEditingController(text: item.contactName);
    _contactMethodController = TextEditingController(text: item.contactMethod);
    _date = item.date;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _itemNameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _contactNameController.dispose();
    _contactMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Type', _typeController),
              _buildField('Item name', _itemNameController),
              _buildField('Location', _locationController),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _date == null
                          ? ''
                          : '${_date!.day.toString().padLeft(2, '0')}-'
                                '${_date!.month.toString().padLeft(2, '0')}-'
                                '${_date!.year}',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (_) =>
                        _date == null ? 'Please select date' : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildField('Details', _detailsController, maxLines: 2),
              _buildField('Contact name', _contactNameController),
              _buildField('Contact method', _contactMethodController),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: _date ?? now,
      builder: (context, child) {
        return Theme(data: ThemeData.dark(useMaterial3: true), child: child!);
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = LostItem(
      id: widget.item.id,
      email: widget.item.email,
      photoUrl: widget.item.photoUrl,
      type: _typeController.text.trim(),
      itemName: _itemNameController.text.trim(),
      location: _locationController.text.trim(),
      date: _date ?? DateTime.now(),
      details: _detailsController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactMethod: _contactMethodController.text.trim(),
    );

    Navigator.pop(context, updated);
  }
}
