import 'package:flutter/material.dart';

class BackgroundLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1941).withOpacity(0.05)
      ..strokeWidth = 10;

    // Horizontal lines
    // for (double y = 100; y < size.height; y += 120) {
    //   canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    // }

    // Diagonal lines
    for (double x = -size.height; x < size.width; x += 200) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
