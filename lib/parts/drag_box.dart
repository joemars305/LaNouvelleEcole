import 'package:flutter/material.dart';
import 'package:quizapp/parts/pretty_text.dart';

import 'consts.dart';

class DragBox extends StatefulWidget {
  final Offset initPos;
  final String label;
  final Color outsideColor;
  final Color insideColor;
  final double fontSize;

  DragBox(this.initPos, this.label, this.fontSize, this.outsideColor,
      this.insideColor);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = Offset(300.0, 300.0);
  double width = 150;
  double fontSize = 15.0;
  String text = "";

  @override
  void initState() {
    super.initState();

    position = widget.initPos;
    text = widget.label;
    fontSize = widget.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    print("x: " + position.dx.toString());
    print("y: " + position.dy.toString());

    var textWidth = 250.0;

    /// la taille de la 2eme barre en haut
    var topBarHeight = AppBar().preferredSize.height;

    /// la taille de la tte première barre
    var actionBarHeight = 24.0;
    //MediaQuery.of(context).padding.top;

    print("tbh: " + topBarHeight.toString());
    print("abh: " + actionBarHeight.toString());

    return Positioned(
      left: position.dx,
      top: position.dy - topBarHeight - actionBarHeight,
      //width: textWidth,
      child: Container(
        //color: Colors.red,
        constraints: BoxConstraints(maxWidth: textWidth),
        child: Draggable(
          data: widget.outsideColor,
          child: prettyTextOrNot(),
          feedback: dragBoxWhenDragged(textWidth),
          onDraggableCanceled: onDragBoxDropped,
        ),
      ),
    );
  }

  void onDragBoxDropped(velocity, offset) {
    setState(() {
      position = offset;
    });
  }

  Material dragBoxWhenDragged(double textWidth) {
    return Material(
      color: Colors.blue.withOpacity(0.5),
      elevation: 20.0,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      child: Container(
        constraints: BoxConstraints(maxWidth: textWidth),
        child: prettyTextOrNot(),
      ),
    );
  }

  Widget prettyTextOrNot() {
    if (widget.outsideColor == NO_DATA && widget.insideColor == NO_DATA) {
      return Text(
        text,
        style: TextStyle(
          fontSize: widget.fontSize,
        ),
      );
    } else {
      return PrettyText(
        text: text,
        outsideColor: widget.outsideColor,
        insideColor: widget.insideColor,
        fontSize: fontSize,
      );
    }
  }
}
