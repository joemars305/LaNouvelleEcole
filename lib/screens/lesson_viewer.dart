import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quizapp/parts/consts.dart';
import 'package:quizapp/services/models.dart';
import 'package:quizapp/shared/photo_canvas.dart';

class LessonViewer extends StatefulWidget {
  LessonViewer({Key key}) : super(key: key);

  @override
  _LessonViewerState createState() => _LessonViewerState();
}

class _LessonViewerState extends State<LessonViewer> {
  static const firstStep = 0;

  BabyLesson _babyLesson;

  int _currentStep = firstStep;
  int _qtySteps;

  /// PLAYER_STATE représente l'état du player audio
  ///
  /// 0 pour STOPPED
  /// 1 pour PLAYING
  /// 2 pour PAUSED
  int _playerState = STOPPED;

  /// RECORDING représente le message audio
  ///
  /// null pour NO_AUDIO_FILE
  /// new Recording(...) pour AUDIO_FILE
  Recording _recording = NO_AUDIO_FILE;

  /// le lecteur audio
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// l'event qui remet a zero le state du player
    /// lorsque un fichier audio vient d'etre joué jusqu'a la fin
    setCompletionEvent();

    var args = ModalRoute.of(context).settings.arguments as Map;

    _babyLesson = args['babyLesson'];
    _qtySteps = _babyLesson.steps.length;

    return Scaffold(
      appBar: topBar(context),
      body: body(context),
      bottomNavigationBar: bottomBar(context),
    );
  }

  /// l'event qui remet a zero le state du player
  /// lorsque un fichier audio vient d'etre joué jusqu'a la fin
  void setCompletionEvent() {
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        _playerState = STOPPED;
      });
    });
  }

  topBar(BuildContext context) {
    return AppBar(
      leading: prevStep(),
      title: whichStep(),
      actions: [
        nextStep(),
      ],
    );
  }

  body(BuildContext context) {
    return photoArea();
  }

  bottomBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: viewerIcons(),
      ),
    );
  }

  viewerIcons() {
    return [
      playPauseAudioIcon(_babyLesson),
      restartAudioIcon(_babyLesson),
    ];
  }

  Widget prevStep() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
      ),
      onPressed: prevStepActions,
    );
  }

  Widget nextStep() {
    return IconButton(
      icon: Icon(
        Icons.arrow_forward,
      ),
      onPressed: nextStepActions,
    );
  }

  prevStepActions() {
    if (_currentStep > firstStep) {
      setState(() {
        _currentStep--;
        audioPlayer.stop();
        _playerState = STOPPED;
      });
    }
  }

  whichStep() {
    return Text("Etape " + (_currentStep + 1).toString());
  }

  nextStepActions() {
    if (_currentStep < (_qtySteps - 1)) {
      setState(() {
        _currentStep++;
        _babyLesson.currentStep = _currentStep;
        audioPlayer.stop();
        _playerState = STOPPED;
      });
    }
  }

  photoArea() {
    var step = _babyLesson.steps[_currentStep];
    var stepFileType = step.fileType;

    return PhotoVideoCanvas(
      file: NO_DATA,
      fileType: stepFileType,
      photoSize: NORMAL_SIZE,
      noFileText: "Oups... Y'a pas de photo dispo.",
      fileUrl: step.photoVideoFileUrl,
    );
  }

  Widget playPauseAudioIcon(BabyLesson babyLesson) {
    if (_playerState == STOPPED) {
      return playIcon(babyLesson);
    } else if (_playerState == PLAYING) {
      return pauseIcon();
    } else if (_playerState == PAUSED) {
      return resumeIcon();
    } else {
      throw Error();
    }
  }

  /// l'icone qui joue un enregistrement audio
  Widget playIcon(BabyLesson babyLesson) {
    return IconButton(
      icon: Icon(
        Icons.play_arrow,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        playIconActions(babyLesson);
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
  void playIconActions(BabyLesson babyLesson) async {
    var step = _babyLesson.steps[_currentStep];
    var audioUrl = step.audioFileUrl;

    await audioPlayer.seek(Duration(milliseconds: 0));
    await audioPlayer.play(
      audioUrl,
      isLocal: false,
    );

    setState(() {
      _playerState = PLAYING;
    });
  }

  void resumeIconActions() async {
    await audioPlayer.resume();

    setState(() {
      _playerState = PLAYING;
    });
  }

  /// l'icone qui joue un enregistrement audio
  Widget restartAudioIcon(BabyLesson babyLesson) {
    return IconButton(
      icon: Icon(
        Icons.skip_previous,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () async {
        await restartAudioActions(babyLesson);
        
      },
      color: Colors.blue,
    );
  }

  Future<void> restartAudioActions(BabyLesson babyLesson) async {
    await audioPlayer.stop();

    playIconActions(babyLesson);
  }
}
