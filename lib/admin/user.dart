import 'package:flutter/material.dart';
import '../data/api/api_service.dart'; // 💡 Sesuaikan path ApiService kamu

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final ApiService apiService = ApiService();
  List users = [];
  List filteredUsers = [];
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 🔄 Fetch Data dari API MySQL
  void loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await apiService.getUsers();
      
      // 🔹 Filter lagi di Flutter untuk memastikan hanya role 'user' yang masuk
      final onlyUsers = data.where((item) {
        final role = (item['role'] ?? '').toString().toLowerCase();
        return role == 'user';
      }).toList();

      setState(() {
        users = onlyUsers;
        filteredUsers = onlyUsers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data user: $e")),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void searchUser(String keyword) {
    final results = users.where((user) {
      final name = (user['name'] ?? '').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      final role = (user['role'] ?? '').toLowerCase();
      final input = keyword.toLowerCase();

      return name.contains(input) || email.contains(input) || role.contains(input);
    }).toList();

    setState(() {
      filteredUsers = results;
    });
  }

  // ➕ TAMBAH USER BARU VIA API
  // ➕ TAMBAH USER BARU (Otomatis Role = 'user')
  // ➕ TAMBAH USER BARU WITH VALIDATION
  void showAddDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Tambah Akun User"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password (Min. 8 Karakter)",
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // 1. Validasi Kolom Kosong
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Semua kolom wajib diisi!")),
                    );
                    return;
                  }

                  // 🛑 2. Validasi Password Minimal 8 Karakter
                  if (passwordController.text.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password minimal harus 8 karakter!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  bool success = await apiService.addUser(
                    nameController.text,
                    emailController.text,
                    "user",
                    passwordController.text,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      loadData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gagal menambah user")),
                      );
                    }
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✏️ EDIT USER & PASSWORD (VIA API)
  // ✏️ EDIT USER WITH VALIDATION
  void showEditDialog(Map user) {
    TextEditingController nameController = TextEditingController(text: user['name']);
    TextEditingController emailController = TextEditingController(text: user['email']);
    TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Edit User (${user['name']})"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password Baru (Min. 8 Karakter)",
                      hintText: "Kosongkan jika tidak diubah",
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // 🛑 Validasi jika password diisi, panjangnya wajib minimal 8 karakter
                  if (passwordController.text.isNotEmpty && passwordController.text.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password baru minimal harus 8 karakter!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  bool success = await apiService.updateUser(
                    user['id'],
                    nameController.text,
                    emailController.text,
                    "user",
                    passwordController.text.isNotEmpty ? passwordController.text : null,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      loadData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gagal mengupdate user")),
                      );
                    }
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🗑️ DIALOG KONFIRMASI HAPUS
  void confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus User"),
        content: Text("Apakah Anda yakin ingin menghapus user '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool success = await apiService.deleteUser(id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal menghapus user")),
                  );
                }
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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

              // 🔍 Search bar
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

              // 📋 List User
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                        ? const Center(child: Text("Data user tidak ditemukan"))
                        : ListView.builder(
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
                                    // 👤 Nama, Email & Role Badge
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
                                          Text(
                                            item['email'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: item['role'] == 'admin'
                                                  ? Colors.black
                                                  : Colors.blueGrey,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              (item['role'] ?? 'user').toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ✏️ Edit Button
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => showEditDialog(item),
                                      ),
                                    ),

                                    // 🗑 Delete Button
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
                                        onPressed: () => confirmDelete(
                                          item['id'],
                                          item['name'],
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
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}