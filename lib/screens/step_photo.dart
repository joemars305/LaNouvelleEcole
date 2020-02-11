import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';
import 'package:quizapp/shared/photo_canvas.dart';

/// Etape 1 on prend une photo

/// Widget to capture and crop the image
class StepPhoto extends StatefulWidget {
  createState() => _StepPhotoState();
}

class _StepPhotoState extends State<StepPhoto> {
  /// PHOTO_FILE représente la
  /// photo de l'étape en cours.
  ///
  /// null pour NO_PHOTO
  /// File pour PHOTO
  File _imageFile = NO_PHOTO;

  /// PHOTO_SIZE représente la taille
  /// de la photo de l'étape.
  ///
  /// 0 pour NORMAL_SIZE
  /// 1 pour FULL_SIZE
  int _photoSize = NORMAL_SIZE;

  /// template
  /*int fnForPhotoSize(int photoSize) {
    if (photoSize == NORMAL_SIZE) {
      return NORMAL_SIZE;
    } else if (photoSize == FULL_SIZE) {
      return FULL_SIZE;
    } else {
      throw Error();
    }
  }*/

  /// SOUS_ETAPES represente l'etape actuelle
  ///
  /// 0 pour PRENDRE_PHOTO
  /// 1 pour MSG_AUDIO
  /// 2 pour TEXTE_OU_EMOJI
  /// 3 pour ENREGISTRER
  int sous_etape = PRENDRE_PHOTO;

  /// FONCTION
  /*int fnForSousEtape() {
    if (sous_etape == PRENDRE_PHOTO) {
      return PRENDRE_PHOTO;
    } 
    
    else if (sous_etape == MSG_AUDIO) {
      return MSG_AUDIO;
    } 
    
    else if (sous_etape == TEXTE_OU_EMOJI) {
      return TEXTE_OU_EMOJI;
    }

    else if (sous_etape == ENREGISTRER) {
      return ENREGISTRER;
    }

    else {
      throw Error();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Report>(
      future: Global.reportRef
          .getDocument(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<Report> snapshot) {
        Report userReport;

        /// panel is the content between
        /// the appbar and the bottomappbar.
        Widget panel;

        /// if we received the userReport
        if (snapshot.hasData) {
          userReport = snapshot.data;

          /// it's time to take a photo
          panel = PhotoCanvas(photoFile: _imageFile, photoSize: _photoSize);
        }

        /// if something got wrong trying
        /// to get userReport
        else if (snapshot.hasError) {
          /// inform the user about it
          panel = errorMsg();
        }

        /// if we're loading userReport
        else {
          /// tell johnny to wait
          panel = loadingMsg();
        }

        /// return the whole screen (appbar + middle + bottomappbar)
        return wholeScreen(userReport, panel);
      },
    );
  }

  /// la barre en haut de l'écran
  Widget getTopBar(Report userReport) {
    String title;
    
    if (userReport != null) {
      // stepIndex est l'index de la dernière
      // étape consultée par l'user
      BabyLesson lesson = userReport.getLatestBabyLessonSeen();

      /// on ajoute 1 a l'index parce qu'on veut
      /// etape 1, etape 2, etc... au lieu de
      /// etape 0, etape 1, etc...
      int stepIndex = lesson.currentStep + 1;
      String currentStepStr = "Etape " + stepIndex.toString();

      /// substepIndex est la sous étape
      /// de l'étape actuelle
      LessonStep currentStep = lesson.getCurrentStep();
      int substepIndex = currentStep.currentSubstep + 1;

      String currentSubstep = "(" +
          substepIndex.toString() +
          "/" +
          howManySubsteps.toString() +
          ")";

      title = currentStepStr + " " + currentSubstep;
    } 
    
    else {
      title = "La Nouvelle Ecole";
    }

    return AppBar(
      title: Text(title),
      actions: <Widget>[
        /// l'icone suivant
        nextButton(),
      ],
    );
  }

  /// le bouton permettant
  /// de passer d'une substep a une autre
  /// puis de passer à une autre étape
  /// lorsque toutes les substep sont ok
  Widget nextButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_forward,
      ),
      onPressed: nextButtonAction,
    );
  }

  /// les actions a effectuer pour passer
  /// d'une substep à un autre
  void nextButtonAction() {
    print('Oki');
  }

  // the whole screen
  Widget wholeScreen(Report userReport, Widget panel) {
    return Scaffold(
      // la barre en haut
      appBar: getTopBar(userReport),
      // la barre d'icones en bas de l'écran
      // (photo, microphone, text, etc...)
      bottomNavigationBar: getBottomBar(),

      // la zone contenant photo, texte, émojis, etc...
      body: panel,
    );
  }

  // la barre d'icones en bas de la photo
  Widget getBottomBar() {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          photoCameraIcon(),
          photoLibraryIcon(),
          photoSizeIcon(),
        ],
      ),
    );
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  // l'icone nous permettant de prendre
  // une photo avec l'appareil photo
  Widget photoCameraIcon() {
    return IconButton(
      icon: Icon(
        Icons.photo_camera,
        size: 30,
      ),
      onPressed: () => _pickImage(ImageSource.camera),
      color: Colors.blue,
    );
  }

  // l'icone nous permettant de prendre
  // une photo dans la mémoire du téléphone
  Widget photoLibraryIcon() {
    return IconButton(
      icon: Icon(
        Icons.photo_library,
        size: 30,
      ),
      onPressed: () => _pickImage(ImageSource.gallery),
      color: Colors.pink,
    );
  }

  /// la photo de l'étape ainsi que
  /// le texte et les indicateurs émojis,
  /// etc...
  Widget photoArea() {
    //print(_imageFile);

    return PhotoCanvas(photoFile: _imageFile, photoSize: _photoSize);
  }

  /// l'icone nous permettant de gérer
  /// la taille de la photo
  Widget photoSizeIcon() {
    IconData icon;
    Function fn;

    if (_photoSize == NORMAL_SIZE) {
      icon = Icons.fullscreen;
      fn = () {
        setState(() {
          _photoSize = FULL_SIZE;
        });
      };
    } else if (_photoSize == FULL_SIZE) {
      icon = Icons.fullscreen_exit;
      fn = () {
        setState(() {
          _photoSize = NORMAL_SIZE;
        });
      };
    } else {
      throw Error();
    }

    return IconButton(
      icon: Icon(
        icon,
        size: 30,
      ),
      onPressed: fn,
      color: Colors.pink,
    );
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

  /// affiche un message sur fond rose
  ///  invitant jonny à
  /// patienter
  Widget loadingMsg() {
    return Container(
      color: Colors.orange,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            studentIcon(),
            msg("Veuillez patientier please..."),
          ],
        ),
      ),
    );
  }

  // le message
  Widget msg(String msg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 0.0),
      child: Text(
        msg,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// affiche un message sur fond violet
  /// informant l'user qu'un problème est survenu
  /// lors du chargement des données utilisateur
  Widget errorMsg() {
    return Container(
      color: Colors.purple,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            studentIcon(),
            msg("Oups il y a un problème lors du chargement des données utilisateur..."),
          ],
        ),
      ),
    );
  }
}
