import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
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

          // 🔹 TOTAL ITEMS
          _buildCard(
            title: "TOTAL ITEMS",
            value: "1,000",
            onTap: onItemsTap,
          ),
          const SizedBox(height: 15),

          // 🔹 TOTAL STOCK
          _buildCard(
            title: "TOTAL STOCK",
            value: "1,000",
            onTap: onItemsTap,
          ),
          const SizedBox(height: 15),

          // 🔹 LOW STOCK (BISA DIKLIK)
          _buildLowStockCard(onItemsTap),
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
                      onTap: onItemsTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuItem(
                      icon: Icons.category_outlined,
                      label: "CATEGORIES",
                      onTap: onCategoriesTap,
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
                  onTap: onUsersTap,
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

  // 🔹 LOW STOCK CARD
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LOW STOCK",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 10),
            Text("• Samsung S26 Ultra [2]", style: TextStyle(color: Colors.white)),
            Text("• iPhone 17 Pro Max [5]", style: TextStyle(color: Colors.white)),
            Text("• HUAWEI Mate 80 Pro [10]", style: TextStyle(color: Colors.white)),
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