import 'package:flutter/material.dart';
// ⚠️ Path ke ApiService disesuaikan dengan struktur folder kamu
import '../data/api/api_service.dart';

class UserHistory extends StatefulWidget {
  final int? userId; // Menerima ID user yang sedang login

  const UserHistory({
    super.key,
    this.userId,
  });

  @override
  State<UserHistory> createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  final ApiService apiService = ApiService();

  String selectedFilter = "ALL";
  List histories = [];
  List filteredHistories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // 🔄 AMBIL DATA RIWAYAT DARI API BERDASARKAN USER ID
  Future<void> loadHistory() async {
    setState(() => isLoading = true);

    try {
      final data = await apiService.getStockHistory(userId: widget.userId);

      if (mounted) {
        setState(() {
          histories = data;
          _filterData(selectedFilter);
        });
      }
    } catch (e) {
      debugPrint("Error saat memuat history: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // 🔍 LOGIKA FILTER (ALL / STOCK IN / STOCK OUT)
  void _filterData(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == "STOCK IN") {
        filteredHistories = histories.where((item) {
          final type = (item['type'] ?? '').toString().toLowerCase();
          return type == 'in' || type == 'stock_in' || item['is_in'] == true;
        }).toList();
      } else if (filter == "STOCK OUT") {
        filteredHistories = histories.where((item) {
          final type = (item['type'] ?? '').toString().toLowerCase();
          return type == 'out' || type == 'stock_out' || item['is_in'] == false;
        }).toList();
      } else {
        filteredHistories = List.from(histories);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 🔥 TITLE
              const Text(
                "HISTORY",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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

              // 🔥 DYNAMIC LIST HISTORY
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.black))
                    : RefreshIndicator(
                        onRefresh: loadHistory,
                        color: Colors.black,
                        child: filteredHistories.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 100),
                                  Center(
                                    child: Text(
                                      "Belum ada riwayat transaksi",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: filteredHistories.length,
                                itemBuilder: (context, index) {
                                  final item = filteredHistories[index];

                                  // Penentuan status IN/OUT
                                  final String rawType =
                                      (item['type'] ?? '').toString().toLowerCase();
                                  final bool isIn = rawType == 'in' ||
                                      rawType == 'stock_in' ||
                                      item['is_in'] == true;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _historyCard(
                                      item: item,
                                      isIn: isIn,
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 FILTER BUTTON WIDGET
  Widget _filterButton(String text) {
    bool isActive = selectedFilter == text;

    return GestureDetector(
      onTap: () => _filterData(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 🔥 HISTORY CARD WIDGET
  Widget _historyCard({required dynamic item, required bool isIn}) {
    // Penanganan relasi ke Item secara aman
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

    // Format tanggal aman dari Null / RangeError
    String rawDate = (item['created_at'] ?? item['date'] ?? '').toString();
    String displayDate = '';
    if (rawDate.isNotEmpty && rawDate.length >= 10) {
      displayDate = rawDate.substring(0, 10);
    }

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
            child: const Icon(Icons.sync_alt, color: Colors.black54), // 👈 Perbaikan warna di sini
          ),

          const SizedBox(width: 12),

          // TEXT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "SKU: $sku ${displayDate.isNotEmpty ? '• $displayDate' : ''}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // QTY & RIGHT ICON (IN / OUT)
          Row(
            children: [
              Text(
                "${isIn ? '+' : '-'}$amount",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIn ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isIn ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIn ? Icons.download : Icons.upload,
                  size: 18,
                  color: isIn ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}