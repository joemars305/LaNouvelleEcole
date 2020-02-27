///
///
/// - ajoute étape text et émojis
/// avant étape upload photo.
/// on veut pouvoir ajouter texte ou émoji,
/// puis sauvegarder résultat local.
///
/// - ajouter 2 boutons étap préc et étap suiv
/// a la place des 2 flèches actuelles
///
/// - ajouter bouton terminer qui propose 2 choix.
///
/// - soit on supprime l'étape
///
/// - soit on termine la leçon

import 'dart:io';
import 'dart:ui';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
        return wholeScreen(userReport, panel);
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
  /// 1 pour TEXT_ET_EMOJI
  /// 2 pour MSG_AUDIO
  /// 3 pour INVENTAIRE
  /// 4 pour UPLOAD_PHOTO
  /// 5 pour UPLOAD_AUDIO
  int sousEtape = PRENDRE_PHOTO;

  /// FONCTION
  /*

  Widget fnForSousEtape() {
    if (sousEtape == PRENDRE_PHOTO) {
      return prendrePhoto();
    } 
    
    else if (sousEtape == MSG_AUDIO) {
      return msgAudio();
    } 
    
    else if (sousEtape == UPLOAD_PHOTO) {
      return txtOuEmoji();
    }

    else if (sousEtape == UPLOAD_AUDIO) {
      return enregistrer();
    }

    else if (sousEtape == INVENTAIRE) {
      return inventaire();
    }

    else {
      throw Error();
    }
  }
  
  Widget prendrePhoto() {

  }
  
  Widget msgAudio() {

  }
  
  Widget txtOuEmoji() {

  }

  Widget enregistrer() {

  }

  Widget inventaire() {

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
  
  Widget noRecording() {

  }

  Widget recording() {

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

  void ...() {

  }

  void ...() {

  }

  void ...() {

  }

  void ...() {

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

  Widget aaa() {

  }

  Widget aaa() {
    
  }

  Widget aaa() {
    
  }

  void bbb() {

  }

  void bbb() {
    
  }

  void bbb() {
    
  }
  
  */

  /// TXT_OU_EMOJI représente ce qu'on veut afficher
  /// sur la photo d'étape
  ///
  /// 0 pour DRAW_TEXT
  /// 1 pour DRAW_EMOJI
  //int _txtOuEmoji = DRAW_TEXT;

  /*
  Widget txtOuEmoji() {
    if (_txtOuEmoji == DRAW_TEXT) {
      return xxx();
    }

    else if (_txtOuEmoji == DRAW_EMOJI) {
      return yyy();
    }

    else {
      throw Error();
    }
  }
  */

  /// TEXTS_AND_EMOJIS représente le texte
  /// et les émojis qu'on veut ajouter
  /// sur notre photo pour expliquer des trucs
  ///
  /// [] pour NO_TEXTS_AND_EMOJIS
  /// List<Widget> autrement
  ///
  List<Widget> _textsAndEmojis = [];

  /*
  fn() {
    if (_textsAndEmojis == NO_TEXTS_AND_EMOJIS) {
      return aaa();
    }

    else {
      return bbb();
    }
  }
  */

  /// CREATE_UPLOAD représente si on demarre l'upload
  ///
  /// false pour DONT_CREATE_UP
  /// true pour CREATE_UP
  bool _createUpload = DONT_CREATE_UP;

  /*
  fnForStartUpload() {
    if (_createUpload == DONT_CREATE_UP) {
      return dontStartUp();
    }

    else if (_createUpload == CREATE_UP) {
      return startUp();
    }

    else {
      throw Error();
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
    if (sousEtape == PRENDRE_PHOTO) {
      return prendrePhotoPanel(
          userReport, "Appuie sur l'appareil photo pour prendre une photo.");
    } else if (sousEtape == MSG_AUDIO) {
      return msgAudioPanel(userReport);
    } else if (sousEtape == TEXT_EMOJI) {
      return txtEmojiPanel(userReport);
    } else if (sousEtape == UPLOAD_FILES) {
      return uploadFilesPanel(userReport);
    }  else if (sousEtape == INVENTAIRE) {
      return inventairePanel(userReport);
    } else {
      throw Error();
    }
  }

  /// permet de voir la photo qu'on a prise
  Widget prendrePhotoPanel(Report userReport, String msg) {

    return RepaintBoundary(
      key: _canvasKey,
      child: PhotoCanvas(
        photoFile: _imageFile,
        photoSize: _photoSize,
        textsAndEmojis: _textsAndEmojis,
        noPhotoText: msg,
        photoUrl:
            userReport.getLatestBabyLessonSeen().getCurrentStep().photoFileUrl,
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

    return prendrePhotoPanel(userReport, msg);
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

  ///
  Widget uploadFilesPanel(Report userReport) {
    return Uploader(
      files: [
        _imageFile, 
        File(_recording.path)
      ],
      userReport: userReport,
      uploadMsgs: [
        "Upload de photo en cours...", 
        "Upload de message audio en cours..."
      ],
      onUploadsDone: [
        afterPhotoUploaded, 
        afterAudioUploaded
      ],
    );
  }



  afterAudioUploaded(String newFilePath, String fileUrl, Report userReport) {
    /// if there's an existing photo path,
    /// delete the photo at that path in firebase,
    /// and store the new path,
    ///
    /// otherwise just store the new path
    storeNewAudioFilePath(newFilePath, fileUrl, userReport);

    /// save the data
    //userReport.save();

    /// reset button so we
    /// can upload a new photo
    /*setState(() {
            _createUpload = DONT_CREATE_UP;
          });*/
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
    return Container(
      color: Colors.pink,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            itemIcon(),
            msg("Ajoute un objet dans ton inventaire en appuyant sur +"),
          ],
        ),
      ),
    );
  }

  /// une icone représentant un objet lambda
  Widget itemIcon() {
    return Image.asset(
      'assets/wrench.png',
      width: 45,
      height: 45,
      fit: BoxFit.contain,
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
      onPressed: () async {
        await nextButtonAction();
      },
    );
  }

  /// les actions a effectuer pour passer
  /// d'une substep à un autre
  Future<void> nextButtonAction() async {
    /// qd on est a la derniere etape
    if (sousEtape == UPLOAD_FILES) {

    }
    /// qd on est à la sous étape 3,
    /// et qu'on veut passer à la sous étape 4,
    else if (sousEtape == TEXT_EMOJI) {
      /// - si les 3 premières sous 
      ///   étapes ont été remplies, 
      ///   on sauvegarde le contenu 
      ///   d u canvas photo
      if (photoStepComplete() && 
          msgAudioStepComplete() &&
          textStepComplete()) {
        
        await savePhotoCanvas();

        incrementSubstep();
      }
      /// - sinon on informe user qu'il doit remplir les 
      ///   3 premières sous étapes avant de continuer
      else {
        userDoUrJob();        
      }
    } 
    /// sinon on passe a l'étape suivante
    else {
      incrementSubstep();
    }

    
  }

  void userDoUrJob() {
    String msg =
        "Avant de pouvoir continuer, il faut prendre une photo, ajouter du texte et/ou émoji dessus, et enregistrer un message audio.";
    
    int durationMsec = 7000;
    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  savePhotoCanvas() async {
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
      _imageFile = imgFile;
      _textsAndEmojis = NO_TEXTS_AND_EMOJIS;
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
    /// a la sous étape photo, qd
    /// on veut retourner en arriere,
    if (sousEtape == PRENDRE_PHOTO) {
      return;
    }

    /// a la sous étape text et emoji 
    /// ou supérieur, qd
    /// on veut retourner en arriere,
    /// on reset le state, 
    /// on veut une page vierge
    else if (sousEtape >= TEXT_EMOJI) {
      resetState();
    }

    else {
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
    if (sousEtape == PRENDRE_PHOTO) {
      return prendrePhotoIcons();
    } else if (sousEtape == MSG_AUDIO) {
      return msgAudioIcons(userReport);
    } else if (sousEtape == UPLOAD_FILES) {
      return uploadPhotoIcons();
    } else if (sousEtape == TEXT_EMOJI) {
      return txtEmojiIcons(userReport);
    } else if (sousEtape == INVENTAIRE) {
      return inventaireIcons(userReport);
    } else {
      throw Error();
    }
  }

  /// les icones de l'étape photo
  List<Widget> prendrePhotoIcons() {
    return [
      photoCameraIcon(),
      photoLibraryIcon(),
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
    ];
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

  /// les icones pour ajouter texte / émoji
  List<Widget> uploadPhotoIcons() {
    return [
      uploadPhotoIcon(),
    ];
  }

  List<Widget> uploadAudioIcons() {
    return [
      uploadAudioIcon(),
    ];
  }

  /// on peut ajouter text ou emoji
  Widget uploadAudioIcon() {
    return IconButton(
      iconSize: ITEM_ICON_SIZE,
      icon: Icon(
        Icons.cloud_upload,
        size: BOTTOM_ICON_SIZE,
        color: Colors.pink,
      ),
      onPressed: uploadAudioActions,
    );
  }

  /// que faire qd on veut uploader une photo
  /// dans le cloud Firebase
  uploadAudioActions() {
    /// si aucun upload n'a été démarré
    if (_createUpload == DONT_CREATE_UP) {
      /// démarre l'upload
      setState(() {
        _createUpload = CREATE_UP;
      });
    }

    /// si un upload est déja en cours
    else if (_createUpload == CREATE_UP) {
      /// informe l'user que du boulot a déja lieu
      int durationMsec = 2000;
      String msg = "Un upload de photo est déja en cours.";
      displaySnackbar(_scaffoldKey, msg, durationMsec);
    } else {
      throw Error();
    }
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
          _imageFile = selected;
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
  Widget photoCameraIcon() {
    return IconButton(
      icon: Icon(
        Icons.photo_camera,
        size: BOTTOM_ICON_SIZE,
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
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () => _pickImage(ImageSource.gallery),
      color: Colors.pink,
    );
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

  // the whole screen
  Widget wholeScreen(Report userReport, Widget panel) {
    return WillPopScope(
      onWillPop: () async {
        // You can do some work here.
        // Returning true allows the pop to happen, returning false prevents it.
        await stopRecordActions();

        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,

        // la barre en haut
        appBar: getTopBar(userReport),

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

  /// on peut ajouter text ou emoji
  Widget uploadPhotoIcon() {
    return IconButton(
      iconSize: ITEM_ICON_SIZE,
      icon: Icon(
        Icons.cloud_upload,
        size: BOTTOM_ICON_SIZE,
        color: Colors.pink,
      ),
      onPressed: uploadPhotoActions,
    );
  }

  /// que faire qd on veut uploader une photo
  /// dans le cloud Firebase
  uploadPhotoActions() {
    /// si aucun upload n'a été démarré
    if (_createUpload == DONT_CREATE_UP) {
      /// démarre l'upload
      setState(() {
        _createUpload = CREATE_UP;
      });
    }

    /// si un upload est déja en cours
    else if (_createUpload == CREATE_UP) {
      /// informe l'user que du boulot a déja lieu
      int durationMsec = 2000;
      String msg = "Un upload de photo est déja en cours.";
      displaySnackbar(_scaffoldKey, msg, durationMsec);
    } else {
      throw Error();
    }
  }

  /// ajoutons du texte
  void addTextActions() {
    /// essayons d'obtenir un texte venant de l'user
    String title = "Ecris ton texte.";
    String subtitle = "Ajoute texte ci-dessous";
    String hint = "Pipi caca etc...";

    Future<String> userInput = getUserInput(
      context,
      title,
      subtitle,
      hint,
    );

    handleFutureText(userInput);
  }

  /// une fois l'input user reçu,
  /// faisons qqch avec
  void handleFutureText(Future<String> userInput) {
    userInput.then((userInput) {
      ///
      if (userInput == NO_USER_INPUT) {
        return noText();
      } else if (userInput == EMPTY_USER_INPUT) {
        return emptyText();
      } else if (userInput.length > 0) {
        return handleText(userInput);
      } else {
        throw Error();
      }
    });
  }


  void noText() {
    String msg = "Creation de texte annulée.";
    int durationMsec = 2000;

    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  void emptyText() {
    String msg = "Ecris du texte, s'il te plait.";
    int durationMsec = 2000;

    displaySnackbar(_scaffoldKey, msg, durationMsec);
  }

  /// que fait on avec le texte obtenu
  void handleText(String userInput) {
    /// on crée un dragbox
    Offset initPos = Offset(250.0, 250.0);
    String label = userInput;
    double fontSize = 25;
    Color outsideColor = Colors.red;
    Color insideColor = Colors.white;

    DragBox draggableText = new DragBox(
      initPos,
      label,
      fontSize,
      outsideColor,
      insideColor,
    );

    /// on l'ajoute à la liste de text and drag
    setState(() {
      _textsAndEmojis.add(draggableText);
    });
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
    var oldfilePath =
        userReport.getLatestBabyLessonSeen().getCurrentStep().photoFilePath;

    if (oldfilePath == NO_PHOTO_PATH) {
      storePhotoPath(newfilePath, fileUrl, userReport);
    } else if (oldfilePath.length > 0) {
      await deleteFile(oldfilePath);
      storePhotoPath(newfilePath, fileUrl, userReport);
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

  void storePhotoPath(String newfilePath, String fileUrl, Report userReport) {
    /// get the current step data
    var step = userReport.getLatestBabyLessonSeen().getCurrentStep();

    /// store new paths
    step.photoFilePath = newfilePath;
    step.photoFileUrl = fileUrl;

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

  void resetState() {
    print("reset step state to beginning");

    setState(() {
      _imageFile = NO_PHOTO;
      _photoSize = NORMAL_SIZE;
      sousEtape = PRENDRE_PHOTO;
      _isRecording = NO_RECORD;
      _recording = NO_AUDIO_FILE;
      _playerState = STOPPED;
      //_txtOuEmoji = DRAW_TEXT;
      _textsAndEmojis = [];
      _createUpload = DONT_CREATE_UP;
    });
  }

  String recordingPathOrUrl(Report userReport) {
    if (_recording != NO_AUDIO_FILE /*&& _recording.path != null*/) {
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

  Widget txtEmojiPanel(Report userReport) {
    return prendrePhotoPanel(
        userReport, "Appuie sur + pour ajouter du texte/émoji");
  }

  List<Widget> txtEmojiIcons(Report userReport) {
    return [
      addTxtOrEmojiIcon(userReport),
    ];
  }

  addTxtOrEmojiIcon(Report userReport) {
    return IconButton(
      iconSize: ITEM_ICON_SIZE,
      icon: Icon(
        Icons.add,
        size: BOTTOM_ICON_SIZE,
        color: Colors.pink,
      ),
      onPressed: addTextActions,
    );
  }

  bool photoStepComplete() {
    return _imageFile != NO_PHOTO;
  }

  bool msgAudioStepComplete() {
    return _recording != NO_AUDIO_FILE;
  }

  bool textStepComplete() {
    return _textsAndEmojis.length > 0;
  }
}
