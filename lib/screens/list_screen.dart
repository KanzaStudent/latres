import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/space_item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';

class ListScreen extends StatefulWidget {
  final String menu;
  final String title;

  const ListScreen({
    super.key,
    required this.menu,
    required this.title,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<SpaceItem> _items = [];
  List<String> _authors = [];
  String _selectedAuthor = '';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final items = await ApiService.getItems(widget.menu);
      final authorSet = <String>{};
      for (var item in items) {
        if (item.author.trim().isNotEmpty && item.author != 'Unknown') {
          authorSet.add(item.author.trim());
        }
      }

      setState(() {
        _items = items;
        _authors = authorSet.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = _selectedAuthor.isEmpty
        ? _items
        : _items.where((element) => element.author == _selectedAuthor).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            tooltip: 'Favorite',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    // Filter Chips Bar
                    if (_authors.isNotEmpty)
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: const Text('All'),
                                selected: _selectedAuthor.isEmpty,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedAuthor = '';
                                  });
                                },
                              ),
                            ),
                            ..._authors.map((author) {
                              final isSelected = _selectedAuthor == author;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(author),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedAuthor = selected ? author : '';
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    Expanded(
                      child: displayedItems.isEmpty
                          ? const Center(child: Text('Tidak ada data ditemukan'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: displayedItems.length,
                              itemBuilder: (context, index) {
                                final item = displayedItems[index];
                                return Card(
                                  color: const Color(0xFFFBF0F7),
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.purple.shade50),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        item.imageUrl,
                                        width: 75,
                                        height: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 75,
                                            height: 55,
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        item.author,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            menu: widget.menu,
                                            id: item.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
