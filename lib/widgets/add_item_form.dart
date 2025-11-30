import 'package:flutter/material.dart';
import '../models/lost_item.dart';

class AddItemForm extends StatefulWidget {
  final void Function(LostItem) onSubmit;

  const AddItemForm({super.key, required this.onSubmit});

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _photoController = TextEditingController();
  final _typeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactMethodController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _emailController.dispose();
    _photoController.dispose();
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Add item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController),
            _buildTextField(
              'Photo URL (optional)',
              _photoController,
              validator: (_) => null,
            ),
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
                  validator: (_) =>
                      _selectedDate == null ? 'Please select a date' : null,
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
            _buildTextField('Contact method', _contactMethodController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = LostItem(
      id: id,
      email: _emailController.text.trim(),
      photoUrl: _photoController.text.trim().isEmpty
          ? 'https://via.placeholder.com/150'
          : _photoController.text.trim(),
      type: _typeController.text.trim(),
      itemName: _itemNameController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      details: _detailsController.text.trim(),
      contactName: _contactNameController.text.trim(),
      contactMethod: _contactMethodController.text.trim(),
    );

    widget.onSubmit(item);
  }
}
