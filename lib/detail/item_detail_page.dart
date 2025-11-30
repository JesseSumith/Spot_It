import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import 'edit_item_page.dart';

class ItemDetailPage extends StatefulWidget {
  final LostItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late LostItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _item),
        ),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(_item.photoUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () async {
                  final updated = await Navigator.push<LostItem?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditItemPage(item: _item),
                    ),
                  );
                  if (updated != null) {
                    setState(() => _item = updated);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildDetailRow('type', _item.type),
                _buildDetailRow('item_name', _item.itemName),
                _buildDetailRow('location', _item.location),
                _buildDetailRow(
                  'date',
                  '${_item.date.day.toString().padLeft(2, '0')}-'
                      '${_item.date.month.toString().padLeft(2, '0')}-'
                      '${_item.date.year}',
                ),
                _buildDetailRow('details', _item.details),
                _buildDetailRow('contact_name', _item.contactName),
                _buildDetailRow(
                  'contact_method',
                  _item.contactMethod,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
