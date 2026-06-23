import 'package:flutter/material.dart';
import '../data/api/api_service.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final ApiService apiService = ApiService();

  List categories = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await apiService.getCategories();

    setState(() {
      categories = data;
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

              Navigator.pop(context);

              loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Kategori berhasil ditambahkan"),
                ),
              );
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

    TextEditingController descController =
        TextEditingController(
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

              Navigator.pop(context);

              await loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Kategori berhasil diperbarui",
                  ),
                ),
              );
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kategori berhasil dihapus"),
      ),
    );
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

              // SEARCH (belum aktif)
              TextField(
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
                child: categories.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada kategori",
                        ),
                      )
                    : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final item = categories[index];

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.circular(10),
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
                                          fontWeight:
                                              FontWeight.bold,
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

                                // EDIT (nanti kita buat)
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
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        deleteCategory(
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