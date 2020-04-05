import 'package:flutter/material.dart';

class PrettyText extends StatelessWidget {
  const PrettyText({
    Key key,
    @required this.text,
    @required this.insideColor,
    @required this.outsideColor,
    @required this.fontSize,
  }) : super(key: key);

  final String text;
  final Color insideColor;
  final Color outsideColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      //alignment: AlignmentDirectional.center,
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = outsideColor,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            color: insideColor,
          ),
        ),
      ],
    );
  }
}