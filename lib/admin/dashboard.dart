import 'package:flutter/material.dart';
import '../data/api/api_service.dart'; // 💡 Pastikan path ApiService sudah sesuai

class Dashboard extends StatefulWidget {
  final VoidCallback onItemsTap;
  final VoidCallback onCategoriesTap;
  final VoidCallback onUsersTap;

  const Dashboard({
    super.key,
    required this.onItemsTap,
    required this.onCategoriesTap,
    required this.onUsersTap,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ApiService apiService = ApiService();

  int totalItems = 0;
  int totalStock = 0;
  List<Map<String, dynamic>> lowStockItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // 🔄 FETCH DATA API & HITUNG DATA SECARA REALTIME
  Future<void> loadDashboardData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final items = await apiService.getItems();

      int itemsCount = items.length;
      int stockSum = 0;
      List<Map<String, dynamic>> lowList = [];

      for (var item in items) {
        int stock = int.tryParse(item['stock']?.toString() ?? '0') ?? 0;
        stockSum += stock;

        // ⚠️ Kriteria stok menipis (misal: stok <= 5)
        if (stock <= 5) {
          lowList.add({
            'name': item['name'] ?? 'Tanpa Nama',
            'stock': stock,
          });
        }
      }

      if (mounted) {
        setState(() {
          totalItems = itemsCount;
          totalStock = stockSum;
          lowStockItems = lowList;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 TOTAL ITEMS (DYNAMIS)
          _buildCard(
            title: "TOTAL ITEMS",
            value: isLoading ? "..." : "$totalItems",
            onTap: widget.onItemsTap,
          ),
          const SizedBox(height: 15),

          // 🔹 TOTAL STOCK (DYNAMIS)
          _buildCard(
            title: "TOTAL STOCK",
            value: isLoading ? "..." : "$totalStock",
            onTap: widget.onItemsTap,
          ),
          const SizedBox(height: 15),

          // 🔹 LOW STOCK (DYNAMIS & BISA DIKLIK)
          _buildLowStockCard(widget.onItemsTap),
          const SizedBox(height: 25),

          // 🔹 TITLE MENU
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("Menu"),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),

          // 🔹 MENU
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMenuItem(
                      icon: Icons.inventory_2_outlined,
                      label: "ITEMS",
                      onTap: widget.onItemsTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuItem(
                      icon: Icons.category_outlined,
                      label: "CATEGORIES",
                      onTap: widget.onCategoriesTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildMenuItem(
                  icon: Icons.group_outlined,
                  label: "USERS",
                  onTap: widget.onUsersTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 CARD (TOTAL ITEMS & TOTAL STOCK)
  Widget _buildCard({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.open_in_new, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  // 🔹 LOW STOCK CARD (LIST DYNAMIC)
  Widget _buildLowStockCard(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "LOW STOCK",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Tampilkan list barang yang stoknya <= 5
            if (!isLoading && lowStockItems.isEmpty)
              const Text(
                "Semua stok aman 👍",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),

            if (!isLoading && lowStockItems.isNotEmpty)
              ...lowStockItems.take(5).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "• ${item['name']} [${item['stock']}]",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // 🔹 MENU ITEM
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}