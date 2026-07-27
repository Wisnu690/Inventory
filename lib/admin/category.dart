import 'package:flutter/material.dart';
import '../data/api/api_service.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  List categories = [];
  List filteredCategories = [];

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

  Future<void> loadData() async {
    final data = await apiService.getCategories();

    setState(() {
      categories = data ?? [];
      filterSearch(searchController.text);
    });
  }

  // LOGIKA SEARCH / PENCARIAN
  void filterSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredCategories = categories;
      } else {
        filteredCategories = categories.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          final desc = (item['description'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              desc.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // TAMBAH KATEGORI
  void showAddDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Kategori"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Nama kategori",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: "Deskripsi",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await apiService.addCategory(
                nameController.text,
                descController.text,
              );

              if (mounted) Navigator.pop(context);

              loadData();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Kategori berhasil ditambahkan"),
                  ),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // EDIT KATEGORI
  void showEditDialog(Map category) {
    TextEditingController nameController =
        TextEditingController(text: category['name']);

    TextEditingController descController = TextEditingController(
      text: category['description'] ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Kategori"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Kategori",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await apiService.updateCategory(
                category['id'],
                nameController.text,
                descController.text,
              );

              if (mounted) Navigator.pop(context);

              await loadData();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Kategori berhasil diperbarui",
                    ),
                  ),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // HAPUS KATEGORI
  void deleteCategory(int id) async {
    await apiService.deleteCategory(id);

    loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kategori berhasil dihapus"),
        ),
      );
    }
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

              // BUTTON TAMBAH
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  onPressed: showAddDialog,
                  child: const Text(
                    "+ ADD NEW CATEGORY",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // SEARCH (SUDAH AKTIF)
              TextField(
                controller: searchController,
                onChanged: filterSearch,
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

              Expanded(
                child: filteredCategories.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? "Belum ada kategori"
                              : "Kategori tidak ditemukan",
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

                                // EDIT
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showEditDialog(item);
                                  },
                                ),

                                // DELETE
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => deleteCategory(
                                      item['id'],
                                    ),
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