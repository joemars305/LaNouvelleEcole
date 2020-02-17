import 'package:flutter/material.dart';
import 'package:quizapp/parts/parts.dart';

/// USER_INPUT_STRING représente
/// un futur texte provenant
/// de l'utilisateur
///
/// null pour NO_USER_INPUT
/// Future<''> pour EMPTY_USER_INPUT
/// Future<un String d'une lettre ou plus> pour le reste

/*
void fnForFutureUserInput(Future<String> userInput) {
  userInput.then((userInput) {
    if (userInput == NO_USER_INPUT) {
      return noUserInput();
    }

    else if (userInput == EMPTY_USER_INPUT) {
      return emptyUserInput();
    }

    else if (userInput.length > 0) {
      return fnForInput();
    }

    else {
      throw Error();
    }
  });
}
*/

/// getUserInput nous permet d'obtenir un String venant
/// de l'utilisateur
///
/// INPUTS
///
/// - context, un BuildContext
/// - title, un String, le titre du dialog
/// - subtitle, un String, le texte au dessus du form
/// - hint, un String, le texte dans le form quand il est vide
///
/// OUTPUTS
///
/// - un USER_INPUT_STRING,
///
Future<String> getUserInput(
  BuildContext context,
  String title,
  String subtitle,
  String hint,
) async {
  String inputText = '';
  return showDialog<String>(
    context: context,
    barrierDismissible:
        false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: new Row(
          children: <Widget>[
            new Expanded(
                child: new TextField(
              autofocus: true,
              decoration:
                  new InputDecoration(labelText: subtitle, hintText: hint),
              onChanged: (value) {
                inputText = value;
              },
            ))
          ],
        ),
        actions: <Widget>[
          /// annuler, retourne null
          FlatButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop(NO_USER_INPUT);
            },
          ),

          /// ok button, retourne le contenu du text form a ce moment
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop(inputText);
            },
          ),
        ],
      );
    },
  );
}

/// affiche un message snackbar
void displaySnackbar(GlobalKey<ScaffoldState> scaffoldKey, String msg, int durationMsec) {
  final snackBar = SnackBar(
    content: Text(msg),
    duration: Duration(milliseconds: durationMsec),
  );

  scaffoldKey.currentState.removeCurrentSnackBar();

  // Find the Scaffold in the widget
  // tree and use it to show a SnackBar.
  scaffoldKey.currentState.showSnackBar(snackBar);
}
