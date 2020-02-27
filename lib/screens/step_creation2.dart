





/*import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../services/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../shared/shared.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class StepCreation extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  StepCreation({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _StepCreationState createState() => _StepCreationState();
}

class _StepCreationState extends State<StepCreation> {
  File _image;

  Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();

  AudioPlayer audioPlayer = AudioPlayer();

  Report userReport;

  int index;

  //TextEditingController _controller = new TextEditingController();

  Future getImage() async {
    // arrete tout enregistrement
    // audio en cours
    if (_isRecording) {
      await _stop();
    }

    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([
      PermissionGroup.storage,
    ]);
 
    // using your method of getting an image
    final File image = await ImagePicker.pickImage(source: ImageSource.camera);

    final result = await ImageGallerySaver.saveFile(image.path);

    print("Photo in gallery" + result);

    setState(() {
      _image = image;
    });
  }

  _start() async {
    print("on veu de l'odio");

    try {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([
        PermissionGroup.microphone,
        PermissionGroup.storage,
      ]);

      if (!(await AudioRecorder.isRecording)) {
        print("start recording");

        await AudioRecorder.start();

        bool isRecording = await AudioRecorder.isRecording;

        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        print("No permissions, or we already are recording");

        
      }
    } catch (e) {
      print("oups..");
      print(e);
    }
   }

  _stop() async {
    try {
      if (await AudioRecorder.isRecording) {
        var recording = await AudioRecorder.stop();
        print("Stop recording: ${recording.path}");
        bool isRecording = await AudioRecorder.isRecording;
        File file = widget.localFileSystem.file(recording.path);
        print("  File length: ${await file.length()}");
        setState(() {
          _recording = recording;
          _isRecording = isRecording;
        });
        //_controller.text = recording.path;
      } else {
        print('There is no recording to be stopped');
      }
    } catch (e) {
      print(e);
    }
  }

  _play() async {
    int result = await audioPlayer.play(_recording.path, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    // Contient le Report utilisateur
    // ainsi que la position du bébé
    // leçon dans la liste de bébé leçons dans le Report
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;

    // a quel position est le bébé leçon?
    // dans userReport.babyLessons
    index = args.index;

    userReport = args.userReport;

    return WillPopScope(
      onWillPop: () async {
        // You can do some work here.
        // Returning true allows the pop to happen, returning false prevents it.
        await _stop();

        return true;
      },
      //child: SafeArea(
      child: Scaffold(
        
        body: SketchArea(
          screen: this,
          //userReport: userReport,
          index: index,
        ),
      ),
      //),
    );
  }
}

// la zone contenant l'image de l'étape
// et les boutons d'actions
class SketchArea extends StatefulWidget {
  const SketchArea({
    Key key,
    @required this.screen,
    //@required this.userReport,
    @required this.index,
  }) : super(key: key);

  //final File _image;
  final _StepCreationState screen;

  //final Report userReport;
  final int index;

  @override
  _SketchAreaState createState() => _SketchAreaState();
}

class _SketchAreaState extends State<SketchArea> {
  List<DragBox> textAndEmojis;

  bool showFormText;
  bool displayInventory;

  //Report userReport;

  @override
  void initState() {
    super.initState();

    textAndEmojis = [];
    showFormText = false;
    displayInventory = false;
  }

  bool doWeShowAudioButton() {
    // si on est en train d'enregistrer un
    // message audio
    if (widget.screen._isRecording) {
      print("On affiche pas bouton audio");

      // on n'affiche pas le bouton' audio'
      return false;
    }
    // si on n'est pas en train d'enregistrer
    // un message audio
    else {
      print("On affiche bouton audio");

      // on affiche le bouton 'audio'
      return true;
    }
  }

  bool doWeShowFormText() {
    // si on
    if (showFormText) {
      print("On affiche le form");

      // on
      return true;
    }
    // si on n'est pas
    else {
      print("On affiche pas form");

      // on affiche le bouton 'audio'
      return false;
    }
  }

  bool doWeShowStopRecordingButton() {
    // si on est en train d'enregistrer un
    // message audio
    if (widget.screen._isRecording) {
      print("On affiche bouton arret");

      // on affiche le bouton
      return true;
    }
    // si on n'est pas en train d'enregistrer
    // un message audio
    else {
      print("On affiche pas bouton arret");

      // on affiche pas le bouton
      return false;
    }
  }

  bool doWeShowPlayAudioButton() {
    // si il existe un fichier audio contenant qqch
    // , et on est pas en train d'enregistrer un
    // message audio,
    if (widget.screen._recording.duration != null &&
        !widget.screen._isRecording) {
      print("On affiche bouton play");

      // on affiche le bouton
      return true;
    }
    // sinon
    else {
      print("On affiche pas bouton play");

      // on affiche pas le bouton
      return false;
    }
  }

  bool doWeShowTextButton() {
    // si il existe un fichier audio contenant qqch
    // , et on est pas en train d'enregistrer un
    // message audio,
    if (true) {
      print("On affiche bouton text");

      // on affiche le bouton
      return true;
    }
    // sinon
    else {
      print("On affiche pas bouton text");

      // on affiche pas le bouton
      return false;
    }
  }

  bool doWeShowTrashButton() {
    // si il existe un fichier audio contenant qqch
    // , et on est pas en train d'enregistrer un
    // message audio,
    if (textAndEmojis.length > 0) {
      print("On affiche bouton poubelle");

      // on affiche le bouton
      return true;
    }
    // sinon
    else {
      print("On affiche pas bouton poubelle");

      // on affiche pas le bouton
      return false;
    }
  }

  bool doWeShowInventoryButton() {
    // si il existe un fichier audio contenant qqch
    // , et on est pas en train d'enregistrer un
    // message audio,
    if (displayInventory) {
      print("On affiche bouton inventaire");

      // on affiche le bouton
      return true;
    }
    // sinon
    else {
      print("On affiche pas bouton inventaire");

      // on affiche pas le bouton
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> photo(Report userReport) {
      return <Widget>[
        // la photo en arrière plan
        PhotoCanvas(image: widget.screen._image, userReport: userReport),
      ];
    }

    List<Widget> textform(Report userReport) {
      // que fait le form en haut a gauche
      // de l'écran quand on appuie sur OK
      Function onPressFunction6 = (text) {
        setState(() {
          textAndEmojis.add(new DragBox(
              new Offset(75.0, 250.0),
              text,
              25,
              // outside color
              Colors.red,
              // inside color
              Colors.white));
          showFormText = false;
        });
      };

      return <Widget>[
        PhotoTextForm(
          onClick: onPressFunction6,
          visible: doWeShowFormText(),
        ),
      ];
    }

    List<Widget> icons(Report userReport) {
      double iconSize = 40;
      String whichCorner = "bottomLeft";

      // style du bouton 'prendre photo'
      double ithFloor = 0;
      Color color = Colors.purple;
      Color backColor = Colors.cyan;
      Function onPressFunction = () async {
        await widget.screen.getImage();

        var bbLesson = userReport.getLatestBabyLessonSeen();

        var currentStep = bbLesson.getCurrentStep();

        print(currentStep.localPhotoPath);

        // si une photo à déja été prise, supprimons la
        //
        if (currentStep.photoTaken()) {
          File photo = File(currentStep.localPhotoPath);

          photo.delete(recursive: true);

          print('Photo précédente supprimée: ' + currentStep.localPhotoPath);
        }

        currentStep.localPhotoPath = widget.screen._image.path;

        // puis on met à jour le Report
        Global.reportRef.upsert(userReport.toMap());
      };
 
      // style du bouton 'prendre audio'
      double ithFloor2 = 1;
      Color color2 = Colors.white;
      Color backColor2 = Colors.pinkAccent;
      Function onPressFunction2 = widget.screen._start;

      // style du bouton 'arret enregistrement audio'
      double ithFloor3 = 1;
      Color color3 = Colors.white;
      Color backColor3 = Colors.red;
      Function onPressFunction3 = () async {
        await widget.screen._stop();

        var bbLesson = userReport.getLatestBabyLessonSeen();

        var currentStep = bbLesson.getCurrentStep();

        currentStep.audioPath = widget.screen._recording.path;

        // puis on met à jour le Report
        Global.reportRef.upsert(userReport.toMap());
      };

      // style du bouton 'play audio'
      double ithFloor4 = 2;
      Color color4 = Colors.white;
      Color backColor4 = Colors.red;
      Function onPressFunction4 = widget.screen._play;

      // style du bouton 'text'
      String textButtonCorner = "bottomRight";
      double ithFloor5 = 0;
      Color color5 = Colors.white;
      Color backColor5 = Colors.red;
      Function onPressFunction5 = () {
        setState(() {
          showFormText = true;
        });
      };

      return <Widget>[
        // l'icone photo en bas à gauche de l'écran
        CornerIcon(
          ithFloor: ithFloor,
          icon: Icons.add_a_photo,
          iconSize: iconSize,
          color: color,
          backColor: backColor,
          onPressFunction: onPressFunction,
          whichCorner: whichCorner,
          visible: true,
        ),
        // l'icone audio en bas à gauche de l'écran
        CornerIcon(
          ithFloor: ithFloor2,
          icon: Icons.record_voice_over,
          iconSize: iconSize,
          color: color2,
          backColor: backColor2,
          onPressFunction: onPressFunction2,
          whichCorner: whichCorner,
          visible: doWeShowAudioButton(),
        ),
        // l'icone 'arret enregistrement audio'
        // en bas à gauche de l'écran
        CornerIcon(
          ithFloor: ithFloor3,
          icon: Icons.stop,
          iconSize: iconSize,
          color: color3,
          backColor: backColor3,
          onPressFunction: onPressFunction3,
          whichCorner: whichCorner,
          visible: doWeShowStopRecordingButton(),
        ),
        // l'icone 'arret enregistrement audio'
        // en bas à gauche de l'écran
        CornerIcon(
          ithFloor: ithFloor4,
          icon: Icons.play_arrow,
          iconSize: iconSize,
          color: color4,
          backColor: backColor4,
          onPressFunction: onPressFunction4,
          whichCorner: whichCorner,
          visible: doWeShowPlayAudioButton(),
        ),
        // l'icone 'text'
        // en bas à droite de l'écran
        CornerIcon(
          ithFloor: ithFloor5,
          icon: Icons.text_fields,
          iconSize: iconSize,
          color: color5,
          backColor: backColor5,
          onPressFunction: onPressFunction5,
          whichCorner: textButtonCorner,
          visible: doWeShowTextButton(),
        ),
        // l'icone poubelle
        CornerIcon(
          ithFloor: 2,
          icon: Icons.delete,
          iconSize: iconSize,
          color: Colors.white,
          backColor: Colors.green,
          onPressFunction: () {
            setState(() {
              if (textAndEmojis.length > 0) {
                textAndEmojis.removeLast();
              }
            });
          },
          whichCorner: "bottomRight",
          visible: doWeShowTrashButton(),
        ),
        // l'icone inventaire
        CornerIcon(
          ithFloor: 1,
          icon: Icons.shopping_cart,
          iconSize: iconSize,
          color: Colors.white,
          backColor: Colors.green,
          onPressFunction: () {
            setState(() {
              displayInventory = true;
            });
          },
          whichCorner: "bottomRight",
          visible: true,
        ),
      ];
    }

    // la liste de bébé leçons a l'écran
    Widget itemsList(Report userReport, int index) {
      BabyLesson babyLesson = userReport.babyLessons[index];

      double contentSize = 20;
      Color backgroundColor = Colors.red;
      Color contentColor = Colors.white;
      int durationMillisec = 100;

      if (babyLesson.items.length == 0) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Pour ajouter des choses, c'est en haut...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        //shrinkWrap: true,
        // combien d' objets
        itemCount: babyLesson.items.length,
        // crée une liste d'items
        // qu'on peut supprimer en swipant
        itemBuilder: (context, index) {
          return Dismissible(
            onDismissed: (DismissDirection direction) {
              // une fois swipé, on supprime l'item
              // situé à la position 'index', dans la liste de bébé leçons
              // items du bébé lecon
              babyLesson.items.removeAt(index);

              // puis on met à jour le Report
              Global.reportRef.upsert(userReport.toMap());

              final snackBar = SnackBar(
                content: Text('Elément supprimé !'),
                duration: Duration(milliseconds: durationMillisec),
              );

              Scaffold.of(context).removeCurrentSnackBar();

              // Find the Scaffold in the widget
              // tree and use it to show a SnackBar.
              Scaffold.of(context).showSnackBar(snackBar);
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.all(5.0),
              decoration: new BoxDecoration(
                color: backgroundColor,
                borderRadius: new BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Row(
                children: <Widget>[
                  // le bouton -
                  IconButton(
                    iconSize: contentSize,
                    icon: Icon(
                      Icons.remove,
                      size: contentSize,
                      color: contentColor,
                    ),
                    onPressed: () {
                      var item = babyLesson.items[index];

                      if (item.qty == 1) {
                        final snackBar = SnackBar(
                            content:
                                Text('Pour supprimer un item, swipez le !'));

                        Scaffold.of(context).removeCurrentSnackBar();

                        // Find the Scaffold in the widget
                        // tree and use it to show a SnackBar.
                        Scaffold.of(context).showSnackBar(snackBar);
                      } else {
                        final snackBar = SnackBar(
                          content: Text('Et 1 de moins !'),
                          duration: Duration(milliseconds: durationMillisec),
                        );

                        Scaffold.of(context).removeCurrentSnackBar();

                        // Find the Scaffold in the widget
                        // tree and use it to show a SnackBar.
                        Scaffold.of(context).showSnackBar(snackBar);

                        // on diminue la qté de cet item
                        item.qty--;

                        // puis on met à jour le Report
                        Global.reportRef.upsert(userReport.toMap());
                      }
                    },
                  ),

                  // la quantité de cet item nécessaire
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Qté",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: contentSize,
                            color: contentColor,
                          ),
                        ),

                        // la quantité
                        Text(
                          babyLesson.items[index].qty.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: contentSize,
                            color: contentColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // le nom de l'item
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 10,
                        //right: 10,
                      ),
                      child: Text(
                        babyLesson.items[index].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: contentSize,
                          color: contentColor,
                        ),
                      ),
                    ),
                  ),

                  // le bouton +
                  IconButton(
                    iconSize: contentSize,
                    icon: Icon(
                      Icons.add,
                      size: contentSize,
                      color: contentColor,
                    ),
                    onPressed: () {
                      var item = babyLesson.items[index];

                      if (false) {
                        
                        // Find the Scaffold in the widget
                        // tree and use it to show a SnackBar.
                        Scaffold.of(context).showSnackBar(snackBar);
                      } else {
                        final snackBar = SnackBar(
                          content: Text('Et 1 de plus !'),
                          duration: Duration(milliseconds: durationMillisec),
                        );

                        Scaffold.of(context).removeCurrentSnackBar();

                        // Find the Scaffold in the widget
                        // tree and use it to show a SnackBar.
                        Scaffold.of(context).showSnackBar(snackBar);

                        // on diminue la qté de cet item
                        item.qty++;

                        // puis on met à jour le Report
                        Global.reportRef.upsert(userReport.toMap());
                      }
                    },
                  ),
                ],
              ),
            ),
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
          );
        },
      );
    }

    List<Widget> inventory(Report userReport) {
      return <Widget>[
        displayInventory
            ? Positioned.fill(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      15, MediaQuery.of(context).padding.top + 5, 15, 5),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      // inventaire + croix
                      Row(
                        children: <Widget>[
                          // texte 'Inventaire'
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: PrettyText(
                                text: 'Inventaire',
                                insideColor: Colors.white,
                                outsideColor: Colors.red,
                                fontSize: 35,
                              ),
                            ),
                          ),

                          // l'icon back permettant de fermer le panneau
                          // inventaire
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: IconButton(
                              iconSize: 50,
                              icon: Icon(
                                Icons.clear,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  displayInventory = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      // form + bouton
                      HorizontalForm(
                        onClick: (text) {
                          // on localise le bébé leçon en cours de création
                          BabyLesson babyLesson =
                              userReport.babyLessons[widget.index];

                          // extrait les noms d'items
                          List<String> itemNames = babyLesson.items.map((item) {
                            return item.name;
                          }).toList();

                          // vérifie que le nom de l'item est unique
                          bool thereIsAnotherBabyWithTHeSameName =
                              itemNames.any((name) {
                            return name == text;
                          });

                          // si il y a déja un bébé avec le mème nom,
                          // informe l'user de cela
                          if (thereIsAnotherBabyWithTHeSameName) {
                            final snackBar = SnackBar(
                                content: Text(
                                    'Un de tes bébés leçon porte déja ce nom. Choisis un autre nom.'));

                            Scaffold.of(context).removeCurrentSnackBar();

                            // Find the Scaffold in the widget
                            // tree and use it to show a SnackBar.
                            Scaffold.of(context).showSnackBar(snackBar);
                          }

                          // sinon, crée un nouvel Item
                          else {
                            // on ajoute un nouveau item parmi
                            // la liste d'items du bébé leçon
                            babyLesson.items.add(new Item(name: text, qty: 1));

                            // puis on met à jour le Report
                            Global.reportRef.upsert(userReport.toMap());

                            print(
                                "Ajouté un: " + text + " à votre inventaire.");

                            final snackBar = SnackBar(
                              content: Text("Ajouté un: " +
                                  text +
                                  " à votre inventaire."),
                              duration: Duration(milliseconds: 2000),
                            );

                            Scaffold.of(context).removeCurrentSnackBar();

                            // Find the Scaffold in the widget
                            // tree and use it to show a SnackBar.
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                        },
                        visible: true,
                        fillerFormMsg: "Ajoute un truc",
                        emptyFormMsg: "Nomme ton truc bruh...",
                        buttonText: "Ajoute",
                      ),

                      Expanded(child: itemsList(userReport, widget.index)),
                    ],
                  ),
                ),
              )
            : Container()
      ];
    }

    List<Widget> whatWeNeed(Report userReport) {
      if (displayInventory) {
        return photo(userReport) + inventory(userReport);
      } else if (false) {
      } else if (false) {
      } else {
        return photo(userReport) +
            icons(userReport) +
            textform(userReport) +
            inventory(userReport) +
            textAndEmojis;
      }
    }

    

    return StreamBuilder<Report>(
        // dans la collection 'reports' ,
        // on surveille le document
        // relatif à l'utilisateur
        //
        stream: Global.reportRef.documentStream,
        builder: (context, snapshot) {
          // Si il y une erreur durant la
          // récup du document utilisateur,
          // affiche l'erreur
          if (snapshot.hasError) {
            return Text(
              'Erreur: ${snapshot.error}',
              style: TextStyle(
                  //fontFamily: 'ComingSoon',
                  ),
            );
          }

          switch (snapshot.connectionState) {
            // si stream: null, ce message s'affiche
            case ConnectionState.none:
              return Center(
                  child: Text(
                'Aucune données en attente...',
                style: TextStyle(
                    //fontFamily: 'ComingSoon',
                    ),
              ));

            // s'affiche lorsque les données sont en cours de chargement
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Chargement...',
                  style: TextStyle(
                      //fontFamily: 'ComingSoon',
                      ),
                ),
              );

            // s'affiche lorsque les données sont chargées
            default:
              return Stack(
                children: whatWeNeed(snapshot.data),
              );
          }
        });
  }
}

// Create a Form widget.
class PhotoTextForm extends StatefulWidget {
  const PhotoTextForm({
    Key key,
    @required this.onClick,
    @required this.visible,
  }) : super(key: key);

  //final File _image;
  final Function onClick;

  final bool visible;

  @override
  PhotoTextFormState createState() {
    return PhotoTextFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class PhotoTextFormState extends State<PhotoTextForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCus tomFormState>.
  final _formKey = GlobalKey<FormState>();

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return Container();
    }

    // Build a Form widget using the _formKey created above.
    return Positioned(
      left: 5,
      top: MediaQuery.of(context).padding.top + 5,
      width: 100,
      height: 150,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.go,
                onFieldSubmitted: (text) {
                  if (_formKey.currentState.validate()) {
                    // If the form is not empty, display a Snackbar.
                    /*Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('')));*/
                    widget.onClick(myController.text);
                  }
                },
                controller: myController,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Texte",
                    fillColor: Colors.white70),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Veuillez svp écrire quelque chose.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState.validate()) {
                    // If the form is not empty, display a Snackbar.
                    
                    widget.onClick(myController.text);
                  }
                },
                child: Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create a Form widget.
