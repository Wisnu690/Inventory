import 'package:flutter/material.dart';
import 'package:inventory/db.helper.dart';

class UserItems extends StatefulWidget {
  const UserItems({super.key});

  @override
  State<UserItems> createState() => _UserItemsState();
}

class _UserItemsState extends State<UserItems> {
  final DBHelper dbHelper = DBHelper();
  List items = [];
  List filteredItems = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await dbHelper.getItems();
    setState(() {
      items = data;
      filteredItems = data;
    });
  }

  // 🔍 SEARCH
  void searchItem(String keyword) {
    final result = items.where((item) {
      final name = item['name'].toString().toLowerCase();
      return name.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredItems = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // ✅ FIX UTAMA DI SINI
      backgroundColor: const Color(0xFFF5F5F5),
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

            // 🔍 SEARCH BAR (SUDAH AMAN)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: searchItem,
                        decoration: const InputDecoration(
                          hintText: "Search items...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 📦 LIST DATA
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var item = filteredItems[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
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
                                style: const TextStyle(fontSize: 12),
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
    );
  }
}