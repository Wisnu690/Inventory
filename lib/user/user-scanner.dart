import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// ⚠️ Pastikan path ke ApiService ini sesuai dengan struktur folder project kamu
import 'package:inventory/data/api/api_service.dart';

class UserScanner extends StatefulWidget {
  const UserScanner({super.key});

  @override
  State<UserScanner> createState() => _UserScannerState();
}

class _UserScannerState extends State<UserScanner> {
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
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 28),
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
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final bool isIn = transactionType == 'IN';

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
                  // Header Bar Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Transaksi Barang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(modalContext),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // CARD DATA BARANG HASIL SCAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "SKU: $itemCode  •  Stok Saat Ini: $currentStock",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TOGGLE STOCK IN / STOCK OUT
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
                              color: isIn ? const Color(0xFF4CAF50) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "STOCK IN (+)",
                                style: TextStyle(
                                  color: isIn ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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
                              color: !isIn ? const Color(0xFFE53935) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "STOCK OUT (-)",
                                style: TextStyle(
                                  color: !isIn ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Input Jumlah (Quantity)
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Jumlah (Quantity)",
                      prefixIcon: const Icon(Icons.tag, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input Catatan (Opsional)
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: "Catatan (Opsional)",
                      prefixIcon: const Icon(Icons.edit_note, size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isIn
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              int qty = int.tryParse(qtyController.text) ?? 0;
                              if (qty <= 0) {
                                ScaffoldMessenger.of(modalContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('Jumlah harus lebih dari 0'),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              // 🔥 PANGGIL API SIMPAN STOK
                              Map<String, dynamic> response;
                              if (transactionType == 'IN') {
                                response = await _apiService.stockIn(
                                  itemId: itemId,
                                  userId: 1,
                                  quantity: qty,
                                  notes: notesController.text.isEmpty
                                      ? null
                                      : notesController.text,
                                );
                              } else {
                                response = await _apiService.stockOut(
                                  itemId: itemId,
                                  userId: 1,
                                  quantity: qty,
                                  notes: notesController.text.isEmpty
                                      ? null
                                      : notesController.text,
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
                                            : (response['message'] ??
                                                'Gagal menyimpan transaksi'),
                                      ),
                                      backgroundColor: isSuccess
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFE53935),
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
                                fontSize: 14,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // 🛑 HEADER LOKAL SUDAH DIHAPUS AGAR TIDAK DOUBLE DENGAN MAIN PAGE

          // SCAN CARD UTAMA
          GestureDetector(
            onTap: () => _startScan('IN'),
            child: Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 54),
                  SizedBox(height: 12),
                  Text(
                    "SCAN BARCODE / QR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // STOCK IN & STOCK OUT BUTTONS
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
                    color: const Color(0xFFE8F5E9), // 🟢 Ubah ke Hijau Muda Soft (Green 50)
                    iconColor: const Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  onTap: () => _startScan('OUT'),
                  child: _buildMenuCard(
                    icon: Icons.upload,
                    title: "STOCK OUT",
                    subtitle: "DISPATCH ITEMS",
                    color: const Color(0xFFFDE8E8), // 🔴 Merah Muda Soft
                    iconColor: const Color(0xFFE53935),
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
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 125,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: iconColor),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 📸 KAMERA SCANNER DENGAN OVERLAY & POSISI TEKS PRESISI
// -----------------------------------------------------------------
class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  // 📐 Pengaturan Ukuran & Offset Kotak Scanner
  final double scanBoxWidth = 280;
  final double scanBoxHeight = 180;
  final double verticalOffset = -60; // Posisi kotak sedikit di atas tengah layar

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // 🎯 HITUNG POSISI BATAS BAWAH KOTAK SECARA DINAMIS
    final double boxBottomPosition =
        (screenHeight / 2) + verticalOffset + (scanBoxHeight / 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Arahkan Kamera ke Barcode/QR",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
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
      body: Stack(
        children: [
          // 1. Kamera Scanner Utama
          MobileScanner(
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

          // 2. Overlay Bagian Gelap & Bingkai Kotak
          CustomPaint(
            size: Size.infinite,
            painter: ScannerOverlayPainter(
              scanBoxWidth: scanBoxWidth,
              scanBoxHeight: scanBoxHeight,
              verticalOffset: verticalOffset,
            ),
          ),

          // 3. Teks Petunjuk (Selalu Berada 20px Di Bawah Kotak)
          Positioned(
            top: boxBottomPosition + 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.qr_code_scanner, color: Colors.white70, size: 28),
                SizedBox(height: 8),
                Text(
                  "Posisikan Barcode / QR di dalam kotak",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 🎨 PAINTER UNTUK MEMBUAT EFEK BAGIAN GELAP DAN LUBANG FOKUS
// -----------------------------------------------------------------
class ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final double scanBoxWidth;
  final double scanBoxHeight;
  final double borderRadius;
  final double verticalOffset;

  ScannerOverlayPainter({
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.6),
    this.scanBoxWidth = 280,
    this.scanBoxHeight = 180,
    this.borderRadius = 16,
    this.verticalOffset = -60,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = overlayColor;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, (size.height / 2) + verticalOffset),
      width: scanBoxWidth,
      height: scanBoxHeight,
    );

    final scanRRect = RRect.fromRectAndRadius(
      scanRect,
      Radius.circular(borderRadius),
    );

    // Membuat "lubang" bening pada background gelap
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);
    canvas.drawRRect(scanRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}