class HorizontalForm extends StatefulWidget {
  const HorizontalForm({
    Key key,
    @required this.onClick,
    @required this.visible,
    @required this.fillerFormMsg,
    @required this.emptyFormMsg,
    @required this.buttonText,
  }) : super(key: key);

  //final File _image;
  final Function onClick;

  final bool visible;

  final String fillerFormMsg;

  final String emptyFormMsg;

  final String buttonText;

  @override
  HorizontalFormState createState() {
    return HorizontalFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class HorizontalFormState extends State<HorizontalForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCus tomFormState>.
  final _formKey = GlobalKey<FormState>();

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return Container();
    }

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.go,
                onFieldSubmitted: (text) {
                  if (_formKey.currentState.validate()) {
                    // If the form is not empty, display a Snackbar.
                    
                    widget.onClick(text);
                  }
                },
                controller: myController,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: widget.fillerFormMsg,
                    fillColor: Colors.white70),
                validator: (value) {
                  if (value.isEmpty) {
                    return widget.emptyFormMsg;
                  }
                  return null;
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: RaisedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false
                // otherwise.*
                if (_formKey.currentState.validate()) {
                  // If the form is not empty, display a Snackbar.
                  
                  widget.onClick(myController.text);
                }
              },
              child: Text(widget.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class DragBox extends StatefulWidget {
  final Offset initPos;
  final String label;
  final Color outsideColor;
  final Color insideColor;
  final double fontSize;

  DragBox(this.initPos, this.label, this.fontSize, this.outsideColor,
      this.insideColor);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = Offset(0.0, 0.0);
  double width = 150;
  double fontSize = 15.0;
  String text = "";

  @override
  void initState() {
    super.initState();

    position = widget.initPos;
    text = widget.label;
    fontSize = widget.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    print("x: " + position.dx.toString());
    print("y: " + position.dy.toString());

    var textWidth = 250.0;

    return Positioned(
      left: position.dx,
      top: position.dy,
      //width: textWidth,
      child: Container(
        //color: Colors.red,
        constraints: BoxConstraints(maxWidth: textWidth),
        child: Draggable(
          data: widget.outsideColor,
          child: PrettyText(
            text: text,
            outsideColor: widget.outsideColor,
            insideColor: widget.insideColor,
            fontSize: fontSize,
          ),
          
          feedback: Material(
            color: Colors.blue.withOpacity(0.5),
            elevation: 20.0,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: Container(
              constraints: BoxConstraints(maxWidth: textWidth),
              child: PrettyText(
                text: text,
                outsideColor: widget.outsideColor,
                insideColor: widget.insideColor,
                fontSize: fontSize,
              ),
            ),
          ),
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              position = offset;
            });
          },
        ),
      ),
    );
  }
}

