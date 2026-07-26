import 'package:flutter/material.dart';
import '../data/api/api_service.dart';

class UserCategory extends StatefulWidget {
  const UserCategory({super.key});

  @override
  State<UserCategory> createState() => _UserCategoryState();
}

class _UserCategoryState extends State<UserCategory> {
  final ApiService apiService = ApiService();

  List categories = [];
  List filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // AMBIL DATA DARI API
  Future<void> loadData() async {
    final data = await apiService.getCategories();

    if (mounted) {
      setState(() {
        categories = data;
        filteredCategories = data;
      });
    }
  }

  // FUNGSI SEARCH
  void searchCategory(String keyword) {
    final result = categories.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final desc = (item['description'] ?? '').toString().toLowerCase();
      return name.contains(keyword.toLowerCase()) ||
          desc.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredCategories = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Category"),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              const Text(
                "CATEGORY",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // SEARCH BAR (SAMA PERSIS DENGAN ADMIN)
              TextField(
                controller: _searchController,
                onChanged: searchCategory,
                decoration: InputDecoration(
                  hintText: "SEARCH CATEGORY",
                  filled: true,
                  fillColor: Colors.grey[300],
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // LIST CATEGORY (TANPA TOMBOL EDIT/DELETE/ADD)
              Expanded(
                child: filteredCategories.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada kategori",
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final item = filteredCategories[index];

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
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
                                        item['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        item['description'] ?? '',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}