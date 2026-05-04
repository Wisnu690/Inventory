import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 20),

          // TITLE
          const Text(
            "History",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // FILTER BUTTONS
          Row(
            children: [
              _filterButton("ALL", true),
              const SizedBox(width: 10),
              _filterButton("STOCK IN", false),
              const SizedBox(width: 10),
              _filterButton("STOCK OUT", false),
            ],
          ),

          const SizedBox(height: 30),

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

          _historyCard(),
          const SizedBox(height: 12),
          _historyCard(),

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

          _historyCard(),
          const SizedBox(height: 12),
          _historyCard(),
        ],
      ),
    );
  }

  Widget _filterButton(String text, bool isActive) {
    return Container(
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
    );
  }

  Widget _historyCard() {
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

          // RIGHT ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
} 