import 'package:flutter/material.dart';

// un message à afficher quand
// une base de donnée est vide
class NoDataMessage extends StatelessWidget {
  final String imagePath;
  final IconData buttonIcon;
  final String message;
  final Function buttonAction;
  final String buttonText;
  final Color buttonColor;

  const NoDataMessage(
      {Key key,
      this.message,
      this.buttonIcon,
      this.buttonText,
      this.imagePath,
      this.buttonAction,
      this.buttonColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      // une liste verticale de
      // tous les éléments de l'écran
      child: ListView(
        children: <Widget>[
          /** l'image décorative  */
          Image.asset(
            imagePath,
            width: 150,
            height: 150,
          ),
          /** espace vital */
          Container(
            height: 30,
          ),
          /** Le message */
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              //fontFamily: 'ComingSoon',
            ),
          ),
          /** espace vital */
          Container(
            height: 30,
          ),
          /** Le bouton effectuant une action */
          new ActionButton(
            text: buttonText,
            icon: buttonIcon,
            color: buttonColor,
            actions: buttonAction,
            font: 'Lobster',
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function actions;
  final String font;

  const ActionButton(
      {Key key, this.text, this.icon, this.color, this.actions, this.font})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: actions,
        label: Expanded(
          child: Text(
            '$text',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: font,
            ),
          ),
        ),
      ),
    );
  }
}
