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
      {Key key, this.message, this.buttonIcon, this.buttonText, this.imagePath, this.buttonAction, this.buttonColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /** l'image décorative  */
          Image.asset(
            imagePath,
            width: 150,
            height: 150,
          ),
          /** Le message */
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          
          /** Le bouton effectuant une action */
          new ActionButton(
            text: buttonText,
            icon: buttonIcon,
            color: buttonColor,
            actions: buttonAction,
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

  const ActionButton(
      {Key key, this.text, this.icon, this.color, this.actions})
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
          child: Text('$text', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
