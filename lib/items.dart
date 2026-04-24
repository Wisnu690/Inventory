import 'package:flutter/material.dart';
import 'db.helper.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  final DBHelper dbHelper = DBHelper();
  List items = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await dbHelper.getItems();
    setState(() {
      items = data;
    });
  }

  // ➕ TAMBAH ITEM
  void showAddDialog() {
    TextEditingController name = TextEditingController();
    TextEditingController category = TextEditingController();
    TextEditingController merk = TextEditingController();
    TextEditingController sku = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Item"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(hintText: "Nama Item"),
              ),
              TextField(
                controller: category,
                decoration: const InputDecoration(hintText: "Category"),
              ),
              TextField(
                controller: merk,
                decoration: const InputDecoration(hintText: "Merk"),
              ),
              TextField(
                controller: sku,
                decoration: const InputDecoration(hintText: "SKU"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await dbHelper.insertItem(
                name.text,
                category.text,
                merk.text,
                sku.text,
              );
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // ✅ AppBar
      appBar: AppBar(
        title: const Text("INVENTORY"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.person_outline),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ITEMS",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text("FILTER"),
                    const VerticalDivider(),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "SEARCH ITEMS",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 📋 LIST DATA DARI DB
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                "${item['sku'] ?? ''}   ${item['merk'] ?? ''}   ${item['category'] ?? ''}",
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ➕ BUTTON TAMBAH
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: showAddDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}