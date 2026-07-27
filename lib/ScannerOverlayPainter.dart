import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final double scanBoxWidth;
  final double scanBoxHeight;
  final double borderRadius;

  ScannerOverlayPainter({
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.55), // Warna latar belakang redup
    this.scanBoxWidth = 260,  // Lebar kotak fokus
    this.scanBoxHeight = 180, // Tinggi kotak fokus (bisa disesuaikan untuk Barcode/QR)
    this.borderRadius = 12,   // Kelengkungan sudut kotak
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = overlayColor;

    // Paint untuk garis pinggir kotak
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Menentukan posisi kotak tepat di tengah layar
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 30), // Agak sedikit ke atas
      width: scanBoxWidth,
      height: scanBoxHeight,
    );

    final scanRRect = RRect.fromRectAndRadius(
      scanRect,
      Radius.circular(borderRadius),
    );

    // Membuat efek "lubang transparan" pada background
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRRect)
      ..fillType = PathFillType.evenOdd;

    // Gambar background dengan lubang di tengah
    canvas.drawPath(path, backgroundPaint);

    // Gambar garis bingkai putih di sekeliling kotak fokus
    canvas.drawRRect(scanRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}