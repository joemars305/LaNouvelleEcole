import 'dart:io';

import 'package:file/local.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';
import 'package:path/path.dart';
import 'package:file/file.dart';

/// String => bool
///
/// Essaie de convertir un String en int
/// et retourne si ou ou non la
/// conversion est réussie
bool stringIsValidInt(String input) {
  int tryInput = int.tryParse(input);

  return tryInput != NO_DATA;
}

/// USER_INPUT_STRING représente
/// un futur texte provenant
/// de l'utilisateur
///
/// null pour NO_USER_INPUT
/// Future<''> pour EMPTY_USER_INPUT
/// Future<un String d'une lettre ou plus> pour le reste

/*
handleUserInput() async {
  String userInput = await getUserInput(
    context,
    title,
    subtitle, 
    hint,
  );

  fnForFutureUserInput(userInput);
}
....
....

void fnForFutureUserInput(String userInput) {
  
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
              onSubmitted: (value) {
                print('give user input back: ' + inputText);

                Navigator.of(context).pop(inputText);
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
fnActions() async {
  Choice userChoice = await getUserChoice(
    context,
    title,
    choices,
  );

  fnForFutureChoice(userChoice);
}



void fnForFutureChoice(Choice choice) {
  
  if (choice == NO_FUTURE_CHOICE) {
    return noChoice();
  }
  else if (choice.choiceValue == QQCH) {
    return doSomethingWChoice();
  }
  else {
    throw Error();
  }
  
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
  //int choiceVal = choice.choiceValue;

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
  var choiceValue;

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

/// nous permet d'afficher un message centré
Widget centeredMsg(String iconPath, String text, Color color,
    [List<Widget> children]) {
  List<Widget> columnChildren = <Widget>[
    icon(iconPath),
    msg(text),
  ];

  if (children != NO_DATA) {
    columnChildren = columnChildren + children;
  }

  return Container(
    color: color,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: columnChildren,
      ),
    ),
  );
}

/// une icone représentant un objet lambda
Widget icon(String path) {
  return Image.asset(
    path,
    width: 45,
    height: 45,
    fit: BoxFit.contain,
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

Future deleteLessonData(Report userReport, int index) async {
  var lesson = userReport.babyLessons[index];

  var result = lesson.deleteLessonData();

  return result;
}

deleteLesson(Report userReport, int index) async {
  /// supprime les photos prises pour cette leçon
  await deleteLessonData(userReport, index);

  // une fois swipé, on supprime le bébé leçon
  // situé à la position 'index', dans la liste de bébé leçons
  // de l'utilisateur
  userReport.babyLessons.removeAt(index);

  // puis on met à jour le Report
  userReport.save();
}

/// nous permet de jouer des fichiers
/// audio locaux ou en ligne
class SoundPlayer {
  /// le player audio
  AudioPlayer audioPlayer = AudioPlayer();

  /// avons nous démarré un fichier audio ?
  bool haveWePlayedSomething = NO_DATA;

  /// String Function => void
  ///
  /// lit un fichier audio situé:
  /// sur le stockage du téléphone,
  /// via un path
  Future<void> playLocal(String localPath, Function updateState) async {
    await audioPlayer.play(
      localPath,
      isLocal: true,
    );

    haveWePlayedSomething = WE_HAVE_PLAYED_AUDIO;

    updateState();

    return NO_DATA;
  }

  /// String Function => void
  ///
  /// lit un fichier audio situé:
  /// sur internet via une url
  Future<void> playRemote(String url, Function updateState) async {
    await audioPlayer.play(
      url,
      isLocal: false,
    );

    haveWePlayedSomething = WE_HAVE_PLAYED_AUDIO;

    updateState();

    return NO_DATA;
  }

  /// Function => void
  ///
  /// pause la lecture d' un fichier audio
  Future<void> pause(Function updateState) async {
    await audioPlayer.pause();

    updateState();

    return NO_DATA;
  }

  /// Function => void
  ///
  /// stop la lecture d'un fichier audio
  Future<void> stop(Function updateState) async {
    await audioPlayer.stop();
    await audioPlayer.release();

    haveWePlayedSomething = WE_HAVENT_PLAYED_AUDIO;

    updateState();

    return NO_DATA;
  }

  /// Function => void
  ///
  ///
  /// crée un event qui s'execute
  /// lorsque un fichier audio
  /// vient d'etre joué jusqu'a la fin
  /// cette fonction doit etre run 1 seule fois
  /// (dans initState de votre programme)
  void setOnComplete(Function updateState) {
    audioPlayer.onPlayerCompletion.listen((event) {
      updateState();
    });

    return NO_DATA;
  }

  /// Function => void
  ///
  /// relance la lecture
  /// d'un fichier audio
  /// au début (0 sec)
  Future<void> restart(Function updateState) async {
    if (!(audioPlayer.state == AudioPlayerState.STOPPED)) {
      var startPosition = Duration(milliseconds: 0);

      await pause(() {});

      await audioPlayer.seek(startPosition);

      await resume(() {});

      updateState();
    }

    return NO_DATA;
  }

  /// Function => void
  ///
  /// relance la lecture d'un
  /// fichier audio mis en pause
  Future<void> resume(Function updateState) async {
    await audioPlayer.resume();

    updateState();

    return NO_DATA;
  }
}

/// Permet d'enregistrer
/// de l'audio provenant
/// du microphone de l'utilisateur,
class SoundRecorder {
  /// un objet contenant des données relatives
  /// au dernier enregistrement local
  FlutterSound flutterSound = new FlutterSound();

  /// télécommande permettant de démarrer/stopper
  /// enregistrement
  var recording = NO_DATA;

  String latestRecordingPath;

  /// String String Function => void
  ///
  /// demarre un enregistrement
  /// audio via microphone,
  /// stocké localement
  Future<void> startRecording(
      String dirPath, String fileName, Function updateState) async {
    try {
      await _requestMicAndStoragePermissions();

      /// le type de fichier audio
      String fileType = "mp3";

      /// le path complet de fichier audio
      String fullPath = "$dirPath/$fileName.$fileType";

      latestRecordingPath = fullPath;

      if (!await isRecording()) {
        await flutterSound.startRecorder(
          uri: fullPath,
          codec: t_CODEC.CODEC_MP3,
        );

        recording = flutterSound.onRecorderStateChanged.listen((e) {
          /*DateTime date =
            new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);*/
        });

        updateState();
      } else {
        print("Pas de permissions, ou enregistrement audio déja en cours..");
      }
    } catch (e) {
      print(
          "oups: L'erreur suivante à été reçue suite à un enregistrement audio: $e");
    }

    return NO_DATA;
  }

  Future isRecording() async {
    return flutterSound.isRecording;
  }

  _requestMicAndStoragePermissions() async {
    await PermissionHandler().requestPermissions([
      PermissionGroup.microphone,
      PermissionGroup.storage,
    ]);
  }

  /// Function => String
  ///
  /// arrete un enregistrement
  /// audio via microphone,
  /// et retourne le path ou est situé l'audio
  Future<String> stopRecording(Function updateState) async {
    try {
      /// si nous somme en train d'enregistrer
      /// un message audio..
      if (await isRecording()) {
        String result = await flutterSound.stopRecorder();

        print('stopRecorder: $result');

        if (recording != null) {
          recording.cancel();
          recording = null;
        }

        updateState();

        return latestRecordingPath;
      } else {
        print("Il n'y a aucun enregistrement à arrêter");
        return NO_DATA;
      }
    } catch (e) {
      print("coké: $e");
    }

    return NO_DATA;
  }

  /// .. => ..
  ///
  ///
  void dispose() {
    flutterSound.stopRecorder();
  }
}

