import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:quizapp/services/services.dart';
import 'package:quizapp/parts/parts.dart';

/// contient la photo de l'étape, et les différents
/// textes et émojis
class PhotoCanvas extends StatelessWidget {
  final File photoFile;

  // la taille de la photo
  final int photoSize;

  // les trucs drag and drop (text emojis etc...)
  final List<Widget> textsAndEmojis;

  // le texte a display qd ya pas de photo
  final String noPhotoText;

  PhotoCanvas({
    Key key,
    this.photoFile,
    this.photoSize,
    this.textsAndEmojis,
    this.noPhotoText,
  }) : super(key: key);

  // affiche la photo sur toute la surface disponible
  //
  Widget photo() {
    return Padding(
      padding: paddedOrNot(photoSize),
      child: Center(
        child: FadeInImage(
          placeholder: AssetImage("assets/icon.png"),
          image: FileImage(photoFile),
          fit: howFitIsPhoto(photoSize),
        ),
      ),
      //),
    );

    /*Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.red, width: 2.0),
          image: DecorationImage(
            image: FileImage(photoFile),
            fit: howFitIsPhoto(photoSize),
          ),
        ),
      ),
    );*/
  }

  /// if we're in full screen mode
  /// no padding, otherwise some padding
  EdgeInsets paddedOrNot(int photoSize) {
    if (photoSize == NORMAL_SIZE) {
      return EdgeInsets.all(8.0);
    } else if (photoSize == FULL_SIZE) {
      return EdgeInsets.all(0.0);
    } else {
      throw Error();
    }
  }

  /// how fit should the photo be on the space available
  /// either full screen or not
  BoxFit howFitIsPhoto(int photoSize) {
    if (photoSize == NORMAL_SIZE) {
      return BoxFit.contain;
    } else if (photoSize == FULL_SIZE) {
      return BoxFit.cover;
    } else {
      throw Error();
    }
  }

  // l'icone d'étudiant
  Widget studentIcon() {
    return Image.asset(
      'assets/icon.png',
      width: 75,
      height: 75,
      fit: BoxFit.contain,
    );
  }

  // le message
  Widget msg() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 0.0),
      child: Text(
        noPhotoText,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// affiche un message sur fond orange
  ///  invitant jonny à
  /// prendre une photo
  Widget takePhotoMsg() {
    return Container(
      color: Colors.orange,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            studentIcon(),
            msg(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // contient tous les éléments de la zone photo
    // photo, texte, émoji, etc...
    List<Widget> elements = [];

    

    // si il n'y a pas de photo disponible
    if (photoFile == NO_PHOTO) {
      // affichons le message sur fond jaune
      // invitant l'user à prendre une photo
      elements.add(takePhotoMsg());
    }

    /// si il y a une photo dispo
    else {
      /// affiche cette photo
      elements.add(photo());
    }

    /// ajoute les texts et emojis etc...
    /// drag and drop
    elements += textsAndEmojis;

    print(elements);
    
    /// nous allons afficher ceci en tant que Stack
    return Stack(
      children: elements,
    );
  }
}
