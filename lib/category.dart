import 'package:flutter/material.dart';
import 'db.helper.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final DBHelper dbHelper = DBHelper();
  List categories = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await dbHelper.getCategories();
    setState(() {
      categories = data;
    });
  }

  // ➕ Tambah kategori
  void showAddDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Kategori"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nama kategori"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await dbHelper.insertCategory(controller.text);
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ❌ Delete
  void deleteCategory(int id) async {
    await dbHelper.deleteCategory(id);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // ✅ AppBar sama seperti Items
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // ➕ Button tambah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: showAddDialog,
                  child: const Text(
                    "+ ADD NEW CATEGORY",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

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

              // 📋 DATA REAL DARI DB
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    var item = categories[index];

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
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // ✏️ Edit
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
                          ),

                          // 🗑 Delete
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deleteCategory(item['id']),
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