class CornerIcon extends StatelessWidget {
  const CornerIcon({
    Key key,
    @required this.ithFloor,
    @required this.iconSize,
    @required this.color,
    @required this.backColor,
    @required this.onPressFunction,
    @required this.whichCorner,
    @required this.icon,
    @required this.visible,
    this.buttonIsWorking = false,
  }) : super(key: key);

  final double ithFloor;
  final double iconSize;
  final Color color;
  final Color backColor;
  final Function onPressFunction;
  final String whichCorner;
  final IconData icon;
  final bool visible;
  final bool buttonIsWorking;

  @override
  Widget build(BuildContext context) {
    double verticalMargin = 20.0;
    double vitalMargin = 4.0;

    double topMargin;
    double bottomMargin;
    double leftMargin;
    double rightMargin;

    if (!visible) {
      return Container();
    }

    if (whichCorner == "topLeft") {
      topMargin = (ithFloor * (iconSize + verticalMargin)) + vitalMargin;
      bottomMargin = null;
      leftMargin = vitalMargin;
      rightMargin = null;
    } else if (whichCorner == "topRight") {
      topMargin = (ithFloor * (iconSize + verticalMargin)) + vitalMargin;
      bottomMargin = null;
      leftMargin = null;
      rightMargin = vitalMargin;
    } else if (whichCorner == "bottomLeft") {
      topMargin = null;
      bottomMargin = (ithFloor * (iconSize + verticalMargin)) + vitalMargin;
      leftMargin = vitalMargin;
      rightMargin = null;
    } else if (whichCorner == "bottomRight") {
      topMargin = null;
      bottomMargin = (ithFloor * (iconSize + verticalMargin)) + vitalMargin;
      leftMargin = null;
      rightMargin = vitalMargin;
    } else {
      throw Error();
    }

    return Positioned(
      left: leftMargin,
      right: rightMargin,
      top: topMargin,
      bottom: bottomMargin,
      child: Container(
        decoration: new BoxDecoration(
          color: backColor,
          borderRadius: new BorderRadius.all(Radius.circular(iconSize / 4.0)),
        ),
        child: IconButton(
          iconSize: iconSize,
          icon: Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          onPressed: onPressFunction,
        ),
      ),
    );
  }
}

*/

