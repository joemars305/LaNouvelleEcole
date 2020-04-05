


///
/// - dans lesson_viewer, crée une icone topbar shopping,
/// qui affiche un panel similaire a l'inventaire,
/// mais read only (pas de + ou -), et qui propose on tap,
/// un choix d'etre redirigé vers:
/// * un site web (si url fournie),
/// * un lieu d'approv. google maps (si lieu approv. fourni).
///
/// - on veut pouvoir ajouter plus d'infos dans
/// l'inventaire, on tap, comme:
/// * les prix unitaire des objets,
/// * une url liant vers un site d'achat
/// * une position google maps représentant
///   un lieu d'approvisionnement de ressource,
///   payant ou naturel.
/// * le prix total de tous les objets topbar
///
/// - ajoute portrait/paysage
///
/// - crée des dossiers 
/// 'bebe_lecons/nom_lecon/etape_x/fichier.ext'
/// lorsque on stocke des photo/video/audio
/// pour les étapes
/// 
/// - implemente une fonctionnalité permettant de télécharger l'ensemble du contenu
/// photo/audio/vidéo d'une leçon, via bluetooth ou autre moyen
/// (zippé de préference)
/// 
/// - implémente l'upload du contenu et la finalisation de la leçon
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quizapp/services/services.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';


