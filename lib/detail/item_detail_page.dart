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
    print(
      '🔍 ItemDetailPage.initState: id=${_item.id}, name=${_item.itemName}, '
      'type=${_item.type}, photoUrl=${_item.photoUrl}',
    );
  }

  Future<void> _editItem() async {
    print(
      '✏️ ItemDetailPage._editItem: navigating to EditItemPage for id=${_item.id}',
    );
    final updated = await Navigator.push<LostItem?>(
      context,
      MaterialPageRoute(builder: (_) => EditItemPage(item: _item)),
    );

    if (updated != null && mounted) {
      print('✏️ ItemDetailPage._editItem: got updated item id=${updated.id}');
      setState(() => _item = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item updated')));
    } else {
      print('✏️ ItemDetailPage._editItem: no updated item returned');
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

    if (confirm != true) {
      print('🗑 ItemDetailPage._deleteItem: user cancelled delete');
      return;
    }

    setState(() => _isDeleting = true);
    print('🗑 ItemDetailPage._deleteItem: deleting id=${_item.id}');

    try {
      await _service.deleteItem(_item.id);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item deleted')));
      Navigator.pop(context, null); // Return to list
    } catch (e, st) {
      print('❌ ItemDetailPage._deleteItem error: $e');
      print(st);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _openFullScreenImage() {
    final hasImage =
        _item.photoUrl.isNotEmpty &&
        !_item.photoUrl.contains('null') &&
        !_item.photoUrl.contains('placeholder');

    if (!hasImage) {
      print('🖼 No valid image to show full screen');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImagePage(
          imageUrl: _item.photoUrl,
          heroTag: 'item-image-${_item.id}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLost = _item.type.toLowerCase() == 'lost';

    final hasImage =
        _item.photoUrl.isNotEmpty &&
        !_item.photoUrl.contains('null') &&
        !_item.photoUrl.contains('placeholder');

    return Scaffold(
      appBar: AppBar(
        title: Text(_item.itemName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              print('✏️ ItemDetailPage: edit icon pressed for id=${_item.id}');
              _editItem();
            },
          ),
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
              // Image Section (now tappable)
              GestureDetector(
                onTap: hasImage ? _openFullScreenImage : null,
                child: Hero(
                  tag: 'item-image-${_item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: hasImage
                          ? Image.network(
                              _item.photoUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 1024,
                              errorBuilder: (_, __, ___) {
                                print(
                                  '⚠️ ItemDetailPage: failed to load network image: ${_item.photoUrl}',
                                );
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Chip + Location
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
                        color: Colors.white,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(_item.details),
                const SizedBox(height: 16),
              ],

              // Contact section
              const Text(
                'Contact',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text(_item.contactName),
                subtitle: Text(_item.contactMethod),
              ),

              const SizedBox(height: 8),

              // Date
              const Text(
                'Reported on',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('${_item.date.day}/${_item.date.month}/${_item.date.year}'),
            ],
          ),
          if (_isDeleting)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
          // Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
