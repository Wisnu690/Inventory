import 'package:flutter/material.dart';
import 'package:inventory/db.helper.dart';

class UserCategory extends StatefulWidget {
  const UserCategory({super.key});

  @override
  State<UserCategory> createState() => _UserCategoryState();
}

class _UserCategoryState extends State<UserCategory> {
  final DBHelper dbHelper = DBHelper();
  List categories = [];
  List filteredCategories = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await dbHelper.getCategories(); // 🔥 pastikan ini ada di DBHelper
    setState(() {
      categories = data;
      filteredCategories = data;
    });
  }

  // 🔍 SEARCH
  void searchCategory(String keyword) {
    final result = categories.where((item) {
      final name = item['name'].toString().toLowerCase();
      return name.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredCategories = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "CATEGORIES",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔍 SEARCH BAR
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
                        onChanged: searchCategory,
                        decoration: const InputDecoration(
                          hintText: "Search categories...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 📦 LIST CATEGORY
            Expanded(
              child: filteredCategories.isEmpty
                  ? const Center(
                      child: Text(
                        "No categories found",
                        style: TextStyle(color: Colors.black38),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        var category = filteredCategories[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.category),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  category['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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