/// nous permet de prendre
/// une photo / vidéo via:
///
/// - la caméra du device
///
/// - une url
///
class PhotoVideoRecorder {
  /// Function bool => File/NO_DATA
  ///
  /// Prend une photo via la caméra,
  /// (ou via Gallery si 2nd argument existe && true)
  /// et retourne le fichier
  ///
  Future<File> takePhoto(Function updateState, [bool pickFromGallery]) async {
    var fromWhere = ImageSource.camera;

    if (pickFromGallery == true) {
      fromWhere = ImageSource.gallery;
    }

    var file = await ImagePicker.pickImage(source: fromWhere);

    if (file != NO_DATA) {
      updateState(file);
    }

    return file;
  }

  /// String Function => bool
  ///
  /// Télécharge une photo située a l'adresse url
  downloadPhoto(String url, Function updateState) {
    return true;
  }

  /// Function bool => File/NO_DATA
  ///
  /// Prend une vidéo via la caméra,
  /// (ou via Gallery si 2nd argument existe && true)
  /// et retourne le fichier
  Future<File> takeVideo(Function updateState, [bool pickFromGallery]) async {
    var fromWhere = ImageSource.camera;

    if (pickFromGallery == true) {
      fromWhere = ImageSource.gallery;
    }

    var file = await ImagePicker.pickVideo(source: fromWhere);

    if (file != NO_DATA) {
      updateState(file);
    }

    return file;
  }

  /// String Function => void
  ///
  /// Télécharge une vidéo située a l'adresse url
  downloadVideo(String url, Function updateState) {
    return true;
  }

  /// .. => ..
  ///
  ///
}

/// nous permet de gérer nos fichiers (File)
class FileManager {
  LocalFileSystem _localFileSystem;

  FileManager() {
    _localFileSystem = LocalFileSystem();
  }

  /// String File Function => bool
  ///
  /// Nous permet de supprimer un fichier
  /// avec son path, ou avec un objet File
  Future<bool> deleteFile(
      String filePath, File file, Function updateState) async {
    if (filePath != NO_DATA) {
      file = _localFileSystem.file(filePath);
      await file.delete(recursive: true);
    } else if (file != NO_DATA) {
      await file.delete(recursive: true);
    }

    return true;
  }

  /// File String String Function => String
  ///
  /// sauvegarde le fichier, nommé selon vos désirs,
  ///  et retourne le path local
  Future<String> saveFile(
      File file, String dirPath, String fileName, Function updateState) async {
    /// le path du fichier qu'on veut stocker quelque part
    String filePath = file.path;

    /// l'extension du fichier
    String fileExt = extension(filePath);

    /// le path local ou on veut stocker ce fichier
    String localfilePath = dirPath + "/$fileName$fileExt";

    // copy the file to a new path
    File newLocalImage = await file.copy(localfilePath);

    print("local file path: $localfilePath");

    return newLocalImage.path;
  }

  /// .. => ..
  ///
  ///

  /// .. => ..
  ///
  ///

}

/*
/// permet de créer des notifications
class Notifier {
  Function(String) onSelectNotification;

  Notifier(Function(String) onSelNotif) {
    onSelectNotification = onSelNotif;
  }

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  /// .. => ..
  ///
  ///
  void initNotifier() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  /// DateTime String String => Future
  ///
  ///
  Future scheduleNotificationOnce(DateTime when, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.schedule(
        0,
        title,
        body,
        when,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  /// .. => ..
  ///
  ///

  /// .. => ..
  ///
  ///
}*/