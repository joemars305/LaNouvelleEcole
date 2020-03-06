import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizapp/parts/consts.dart';
import 'package:quizapp/parts/toolbox.dart';
import 'package:video_player/video_player.dart';

class PickPhotoVideo extends StatefulWidget {
  PickPhotoVideo({Key key}) : super(key: key);

  @override
  _PickPhotoVideoState createState() => _PickPhotoVideoState();
}

class _PickPhotoVideoState extends State<PickPhotoVideo> {
  File _imageFile;
  File _videoFile;
  dynamic _pickImageError;
  bool isVideo = true;
  VideoPlayerController _controller;
  String _retrieveDataError;
  Response response;
  Dio dio = new Dio();

  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  

  Future<void> _playVideo(File file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      _controller = VideoPlayerController.file(file);
      await _controller.setVolume(1.0);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      setState(() {});
    }
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (isVideo) {
      final File file = await ImagePicker.pickVideo(source: source);
      
      setState(() {
        _videoFile = file;
      });

      await _playVideo(file);
    } else {
      try {
        _imageFile = await ImagePicker.pickImage(source: source);
        setState(() {});
      } catch (e) {
        _pickImageError = e;
      }
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      await _controller.dispose();
      _controller = null;
    }
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return noVideoTakenYet();
    }
    return showVideoPlayer();
  }

  Widget showVideoPlayer() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget noVideoTakenYet() {
    return centeredMsg(
      'assets/icon.png',
      "Tu n'as pas sélectionné de vidéo pour l'instant.",
      Colors.pinkAccent,
    );
  }

  Widget noPhotoTakenYet() {
    return centeredMsg(
      'assets/icon.png',
      "Tu n'as pas sélectionné de photo pour l'instant.",
      Colors.pinkAccent,
    );
  }

  Widget errorMsg(String err) {
    return centeredMsg(
      'assets/icon.png',
      err,
      Colors.pinkAccent,
    );
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else if (_pickImageError != null) {
      return errorMsg(
        "Erreur d'obtention d'image: $_pickImageError",
      );
    } else {
      return noPhotoTakenYet();
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          _imageFile = response.file;
        });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: videoArea(),
      bottomNavigationBar: getBottomBar(context),
    );
  }

  Widget getBottomBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          pickImageFromGallery(context),
          pickImage(context),
          pickVideoFromGallery(),
          pickVideo(),
        ],
      ),
    );
  }

  Widget pickVideo() {
    return IconButton(
      icon: Icon(
        Icons.videocam,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        isVideo = true;
        _onImageButtonPressed(ImageSource.camera);
      },
      color: Colors.blue,
    );
  }

  Widget pickVideoFromGallery() {
    return IconButton(
      icon: Icon(
        Icons.video_library,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        isVideo = true;
        _onImageButtonPressed(ImageSource.gallery);
      },
      color: Colors.blue,
    );
  }

  Widget pickImage(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.camera_alt,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        isVideo = false;
        _onImageButtonPressed(ImageSource.camera, context: context);
      },
      color: Colors.blue,
    );
  }

  Widget pickImageFromGallery(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.photo_library,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () {
        isVideo = false;
        _onImageButtonPressed(ImageSource.gallery, context: context);
      },
      color: Colors.blue,
    );
  }

  Widget uploadButton() {
    return IconButton(
      icon: Icon(
        Icons.cloud_upload,
        size: BOTTOM_ICON_SIZE,
      ),
      onPressed: () async {
        var videoBytes = _videoFile.readAsBytesSync();
        var base64Video = base64Encode(videoBytes);

        print(videoBytes);

        response = await dio.post(
          "http://upload.giphy.com/v1/gifs",
          data: {
            "api_key": "Vu7m3UDNtOe4vRlOFVhmPSNNuYLQ38DW",
            "file": base64Video,
          },
          onSendProgress: (int sent, int total) {
            print("$sent / $total");
          },
        );

        print("response: " + response.data.toString());
      },
      color: Colors.blue,
    );
  }

  Center videoArea() {
    return Center(
      child: Platform.isAndroid
          ? FutureBuilder<void>(
              future: retrieveLostData(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return noPhotoTakenYet();
                  case ConnectionState.done:
                    return isVideo ? _previewVideo() : _previewImage();
                  default:
                    if (snapshot.hasError) {
                      return errorMsg(
                        "Erreur durant prise d'image/vidéo: ${snapshot.error}}",
                      );
                    } else {
                      return noPhotoTakenYet();
                    }
                }
              },
            )
          : (isVideo ? _previewVideo() : _previewImage()),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Photo/Video"),
      actions: <Widget>[
        uploadButton(),
      ],
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
