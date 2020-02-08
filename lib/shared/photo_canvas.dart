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

  PhotoCanvas({
    Key key,
    this.photoFile, this.photoSize,
  }) : super(key: key);

  // affiche la photo sur toute la surface disponible
  // 
  Widget photo() {
    return //Positioned.fill(
      //child: 
      Padding(
        padding: EdgeInsets.all(paddedOrNot(photoSize)),
        child: Container(
          
          decoration: BoxDecoration(
            //border: Border.all(color: Colors.red, width: 2.0),
            image: DecorationImage(
              image: FileImage(photoFile),
              fit: howFitIsPhoto(photoSize),
            ),
          ),
        ),
      );//,
//);
  }

  /// if we're in full screen mode
  /// no padding, otherwise some padding
  double paddedOrNot(int photoSize) {
    if (photoSize == NORMAL_SIZE) {
      return 8.0;
    } else if (photoSize == FULL_SIZE) {
      return 0.0;
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
        "Appuie sur l'appareil photo pour prendre une photo",
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

    //print(photoFile);

    // si il n'y a pas de photo disponible
    if (photoFile == null) {
      // affichons le message sur fond jaune
      // invitant l'user à prendre une photo
      elements.add(takePhotoMsg());
    } 
    /// si il y a une photo dispo
    else {
      /// affiche cette photo
      elements.add(photo());
    }

    /// nous allons afficher ceci en tant que Stack
    return Stack(
      children: elements,
    );
  }
}
