
import 'package:flutter/material.dart';
import 'package:quizapp/parts/parts.dart';

/// PHOTO_URL représente
/// le moyen d'affichage de photo
/// via file ou via url
///
/// null pour NO_PHOTO_URL
/// String autrement

/*
photoUrl() {
  if (photoUrl == NO_PHOTO_URL) {
    return noUrl();
  }

  else if (photoUrl is String &&
           photoUrl.length > 0) {
    return url();
  }

  else {
    throw Error();
  }
 
}
*/

/// contient la photo de l'étape, et les différents
/// textes et émojis
class PhotoCanvas extends StatelessWidget {
  final dynamic photoFile;

  // la taille de la photo
  final int photoSize;

  // les trucs drag and drop (text emojis etc...)
  final List<Widget> textsAndEmojis;

  // le texte a display qd ya pas de photo
  final String noPhotoText;

  /// si photo uploadée, l'url
  final String photoUrl;

  PhotoCanvas({
    Key key,
    this.photoFile,
    this.photoSize,
    this.textsAndEmojis,
    this.noPhotoText,
    this.photoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // contient tous les éléments de la zone photo
    // photo, texte, émoji, etc...
    List<Widget> elements = [];

    // si il n'y a pas de photo disponible,
    // ni localement, ni uploadée
    if (photoFile == NO_PHOTO && photoUrl == NO_PHOTO_URL) {
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

  nyanCat() {
    return AssetImage(
      'assets/nyan.gif',
    );
  }

  // affiche la photo sur toute la surface disponible
  //
  Widget photo() {
    return Padding(
      padding: paddedOrNot(photoSize),
      child: Center(
        child: FadeInImage(
          placeholder: nyanCat(),
          image: imageUrlOrFile(),
          fit: howFitIsPhoto(photoSize),
        ),
      ),
      //),
    );
  }

  /// returns first the local photo,
  /// if there's one,
  /// or the uploaded photo
  imageUrlOrFile() {
    if (photoFile != NO_PHOTO) {
      return fileImage();
    }

    else if (photoUrl != NO_PHOTO_URL) {
      return networkImage();
    } 
    
    else {
      throw Error();
    }
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

  
  

  /// affiche un message sur fond orange
  ///  invitant jonny à
  /// prendre une photo
  Widget takePhotoMsg() {
    return centeredMsg(
      'assets/icon.png',
      noPhotoText,
      Colors.lightBlue,    
    );

  }  
  

  

  networkImage() {
    return NetworkImage(photoUrl);
  }

  fileImage() {
    return FileImage(photoFile);
  }
}
