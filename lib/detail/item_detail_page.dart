import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../service/lost_item_service.dart';
import 'edit_item_page.dart';

class ItemDetailPage extends StatefulWidget {
  final LostItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final LostItemService _service = LostItemService();

  late LostItem _item;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _editItem() async {
    final updated = await Navigator.push<LostItem?>(
      context,
      MaterialPageRoute(builder: (_) => EditItemPage(item: _item)),
    );

    if (updated != null && mounted) {
      setState(() => _item = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item updated')));
      // Also pop back to list with updated item if you want:
      // Navigator.pop(context, updated);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await _service.deleteItem(_item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item deleted')));

      // Pop back to list; ItemsPage can call _refresh()
      Navigator.pop(context, null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = _item.type.toLowerCase() == 'lost';

    return Scaffold(
      appBar: AppBar(
        title: Text(_item.itemName),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editItem),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _deleteItem,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _item.photoUrl.isNotEmpty
                      ? Image.network(
                          _item.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: Colors.white10,
                          child: const Center(
                            child: Icon(Icons.photo, size: 48),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Type chip + location
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLost ? Colors.redAccent : Colors.greenAccent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      isLost ? 'Lost' : 'Found',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _item.location,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                _item.itemName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              if (_item.details.isNotEmpty) ...[
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _item.details,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
              ],

              // Contact info
              const Text(
                'Contact',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(_item.contactName),
                subtitle: Text(_item.contactMethod),
              ),

              const SizedBox(height: 8),

              // Date
              const Text(
                'Reported on',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _item.date.toLocal().toString().substring(0, 16),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
