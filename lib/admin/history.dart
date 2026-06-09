import 'package:flutter/material.dart';
import '../data/api/api_service.dart'; // 👈 Pastikan path impor ini benar sesuai letak ApiService-mu

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final ApiService _apiService = ApiService();
  
  // State untuk menyimpan filter aktif: 'ALL', 'IN', atau 'OUT'
  String _activeFilter = "ALL"; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              _filterButton("ALL", _activeFilter == "ALL"),
              const SizedBox(width: 10),
              _filterButton("STOCK IN", _activeFilter == "IN"),
              const SizedBox(width: 10),
              _filterButton("STOCK OUT", _activeFilter == "OUT"),
            ],
          ),

          const SizedBox(height: 20),

          // LIST DATA MENGGUNAKAN FUTUREBUILDER
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _apiService.getStockHistory(), // 👈 Ambil data dari API Laravel
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Gagal memuat data: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                var rawData = snapshot.data ?? [];

                // Filter data di sisi client berdasarkan tombol yang aktif
                if (_activeFilter != "ALL") {
                  rawData = rawData.where((log) => log['type'].toString().toUpperCase() == _activeFilter).toList();
                }

                if (rawData.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada riwayat transaksi."),
                  );
                }

                return ListView.builder(
                  itemCount: rawData.length,
                  itemBuilder: (context, index) {
                    final log = rawData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _historyCard(log),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tombol Filter dengan fungsionalitas Klik (InkWell)
  Widget _filterButton(String text, bool isActive) {
    return InkWell(
      onTap: () {
        setState(() {
          // Mengubah status filter saat diklik
          if (text == "ALL") _activeFilter = "ALL";
          if (text == "STOCK IN") _activeFilter = "IN";
          if (text == "STOCK OUT") _activeFilter = "OUT";
        });
      },
      borderRadius: BorderRadius.circular(10),
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

  // Card UI Kerenmu yang sekarang sudah dinamis membaca data JSON
  Widget _historyCard(Map<String, dynamic> log) {
    final type = log['type']; // 'in' atau 'out'
    final qty = log['quantity'];
    final notes = log['notes'] ?? 'Tanpa catatan';
    
    // Ambil data relasi item dari Laravel
    final itemName = log['item'] != null ? log['item']['name'] : 'Barang Tidak Diketahui';
    final itemSku = log['item'] != null ? 'QTY: $qty' : 'Unknown';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // LEFT ICON: Warna ikon dinamis berdasarkan tipe stok
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: type == 'in' ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              type == 'in' ? Icons.download : Icons.upload,
              color: type == 'in' ? Colors.green[700] : Colors.red[700],
            ),
          ),

          const SizedBox(width: 12),

          // TEXT DATA BARANG
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
                  "Note: $notes",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // RIGHT BADGE QUANTITY
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: type == 'in' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              type == 'in' ? "+$qty" : "-$qty",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}