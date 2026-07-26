import 'package:flutter/material.dart';
// ⚠️ Pastikan path ke ApiService ini sesuai dengan struktur folder project kamu
import '../data/api/api_service.dart';

class UserItems extends StatefulWidget {
  const UserItems({super.key});

  @override
  State<UserItems> createState() => _UserItemsState();
}

class _UserItemsState extends State<UserItems> {
  final ApiService apiService = ApiService();

  List items = [];
  List filteredItems = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // 🔄 LOAD DATA DARI API
  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final itemsData = await apiService.getItems();

      if (mounted) {
        setState(() {
          items = itemsData;
          filteredItems = itemsData;
        });
      }
    } catch (e) {
      debugPrint("Error saat load data: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // 🔍 PENCARIAN ITEM (Filter Nama, SKU, Brand, atau Barcode)
  void searchItem(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        filteredItems = items;
      });
      return;
    }

    final query = keyword.toLowerCase();
    final result = items.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final sku = (item['sku'] ?? '').toString().toLowerCase();
      final brand = (item['brand'] ?? '').toString().toLowerCase();
      final barcode = (item['barcode'] ?? '').toString().toLowerCase();

      return name.contains(query) ||
          sku.contains(query) ||
          brand.contains(query) ||
          barcode.contains(query);
    }).toList();

    setState(() {
      filteredItems = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 📌 TITLE
              const Text(
                "ITEMS",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // 🔍 SEARCH BAR
              TextField(
                controller: searchController,
                onChanged: searchItem,
                decoration: InputDecoration(
                  hintText: "SEARCH ITEMS...",
                  filled: true,
                  fillColor: Colors.grey[300],
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchItem('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 📦 LIST ITEMS (READ ONLY & CAN REFRESH)
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.black))
                    : RefreshIndicator(
                        onRefresh: loadData,
                        color: Colors.black,
                        child: filteredItems.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 100),
                                  Center(
                                    child: Text(
                                      "Tidak ada item ditemukan",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  final int stock = item['stock'] ?? 0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'] ?? 'Tanpa Nama',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "SKU: ${item['sku'] ?? '-'} | Brand: ${item['brand'] ?? '-'}",
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                "Stok: $stock | Barcode: ${item['barcode'] ?? '-'}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 🏷️ INDIKATOR STATUS STOK (Tersedia / Habis)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: stock > 0
                                                ? Colors.green[100]
                                                : Colors.red[100],
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            stock > 0 ? "Tersedia" : "Habis",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: stock > 0
                                                  ? Colors.green[800]
                                                  : Colors.red[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}