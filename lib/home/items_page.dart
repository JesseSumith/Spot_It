import 'package:flutter/material.dart';

import '../../models/lost_item.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/add_item_form.dart';
import '../detail/item_detail_page.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<LostItem> _items = [
    LostItem(
      id: '1',
      email: 'finder@college.edu',
      photoUrl:
          'https://images.pexels.com/photos/59886/pexels-photo-59886.jpeg?auto=compress&cs=tinysrgb&w=800',
      type: 'found',
      itemName: 'black wallet',
      location: 'library second floor',
      date: DateTime(2025, 11, 29),
      details: 'Has student ID inside',
      contactName: 'Jesse',
      contactMethod: 'WhatsApp: 7702xxxxxx',
    ),
    LostItem(
      id: '2',
      email: 'owner@college.edu',
      photoUrl:
          'https://images.pexels.com/photos/130879/pexels-photo-130879.jpeg?auto=compress&cs=tinysrgb&w=800',
      type: 'Lost',
      itemName: 'Car keys',
      location: 'Parking lot',
      date: DateTime(2025, 11, 28),
      details: 'Hyundai key + keychain',
      contactName: 'Sam',
      contactMethod: 'Call: 98xxxxxxx',
    ),
    LostItem(
      id: '3',
      email: 'bracelet@college.edu',
      photoUrl:
          'https://images.pexels.com/photos/1035673/pexels-photo-1035673.jpeg?auto=compress&cs=tinysrgb&w=800',
      type: 'Lost',
      itemName: 'Bracelet',
      location: 'Cafeteria',
      date: DateTime(2025, 11, 27),
      details: 'Brown leather bracelet',
      contactName: 'Alex',
      contactMethod: 'Insta: @alex',
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((item) {
      final q = _searchQuery.toLowerCase();
      return item.itemName.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q) ||
          item.type.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(currentPage: "home"),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Users',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                hintText: 'Search',
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
            child: ListView.separated(
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72, color: Colors.white10),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Image.network(item.photoUrl, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(
                    item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item.type,
                    style: TextStyle(
                      color: item.type.toLowerCase() == 'found'
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () async {
                    final updated = await Navigator.push<LostItem?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailPage(item: item),
                      ),
                    );
                    if (updated != null) {
                      setState(() {
                        final i = _items.indexWhere(
                          (element) => element.id == item.id,
                        );
                        if (i != -1) _items[i] = updated;
                      });
                    }
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
