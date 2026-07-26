import 'package:flutter/material.dart';

// ⚠️ Pastikan path ApiService sudah sesuai dengan struktur folder kamu
import '../data/api/api_service.dart';

// 🔹 IMPORT HALAMAN TUJUAN USER
import 'user-items.dart';
import 'user-category.dart';
import 'user-history.dart';

class UserDashboard extends StatefulWidget {
  final int? userId; // Untuk memfilter history berdasarkan user yang sedang login

  const UserDashboard({
    super.key,
    this.userId,
  });

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final ApiService apiService = ApiService();

  int totalItems = 0;
  int totalStock = 0;
  List<Map<String, dynamic>> lowStockItems = [];
  List recentHistory = [];
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
      // 1. Ambil Data Items dari API
      final items = await apiService.getItems();

      int itemsCount = items.length;
      int stockSum = 0;
      List<Map<String, dynamic>> lowList = [];

      for (var item in items) {
        int stock = int.tryParse(item['stock']?.toString() ?? '0') ?? 0;
        stockSum += stock;

        // ⚠️ Kriteria stok menipis (stok <= 5)
        if (stock <= 5) {
          lowList.add({
            'name': item['name'] ?? 'Tanpa Nama',
            'stock': stock,
          });
        }
      }

      // 2. Ambil Data Stock History
      List histories = [];
      try {
        histories = await apiService.getStockHistory(userId: widget.userId);
      } catch (e) {
        debugPrint("Error fetching history: $e");
      }

      if (mounted) {
        setState(() {
          totalItems = itemsCount;
          totalStock = stockSum;
          lowStockItems = lowList;
          recentHistory = histories.take(3).toList();
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
    return RefreshIndicator(
      onRefresh: loadDashboardData,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 TOTAL ITEMS (DYNAMIS & REALTIME)
            _buildCard(
              title: "TOTAL ITEMS",
              value: isLoading ? "..." : "$totalItems",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserItems()),
                ).then((_) => loadDashboardData());
              },
            ),
            const SizedBox(height: 15),

            // 🔹 TOTAL STOCK (DYNAMIS & REALTIME)
            _buildCard(
              title: "TOTAL STOCK",
              value: isLoading ? "..." : "$totalStock",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserItems()),
                ).then((_) => loadDashboardData());
              },
            ),
            const SizedBox(height: 15),

            // 🔹 LOW STOCK (DYNAMIS & BISA DIKLIK)
            _buildLowStockCard(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserItems()),
              ).then((_) => loadDashboardData());
            }),
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

            // 🔹 MENU ITEMS & CATEGORIES
            Row(
              children: [
                Expanded(
                  child: _buildMenuItem(
                    icon: Icons.inventory_2_outlined,
                    label: "ITEMS",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserItems()),
                      ).then((_) => loadDashboardData());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuItem(
                    icon: Icons.category_outlined,
                    label: "CATEGORIES",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserCategory()),
                      ).then((_) => loadDashboardData());
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 MENU HISTORY
            SizedBox(
              width: double.infinity,
              child: _buildMenuItem(
                icon: Icons.history,
                label: "HISTORY",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserHistory(userId: widget.userId),
                    ),
                  ).then((_) => loadDashboardData());
                },
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 HEADER HISTORY PREVIEW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "RECENT HISTORY",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserHistory(userId: widget.userId),
                      ),
                    ).then((_) => loadDashboardData());
                  },
                  child: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 RECENT HISTORY LIST
            if (isLoading)
              const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              )
            else if (recentHistory.isEmpty)
              Container(
                height: 100,
                alignment: Alignment.center,
                child: const Text(
                  "Belum ada riwayat transaksi",
                  style: TextStyle(color: Colors.black38),
                ),
              )
            else
              Column(
                children: recentHistory.map((item) {
                  final String rawType =
                      (item['type'] ?? '').toString().toLowerCase();
                  final bool isIn = rawType == 'in' ||
                      rawType == 'stock_in' ||
                      item['is_in'] == true;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildMiniHistoryCard(item: item, isIn: isIn),
                  );
                }).toList(),
              ),
          ],
        ),
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
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 MINI HISTORY CARD
  Widget _buildMiniHistoryCard({required dynamic item, required bool isIn}) {
    final dynamic rawItemData = item is Map ? item['item'] : null;
    final Map itemData = rawItemData is Map ? rawItemData : {};

    final String itemName = (itemData['name'] ??
            item['item_name'] ??
            item['name'] ??
            'Item Tanpa Nama')
        .toString();

    final String sku = (itemData['sku'] ?? item['sku'] ?? '-').toString();

    final int amount = int.tryParse(
            (item['quantity'] ?? item['amount'] ?? item['qty'] ?? 0)
                .toString()) ??
        0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isIn ? Icons.download : Icons.upload,
            color: isIn ? Colors.green[700] : Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "SKU: $sku",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isIn ? '+' : '-'}$amount",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isIn ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}