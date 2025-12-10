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

class _AddItemPageState extends State<AddItemPage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactMethodController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  String? _photoPath;
  String? _selectedType;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();
  final LostItemService _service = LostItemService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _retrieveLostData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _itemNameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _contactNameController.dispose();
    _contactMethodController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _retrieveLostData() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return;
    if (response.file != null) {
      setState(() => _photoPath = response.file!.path);
      print(
        '♻️ RETRIEVE_LOST_DATA: restored photoPath = $_photoPath, exists? ${File(_photoPath!).existsSync()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTypeSelector(),
                const SizedBox(height: 16),
                _buildDetailsCard(),
                const SizedBox(height: 16),
                _buildPhotoCard(),
                const SizedBox(height: 16),
                _buildContactCard(),
                const SizedBox(height: 24),
                _buildSubmitButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, filled: true),
        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "What are you reporting?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _typeOption("Lost")),
                const SizedBox(width: 12),
                Expanded(child: _typeOption("Found")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeOption(String type) {
    final selected = _selectedType == type.toLowerCase();
    final color = type == "Lost" ? Colors.redAccent : Colors.greenAccent;

    return InkWell(
      onTap: () {
        setState(() => _selectedType = type.toLowerCase());
        print('🔵 TYPE SELECTED: $_selectedType');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? color : Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: selected ? color.withOpacity(0.2) : null,
        ),
        child: Column(
          children: [
            Icon(
              type == "Lost" ? Icons.search_off : Icons.check_circle_outline,
              size: 40,
              color: selected ? color : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Item name", _itemNameController),
            _buildTextField("Location", _locationController),
            _buildTextField("Details", _detailsController, maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Photo (Optional)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
              ],
            ),
            if (_photoPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(_photoPath!),
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        print('🧹 CLEAR PHOTO, old path = $_photoPath');
                        setState(() => _photoPath = null);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Email", _emailController),
            _buildTextField("Contact Name", _contactNameController),
            _buildTextField("Contact Method", _contactMethodController),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: "Date",
                    icon: Icon(Icons.calendar_today),
                  ),
                  validator: (_) => _selectedDate == null ? "Required" : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButtons() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text("Submit"),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (picked != null) {
        setState(() => _photoPath = picked.path);
        print(
          '📸 PICK_IMAGE: source=$source, path=$_photoPath, exists? ${File(_photoPath!).existsSync()}',
        );
      } else {
        print('📸 PICK_IMAGE: user cancelled, no file selected');
      }
    } catch (e) {
      print("❌ Error picking image: $e");
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _selectedDate = picked;
      _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      print('📅 DATE PICKED: $_selectedDate');
    }
  }

  Future<void> _submit() async {
    print('🚀 SUBMIT PRESSED');
    print('🚀 SUBMIT: selectedType = $_selectedType');
    print('🚀 SUBMIT: photoPath = $_photoPath');

    if (_photoPath != null) {
      print(
        '🚀 SUBMIT: file exists? ${File(_photoPath!).existsSync()} (path=$_photoPath)',
      );
    }

    if (!_formKey.currentState!.validate() || _selectedType == null) {
      print('⚠️ SUBMIT: form invalid or type not selected');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please complete the form")));
      return;
    }

    setState(() => _isSubmitting = true);

    final item = LostItem(
      id: 0,
      email: _emailController.text,
      photoUrl: "",
      type: _selectedType!,
      itemName: _itemNameController.text,
      location: _locationController.text,
      date: _selectedDate ?? DateTime.now(),
      details: _detailsController.text,
      contactName: _contactNameController.text,
      contactMethod: _contactMethodController.text,
    );

    try {
      LostItem created;

      if (_photoPath != null && _photoPath!.isNotEmpty) {
        // ✅ TRUST the picker path; let MultipartFile throw if there's a real issue
        print("📤 SUBMIT: calling createItemWithImage, path=$_photoPath");
        created = await _service.createItemWithImage(item, _photoPath!);
      } else {
        print("📤 SUBMIT: calling createItem (JSON only, no image)");
        created = await _service.createItem(item);
      }

      print('✅ SUBMIT SUCCESS: created item id=${created.id}');

      if (mounted) {
        widget.onSubmit(created);
        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ SUBMIT ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isSubmitting = false);
      }
    }
  }
}
