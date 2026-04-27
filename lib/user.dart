import 'package:flutter/material.dart';
import 'db.helper.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final DBHelper dbHelper = DBHelper();
  List users = [];
  List filteredUsers = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await dbHelper.getUsers();
    setState(() {
      users = data;
      filteredUsers = data; // penting!
    });
  }

  void searchUser(String keyword) {
    final results = users.where((user) {
      final name = (user['name'] ?? '').toLowerCase();
      final role = (user['role'] ?? '').toLowerCase();
      final input = keyword.toLowerCase();

      return name.contains(input) || role.contains(input);
    }).toList();

    setState(() {
      filteredUsers = results;
    });
  }
  
  // ➕ Add User
  void showAddDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Nama"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(hintText: "Role"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await dbHelper.insertUser(
                nameController.text,
                roleController.text,
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

  void deleteUser(int id) async {
    await dbHelper.deleteUser(id);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // 🔝 AppBar (konsisten Items)
      appBar: AppBar(
        title: const Text("INVENTORY"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "USERS",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // 🔍 Search bar (match Items)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: searchUser,
                        decoration: const InputDecoration(
                          hintText: "SEARCH USERS",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 📋 List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var item = filteredUsers[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // 👤 Name + Role
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  item['role'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ✏️ Edit
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
                            ),
                          ),

                          // 🗑 Delete
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteUser(item['id']),
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

      // ➕ FAB kecil (match Items)
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}