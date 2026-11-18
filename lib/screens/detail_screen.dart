import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_service.dart';
import '../models/space_item.dart';

class DetailScreen extends StatefulWidget {
  final String menu;
  final int id;

  const DetailScreen({
    super.key,
    required this.menu,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  SpaceItem? _item;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final item = await ApiService.getSingleItem(widget.menu, widget.id);
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      // If fetching fails, check if the item is cached in favorites
      final box = Hive.box('favorites');
      if (box.containsKey(widget.id.toString())) {
        final raw = box.get(widget.id.toString());
        setState(() {
          _item = SpaceItem.fromMap(raw is Map ? raw : Map<dynamic, dynamic>.from(raw));
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat detail: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl() async {
    if (_item != null && _item!.url.isNotEmpty) {
      final uri = Uri.parse(_item!.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka link berita'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB),
      appBar: AppBar(
        title: const Text('Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder(
            valueListenable: Hive.box('favorites').listenable(),
            builder: (context, box, child) {
              final isFav = box.containsKey(widget.id.toString());
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
                tooltip: isFav ? 'Hapus Favorite' : 'Tambah Favorite',
                onPressed: () {
                  if (_item == null) return;
                  if (isFav) {
                    box.delete(widget.id.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dihapus dari favorite')),
                    );
                  } else {
                    box.put(widget.id.toString(), _item!.toMap());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ditambahkan ke favorite')),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _item == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Large Image
                          Image.network(
                            _item!.imageUrl,
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 260,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _item!.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _item!.author,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _item!.publishedAt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _item!.summary,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 70), // Spacing for FAB
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Buka Web',
        backgroundColor: const Color(0xFFF3E5F5),
        foregroundColor: const Color(0xFF8E24AA),
        onPressed: _launchUrl,
        child: const Icon(Icons.open_in_new),
      ),
    );
  }
}