/// Widget to capture and crop the image
class StepCreation extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  StepCreation({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  createState() => _StepCreationState();
}

class _StepCreationState extends State<StepCreation> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Report>(
      stream: Global.reportRef
          .documentStream, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<Report> snapshot) {
        Report userReport;

        /// panel is the content between
        /// the appbar and the bottomappbar.
        Widget panel;

        /// if we received the userReport
        if (snapshot.hasData) {
          userReport = snapshot.data;

          /// it's time to do steps
          panel = stepPanel(userReport);
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
        return wholeScreen(context, userReport, panel);
      },
    );
  }

  /// nous permet d'afficher des snackbar
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// nous permet de sauvegarder la zone photo
  final _canvasKey = GlobalKey();

  /// le liseur de fichier audio
  SoundPlayer audioPlayer;

  /// l'enregistreur via microphone
  SoundRecorder audioRecorder;

  /// permet de prendre photo / vidéo
  PhotoVideoRecorder photoVideoRecorder;

  /// permet de sauvegarder localement / supprimer / télécharger
  /// des fichiers (File)
  FileManager fileManager;

  /// initialise le controller
  @override
  void initState() {
    super.initState();

    audioPlayer = new SoundPlayer();

    /// nous permet d'update le state
    /// lorsque un fichier audio est completé
    audioPlayer.setOnComplete(() {
      setState(() {
        _playerState = STOPPED;
      });
    });

    audioRecorder = new SoundRecorder();

    photoVideoRecorder = new PhotoVideoRecorder();

    fileManager = new FileManager();
  }

  @override
  void dispose() {
    print('allez hop on ferme boutique.');

    audioPlayer.stop(() {});
    audioRecorder.dispose();
    
    super.dispose();
  }

  /// _photoVideoFile représente la
  /// photo/video de l'étape en cours.
  ///
  /// null pour NO_DATA
  /// File pour un fichier photo/video
  File _photoVideoFile = NO_DATA;
  /*
  handleImageFile() {
    if (_photoVideoFile == NO_DATA) {
      noPhoto();
    } else {
      photo();
    }
  }
  */

  /// _fileType représente le type
  /// de média pris par l'utilisateur
  /// avec sa camera
  ///
  /// 0 pour VIDEO_FILE
  /// 1 pour PHOTO_FILE

  /*
  fnForFileType() {
    if (_fileType == VIDEO_FILE) {
      return fnForVideoFile();
    } else if (_fileType == PHOTO_FILE) {
      return fnForPhotoFile();
    } else {
      throw Error();
    }
  }
  */
  int _fileType = NO_DATA;

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
  int sousEtape = PRENDRE_PHOTO_VIDEO;

  /*
  fnForSousEtape() {
    if (sousEtape == PRENDRE_PHOTO_VIDEO) {
      prendrePhotoVideo();
    } else if (sousEtape == MSG_AUDIO) {
      msgAudio();
    } else if (sousEtape == INVENTAIRE) {
      inventaire();
    } else if (sousEtape == UPLOAD_FILES) {
      uploadFiles();
    } else {
      throw Error();
    }
  }
  */

  /// IS_RECORDING représente si on est en train, ou pas,
  /// d'enregistrer un message audio
  ///
  /// false pour NO_RECORD
  /// true pour WE_RECORD
  bool _isRecording = NO_RECORD;

  /*
  int fnForRecording() {
    if (_isRecording == NO_RECORD) {
      return noRecording();
    } 
    
    else if (_isRecording == WE_RECORD) {
      return recording();
    } 

    else {
      throw Error();
    }
  }
 

  */

  /*
  
  void ...() {
    if (_audioPath == NO_AUDIO_FILE) {
      return ...();
    }

    else {
      return ...();
    }
  }

  */

  /// PLAYER_STATE représente l'état du player audio
  ///
  /// 0 pour STOPPED
  /// 1 pour PLAYING
  /// 2 pour PAUSED
  int _playerState = STOPPED;

  /*
  Widget fn() {
    if (_playerState == STOPPED) {
      return stopped();
    }

    else if (_playerState == PLAYING) {
      return playing();
    }

    else if (_playerState == PAUSED) {
      return paused();
    }

    else {
      throw Error();
    }
  }

  */

  /// PHOTO_VIDEO_UPLOAD_STATUS représente
  /// l'état d'avancement de l'upload de photo/vidéo
  int photoVideoUploadStatus = NOT_UPLOADED;

  /*
  fnForUpStatus() {
    if (photoVideoUploadStatus == NOT_UPLOADED) {
      return noUp();
    } else if (photoVideoUploadStatus == UPLOAD_IN_PROGRESS) {
      return upInProgress();
    } else if (photoVideoUploadStatus == UPLOAD_SUCCESS) {
      return upSuccess();
    } else if (photoVideoUploadStatus == UPLOAD_FAIL) {
      return upFail();
    }
  }
  */

  /// _displayMode représente le type d'affichage
  /// de l'étape.
  ///
  /// -1 pour STEP_CREATION
  /// -2 pour STEP_VIEWER
  int _displayMode = STEP_CREATION;

  /*

  /// _displayMode => Widget
  /// 
  /// 
  Widget fnForDisplayMode(int displayMode) {
    if (displayMode == STEP_CREATION) {
      return fnForStepCreation();
    } else if (displayMode == STEP_VIEWER) {
      return fnForStepViewer();
    } else {
      throw Error();
    }
  }

  */

  /// Report => Widget
  ///
  /// quel contenu doit on afficher entre la top bar et
  /// la bottom bar.
  Widget stepPanel(Report userReport) {
    if (_displayMode == STEP_CREATION) {
      return stepPanelForStepCreation(userReport);
    } else if (_displayMode == STEP_VIEWER) {
      return stepPanelForStepViewer(userReport);
    } else {
      throw ErrorDescription("Mode d'affichage invalide: $_displayMode");
    }
  }

  Widget stepPanelForStepCreation(Report userReport) {
    if (sousEtape == PRENDRE_PHOTO_VIDEO) {
      return prendrePhotoVideoPanel(userReport,
          "Appuie sur l'appareil photo pour prendre une photo/vidéo.");
    } else if (sousEtape == MSG_AUDIO) {
      return msgAudioPanel(userReport);
    } else if (sousEtape == UPLOAD_FILES) {
      return uploadFilesPanel(userReport);
    } else if (sousEtape == INVENTAIRE) {
      return inventairePanel(userReport);
    } else {
      throw Error();
    }
  }

  /// permet de voir la photo qu'on a prise
  Widget prendrePhotoVideoPanel(Report userReport, String msg) {
    var currentStep = userReport.getLatestBabyLessonSeen().getCurrentStep();

    print("ft: " + _fileType.toString());
    print("csft: " + currentStep.fileType.toString());

    return RepaintBoundary(
      key: _canvasKey,
      child: PhotoVideoCanvas(
        file: _photoVideoFile,
        photoSize: _photoSize,
        fileType: _fileType != NO_DATA ? _fileType : currentStep.fileType,
        noFileText: msg,
        fileUrl: currentStep.photoVideoFileUrl,
        filePath: currentStep.photoVideoFilePath,
      ),
    );
  }

  /// si on n'enregistre pas de message audio,
  /// on affiche prendrePhotoPanel(),
  /// sinon on affiche un compte à rebours
  /// en forme de cercle
  Widget msgAudioPanel(Report userReport) {
    if (_isRecording == NO_RECORD) {
      return noRecordingAudioPanel(userReport);
    } else if (_isRecording == WE_RECORD) {
      return recordingAudioPanel();
    } else {
      throw Error();
    }
  }

  /// pas d'enregistrement, donc photo
  Widget noRecordingAudioPanel(Report userReport) {
    String msg = noRecordingMsg();

    return centeredMsg("assets/icon.png", msg, Colors.purpleAccent);
  }

  /// quel instructions donner a l'user durant étape audio
  String noRecordingMsg() {
    /// si il n'existe aucun enregistrement audio,
    /// (recording ou audioPath)
    if (audioRecorder.recording == NO_DATA) {
      return "Appuie sur le micro pour enregistrer un message audio.";
    }

    /// sinon invite user à écouter
    else {
      return "Appuie sur l'icone play pour écouter le message audio.";
    }
  }

  /// enregistrement, donc countdown
  Widget recordingAudioPanel() {
    return centeredMsg(
        "assets/icon.png", "Enregistrement audio en cours...", Colors.pink);
  }

  Widget uploadFilesPanel(Report userReport) {
    if (photoVideoUploadStatus == NOT_UPLOADED) {
      return noFilesUploaded();
    } else if (photoVideoUploadStatus == UPLOAD_IN_PROGRESS) {
      return upInProgress();
    } else if (photoVideoUploadStatus == UPLOAD_SUCCESS) {
      return upSuccess();
    } else if (photoVideoUploadStatus == UPLOAD_FAIL) {
      return upFail();
    } else {
      throw Error();
    }
  }

  /// l'inventaire d'objets
  Widget inventairePanel(Report userReport) {
    /// combien d'items individuels existent dans l'inventaire ?
    int qtyItems = userReport.getLatestBabyLessonSeen().items.length;

    /// si il y aucun items dans l'inventaire
    /// affiche un message invitant user
    /// à appuyer sur l'icone +
    if (qtyItems == 0) {
      return createItemsMsg();
    }

    /// sinon affiche une liste
    /// des items
    else {
      return itemsList(userReport);
    }
  }

  /// Ajoute un objet dans ton inventaire en appuyant sur +
  Widget createItemsMsg() {
    return centeredMsg(
      'assets/wrench.png',
      "Ajoute un objet dans ton inventaire en appuyant sur +",
      Colors.red,
    );
  }

  /// une liste d'objets
  Widget itemsList(Report userReport) {
    var babyLesson = userReport.getLatestBabyLessonSeen();

    return ListView.builder(
      // combien d' objets
      itemCount: babyLesson.items.length,
      // crée une liste d'items
      // qu'on peut supprimer en swipant
      itemBuilder: (context, index) {
        return swipableItem(context, index, userReport);
      },
    );
  }

  /// _displayMode Report BuildContext => Widget
  ///
  /// Produit la barre en haut de l'écran
  Widget getTopBar(int displayMode, Report userReport, BuildContext context) {
    if (displayMode == STEP_CREATION) {
      return getTopBarForStepCreation(userReport, context);
    } else if (displayMode == STEP_VIEWER) {
      return getTopBarForStepViewer(userReport, context);
    } else {
      throw Error();
    }
  }

  /// Report BuildContext => Widget
  ///
  /// Produit la barre en haut de l'écran
  /// pour le visionner d'étapes
  Widget getTopBarForStepViewer(Report userReport, BuildContext context) {
    var babyLesson = userReport.getLatestBabyLessonSeen();
    var currentStepIndexPlusOneForCoherence = babyLesson.currentStep + 1;
    var title = "Etape $currentStepIndexPlusOneForCoherence";

    return AppBar(
      leading: backButton(userReport),
      title: titleNavigation(title, userReport, context),
      actions: <Widget>[
        nextButton(userReport, context),
      ],
    );
  }

  /// Report BuildContext => Widget
  ///
  ///
  /// produit la barre en
  /// haut de l'écran,
  /// pour le créateur de leçon
  Widget getTopBarForStepCreation(Report userReport, BuildContext context) {
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

      String currentSubstep = "(" +
          (sousEtape + 1).toString() +
          "/" +
          howManySubsteps.toString() +
          ")";

      title = currentStepStr + " " + currentSubstep;
    } else {
      title = "La Nouvelle Ecole";
    }

    return AppBar(
      leading: backButton(userReport),
      title: titleNavigation(title, userReport, context),
      actions: <Widget>[
        delButton(userReport, context),
        nextButton(userReport, context),
      ],
    );
  }

  Widget titleNavigation(
      String title, Report userReport, BuildContext context) {
    return new GestureDetector(
      onTap: () {
        goToStepActions(userReport, context);
      },
      child: new Text(title),
    );
  }

  void goToStepActions(Report userReport, BuildContext context) {
    List<Choice> choices = stepsChoices(userReport);

    Future<Choice> userChoice = getUserChoice(
      context,
      "Tu veux aller vers quelle étape ?",
      choices,
    );

    fnForStepChoice(userChoice, userReport);
  }

  List<Choice> stepsChoices(Report userReport) {
    var babyLesson = userReport.getLatestBabyLessonSeen();
    var steps = babyLesson.steps;

    List<Choice> choices = steps
        .asMap()
        .map((etapeIndex, step) {
          var etapeDescription = "🚀 Etape " + (etapeIndex + 1).toString();
          var etapeChoisie = Choice(
            etapeDescription,
            etapeIndex,
          );

          return MapEntry(
            etapeIndex,
            etapeChoisie,
          );
        })
        .values
        .toList();

    /// si on est en mode création d'étape,
    /// on veut pouvoir avoir le choix de
    /// basculer en mode visionnage d'étape, et vice versa
    addDisplayModeChoice(_displayMode, choices);

    return choices;
  }

  /// _displayMode List<Choice> => void
  ///
  /// Ajoute un choix de basculement entre displayModes
  /// au tout début de la liste de choix (index 0)
  void addDisplayModeChoice(int displayMode, List<Choice> choices) {
    if (displayMode == STEP_CREATION) {
      /// ajoute un choix permettant de passer
      /// l'écran de step_creation en mode step_viewer
      choices.insert(
          0,
          new Choice(
            "Preview résultat final.",
            STEP_VIEWER,
          ));
    } else if (displayMode == STEP_VIEWER) {
      /// ajoute un choix permettant de passer
      /// l'écran de step_viewer en mode step_creation
      choices.insert(
          0,
          new Choice(
            "Panneau de création/modification d'étape.",
            STEP_CREATION,
          ));
    } else {
      throw Error();
    }
  }

  void fnForStepChoice(Future<Choice> futureChoice, Report userReport) {
    futureChoice.then((choice) {
      if (choice == NO_FUTURE_CHOICE) {
        return noStepChoice(choice);
      } else {
        return handleStepChoice(choice, userReport);
      }
    });
  }

  /// le bouton permettant
  /// de passer d'une substep a une autre
  /// puis de passer à une autre étape
  /// lorsque toutes les substep sont ok
  Widget nextButton(Report userReport, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_forward,
      ),
      onPressed: () async {
        await nextButtonAction(userReport, context);
      },
    );
  }

  Widget delButton(Report userReport, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.delete,
      ),
      onPressed: () {
        delButtonActions(userReport, context);
      },
    );
  }

  delButtonActions(Report userReport, BuildContext context) {
    List<Choice> choices = [
      Choice("On supprime l'étape.", SUPPRIME_ETAPE),
      Choice("On remet à zero l'étape.", REMET_A_ZERO_ETAPE),
    ];

    Future<Choice> userChoice = getUserChoice(
      context,
      "Voulez vous supprimer, ou remetre à zero l'étape ?",
      choices,
    );

    fnForStepOutcome(userChoice, userReport, context);
  }

  void fnForStepOutcome(
      Future<Choice> futureChoice, Report userReport, BuildContext context) {
    futureChoice.then((choice) async {
      if (choice == NO_FUTURE_CHOICE) {
        noStepChoice(choice);
      } else if (choice.choiceValue == SUPPRIME_ETAPE) {
        supprimeEtapeActions(userReport, context);
      } else if (choice.choiceValue == REMET_A_ZERO_ETAPE) {
        resetState(PRENDRE_PHOTO_VIDEO);
      } else {
        throw Error();
      }
    });
  }

  /// les actions a effectuer pour passer
  /// d'une substep à un autre
  Future<void> nextButtonAction(Report userReport, BuildContext context) async {
    if (_displayMode == STEP_CREATION) {
      incrementSubstepAndCie(userReport, context);
    } else if (_displayMode == STEP_VIEWER) {
      incrementCurrentStep(userReport);
    }
  }

  void incrementCurrentStep(Report userReport) {
    var babyLesson = userReport.getLatestBabyLessonSeen();
    var currentStep = babyLesson.currentStep;
    var lastStepIndex = babyLesson.steps.length - 1;

    /// si on est pas encore à la derniere étape, on incremente
    if (!(currentStep == lastStepIndex)) {
      babyLesson.currentStep++;
      userReport.save();
    } else {
      displaySnackbar(_scaffoldKey,
          "On ne peut pas monter plus haut que la dernière étape.", 2500);
    }
  }

  void incrementSubstepAndCie(Report userReport, BuildContext context) {
    if (sousEtape < lastSubstep) {
      if (sousEtape == PRENDRE_PHOTO_VIDEO) {
        incrementSubstep();
      } else if (sousEtape == MSG_AUDIO) {
        /// si on est à l'étape audio,
        /// on arrete l'enregistreur et le lecteur
        if (sousEtape == MSG_AUDIO) {
          stopRecordingAndSave(userReport);
          audioPlayer.stop(() {
            setState(() {
              _playerState = STOPPED;
            });
          });
        }

        incrementSubstep();
      } else if (sousEtape == INVENTAIRE) {
        nextStepOrLessonOver(userReport, context);
      } else if (sousEtape == UPLOAD_FILES) {
      } else {
        throw Error();
      }
    }
  }

  void nextStepOrLessonOver(Report userReport, BuildContext context) {
    var choices = [
      Choice("Etape suivante !", ETAP_SUIV),
      Choice("La leçon est terminée !", FIN_LECON),
    ];

    Future<Choice> userChoice = getUserChoice(
      context,
      "On va à l'étape suivante, ou la leçon est terminée ?",
      choices,
    );

    fnForStepOutcomeChoice(userReport, userChoice);
  }

  void fnForStepOutcomeChoice(Report userReport, Future<Choice> futureChoice) {
    futureChoice.then((choice) {
      if (choice == NO_FUTURE_CHOICE) {
        return noOutcomeChoice();
      } else if (choice.choiceValue == ETAP_SUIV) {
        return etapSuivChoice(userReport);
      } else if (choice.choiceValue == FIN_LECON) {
        return finLeconChoice(userReport);
      }
    });
  }

  void userDoUrJob() {
    String msg =
        "Avant de pouvoir continuer, il faut prendre une photo, ajouter du texte et/ou émoji dessus, et enregistrer un message audio.";

    int durationMsec = 7000;
    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  void incrementSubstep() {
    return setState(() {
      sousEtape++;
    });
  }

  /// Report => void
  ///
  /// le bouton permettant de naviguer en arrière
  Widget backButton(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
      ),
      onPressed: () {
        backButtonAction(userReport);
      },
    );
  }

  /// Report => void
  ///
  /// les actions a effectuer pour passer
  /// a la sous étape précédente
  /// (en mode _displayMode == STEP_CREATION)
  ///
  /// ou a l'étape précedente
  /// (en mode _displayMode == STEP_VIEWER)
  void backButtonAction(Report userReport) {
    if (_displayMode == STEP_CREATION) {
      decrementSubstepAndCie(userReport);
    } else if (_displayMode == STEP_VIEWER) {
      decrementCurrentStep(userReport);
    }
  }

  void decrementCurrentStep(Report userReport) {
    var babyLesson = userReport.getLatestBabyLessonSeen();
    var currentStep = babyLesson.currentStep;

    /// décremente si étape actuelle supérieure a 0
    if (currentStep > 0) {
      babyLesson.currentStep--;
      userReport.save();
    } else {
      displaySnackbar(_scaffoldKey,
          "On peut pas descendre plus bas que la première étape.", 2500);
    }
  }

  void decrementSubstepAndCie(Report userReport) {
    if (sousEtape > PRENDRE_PHOTO_VIDEO) {
      /// si on est à l'étape audio,
      /// on arrete l'enregistreur et le lecteur
      if (sousEtape == MSG_AUDIO) {
        stopRecordingAndSave(userReport);
        audioPlayer.stop(() {
          setState(() {
            _playerState = STOPPED;
          });
        });

        decrementSubstep();
      } else {
        decrementSubstep();
      }
    } else {
      displaySnackbar(_scaffoldKey,
          "On peut pas descendre plus bas que la première étape.", 2500);
    }
  }

  void decrementSubstep() {
    return setState(() {
      sousEtape--;
    });
  }

  // la barre d'icones en bas de la photo
  Widget getBottomBar(Report userReport, BuildContext context) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: substepIcons(userReport, context),
      ),
    );
  }

  /// les icones de la sous étape en cours
  List<Widget> substepIcons(Report userReport, BuildContext context) {
    if (_displayMode == STEP_CREATION) {
      return substepIconsForStepCreation(userReport, context);
    } else if (_displayMode == STEP_VIEWER) {
      return substepIconsForStepViewer(userReport, context);
    } else {
      throw ErrorDescription("Invalide mode d'affichage: $_displayMode");
    }
  }

  List<Widget> substepIconsForStepCreation(
      Report userReport, BuildContext context) {
    if (sousEtape == PRENDRE_PHOTO_VIDEO) {
      return prendrePhotoIcons(userReport, context);
    } else if (sousEtape == MSG_AUDIO) {
      return msgAudioIcons(userReport);
    } else if (sousEtape == UPLOAD_FILES) {
      return uploadFilesIcons(userReport);
    } else if (sousEtape == INVENTAIRE) {
      return inventaireIcons(userReport, context);
    } else {
      throw Error();
    }
  }

  /// les icones de l'étape photo
  List<Widget> prendrePhotoIcons(Report userReport, BuildContext context) {
    return [
      photoCameraIcon(userReport, PHOTO_AND_VIDEO, context),
      photoLibraryIcon(userReport, PHOTO_AND_VIDEO, context),
      photoSizeIcon(),
    ];
  }

  /// les icones de l'étape message audio
  List<Widget> msgAudioIcons(Report userReport) {
    if (_isRecording == WE_RECORD) {
      return micIcon(userReport);
    } else {
      return micAndPlayIcons(userReport);
    }
  }

  /// si on enregistre de l'audio
  /// on veut juste l'icone micro
  List<Widget> micIcon(Report userReport) {
    return [
      recordIcon(userReport),
    ];
  }

  /// si pas d'enregistrement audio en cours,
  /// on veut micro + play/pause
  List<Widget> micAndPlayIcons(Report userReport) {
    return [
      recordIcon(userReport),
      playPauseIcon(userReport),
      restartAudioIcon(userReport),
    ];
  }

  /// Report => void
  ///
  ///
  Widget restartAudioIcon(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.skip_previous,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () async {
        await restartAudioActions(userReport);
      },
      color: Colors.blue,
    );
  }

  Future<void> restartAudioActions(Report userReport) async {
    /// si il existe un fichier audio
    /// a redemarrer
    if (audioPlayer.haveWePlayedSomething == WE_HAVE_PLAYED_AUDIO) {
      audioPlayer.restart(() {
        setState(() {
          _playerState = PLAYING;
        });
      });
    } else {
      displaySnackbar(
          _scaffoldKey, "Y'a rien à redémarrer pour l'instant.", 3000);
    }
  }

  /// l'icone qui joue/pause un enregistrement audio
  Widget playPauseIcon(Report userReport) {
    if (_playerState == STOPPED) {
      return playIcon(userReport);
    } else if (_playerState == PLAYING) {
      return pauseIcon();
    } else if (_playerState == PAUSED) {
      return resumeIcon();
    } else {
      throw Error();
    }
  }

  /// l'icone qui joue un enregistrement audio
  Widget playIcon(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.play_arrow,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        var step = userReport.getLatestBabyLessonSeen().getCurrentStep();
        String localAudioPath = step.audioFilePath;
        String audioUrl = step.audioFileUrl;

        if (localAudioPath != NO_DATA) {
          audioPlayer.playLocal(localAudioPath, () {
            setState(() {
              _playerState = PLAYING;
            });
          });
        } else if (audioUrl != NO_DATA) {
          audioPlayer.playRemote(audioUrl, () {
            setState(() {
              _playerState = PLAYING;
            });
          });
        } else {
          print(localAudioPath);

          displaySnackbar(
              _scaffoldKey,
              "Il n'y a pas encore de message audio à lire pour cette étape.",
              3500);
        }
      },
      color: Colors.blue,
    );
  }

  /// l'icone qui met en pause un enregistrement audio
  Widget pauseIcon() {
    return IconButton(
      icon: Icon(
        Icons.pause,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        audioPlayer.pause(() {
          setState(() {
            _playerState = PAUSED;
          });
        });
      },
      color: Colors.blue,
    );
  }

  /// l'icone qui relance un enregistrement audio pausé
  Widget resumeIcon() {
    return IconButton(
      icon: Icon(
        Icons.play_arrow,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        audioPlayer.resume(() {
          setState(() {
            _playerState = PLAYING;
          });
        });
      },
      color: Colors.blue,
    );
  }

  // l'icone nous permettant d'enregistrer
  /// un message audio
  Widget recordIcon(Report userReport) {
    if (_isRecording == NO_RECORD) {
      return startRecordingIcon(userReport);
    } else if (_isRecording == WE_RECORD) {
      return stopRecordingIcon(userReport);
    } else {
      throw Error();
    }
  }

  // l'icone qui demarre un enregistrement audio
  Widget startRecordingIcon(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.mic,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () async {
        startRecording(userReport);
      },
      color: Colors.blue,
    );
  }

  void startRecording(Report userReport) async {
    /// si un enregistrement audio est en train d'être lu
    /// on arrete
    if (_playerState == PLAYING || _playerState == PAUSED) {
      await audioPlayer.stop(() {
        setState(() {
          _playerState = STOPPED;
        });
      });
    }

    /// supprime le précédent fichier audio, si existant
    var step = userReport.getLatestBabyLessonSeen().getCurrentStep();
    String localAudioPath = step.audioFilePath;
    bool oldAudioExists;

    if (localAudioPath != NO_DATA) {
      oldAudioExists =
          await fileManager.deleteFile(localAudioPath, NO_DATA, () {});
    }

    print("old audio file exists: $oldAudioExists");

    /// le path du dossier appli
    Directory dir = await getExternalStorageDirectory();
    String dirPath = dir.path;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await audioRecorder.startRecording(dirPath, fileName, () {
      setState(() {
        _isRecording = WE_RECORD;
      });
    });
  }

  /// l'icone qui arrete un enregistrement audio
  Widget stopRecordingIcon(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.stop,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () async {
        stopRecordingAndSave(userReport);
      },
      color: Colors.blue,
    );
  }

  Future stopRecordingAndSave(Report userReport) async {
    /// on arrête l'écoute, et on
    /// récupère le path du fichier audio
    if (_isRecording == WE_RECORD) {
      String localAudioPath = await audioRecorder.stopRecording(() {
        setState(() {
          _isRecording = NO_RECORD;
        });
      });

      /// on sauvegarde ce path local dans notre db
      storeAudioPath(localAudioPath, userReport);

      return true;
    }

    return false;
  }

  List<Widget> uploadFilesIcons(Report userReport) {
    return [
      uploadFilesIcon(userReport),
    ];
  }

  Widget uploadFilesIcon(Report userReport) {
    return IconButton(
      iconSize: ITEM_ICON_SIZE,
      icon: Icon(
        Icons.cloud_upload,
        size: BOTTOM_ICON_SIZE,
        color: Colors.pink,
      ),
      onPressed: () {},
    );
  }

  /// les icones de l'inventaire
  List<Widget> inventaireIcons(Report userReport, BuildContext context) {
    return [
      addItemIcon(userReport, context),
    ];
  }

  // l'icone nous permettant d'ajouter
  /// un item dans notre inventaire
  Widget addItemIcon(Report userReport, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.add,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        addItemActions(userReport, context);
      },
      color: Colors.blue,
    );
  }

  /// que faire quand on veut ajouter un
  /// item dans notre liste d'items
  void addItemActions(Report userReport, BuildContext context) {
    /// obtient le nom de l'objet
    Future<String> itemName = getItemName(context);

    /// une fois obtenu on veut faire les
    /// choses suivantes..
    processItemName(itemName, userReport);
  }

  /// on fait quoi avec l'input de l'user ?
  void processItemName(Future<String> itemName, Report userReport) {
    itemName.then((itemName) {
      /// si l'user a appuyé sur ANNULER
      /// lors de l'entrée du nom de l'objet
      /// on fé rien
      if (itemName == NO_USER_INPUT) {
        return cancelledItemCreation();
      }

      /// si l'user à rien écrit
      /// on l'informe qu'il faut écrire
      /// qqch, snackbar
      else if (itemName == EMPTY_USER_INPUT) {
        return typeSomethingDude();
      }

      /// si l'user à écrit quelque chose
      /// crée un objet portant ce nom
      else if (itemName.length > 0) {
        return createNewItem(itemName, userReport);
      } else {
        throw Error();
      }
    });
  }

  // l'icone nous permettant de prendre
  // une photo avec l'appareil photo
  Widget photoCameraIcon(
      Report userReport, int whatCapture, BuildContext context) {
    Function actions;

    if (whatCapture == PHOTO_AND_VIDEO) {
      actions = () {
        recordPhotoVideo(userReport, context);
      };
    } else if (whatCapture == PHOTO_ONLY) {
      actions = () {
        recordAndSavePhoto(userReport);
      };
    } else if (whatCapture == VIDEO_ONLY) {
      actions = () {
        recordAndSaveVideo(userReport);
      };
    }

    return IconButton(
      icon: Icon(
        Icons.photo_camera,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: actions,
      color: Colors.blue,
    );
  }

  recordPhotoVideo(Report userReport, BuildContext context) {
    Future<Choice> userChoice = getUserChoice(
      context,
      "Veux tu prendre une photo, ou une vidéo ?",
      [
        Choice("Une photo", PHOTO_FILE),
        Choice("Une vidéo", VIDEO_FILE),
      ],
    );

    fnForRecordChoice(userReport, userChoice);
  }

  void fnForRecordChoice(Report userReport, Future<Choice> futureChoice) {
    futureChoice.then((choice) {
      if (choice == NO_FUTURE_CHOICE) {
        noFileChoice();
      } else if (choice.choiceValue == PHOTO_FILE) {
        recordAndSavePhoto(userReport);
      } else if (choice.choiceValue == VIDEO_FILE) {
        recordAndSaveVideo(userReport);
      }
    });
  }

  // l'icone nous permettant de prendre
  // une photo dans la mémoire du téléphone
  Widget photoLibraryIcon(
      Report userReport, int whatCapture, BuildContext context) {
    Function actions;

    if (whatCapture == PHOTO_AND_VIDEO) {
      actions = () {
        localPhotoVideo(userReport, context);
      };
    } else if (whatCapture == PHOTO_ONLY) {
      actions = () {
        getLocalPhoto(userReport);
      };
    } else if (whatCapture == VIDEO_ONLY) {
      actions = () {
        getLocalVideo(userReport);
      };
    }

    return IconButton(
      icon: Icon(
        Icons.photo_library,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: actions,
      color: Colors.pink,
    );
  }

  localPhotoVideo(Report userReport, BuildContext context) {
    Future<Choice> userChoice = getUserChoice(
      context,
      "Veux tu prendre une photo, ou une vidéo ?",
      [
        Choice("Une photo", PHOTO_FILE),
        Choice("Une vidéo", VIDEO_FILE),
      ],
    );

    fnForLocalFileChoice(userReport, userChoice);
  }

  void fnForLocalFileChoice(Report userReport, Future<Choice> futureChoice) {
    futureChoice.then((choice) {
      if (choice == NO_FUTURE_CHOICE) {
        return noFileChoice();
      } else if (choice.choiceValue == PHOTO_FILE) {
        return getLocalPhoto(userReport);
      } else if (choice.choiceValue == VIDEO_FILE) {
        return getLocalVideo(userReport);
      }
    });
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
        size: BOTTOM_ICON_SIZE,
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
    return centeredMsg(
      'assets/icon.png',
      "Veuillez patienter svp...",
      Colors.purple,
    );
  }

  /// affiche un message sur fond violet
  /// informant l'user qu'un problème est survenu
  /// lors du chargement des données utilisateur
  Widget errorMsg() {
    return centeredMsg(
      'assets/icon.png',
      "Oups il y a un problème lors du chargement des données utilisateur...",
      Colors.green,
    );
  }

  // the whole screen
  Widget wholeScreen(BuildContext context, Report userReport, Widget panel) {
    return WillPopScope(
      onWillPop: () async {
        //await stopRecordActions();

        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,

        // la barre en haut
        appBar: getTopBar(_displayMode, userReport, context),

        // la barre d'icones en bas de l'écran
        // (photo, microphone, text, etc...)
        bottomNavigationBar: getBottomBar(userReport, context),

        // la zone contenant photo, texte, émojis, etc...
        body: panel,
      ),
    );
  }

  /// obtient un string de l'user
  Future<String> getItemName(BuildContext context) {
    String title = "Comment s'appelle l'objet ?";
    String subtitle = "Nom de l'objet";
    String hint = "Un tournevis...";

    return getUserInput(context, title, subtitle, hint);
  }

  /// affiche snackbar informant user qu'il
  /// faut écrire qqchose
  void typeSomethingDude() {
    String msg = "Donne un nom à cet item, s'il te plait.";
    int durationMsec = 2000;

    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  /// ajoute nouveau item dans liste items user,
  /// puis sauvegarde user data
  void createNewItem(String itemName, Report userReport) {
    /// ajoute item dans liste items
    userReport
        .getLatestBabyLessonSeen()
        .items
        .add(new Item(name: itemName, qty: 1));

    /// sauvegarde user data
    userReport.save();

    String msg = "Objet suivant crée: '" + itemName + "'";
    int durationMsec = 2000;

    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  ///
  void cancelledItemCreation() {
    String msg = "Création d'objet annulée.";
    int durationMsec = 2000;

    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  /// un objet qu'on peut supprimer de la liste
  /// en swipant
  Widget swipableItem(BuildContext context, int index, Report userReport) {
    return Dismissible(
      onDismissed: (DismissDirection direction) {
        afterSwipe(context, index, userReport);
      },
      child: itemLayout(context, index, userReport),
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
    );
  }

  /// after wiping we do this to erase the item
  void afterSwipe(BuildContext context, int index, Report userReport) {
    // une fois swipé, on supprime l'item
    // situé à la position 'index', dans la liste de bébé leçons
    // items du bébé lecon
    userReport.getLatestBabyLessonSeen().items.removeAt(index);

    // puis on met à jour le Report
    userReport.save();

    /// informe l'user qu'un objet est supprimé
    String msg = "Objet supprimé avec succès !";
    int durationMsec = 2000;
    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  /// la bannière représentant un objet individuel
  /// avec 2 boutons + et - pour modifier la quantité
  /// de cet item.
  itemLayout(BuildContext context, int index, Report userReport) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      decoration: new BoxDecoration(
        color: Colors.orange,
        borderRadius: new BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Row(
        children: <Widget>[
          minusButton(context, index, userReport),
          qtyItem(context, index, userReport),
          itemName(context, index, userReport),
          plusButton(context, index, userReport),
        ],
      ),
    );
  }

  /// que faire qd on appuie sur -
  void minusButtonActions(BuildContext context, int index, Report userReport) {
    var item = userReport.getLatestBabyLessonSeen().items[index];

    /// si il reste qu'un item, informe l'user
    /// qu'il peut le supprimer en le swipant
    if (item.qty == 1) {
      String msg = "Pour supprimer un item, swipez le !";
      int durationMsec = 1000;

      displaySnackbar(_scaffoldKey, msg, durationMsec);
    }

    /// sinon, décremente la qté d'item
    else {
      String msg = "OK ! Un objet de moins.";
      int durationMsec = 1000;

      displaySnackbar(_scaffoldKey, msg, durationMsec);

      // on diminue la qté de cet item
      item.qty--;

      // puis on met à jour le Report
      userReport.save();
    }
  }

  /// le bouton -
  Widget minusButton(BuildContext context, int index, Report userReport) {
    // le bouton -
    return IconButton(
      iconSize: ITEM_ICON_SIZE,
      icon: Icon(
        Icons.remove,
        size: ITEM_ICON_SIZE,
        color: ITEM_ICON_COLOR,
      ),
      onPressed: () {
        minusButtonActions(context, index, userReport);
      },
    );
  }

  /// le nom de l'objet
  Widget itemName(BuildContext context, int index, Report userReport) {
    // le nom de l'item
    ///
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
          left: 10,
          //right: 10,
        ),
        child: Text(
          userReport.getLatestBabyLessonSeen().items[index].name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ITEM_ICON_SIZE,
            color: ITEM_ICON_COLOR,
          ),
        ),
      ),
    );
  }

  /// combien de cet item existe il ?
  Widget qtyItem(BuildContext context, int index, Report userReport) {
    return Container(
      child: Column(
        children: <Widget>[
          qtyDesc(),
          qtyNumber(userReport, index),
        ],
      ),
    );
  }

  /// Qté de l'objet
  Text qtyNumber(Report userReport, int index) {
    return Text(
      userReport.getLatestBabyLessonSeen().items[index].qty.toString(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: ITEM_ICON_SIZE,
        color: ITEM_ICON_COLOR,
      ),
    );
  }

  /// titre descriptif du chiffre dessous
  Text qtyDesc() {
    return Text(
      "Qté",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: ITEM_ICON_SIZE,
        color: ITEM_ICON_COLOR,
      ),
    );
  }

  /// le bouton +
  plusButton(BuildContext context, int index, Report userReport) {
    return IconButton(
      iconSize: ITEM_ICON_SIZE,
      icon: Icon(
        Icons.add,
        size: ITEM_ICON_SIZE,
        color: ITEM_ICON_COLOR,
      ),
      onPressed: () {
        plusButtonActions(context, index, userReport);
      },
    );
  }

  /// que faire qd on appuie sur +
  void plusButtonActions(BuildContext context, int index, Report userReport) {
    String msg = "OK ! Un objet de plus.";
    int durationMsec = 1000;
    Item item = userReport.getLatestBabyLessonSeen().items[index];

    displaySnackbar(_scaffoldKey, msg, durationMsec);

    // on diminue la qté de cet item
    item.qty++;

    // puis on met à jour le Report
    userReport.save();
  }

  /// String int Report => void
  ///
  /// Stocke le path local d'une photo/vidéo,
  /// dans la db
  void storePhotoVideoPath(String filePath, int fileType, Report userReport) {
    /// get the current step data
    var step = userReport.getLatestBabyLessonSeen().getCurrentStep();

    /// store new paths
    step.photoVideoFilePath = filePath;
    step.fileType = _fileType;

    /// save data
    userReport.save();
  }

  /// String Report => void
  ///
  /// Stocke le path local d'un message audio,
  /// dans la db
  void storeAudioPath(String newfilePath, Report userReport) {
    /// get the current step data
    var step = userReport.getLatestBabyLessonSeen().getCurrentStep();

    /// store new paths
    step.audioFilePath = newfilePath;

    /// save data
    userReport.save();
  }

  void resetState(int indexEtape) {
    print("reset step state to beginning");

    setState(() {
      _photoVideoFile = NO_DATA;
      _fileType = NO_DATA;
      _photoSize = NORMAL_SIZE;
      sousEtape = indexEtape;
      _isRecording = NO_RECORD;
      audioRecorder.recording = NO_DATA;
      _playerState = STOPPED;
      audioPlayer.stop(() {});
      audioRecorder.stopRecording(() {});
    });
  }

  void noStepChoice(Choice choice) {
    var msg = "On reste ici !";
    var durationMsec = 2500;

    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  /// Choice Report => void
  ///
  /// soit on va vers une étape particulière,
  /// soit on change le mode de visionnage des étapes
  void handleStepChoice(Choice choice, Report userReport) {
    var choiceValue = choice.choiceValue;

    /// si on veut créer/modifier nos étapes
    if (choiceValue == STEP_CREATION) {
      setState(() {
        _displayMode = STEP_CREATION;
      });
    }

    /// si on veut visionner l'étape
    else if (choiceValue == STEP_VIEWER) {
      setState(() {
        _displayMode = STEP_VIEWER;
      });
    }

    /// autrement on va à une étape particulière
    else {
      var bblesson = userReport.getLatestBabyLessonSeen();
      bblesson.currentStep = choice.choiceValue;

      resetState(PRENDRE_PHOTO_VIDEO);

      userReport.save();
    }
  }

  /// Report BuildContext => void
  ///
  /// quand on appuie sur la poubelle,
  /// on veut supprimer l'étape en cours de création
  /// parmi la liste d'étapes du bébé leçon,
  /// ainsi que le contenu photo/video et audio
  /// associé
  Future<void> supprimeEtapeActions(
      Report userReport, BuildContext context) async {
    /// les étapes de la lecon
    /// et l'index de l'étape a supprimer
    var babyLesson = userReport.getLatestBabyLessonSeen();
    var steps = babyLesson.steps;
    int currentStep = babyLesson.currentStep;

    /// combien d'étapes existe t'il ?
    var qtySteps = steps.length;

    /// si il y a plus d'une étape
    /// on supprime l'etape actuelle
    if (qtySteps > 1) {
      if (sousEtape == MSG_AUDIO) {
        /// arrête les éventuels enregistrements 
        /// audio ou lecture audio
        /// en cours
        stopRecordingAndSave(userReport);
        audioPlayer.stop(() {
          setState(() {
            _playerState = STOPPED;
          });
        });
      }

      /// supprime le contenu photo/video/audio
      /// local de l'étape
      LessonStep step = babyLesson.getCurrentStep();
      var photoVideoPath = step.photoVideoFilePath;
      var audioPath = step.audioFilePath;

      await fileManager.deleteFile(photoVideoPath, NO_DATA, () {});
      await fileManager.deleteFile(audioPath, NO_DATA, () {});

      /// supprime l'étape
      steps.removeAt(currentStep);

      /// l'étape actuelle est la toute dernière étape
      babyLesson.currentStep = steps.length - 1;

      userReport.save();

      resetState(PRENDRE_PHOTO_VIDEO);

      displaySnackbar(_scaffoldKey, "Etape supprimée !", 2500);
    }

    /// sinon on indique a l'user qu'il peut supprimer
    /// cette leçon en la swipant
    else {
      displaySnackbar(
        _scaffoldKey,
        "Pour supprimer le bébé leçon, swipe le horizontalement dans le menu de bébé leçons",
        3500,
      );
    }
  }

  void noOutcomeChoice() {
    displaySnackbar(_scaffoldKey, "On reste ici pour l'instant !", 2500);
  }

  void etapSuivChoice(Report userReport) {
    var lesson = userReport.getLatestBabyLessonSeen();
    var steps = lesson.steps;
    var qtySteps = steps.length;
    var currentStep = lesson.currentStep;
    var lastStepIndex = qtySteps - 1;

    /// si nous sommes a la derniére étape de la liste d'étapes
    /// on ajoute une nouvelle étape
    if (currentStep == lastStepIndex) {
      /// ajoute l'étape à la fin de la liste d'étapes
      steps.add(new LessonStep());
    } else {
      /// on ajoute l'étape right after l'étape actuelle
      var index = currentStep + 1;

      /// on veut ajouter notre item aprés l'item actuel
      steps.insert(index, new LessonStep());
    }

    lesson.currentStep++;

    userReport.save();

    resetState(PRENDRE_PHOTO_VIDEO);
  }

  void finLeconChoice(Report userReport) {
    resetState(PREND_THUMBNAIL_PHOTO);
  }

  void noFileChoice() {
    displaySnackbar(_scaffoldKey, "On ne prend pas de photo/vidéo.", 2500);
  }

  /// Report bool => void
  ///
  /// prend une photo, stocke la dans le state,
  /// stocke la dans le dossier
  /// local des données de l'appli,
  /// et sauvegarde le path local de cette photo
  /// et supprime la photo précédemment prise, si path existant
  /// 2nd parametre optionnel, si true, pick from gallery
  recordAndSavePhoto(Report userReport, [bool pickOnGallery]) async {
    /// prend une photo,
    /// stocke la photo dans le state,
    /// et obtient  cette photo en tant que fichier
    File photoFile = await photoVideoRecorder.takePhoto((File photo) {
      setState(() {
        _photoVideoFile = photo;
        _fileType = PHOTO_FILE;
      });
    }, pickOnGallery);

    /// si une photo a été prise
    /// on la sauvegarde localement,
    /// et on sauvegarde les infos relatives a son emplacement
    /// et type (photo) dans notre base de données
    if (photoFile != NO_DATA) {
      /// l'étape actuelle
      LessonStep currentStep =
          userReport.getLatestBabyLessonSeen().getCurrentStep();

      /// le path du dossier appli
      Directory dir = await getExternalStorageDirectory();
      String dirPath = dir.path;

      /// le path de la photo précédemment prise,
      /// pour pouvoir éventuellement la supprimer
      String previousPhotoFilePath = currentStep.photoVideoFilePath;

      /// now in milliseconds
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      /// sauvegarde la photo prise
      /// dans le dossier appli,
      /// et obtient le path
      String localPhotoPath =
          await fileManager.saveFile(photoFile, dirPath, fileName, () {});

      /// supprime la photo prise précedemment, si existante
      bool deleted;

      if (previousPhotoFilePath != NO_DATA) {
        deleted =
            await fileManager.deleteFile(previousPhotoFilePath, NO_DATA, () {});
      }

      /// sauvegarde le path
      storePhotoVideoPath(localPhotoPath, _fileType, userReport);

      print("previous photo (if any): $previousPhotoFilePath");
      print("app folder path: $dirPath");
      print("local file path 2nd time: $localPhotoPath");
      print("deletion boolean: $deleted");
    }
  }

  /// Report bool => void
  ///
  /// prend une video, stocke la dans le state,
  /// stocke la dans le dossier
  /// local des données de l'appli,
  /// sauvegarde le path local de cette video,
  /// et supprime la video précédemment prise, si path existant
  /// 2nd parametre optionnel, si true, pick from gallery
  recordAndSaveVideo(Report userReport, [bool pickFromGallery]) async {
    /// prend une vidéo,
    /// stocke la vidéo dans le state,
    /// et obtient  cette vidéo en tant que fichier
    File videoFile = await photoVideoRecorder.takeVideo((File video) {
      setState(() {
        _photoVideoFile = video;
        _fileType = VIDEO_FILE;
      });
    }, pickFromGallery);

    /// si une vidéo a été prise
    /// on la sauvegarde localement,
    /// et on sauvegarde les infos relatives a son emplacement
    /// et type (video) dans notre base de données
    if (videoFile != NO_DATA) {
      /// l'étape actuelle
      LessonStep currentStep =
          userReport.getLatestBabyLessonSeen().getCurrentStep();

      /// le path du dossier appli
      Directory dir = await getExternalStorageDirectory();
      String dirPath = dir.path;

      /// le path de la vidéo précédemment prise,
      /// pour pouvoir éventuellement la supprimer
      String previousVideoFilePath = currentStep.photoVideoFilePath;

      /// now in milliseconds
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      /// sauvegarde la video prise
      /// dans le dossier appli,
      /// et obtient le path
      String localVideoPath =
          await fileManager.saveFile(videoFile, dirPath, fileName, () {});

      /// supprime la vidéo prise précedemment, si existante
      bool deleted;

      if (previousVideoFilePath != NO_DATA) {
        deleted =
            await fileManager.deleteFile(previousVideoFilePath, NO_DATA, () {});
      }

      /// sauvegarde le path
      storePhotoVideoPath(localVideoPath, _fileType, userReport);

      print("previous vidéo (if any): $previousVideoFilePath");
      print("app folder path: $dirPath");
      print("local file path 2nd time: $localVideoPath");
      print("deletion boolean: $deleted");
    }
  }

  void getLocalPhoto(Report userReport) {
    recordAndSavePhoto(userReport, true);
  }

  void getLocalVideo(Report userReport) {
    recordAndSaveVideo(userReport, true);
  }

  Widget noFilesUploaded() {
    return centeredMsg(
      "assets/icon.png",
      "Appuie sur le nuage pour lancer l'upload.",
      Colors.purpleAccent,
    );
  }

  Widget upInProgress() {
    return centeredMsg(
      "assets/icon.png",
      "Upload en cours...",
      Colors.pink,
    );
  }

  Widget upSuccess() {
    return centeredMsg(
      "assets/icon.png",
      "Upload réussi !",
      Colors.purpleAccent,
    );
  }

  Widget upFail() {
    return centeredMsg(
      "assets/icon.png",
      "Echec de l'upload. Appuie sur le nuage pour réessayer.",
      Colors.purpleAccent,
    );
  }

  void uploadAlreadyGoingOn() {
    displaySnackbar(
        _scaffoldKey, "Un upload de fichier est déja en cours.", 2500);
  }

  /// Report BuildContext => List<Widget>
  ///
  /// affiche les icones du visionneur d'étapes
  List<Widget> substepIconsForStepViewer(
      Report userReport, BuildContext context) {
    return [
      playPauseIcon(userReport),
      restartAudioIcon(userReport),
    ];
  }

  /// Report => Widget
  ///
  /// Le contenu a afficher entre top et bottom bar,
  /// en mode visionnage d'étape
  Widget stepPanelForStepViewer(Report userReport) {
    return prendrePhotoVideoPanel(userReport,
        "Pas de photo dispo pour cette étape");
  }
}
