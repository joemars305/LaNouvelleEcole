import 'package:flutter/material.dart';
import 'dart:math' as math;

///
class TimerPainter extends CustomPainter {
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    /// dessine le cercle clair
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;

    /// dessine le cercle loading
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  /// check if we need to redraw the whole thing
  @override
  bool shouldRepaint(TimerPainter old) {
    /// if the animation / color value is not
    /// equal to the older value,
    /// we redraw the whole thing
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}