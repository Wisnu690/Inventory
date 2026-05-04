import 'package:flutter/material.dart';

// 🔹 IMPORT HALAMAN TUJUAN
import 'user-items.dart';
import 'user-category.dart';
import 'user-history.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 10),

          // 🔥 TOTAL ITEMS CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "TOTAL ITEMS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "1,000",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 MENU ITEMS & CATEGORIES
          Row(
            children: [
              Expanded(
                child: _menuCard(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  title: "ITEMS",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserItems(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _menuCard(
                  context: context,
                  icon: Icons.category_outlined,
                  title: "CATEGORIES",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserCategory(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔥 HISTORY CARD
          _menuCard(
            context: context,
            icon: Icons.history,
            title: "HISTORY",
            isFull: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserHistory(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // 🔥 HEADER HISTORY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "HISTORY",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),

          const SizedBox(height: 10),

          // 🔥 EMPTY STATE
          Container(
            height: 200,
            alignment: Alignment.center,
            child: const Text(
              "No data",
              style: TextStyle(color: Colors.black38),
            ),
          )
        ],
      ),
    );
  }

  // 🔥 COMPONENT MENU CARD (CLICKABLE)
  Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    bool isFull = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isFull ? 80 : 100,
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: Colors.black87),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}