import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:path/path.dart';
import 'models.dart';

/// UPLOAD_TASK représente l"upload d'un fichier vers
/// le cloud Firebase
///
/// null pour NO_UPLOAD_TASK (pas d'upload en cours)
/// un StorageUploadTask autrement (un upload est en cours/pause/terminé)
///

/*
fnForUploadTask() {
  if (_uploadTask == NO_UPLOAD_TASK) {
    return handleNoTask();
  }

  else {
    return handleTask();
  }
}
*/

/// UPLOAD_STATUS représente l'état actuel du
/// Uploader existant
///
/// 0 pour UP_IN_PROGRESS
/// 1 pour UP_PAUSED
/// 2 pour UP_COMPLETED

/*
fnForUpStatus() {
  if (_uploadTask.isInProgress) {
    return UP_IN_PROGRESS;
  }

  else if (_uploadTask.isPaused) {
    return UP_PAUSED;
  }

  else if (_uploadTask.isComplete) {
    return UP_COMPLETED;
  }
}
*/

/// Widget used to handle the management of
/// uploading stuff to Firebase
class Uploader extends StatefulWidget {
  final List<File> files;
  final Report userReport;
  final List<String> uploadMsgs;
  final List<Function> onUploadsDone;

  Uploader({
    Key key,
    this.files,
    this.userReport,
    this.uploadMsgs,
    this.onUploadsDone,
  }) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: storageBucketUri);

  StorageUploadTask _uploadTask = NO_DATA;

  String _uploadMsg;

  List<File> files;
  Report userReport;
  List<String> uploadMsgs;
  List<Function> onUploadsDone;

  @override
  void initState() {
    super.initState();

    files = widget.files;
    userReport = widget.userReport;
    uploadMsgs = widget.uploadMsgs;
    onUploadsDone = widget.onUploadsDone;
  }

  @override
  void dispose() {
    _uploadTask.cancel();
    print("upload annulé !!");
    super.dispose();
  }

  /// demarre l'upload,
  /// et run la fonction de fin d'upload quand
  /// l'upload est terminé
  startUpload(BuildContext context, File file, Function uploadDoneFunc,
      String lastMsg) async {
    String _filePath = getFilePath(context, file);

    ///objet represent la location du fichier dans firebase
    var ref = _storage.ref().child(_filePath);

    setState(() {
      /// create the process of uploading the file
      _uploadTask = ref.putFile(file);

      /// the message to be displayed while upload is going on.
      _uploadMsg = lastMsg;

      runOnUploadDoneFunc(ref, _filePath, uploadDoneFunc);
    });
  }

  String getFilePath(BuildContext context, File file) {
    String uid = getUserUid(context);

    /// instant t en millisecondes, sert de nom de fichier
    int millisSinceEpoch = getCurrentMillisTime();

    /// le type du fichier (.jpg, .gif, etc...)
    String filetype = getFileType(file);

    /// le path du fichier dans firebase
    String _filePath = 'step_files/$uid/$millisSinceEpoch$filetype';

    print("file path: " + _filePath);
    return _filePath;
  }

  int getCurrentMillisTime() {
    /// instant t en millisecondes, sert de nom de fichier
    int millisSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    return millisSinceEpoch;
  }

  String getUserUid(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    String uid = user.uid;
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    /// create an upload task if necessary
    createUploadTask(context);

    /// if the uploads are all complete
    /// show message telling user to click the next button to go to the next step
    if (uploadTaskIsComplete() && !theresFilesToUpload()) {
      return goToNextStep();
    }

    /// otherwise show upload progress
    else {
      return showUploadProgress();
    }
  }

  createUploadTask(BuildContext context) {
    /// if there's 1 or more files to upload
    /// and the uploadtask is either nonexistent,
    /// or completed...
    if (theresFilesToUpload() &&
        (!uploadTaskExists() || uploadTaskIsComplete())) {
      /// ...start an file upload.
      /// we get the file, and it's
      /// corresponding function
      /// that we run after the file upload is done.
      /// this function allows us to do
      /// stuff like saving data to a database,
      /// or anything else.
      /// there's 2 lists, a list of files,
      /// and a list of functions,
      /// we pop the last file,
      /// we pop it's corresponding fonction to be run on upload end
      /// we pop the message to be displayed during upload
      var lastFile = files.removeLast();
      var lastFunc = onUploadsDone.removeLast();
      var lastMsg = uploadMsgs.removeLast();
      startUpload(context, lastFile, lastFunc, lastMsg);
    }
  }

  bool theresFilesToUpload() => files.length > 0;

  Widget showUploadProgress() {
    return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;

          double progressPercent =
              event != null ? event.bytesTransferred / event.totalByteCount : 0;

          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                uploadStatusIcon(),
                uploadMsg(),
                horizontalUploadProgress(progressPercent),
                numericUploadProgress(progressPercent),
              ]);
        });
  }

  uploadStatusIcon() {
    var icon;

    if (uploadTaskIsInProgress()) {
      icon = nyanCat();
    } else if (uploadTaskIsPaused()) {
      icon = paused();
    } else if (uploadTaskIsComplete()) {
      icon = boomerMeme();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: icon,
    );
  }

  bool uploadTaskIsComplete() => _uploadTask.isComplete;

  bool uploadTaskIsPaused() => _uploadTask.isPaused;

  bool uploadTaskIsInProgress() => _uploadTask.isInProgress;

  horizontalUploadProgress(double progressPercent) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: LinearProgressIndicator(value: progressPercent),
    );
  }

  numericUploadProgress(double progressPercent) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        '${(progressPercent * 100).toStringAsFixed(2)} % ',
        style: TextStyle(fontSize: 50),
      ),
    );
  }

  nyanCat() {
    return Image.asset(
      'assets/nyan.gif',
      width: 350,
    );
  }

  paused() {
    return Image.asset(
      'assets/paused.gif',
      width: 350,
    );
  }

  boomerMeme() {
    return Image.asset(
      'assets/boomer.gif',
      width: 350,
    );
  }

  Future<void> runOnUploadDoneFunc(
      StorageReference ref, String filePath, Function func) async {
    await _uploadTask.onComplete;
    print('upload complete.');

    //_uploadTask.cancel();

    String fileUrl = await ref.getDownloadURL() as String;

    func(filePath, fileUrl, widget.userReport);
  }

  String getFileType(File file) {
    String path = file.path;
    String ext = extension(path);

    print("file type: " + ext);

    return ext;
  }

  bool uploadTaskExists() {
    return _uploadTask != NO_DATA;
  }

  uploadMsg() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(_uploadMsg,
          style: TextStyle(
            fontSize: 20,
          )),
    );
  }

  Widget goToNextStep() {
    return centeredMsg(
      "assets/icon.png", 
      "Etape uploadée avec succès ! Appuie sur ➜ pour continuer. 😍",
      Colors.indigoAccent,
    );
  }
}
