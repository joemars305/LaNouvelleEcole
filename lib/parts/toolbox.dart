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
void displaySnackbar(
    GlobalKey<ScaffoldState> scaffoldKey, String msg, int durationMsec) {
  final snackBar = SnackBar(
    content: Text(msg),
    duration: Duration(milliseconds: durationMsec),
  );

  scaffoldKey.currentState.removeCurrentSnackBar();

  // Find the Scaffold in the widget
  // tree and use it to show a SnackBar.
  scaffoldKey.currentState.showSnackBar(snackBar);
}


/// FUTURE_CHOICE représente
/// un futur choix provenant
/// de l'utilisateur
///
/// null pour NO_FUTURE_CHOICE
/// Future<Choice> autrement

/*
void fnForFutureChoice(Future<Choice> futureChoice) {
  futureChoice.then((choice) {
    if (choice == NO_FUTURE_CHOICE) {
      return noChoice();
    }

    else {
      return doSomethingWChoice();
    }
  });
}
*/

/// getUserChoice nous permet d'obtenir un Choice venant
/// de l'utilisateur
///
/// INPUTS
///
/// - context, un BuildContext
/// - title, un String, le titre du dialog
/// - choices une liste de type Choices
///
/// OUTPUTS
///
/// - un FUTURE_CHOICE
///
Future<Choice> getUserChoice(
  BuildContext context,
  String title,
  List<Choice> choices,
) async {
  return await showDialog<Choice>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: makeChoicesList(context, choices),
        );
      });
}

/// crée un liste de choix cliquables
List makeChoicesList(BuildContext context, List<Choice> choices) {
  return choices.map((choice) {
    return handleChoice(context, choice);
  }).toList();
}

/// crée un choix individuel cliquable
SimpleDialogOption handleChoice(BuildContext context, Choice choice) {
  String choiceDesc = choice.choiceDescription;
  int choiceVal = choice.choiceValue;

  return SimpleDialogOption(
    onPressed: () {
      Navigator.pop(context, choice);
    },
    child: Text(choiceDesc),
  );
}

/// Choice est un objet représentant
/// un choix individuel que l'user
/// peut faire parmis plusieurs choix
///
/// Cet objet à 2 champs:
///
/// choiceDescription est un String décrivant le choix
/// choiceValue est un int représentant la valeur de ce choix

/*
fnForChoice(Choice choice) {
  String choiceDesc = choice.choiceDescription;
  int choiceVal = choice.choiceValue;


}
*/
class Choice {
  String choiceDescription;
  int choiceValue;

  Choice(this.choiceDescription, this.choiceValue);
}

/// Choices représente une liste de Choice
///

/*
List fnForChoices(List<Choice> choices) {
  return choices.map((choice) {
    return handleChoice(choice);
  }).toList();
}
*/
