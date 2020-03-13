/// - implémente un upload de photo video via cloudfare, ou autre CDN
///
/// - Dans la liste de choix de Etape .. (../..),
/// ajoute un choix permettant de passer au meme écran que lesson_viewer,
/// et back and forth
///
/// - Ajoute une icone Boussole, a coté de Favoris.
/// ce panneau est constitué de 2 panneau swipable left right:
///
/// - un panneau Agenda, affichant une liste des 'choses a faire',
/// pour chaque jour, nous permettant de créer/modifier/annuler
/// des 'choses a faire' a un moment donné, a un jour donné.
///
/// - un panneau Carte, qui affiche une carte Google Maps
/// centrée sur la position actuelle, et possibilité de rajouter des
/// des marqueurs avec un nom et un type.
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
import 'dart:io';
import 'dart:ui';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quizapp/parts/cloudinary_api.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';
import 'package:quizapp/shared/photo_canvas.dart';
import 'package:file/local.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../parts/consts.dart';
import '../parts/parts.dart';

/// Widget to capture and crop the image
class StepCreation extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  StepCreation({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  createState() => _StepCreationState();
}

class _StepCreationState extends State<StepCreation>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    /// l'event qui remet a zero le state du player
    /// lorsque un fichier audio vient d'etre joué jusqu'a la fin
    setCompletionEvent();

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
          panel = substepPanel(userReport);
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

  /// permet de créer une jolie amimation de countdown
  /// lors de l'enregistrement audio
  AnimationController controller;

  /// nous permet d'afficher des snackbar
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// nous permet de sauvegarder la zone photo
  final _canvasKey = GlobalKey();

  /// nous permet d'uploader nos fichiers
  final fileUploader = FileUploader();

  /// convertit le temps restant
  /// de l'enregistrement audio (Duration) en cours,
  /// en format mm:ss (string)
  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  /// initialise le controller
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: DUREE_MSG_AUDIO),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.stop();
    audioPlayer.dispose();
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

  /// RECORDING représente le message audio
  ///
  /// null pour NO_AUDIO_FILE
  /// new Recording(...) pour AUDIO_FILE
  Recording _recording = NO_AUDIO_FILE;

  /*
  
  void ...() {
    if (_recording == NO_AUDIO_FILE) {
      return ...();
    }

    else {
      return ...();
    }
  }

  */

  /// le lecteur audio
  AudioPlayer audioPlayer = AudioPlayer();

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
  

  /// nous permet de supprimer une photo
  /// stockée dans firebase storage
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: storageBucketUri);

  /// l'event qui remet a zero le state du player
  /// lorsque un fichier audio vient d'etre joué jusqu'a la fin
  void setCompletionEvent() {
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        _playerState = STOPPED;
      });
    });
  }

  /// quel contenu doit on afficher entre la top bar et
  /// la bottom bar
  Widget substepPanel(Report userReport) {
    if (sousEtape == PRENDRE_PHOTO_VIDEO) {
      return prendrePhotoVideoPanel(userReport,
          "Appuie sur l'appareil photo pour prendre une photo/vidéo.");
    } else if (sousEtape == MSG_AUDIO) {
      return msgAudioPanel(userReport);
    } else if (sousEtape == UPLOAD_FILES) {
      return uploadFilesPanel(userReport);
    } else if (sousEtape == INVENTAIRE) {
      return inventairePanel(userReport);
    } else if (sousEtape == FIN_LECON) {
      return finLeconPanel(userReport);
    } else if (sousEtape == PREND_THUMBNAIL_PHOTO) {
      return prendThumbnailPanel(userReport);
    } else if (sousEtape == COMPLETE_INVENTORY) {
      return completeInventoryPanel(userReport);
    } else if (sousEtape == UPLOAD_THUMBNAIL) {
      return uploadThumbPanel(userReport);
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
    if (_recording == NO_AUDIO_FILE) {
      return "Appuie sur le micro pour enregistrer un message audio.";
    } else {
      return "Appuie sur l'icone play pour écouter le message audio.";
    }
  }

  /// enregistrement, donc countdown
  Widget recordingAudioPanel() {
    return circularCountdown();
  }

  /// une compte à rebours circulaire
  Widget circularCountdown() {
    return Container(
      color: Colors.orange,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            bigCircleAndText(),
          ],
        ),
      ),
    );
  }

  /// le gros cercle et le texte
  Widget bigCircleAndText() {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.center,
        child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: <Widget>[
                bigCircle(),
                txtInsideBigCircle(),
              ],
            )),
      ),
    );
  }

  /// le gros cercle
  Widget bigCircle() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          /// arrete l'enregistrement audio si l'animation est finie
          stopRecordWhenNecessary();
          return new CustomPaint(
            painter: TimerPainter(
              color: Colors.pink,
              backgroundColor: Colors.white,
              animation: controller,
            ),
          );
        },
      ),
    );
  }

  /// arrete l'enregistrement audio si l'animation est finie
  void stopRecordWhenNecessary() {
    if (controller.value == END_ANIM) {
      endAnim();
    }
  }

  /// arrete l'enregistrement audio en cours
  void endAnim() {
    if (_isRecording) {
      stopRecordActions();
    }
  }

  /// le texte dans le gros cercle
  Widget txtInsideBigCircle() {
    return Align(
      alignment: FractionalOffset.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Vas-y, parle...',
          ),

          /// le compte a rebours numérique (mm:ss)
          AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget child) {
              return new Text(
                timerString,
                style: TextStyle(
                  fontSize: 45,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget uploadFilesPanel(Report userReport) {
    if (photoVideoUploadStatus == NOT_UPLOADED) {
      return noUp();
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

  afterAudioUploaded(String newFilePath, String fileUrl, Report userReport) {
    /// if there's an existing photo path,
    /// delete the photo at that path in firebase,
    /// and store the new path,
    ///
    /// otherwise just store the new path
    storeNewAudioFilePath(newFilePath, fileUrl, userReport);
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

  /// la barre en haut de l'écran
  Widget getTopBar(Report userReport, BuildContext context) {
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
      //LessonStep currentStep = lesson.getCurrentStep();
      //int substepIndex = currentStep.currentSubstep + 1;

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
      leading: backButton(),
      title: titleNavigation(title, userReport),
      actions: <Widget>[
        delButton(userReport, context),
        nextButton(userReport),
      ],
    );
  }

  Widget titleNavigation(String title, Report userReport) {
    return new GestureDetector(
      onTap: () {
        goToStepActions(userReport);
      },
      child: new Text(title),
    );
  }

  void goToStepActions(Report userReport) {
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

    return steps
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
  Widget nextButton(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.arrow_forward,
      ),
      onPressed: () async {
        await nextButtonAction(userReport);
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
        await supprimeEtapeActions(userReport, context);
      } else if (choice.choiceValue == REMET_A_ZERO_ETAPE) {
        remetAZeroEtapeActions(userReport);
      } else {
        throw Error();
      }
    });
  }

  /// les actions a effectuer pour passer
  /// d'une substep à un autre
  Future<void> nextButtonAction(Report userReport) async {
    if (sousEtape < lastStep) {
      if (sousEtape == UPLOAD_FILES) {
        nextStepOrLessonOver(userReport);
      } else if (sousEtape == PREND_THUMBNAIL_PHOTO) {
        await uglifyPhotoFile();
        incrementSubstep();
      } else {
        incrementSubstep();
      }
    }
  }

  void nextStepOrLessonOver(Report userReport) {
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

  uglifyPhotoFile() async {
    RenderRepaintBoundary boundary =
        _canvasKey.currentContext.findRenderObject();

    /// convertit image canvas en list de bytes png
    var image = await boundary.toImage();
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();

    /// ceci est un path unique pour une photo d'étape modifiée
    var tempDir = (await getTemporaryDirectory()).path;
    var fullImgPath = '$tempDir/photo_canvas.png';

    /// supprime photo préexistante au cas ou
    var fileExists = await File(fullImgPath).exists();

    if (fileExists) {
      await File(fullImgPath).delete();
    }

    /// sauvegarde list bytes png
    /// dans le File situé au path unique
    var imgFile = new File(fullImgPath);
    imgFile.writeAsBytes(pngBytes);

    /// sauvegarde cette nouvelle photo
    /// et vide panier de texte et emoji
    setState(() {
      _photoVideoFile = imgFile;
    });
  }

  void incrementSubstep() {
    return setState(() {
      sousEtape++;
    });
  }

  /// le bouton permettant
  /// de passer à la sous étape précédente
  Widget backButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
      ),
      onPressed: backButtonAction,
    );
  }

  /// les actions a effectuer pour passer
  /// a la sous étape précédente
  void backButtonAction() {
    if (sousEtape > PRENDRE_PHOTO_VIDEO) {
      decrementSubstep();
    }
  }

  void decrementSubstep() {
    return setState(() {
      sousEtape--;
    });
  }

  // la barre d'icones en bas de la photo
  Widget getBottomBar(Report userReport) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: substepIcons(userReport),
      ),
    );
  }

  /// les icones de la sous étape en cours
  List<Widget> substepIcons(Report userReport) {
    if (sousEtape == PRENDRE_PHOTO_VIDEO) {
      return prendrePhotoIcons();
    } else if (sousEtape == MSG_AUDIO) {
      return msgAudioIcons(userReport);
    } else if (sousEtape == UPLOAD_FILES) {
      return uploadFilesIcons();
    } else if (sousEtape == UPLOAD_THUMBNAIL) {
      return uploadThumbIcons(userReport);
    } else if (sousEtape == INVENTAIRE) {
      return inventaireIcons(userReport);
    } else if (sousEtape == PREND_THUMBNAIL_PHOTO) {
      return thumbnailIcons(userReport);
    } else if (sousEtape == COMPLETE_INVENTORY) {
      return completeInventaireIcons(userReport);
    } else {
      throw Error();
    }
  }

  /// les icones de l'étape photo
  List<Widget> prendrePhotoIcons() {
    return [
      photoCameraIcon(PHOTO_AND_VIDEO),
      photoLibraryIcon(PHOTO_AND_VIDEO),
      photoSizeIcon(),
    ];
  }

  /// les icones de l'étape message audio
  List<Widget> msgAudioIcons(Report userReport) {
    if (_isRecording == WE_RECORD) {
      return micIcon();
    } else {
      return micAndPlayIcons(userReport);
    }
  }

  /// si on enregistre de l'audio
  /// on veut juste l'icone micro
  List<Widget> micIcon() {
    return [
      recordIcon(),
    ];
  }

  /// si pas d'enregistrement audio en cours,
  /// on veut micro + play/pause
  List<Widget> micAndPlayIcons(Report userReport) {
    return [
      recordIcon(),
      playPauseIcon(userReport),
      restartAudioIcon(userReport),
    ];
  }

  /// l'icone qui joue un enregistrement audio
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
    await audioPlayer.stop();

    playIconActions(userReport);
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
        playIconActions(userReport);
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
      onPressed: pauseIconActions,
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
      onPressed: resumeIconActions,
      color: Colors.blue,
    );
  }

  /// les actions a effectuer pour play/pause/resume
  void pauseIconActions() async {
    await audioPlayer.pause();

    setState(() {
      _playerState = PAUSED;
    });
  }

  ///
  void playIconActions(Report userReport) async {
    var audioUrl =
        userReport.getLatestBabyLessonSeen().getCurrentStep().audioFileUrl;

    /// si il existe un fichier audio ou une url
    if (_recording != NO_AUDIO_FILE || audioUrl != NO_DATA) {
      await audioPlayer.play(
        recordingPathOrUrl(userReport),
        isLocal: localOrNot(userReport),
      );

      setState(() {
        _playerState = PLAYING;
      });
    }
  }

  void resumeIconActions() async {
    await audioPlayer.resume();

    setState(() {
      _playerState = PLAYING;
    });
  }

  /// la durée de l'enregistrement audio en cours
  ///
  Widget recordDuration() {
    if (_isRecording == NO_RECORD) {
      return nothing();
    } else if (_isRecording == WE_RECORD) {
      return secondsPassed();
    } else {
      throw Error();
    }
  }

  /// conteneur vide parce qu'on n'enregistre rien
  Widget nothing() {
    return Text('0:00');
  }

  Widget secondsPassed() {
    return Text('En cours...');
  }

  // l'icone nous permettant d'enregistrer
  /// un message audio
  Widget recordIcon() {
    if (_isRecording == NO_RECORD) {
      return letsRecordIcon();
    } else if (_isRecording == WE_RECORD) {
      return stopRecordIcon();
    } else {
      throw Error();
    }
  }

  // l'icone qui demarre un enregistrement audio
  Widget letsRecordIcon() {
    return IconButton(
      icon: Icon(
        Icons.mic,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: letsRecordActions,
      color: Colors.blue,
    );
  }

  /// l'icone qui arrete un enregistrement audio
  Widget stopRecordIcon() {
    return IconButton(
      icon: Icon(
        Icons.stop,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: stopRecordActions,
      color: Colors.blue,
    );
  }

  /// les actions pour demarrer un enregistrement
  void letsRecordActions() async {
    print('coucou');

    try {
      /// demande la permission à l'user de pouvoir
      /// utiliser son microphone, et son stockage
      await PermissionHandler().requestPermissions([
        PermissionGroup.microphone,
        PermissionGroup.storage,
      ]);

      /// si il n'y a pas d'enregistrement en cours
      if (!(await AudioRecorder.isRecording)) {
        print("start recording");

        /// démarre l'enregistrement audio
        await AudioRecorder.start();

        /// remet l'animation de countdown au début
        controller.reverse(from: BEGIN_ANIM);

        /// update le state pour qu'on
        /// puisse voir les changements a l'écran
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = WE_RECORD;
        });
      } else {
        print("No permissions, or we already are recording");
      }
    } catch (e) {
      print("oups..");
      print(e);
    }
  }

  /// les actions pour arreter un enregistrement
  Future stopRecordActions() async {
    try {
      /// si nous somme en train d'enregistrer
      /// un message audio..
      if (await AudioRecorder.isRecording) {
        /// arrete l'enregistrement audio
        var recording = await AudioRecorder.stop();
        print("Stop recording: ${recording.path}");

        /// affiche la taille du fichier audio en bytes (octets)
        File file = widget.localFileSystem.file(recording.path);
        print("  File length: ${await file.length()}");

        /// update le state
        setState(() {
          _recording = recording;
          _isRecording = NO_RECORD;
        });

        return NO_RECORD;
      } else {
        print('There is no recording to be stopped');
      }
    } catch (e) {
      print(e);
    }
  }

  List<Widget> uploadFilesIcons() {
    return [
      uploadFilesIcon(),
    ];
  }

  

  Widget uploadFilesIcon() {
    return IconButton(
      iconSize: ITEM_ICON_SIZE,
      icon: Icon(
        Icons.cloud_upload,
        size: BOTTOM_ICON_SIZE,
        color: Colors.pink,
      ),
      onPressed: uploadFilesActions,
    );
  }

  uploadFilesActions() {
    
  }

  /// les icones de l'inventaire
  List<Widget> inventaireIcons(Report userReport) {
    return [
      addItemIcon(userReport),
    ];
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      File selected = await ImagePicker.pickImage(source: source);

      if (selected != null) {
        setState(() {
          _photoVideoFile = selected;
          _fileType = PHOTO_FILE;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  /// Select an vidéo via gallery or camera
  Future<void> _pickVideo(ImageSource source) async {
    try {
      File selected = await ImagePicker.pickVideo(source: source);

      if (selected != null) {
        setState(() {
          _photoVideoFile = selected;
          _fileType = VIDEO_FILE;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // l'icone nous permettant d'ajouter
  /// un item dans notre inventaire
  Widget addItemIcon(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.add,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        addItemActions(userReport);
      },
      color: Colors.blue,
    );
  }

  /// que faire quand on veut ajouter un
  /// item dans notre liste d'items
  void addItemActions(Report userReport) {
    /// obtient le nom de l'objet
    Future<String> itemName = getItemName();

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
  Widget photoCameraIcon(int whatCapture) {
    Function actions;

    if (whatCapture == PHOTO_AND_VIDEO) {
      actions = recordPhotoVideo;
    } else if (whatCapture == PHOTO_ONLY) {
      actions = recordPhoto;
    } else if (whatCapture == VIDEO_ONLY) {
      actions = recordVideo;
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

  recordPhotoVideo() {
    Future<Choice> userChoice = getUserChoice(
      context,
      "Veux tu prendre une photo, ou une vidéo ?",
      [
        Choice("Une photo", PHOTO_FILE),
        Choice("Une vidéo", VIDEO_FILE),
      ],
    );

    fnForRecordChoice(userChoice);
  }

  void fnForRecordChoice(Future<Choice> futureChoice) {
    futureChoice.then((choice) {
      if (choice == NO_FUTURE_CHOICE) {
        return noFileChoice();
      } else if (choice.choiceValue == PHOTO_FILE) {
        return recordPhoto();
      } else if (choice.choiceValue == VIDEO_FILE) {
        return recordVideo();
      }
    });
  }

  // l'icone nous permettant de prendre
  // une photo dans la mémoire du téléphone
  Widget photoLibraryIcon(int whatCapture) {
    Function actions;

    if (whatCapture == PHOTO_AND_VIDEO) {
      actions = localPhotoVideo;
    } else if (whatCapture == PHOTO_ONLY) {
      actions = getLocalPhoto;
    } else if (whatCapture == VIDEO_ONLY) {
      actions = getLocalVideo;
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

  localPhotoVideo() {
    Future<Choice> userChoice = getUserChoice(
      context,
      "Veux tu prendre une photo, ou une vidéo ?",
      [
        Choice("Une photo", PHOTO_FILE),
        Choice("Une vidéo", VIDEO_FILE),
      ],
    );

    fnForLocalFileChoice(userChoice);
  }

  void fnForLocalFileChoice(Future<Choice> futureChoice) {
    futureChoice.then((choice) {
      if (choice == NO_FUTURE_CHOICE) {
        return noFileChoice();
      } else if (choice.choiceValue == PHOTO_FILE) {
        return getLocalPhoto();
      } else if (choice.choiceValue == VIDEO_FILE) {
        return getLocalVideo();
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
        await stopRecordActions();

        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,

        // la barre en haut
        appBar: getTopBar(userReport, context),

        // la barre d'icones en bas de l'écran
        // (photo, microphone, text, etc...)
        bottomNavigationBar: getBottomBar(userReport),

        // la zone contenant photo, texte, émojis, etc...
        body: panel,
      ),
    );
  }

  /// obtient un string de l'user
  Future<String> getItemName() {
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

  

  afterPhotoUploaded(String newFilePath, String fileUrl, Report userReport) {
    /// if there's an existing photo path,
    /// delete the photo at that path in firebase,
    /// and store the new path,
    ///
    /// otherwise just store the new path
    storeNewPhotoFilePath(newFilePath, fileUrl, userReport);

    /// save the data
    //userReport.save();

    /// reset button so we
    /// can upload a new photo
    /*setState(() {
                                                                                                                                                                                                                                                                                                                                                                                              _createUpload = DONT_CREATE_UP;
                                                                                                                                                                                                                                                                                                                                                                                            });*/
  }

  /// if there's an existing photo path,
  /// delete the photo at that path in firebase,
  /// and store the new path,
  ///
  /// otherwise just store the new path
  Future<void> storeNewPhotoFilePath(
      String newfilePath, String fileUrl, Report userReport) async {
    var oldfilePath = userReport
        .getLatestBabyLessonSeen()
        .getCurrentStep()
        .photoVideoFilePath;

    if (oldfilePath == NO_PHOTO_PATH) {
      storePhotoVideoPath(newfilePath, fileUrl, userReport);
    } else if (oldfilePath.length > 0) {
      await deleteFile(oldfilePath);
      storePhotoVideoPath(newfilePath, fileUrl, userReport);
    } else {
      throw Error();
    }
  }

  /// if there's an existing photo path,
  /// delete the photo at that path in firebase,
  /// and store the new path,
  ///
  /// otherwise just store the new path
  Future<void> storeNewAudioFilePath(
      String newfilePath, String fileUrl, Report userReport) async {
    var oldfilePath =
        userReport.getLatestBabyLessonSeen().getCurrentStep().audioFilePath;

    if (oldfilePath == NO_PHOTO_PATH) {
      storeAudioPath(newfilePath, fileUrl, userReport);
    } else if (oldfilePath.length > 0) {
      await deleteFile(oldfilePath);
      storeAudioPath(newfilePath, fileUrl, userReport);
    } else {
      throw Error();
    }
  }

  void storePhotoVideoPath(
      String newfilePath, String fileUrl, Report userReport) {
    /// get the current step data
    var step = userReport.getLatestBabyLessonSeen().getCurrentStep();

    /// store new paths
    step.photoVideoFilePath = newfilePath;
    step.photoVideoFileUrl = fileUrl;

    step.fileType = _fileType;

    print("file type during save: " + _fileType.toString());

    /// save data
    userReport.save();
  }

  void storeAudioPath(String newfilePath, String fileUrl, Report userReport) {
    /// get the current step data
    var step = userReport.getLatestBabyLessonSeen().getCurrentStep();

    /// store new paths
    step.audioFilePath = newfilePath;
    step.audioFileUrl = fileUrl;

    /// save data
    userReport.save();
  }

  /// supprime la photo stockée dans firebase storage
  deleteFile(String oldfilePath) async {
    await _storage.ref().child(oldfilePath).delete();
  }

  void resetState(int indexEtape) {
    print("reset step state to beginning");

    setState(() {
      _photoVideoFile = NO_PHOTO;
      _photoSize = NORMAL_SIZE;
      sousEtape = indexEtape;
      _isRecording = NO_RECORD;
      _recording = NO_AUDIO_FILE;
      _playerState = STOPPED;
    });
  }

  String recordingPathOrUrl(Report userReport) {
    if (_recording != NO_AUDIO_FILE) {
      return recordingPath();
    } else {
      return audioUrl(userReport);
    }
  }

  localOrNot(Report userReport) {
    if (_recording != NO_AUDIO_FILE) {
      return true;
    } else {
      return false;
    }
  }

  String recordingPath() {
    print("recording path: " + _recording.path);
    return _recording.path;
  }

  String audioUrl(Report userReport) {
    String audioUrl =
        userReport.getLatestBabyLessonSeen().getCurrentStep().audioFileUrl;

    print("audio url: " + audioUrl);
    return audioUrl;
  }

  bool photoStepComplete() {
    return _photoVideoFile != NO_PHOTO;
  }

  bool msgAudioStepComplete() {
    return _recording != NO_AUDIO_FILE;
  }

  void noStepChoice(Choice choice) {
    var msg = "On reste ici !";
    var durationMsec = 2500;

    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  void handleStepChoice(Choice choice, Report userReport) {
    var bblesson = userReport.getLatestBabyLessonSeen();
    bblesson.currentStep = choice.choiceValue;

    userReport.save();
  }

  Future<void> supprimeEtapeActions(
      Report userReport, BuildContext context) async {
    var babyLessonFaible = userReport.latestBabyLessonSeen;
    userReport.latestBabyLessonSeen--;

    await deleteLesson(userReport, babyLessonFaible);

    displaySnackbar(_scaffoldKey, "Bébé leçon supprimé.", 2500);

    Navigator.of(context).pop();
  }

  void remetAZeroEtapeActions(Report userReport) {
    resetState(PRENDRE_PHOTO_VIDEO);
  }

  void noOutcomeChoice() {
    displaySnackbar(_scaffoldKey, "On reste ici pour l'instant !", 2500);
  }

  void etapSuivChoice(Report userReport) {
    var lesson = userReport.getLatestBabyLessonSeen();

    lesson.currentStep++;
    lesson.steps.add(new LessonStep());

    userReport.save();

    resetState(PRENDRE_PHOTO_VIDEO);
  }

  void finLeconChoice(Report userReport) {
    resetState(PREND_THUMBNAIL_PHOTO);
  }

  Widget finLeconPanel(Report userReport) {
    return null;
  }

  Widget prendThumbnailPanel(Report userReport) {
    return RepaintBoundary(
      key: _canvasKey,
      child: PhotoVideoCanvas(
        file: _photoVideoFile,
        fileType: _fileType,
        photoSize: _photoSize,
        noFileText:
            "Appuie sur l'appareil photo pour prendre une photo d'identité de ton projet.  😎",
        fileUrl: NO_DATA,
      ),
    );
  }

  Widget completeInventoryPanel(Report userReport) {
    return inventairePanel(userReport);
  }

  List<Widget> thumbnailIcons(Report userReport) {
    return [
      photoCameraIcon(PHOTO_ONLY),
      photoLibraryIcon(PHOTO_ONLY),
      photoSizeIcon(),
    ];
  }

  List<Widget> completeInventaireIcons(Report userReport) {
    return inventaireIcons(userReport);
  }

  Widget uploadThumbPanel(Report userReport) {
    return Uploader(
      files: [_photoVideoFile],
      userReport: userReport,
      uploadMsgs: [
        "Upload de photo thumbnail en cours...",
      ],
      onUploadsDone: [afterThumbPhotoUploaded],
    );
  }

  List<Widget> uploadThumbIcons(Report userReport) {
    return [];
  }

  afterThumbPhotoUploaded(
      String newFilePath, String fileUrl, Report userReport) {
    /// sauvegarde paths thumbnail, sets baby lesson as mature,
    /// and store the baby lesson among lessons
    saveLesson(newFilePath, fileUrl, userReport);

    Navigator.of(context).pop();
  }

  Future<void> saveLesson(
      String newfilePath, String fileUrl, Report userReport) async {
    /// get the baby lesson to become adult
    var babyLesson = userReport.getLatestBabyLessonSeen();
    var oldfilePath = babyLesson.thumbnailPath;

    /// si il existe une thumbnail existante, supprime la
    if (oldfilePath != NO_DATA) {
      await deleteFile(oldfilePath);
    }

    /// store new paths
    storeThumbPaths(babyLesson, newfilePath, fileUrl);

    /// the lesson is ready to be displayed in the Lecons panel
    makeLessonMature(babyLesson);

    /// save the url of the user google icon
    saveUserIconUrl(babyLesson);

    print(userReport.toString());

    /// save data
    userReport.save();
  }

  void makeLessonMature(BabyLesson babyLesson) {
    babyLesson.isMature = MATURE;
  }

  void storeThumbPaths(
      BabyLesson babyLesson, String newfilePath, String fileUrl) {
    babyLesson.thumbnailPath = newfilePath;
    babyLesson.thumbnailUrl = fileUrl;
  }

  void saveUserIconUrl(BabyLesson babyLesson) {
    var user = Provider.of<FirebaseUser>(context);

    babyLesson.userIconUrl = user.photoUrl;
  }

  incrementIfThumbPhotoTaken() {
    if (_photoVideoFile == NO_PHOTO) {
      takeAThumbPlz();
    } else {
      incrementSubstep();
    }
  }

  void takeAThumbPlz() {
    displaySnackbar(
        _scaffoldKey,
        "Prend une photo représentant ta leçon, ou le produit final, stp...",
        2500);
  }

  
  void noFileChoice() {
    displaySnackbar(_scaffoldKey, "On ne prend pas de photo/vidéo.", 2500);
  }

  void recordPhoto() {
    _pickImage(ImageSource.camera);
  }

  void recordVideo() {
    _pickVideo(ImageSource.camera);
  }

  void getLocalPhoto() {
    _pickImage(ImageSource.gallery);
  }

  void getLocalVideo() {
    _pickVideo(ImageSource.gallery);
  }
}
