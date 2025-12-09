import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../service/lost_item_service.dart';
import '../widgets/app_drawer.dart';
import '../detail/item_detail_page.dart'; // if you still use this

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LostItemService _service = LostItemService();

  late Future<List<LostItem>> _itemsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _itemsFuture = _service.fetchItems();
  }

  void _refresh() {
    setState(() {
      _itemsFuture = _service.fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(currentPage: "home"),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Items',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by title or location',
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: FutureBuilder<List<LostItem>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                // 🔍 Apply search on itemName & location
                final filtered = items.where((item) {
                  final q = _searchQuery.toLowerCase();
                  return item.itemName.toLowerCase().contains(q) ||
                      item.location.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 72,
                    color: Colors.white10,
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Image.network(
                            item.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      title: Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${item.type} • ${item.location}',
                        style: TextStyle(
                          color: item.type.toLowerCase() == 'lost'
                              ? Colors.redAccent
                              : Colors.greenAccent,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // If you still use a detail page:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemDetailPage(item: item),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
