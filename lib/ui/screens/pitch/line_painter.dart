import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  double? pitchLength;

  LinePainter({this.pitchLength});

  @override
  void paint(Canvas canvas, Size size) {
    double penaltyBox = size.width / 4;
    var paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4.0;

    var path = Path();

    // Outside of Pitch
    path.lineTo(0.0, pitchLength!);
    path.lineTo(size.width, pitchLength!);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);

    // Penalty Box
    path.moveTo(size.width * 0.2, 0.0);
    path.lineTo(size.width * 0.2, pitchLength! * 0.2);
    path.lineTo(size.width * 0.8, pitchLength! * 0.2);
    path.lineTo(size.width * 0.8, 0.0);

    // 6 yard box
    path.moveTo(size.width * 0.375, 0.0);
    path.lineTo(size.width * 0.375, pitchLength! * 0.1);
    path.lineTo(size.width * 0.625, pitchLength! * 0.1);
    path.lineTo(size.width * 0.625, 0.0);

    // Penalty Box Arc
    path.moveTo(size.width * 0.375, pitchLength! * 0.2);
    path.quadraticBezierTo(size.width / 2, pitchLength! / 3.5,
        (penaltyBox * 3) - (penaltyBox / 2), pitchLength! / 5);

    // Top Left Corner
    path.moveTo(size.width * 0.05, 0.0);
    path.arcToPoint(Offset(0.0, pitchLength! * 0.05),
        radius: const Radius.circular(30));

    // Top Right Corner
    path.moveTo(size.width * 0.95, 0.0);
    path.arcToPoint(Offset(size.width, pitchLength! * 0.05),
        radius: const Radius.circular(30), clockwise: false);

    // Centre Circle
    path.moveTo(size.width * 0.3, pitchLength!);
    path.arcToPoint(Offset(size.width * 0.7, pitchLength!),
        radius: const Radius.circular(20));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
