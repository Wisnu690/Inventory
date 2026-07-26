import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// ⚠️ Pastikan path ke ApiService ini benar di project kamu
import 'package:inventory/data/api/api_service.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final ApiService _apiService = ApiService();

  // 1. Membuka Halaman Kamera & Cek Ke Database
  Future<void> _startScan(String defaultType) async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScannerScreen(),
      ),
    );

    if (scannedCode != null && scannedCode.isNotEmpty && mounted) {
      // ⏳ TAMPILKAN LOADING DIALOG SAAT PROSES PENGECEKAN
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );

      // 🔍 CEK KE DATABASE VIA API SERVICE
      final itemData = await _apiService.getItemByCode(scannedCode);

      // TUTUP LOADING DIALOG
      if (mounted) Navigator.pop(context);

      // 🚨 CEK HASIL DATABASE
      if (itemData != null && itemData['id'] != null) {
        // ✅ BARANG DITEMUKAN -> BUKA BOTTOM SHEET TRANSAKSI
        if (mounted) {
          _showTransactionBottomSheet(
            itemData: itemData,
            initialType: defaultType,
          );
        }
      } else {
        // ❌ BARANG TIDAK DITEMUKAN -> TAMPILKAN ALERT DIALOG
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 10),
                  Text("Barang Tidak Ada"),
                ],
              ),
              content: Text(
                "Barang dengan Kode/SKU '$scannedCode' belum terdaftar di database.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  // 2. Bottom Sheet Modal Transaksi (Stock In / Stock Out)
  void _showTransactionBottomSheet({
    required Map<String, dynamic> itemData,
    required String initialType,
  }) {
    String transactionType = initialType;
    final TextEditingController qtyController = TextEditingController(text: '1');
    final TextEditingController notesController = TextEditingController();
    bool isSubmitting = false;

    // Ambil detail data barang
    final int itemId = itemData['id'];
    final String itemName = itemData['name'] ?? 'Barang Tanpa Nama';
    final String itemCode = itemData['barcode'] ?? itemData['sku'] ?? '-';
    final int currentStock = itemData['stock'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Transaksi Barang",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalContext),
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // CARD DATA BARANG HASIL SCAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: Colors.black54),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "SKU: $itemCode  •  Stok Saat Ini: $currentStock",
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opsi Pilihan (STOCK IN / STOCK OUT)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => transactionType = 'IN');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: transactionType == 'IN' ? Colors.green : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "STOCK IN (+)",
                                style: TextStyle(
                                  color: transactionType == 'IN' ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => transactionType = 'OUT');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: transactionType == 'OUT' ? Colors.red : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "STOCK OUT (-)",
                                style: TextStyle(
                                  color: transactionType == 'OUT' ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Input Jumlah (Quantity)
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Jumlah (Quantity)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input Catatan (Opsional)
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: "Catatan (Opsional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: transactionType == 'IN' ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              int qty = int.tryParse(qtyController.text) ?? 0;
                              if (qty <= 0) {
                                ScaffoldMessenger.of(modalContext).showSnackBar(
                                  const SnackBar(content: Text('Jumlah harus lebih dari 0')),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              // 🔥 PANGGIL API SIMPAN STOK (STOCK IN / STOCK OUT)
                              Map<String, dynamic> response;
                              if (transactionType == 'IN') {
                                response = await _apiService.stockIn(
                                  itemId: itemId,
                                  userId: 1, // Ganti dengan ID User aktif jika ada
                                  quantity: qty,
                                  notes: notesController.text.isEmpty ? null : notesController.text,
                                );
                              } else {
                                response = await _apiService.stockOut(
                                  itemId: itemId,
                                  userId: 1, // Ganti dengan ID User aktif jika ada
                                  quantity: qty,
                                  notes: notesController.text.isEmpty ? null : notesController.text,
                                );
                              }

                              setModalState(() => isSubmitting = false);

                              bool isSuccess = response['success'] != false;

                              if (modalContext.mounted) {
                                Navigator.pop(modalContext);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSuccess
                                            ? 'Berhasil ${transactionType == 'IN' ? 'Stock In' : 'Stock Out'} $itemName!'
                                            : (response['message'] ?? 'Gagal menyimpan transaksi'),
                                      ),
                                      backgroundColor: isSuccess ? Colors.green : Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "SIMPAN ${transactionType == 'IN' ? 'STOCK IN' : 'STOCK OUT'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // SCAN CARD UTAMA
          GestureDetector(
            onTap: () => _startScan('IN'),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "SCAN BARCODE / QR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // STOCK IN & STOCK OUT BUTTONS
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _startScan('IN'),
                  child: _buildMenuCard(
                    icon: Icons.download,
                    title: "STOCK IN",
                    subtitle: "RECEIVE\nSHIPMENTS",
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _startScan('OUT'),
                  child: _buildMenuCard(
                    icon: Icons.upload,
                    title: "STOCK OUT",
                    subtitle: "DISPATCH ITEMS",
                    color: Colors.red.shade50,
                    iconColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = const Color(0xFFEEEEEE),
    Color iconColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 130,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 📸 KAMERA SCANNER DENGAN CONTROLLER MANAGEMENT
// -----------------------------------------------------------------
class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arahkan Kamera ke Barcode/QR"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_isScanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
              setState(() {
                _isScanned = true;
              });
              Navigator.pop(context, barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}