import 'dart:io';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';
import 'package:quizapp/shared/photo_canvas.dart';
import 'package:file/local.dart';
import 'package:audioplayers/audioplayers.dart';

/// Widget to capture and crop the image
class StepCreation extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  StepCreation({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  createState() => _StepCreationState();
}

class _StepCreationState extends State<StepCreation>
    with TickerProviderStateMixin {
  /// permet de créer une jolie amimation de countdown
  /// lors de l'enregistrement audio
  AnimationController controller;

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
  /// 1 pour MSG_AUDIO
  /// 2 pour INVENTAIRE
  /// 3 pour TEXTE_OU_EMOJI
  /// 4 pour ENREGISTRER
  int sous_etape = PRENDRE_PHOTO;

  /// FONCTION
  /*

  Widget fnForSousEtape() {
    if (sous_etape == PRENDRE_PHOTO) {
      return prendrePhoto();
    } 
    
    else if (sous_etape == MSG_AUDIO) {
      return msgAudio();
    } 
    
    else if (sous_etape == TEXTE_OU_EMOJI) {
      return txtOuEmoji();
    }

    else if (sous_etape == ENREGISTRER) {
      return enregistrer();
    }

    else if (sous_etape == INVENTAIRE) {
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
    if (sous_etape == PRENDRE_PHOTO) {
      return prendrePhotoPanel();
    } else if (sous_etape == MSG_AUDIO) {
      return msgAudioPanel();
    } else if (sous_etape == TEXTE_OU_EMOJI) {
      return txtOuEmojiPanel();
    } else if (sous_etape == ENREGISTRER) {
      return enregistrerPanel();
    } else if (sous_etape == INVENTAIRE) {
      return inventairePanel();
    } else {
      throw Error();
    }
  }

  /// permet de voir la photo qu'on a prise
  Widget prendrePhotoPanel() {
    return PhotoCanvas(photoFile: _imageFile, photoSize: _photoSize);
  }

  /// si on n'enregistre pas de message audio,
  /// on affiche prendrePhotoPanel(),
  /// sinon on affiche un compte à rebours
  /// en forme de cercle
  Widget msgAudioPanel() {
    if (_isRecording == NO_RECORD) {
      return noRecordingAudioPanel();
    } else if (_isRecording == WE_RECORD) {
      return recordingAudioPanel();
    } else {
      throw Error();
    }
  }

  /// pas d'enregistrement, donc photo
  Widget noRecordingAudioPanel() {
    return prendrePhotoPanel();
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

  Widget txtOuEmojiPanel() {}

  Widget enregistrerPanel() {}

  Widget inventairePanel() {}

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
          (sous_etape + 1).toString() +
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
      onPressed: nextButtonAction,
    );
  }

  /// les actions a effectuer pour passer
  /// d'une substep à un autre
  void nextButtonAction() {
    // on update le state
    setState(() {
      sous_etape++;
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
    if (sous_etape > PRENDRE_PHOTO) {
      // on update le state
      setState(() {
        sous_etape--;
      });
    }
  }

  // la barre d'icones en bas de la photo
  Widget getBottomBar() {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: substepIcons(),
      ),
    );
  }

  /// les icones de la sous étape en cours
  List<Widget> substepIcons() {
    if (sous_etape == PRENDRE_PHOTO) {
      return prendrePhotoIcons();
    } else if (sous_etape == MSG_AUDIO) {
      return msgAudioIcons();
    } else if (sous_etape == TEXTE_OU_EMOJI) {
      return txtOuEmojiIcons();
    } else if (sous_etape == ENREGISTRER) {
      return enregistrerIcons();
    } else if (sous_etape == INVENTAIRE) {
      return inventaireIcons();
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
  List<Widget> msgAudioIcons() {
    if (_isRecording == WE_RECORD) {
      return micIcon();
    } else {
      return micAndPlayIcons();
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
  List<Widget> micAndPlayIcons() {
    return [
      recordIcon(),
      playPauseIcon(),
    ];
  }

  /// l'icone qui joue/pause un enregistrement audio
  Widget playPauseIcon() {
    if (_playerState == STOPPED) {
      return playIcon();
    } else if (_playerState == PLAYING) {
      return pauseIcon();
    } else if (_playerState == PAUSED) {
      return resumeIcon();
    } else {
      throw Error();
    }
  }

  /// l'icone qui joue un enregistrement audio
  Widget playIcon() {
    return IconButton(
      icon: Icon(
        Icons.play_arrow,
        size: 30,
      ),
      onPressed: playIconActions,
      color: Colors.blue,
    );
  }

  /// l'icone qui met en pause un enregistrement audio
  Widget pauseIcon() {
    return IconButton(
      icon: Icon(
        Icons.pause,
        size: 30,
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
        size: 30,
      ),
      onPressed: resumeIconActions,
      color: Colors.blue,
    );
  }

  /// les actions a effectuer pour play/pause/resume
  void pauseIconActions() async {
    int result = await audioPlayer.pause();

    setState(() {
      _playerState = PAUSED;
    });
  }

  void playIconActions() async {
    if (_recording != NO_AUDIO_FILE) {
      int result = await audioPlayer.play(_recording.path, isLocal: true);

      setState(() {
        _playerState = PLAYING;
      });
    }
  }

  void resumeIconActions() async {
    int result = await audioPlayer.resume();

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

  /*void ...() {

  }

  void ...() {

  }*/

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
        size: 30,
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
        size: 30,
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
      Map<PermissionGroup, PermissionStatus> permissions =
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

  List<Widget> txtOuEmojiIcons() {}

  List<Widget> enregistrerIcons() {}

  List<Widget> inventaireIcons() {}

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
        // la barre en haut
        appBar: getTopBar(userReport),

        // la barre d'icones en bas de l'écran
        // (photo, microphone, text, etc...)
        bottomNavigationBar: getBottomBar(),

        // la zone contenant photo, texte, émojis, etc...
        body: panel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// l'event qui remet a zero le state du player
    /// lorsque un fichier audio vient d'etre joué jusqu'a la fin
    setCompletionEvent();

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
}
