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

  StorageUploadTask _uploadTask = NO_UPLOAD_TASK;


  startUpload(BuildContext context, File file, Function func) async {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    String uid = user.uid;
    /// instant t en millisecondes, sert de nom de fichier
    int millisSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    
    /// le type du fichier (.jpg, .gif, etc...)
    String filetype = getFileType(file);

    /// le path du fichier dans firebase
    String _filePath = 'step_files/$uid/$millisSinceEpoch$filetype';

    print("file path: " + _filePath);

    ///objet represent la location du fichier dans firebase
    var ref = _storage.ref().child(_filePath);

    setState(() {
      /// create the process of uploading the file
      _uploadTask = ref.putFile(file);
      
      runOnUploadDoneFunc(ref, _filePath, func);
    });
  }

  @override
  Widget build(BuildContext context) {
    createUploadTask(context);

    return handleTask();
  }

  createUploadTask(BuildContext context) {
    /// if there's 1 or more files to upload
    if (widget.files.length > 0)  {
      /// start an file upload.
      /// we get the file, and it's
      /// corresponding function
      /// that we run after the file upload is done.
      /// this function allows us to do
      /// stuff like saving data to a database,
      /// or anything else.
      /// there's 2 lists, a list of files,
      /// and a list of functions,
      /// we pop the last file,
      /// we also pop it's corresponding last fonction
      var lastFile = widget.files.removeLast();
      var lastFunc = widget.onUploadsDone.removeLast();

      startUpload(context, lastFile, lastFunc);
    }

    
  }

  Widget handleTask() {
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
                horizontalUploadProgress(progressPercent),
                numericUploadProgress(progressPercent),
              ]);
        });
  }

  /// une icone représentant un objet lambda
  Widget cloudIcon() {
    return Image.asset(
      'assets/icon.png',
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

  /*Widget handleNoTask() {
    return Container(
      color: Colors.pink,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            cloudIcon(),
            msg(widget.uploadMsg),
          ],
        ),
      ),
    );
  }*/

  uploadStatusIcon() {
    if (_uploadTask.isInProgress) {
      return nyanCat();
    } else if (_uploadTask.isPaused) {
      return paused();
    } else if (_uploadTask.isComplete) {
      return boomerMeme();
    }
  }

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
}
