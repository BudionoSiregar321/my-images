import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint =
        Paint()
          ..color = Color(0xFF2196F3).withOpacity(0.1)
          ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.4,
      size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.15,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    paint.color = Color(0xFF2196F3).withOpacity(0.05);
    var path2 = Path();
    path2.moveTo(size.width, 0);
    path2.lineTo(size.width, size.height * 0.4);
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.35,
    );
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.2,
      size.width * 0.2,
      size.height * 0.25,
    );
    path2.lineTo(0, 0);
    path2.close();

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
