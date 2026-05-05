import 'package:flutter/material.dart';

class UserHistory extends StatefulWidget {
  const UserHistory({super.key});

  @override
  State<UserHistory> createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  String selectedFilter = "ALL";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 🔥 TITLE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "HISTORY",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 FILTER BUTTONS
              Row(
                children: [
                  _filterButton("ALL"),
                  const SizedBox(width: 10),
                  _filterButton("STOCK IN"),
                  const SizedBox(width: 10),
                  _filterButton("STOCK OUT"),
                ],
              ),

              const SizedBox(height: 20),

              // 🔥 LIST
              Expanded(
                child: ListView(
                  children: [
                    // TODAY
                    const Text(
                      "TODAY — APR 20",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _historyCard(isIn: true),
                    const SizedBox(height: 12),
                    _historyCard(isIn: false),

                    const SizedBox(height: 30),

                    // YESTERDAY
                    const Text(
                      "YESTERDAY — APR 19",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _historyCard(isIn: true),
                    const SizedBox(height: 12),
                    _historyCard(isIn: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 FILTER BUTTON
  Widget _filterButton(String text) {
    bool isActive = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 🔥 HISTORY CARD (ICON STYLE)
  Widget _historyCard({required bool isIn}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // LEFT ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sync_alt),
          ),

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Samsung S26 Ultra",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "SKU-HP-201",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // RIGHT ICON (🔥 IN / OUT pakai icon)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIn ? Icons.download : Icons.upload,
            ),
          ),
        ],
      ),
    );
  }
}