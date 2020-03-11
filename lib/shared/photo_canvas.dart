import 'package:flutter/material.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// PHOTO_URL représente
/// le moyen d'affichage de photo
/// via file ou via url
///
/// null pour NO_PHOTO_URL
/// String autrement

/*
photoUrl() {
  if (photoUrl == NO_PHOTO_URL) {
    return noUrl();
  }

  else if (photoUrl is String &&
           photoUrl.length > 0) {
    return url();
  }

  else {
    throw Error();
  }
 
}
*/

/// contient la photo de l'étape, et les différents
/// textes et émojis
class PhotoVideoCanvas extends StatefulWidget {
  final dynamic file;

  final int fileType;

  // la taille de la photo
  final int photoSize;

  // les trucs drag and drop (text emojis etc...)
  //final List<Widget> textsAndEmojis;

  // le texte a display qd ya pas de photo
  final String noFileText;

  /// si photo uploadée, l'url
  final String fileUrl;

 
  PhotoVideoCanvas({
    Key key,
    this.file,
    this.fileType,
    this.photoSize,
    this.noFileText,
    this.fileUrl,
  }) : super(key: key);

  @override
  _PhotoVideoCanvasState createState() => _PhotoVideoCanvasState();
}

class _PhotoVideoCanvasState extends State<PhotoVideoCanvas> {
  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;

  //ChewieController _chewieController;

  @override
  void initState() {
    /// si il y a une video a afficher,
    /// et que le video controller est inexistant,
    /// crée le
    initVideoPlayer();


    super.initState();
  }

  void initVideoPlayer() {
    if (theresAVideo() && _videoPlayerController == NO_DATA) {
      _videoPlayerController = getVideoPlayerController();
      _initializeVideoPlayerFuture = _videoPlayerController.initialize();

      print("vpc: " + _videoPlayerController.toString());
      //_chewieController = getChewieController(_videoPlayerController);
    }
  }

  bool theresAVideo() => somethingToShow() && widget.fileType == VIDEO_FILE;

  bool theresAPhoto() => somethingToShow() && widget.fileType == PHOTO_FILE;

  bool somethingToShow() => !nothingToShow();

  ChewieController getChewieController(VideoPlayerController videoController) {
    return ChewieController(
      videoPlayerController: videoController,
      aspectRatio: 3 / 2,
      autoPlay: true,
      looping: false,
    );
  }

  @override
  void dispose() {
    if (theresAVideo()) {
      _videoPlayerController.dispose();
      //_chewieController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // contient tous les éléments de la zone photo
    // photo, texte, émoji, etc...
    List<Widget> elements = [];

    print(widget.fileType);
    print(theresAPhoto());
    print(theresAVideo());

    // si il n'y a pas de photo/video disponible,
    // ni localement, ni uploadée
    if (nothingToShow()) {
      // affichons le message sur fond jaune
      // invitant l'user à prendre une photo/vidéo
      elements.add(takePhotoVideoMsg());
    }

    /// si il y a un fichier vidéo dispo
    else if (theresAVideo()) {
      initVideoPlayer();

      /// affiche cette photo/video
      elements.add(displayFutureVideoCanvas());
      elements.add(videoIcons());
    }

    /// si il y a un fichier vidéo dispo
    else if (theresAPhoto()) {
      /// affiche cette photo/video
      elements.add(displayPhotoCanvas());
    }

    print(elements);

    /// nous allons afficher ceci en tant que Stack
    return Stack(
      children: elements,
    );
  }

  bool nothingToShow() {
    return widget.file == NO_DATA && widget.fileUrl == NO_DATA;
  }

  nyanCat() {
    return AssetImage(
      'assets/nyan.gif',
    );
  }

  Widget displayPhotoCanvas() {
    return Padding(
      padding: paddedOrNot(widget.photoSize),
      child: Center(
        child: FadeInImage(
          placeholder: nyanCat(),
          image: photoUrlOrFile(),
          fit: howFitIsPhoto(widget.photoSize),
        ),
      ),
      //),
    );
  }

  /// returns first the local photo,
  /// if there's one,
  /// or the uploaded photo
  photoUrlOrFile() {
    if (widget.file != NO_DATA) {
      return fileImage();
    } else if (widget.fileUrl != NO_DATA) {
      return networkImage();
    } else {
      throw Error();
    }
  }

  /// returns first the local photo/video file,
  /// if there's one,
  /// or the photo/video url
  fileOrUrl() {
    if (widget.file != NO_DATA) {
      return widget.file;
    } else if (widget.fileUrl != NO_DATA) {
      return widget.fileUrl;
    } else {
      throw Error();
    }
  }

  /// create a VideoPlayerController
  /// first from a local file,
  /// if there's one,
  /// or from a url
  getVideoPlayerController() {
    if (widget.file != NO_DATA) {
      return VideoPlayerController.file(widget.file);
    } else if (widget.fileUrl != NO_DATA) {
      return VideoPlayerController.network(widget.fileUrl);
    } else {
      throw Error();
    }
  }

  /// if we're in full screen mode
  /// no padding, otherwise some padding
  EdgeInsets paddedOrNot(int photoSize) {
    if (photoSize == NORMAL_SIZE) {
      return EdgeInsets.all(8.0);
    } else if (photoSize == FULL_SIZE) {
      return EdgeInsets.all(0.0);
    } else {
      throw Error();
    }
  }

  /// how fit should the photo be on the space available
  /// either full screen or not
  BoxFit howFitIsPhoto(int photoSize) {
    if (photoSize == NORMAL_SIZE) {
      return BoxFit.contain;
    } else if (photoSize == FULL_SIZE) {
      return BoxFit.cover;
    } else {
      throw Error();
    }
  }

  /// how fit should the video be on the space available
  /// either full screen or not
  Widget howFitIsVideo(int photoSize) {
    if (photoSize == NORMAL_SIZE) {
      return normalSizeVideo();
    } else if (photoSize == FULL_SIZE) {
      return fullScreenVideo();
    } else {
      throw Error();
    }
  }

  Widget studentIcon() {
    return Image.asset(
      'assets/icon.png',
      width: 75,
      height: 75,
      fit: BoxFit.contain,
    );
  }

  /// affiche un message sur fond orange
  ///  invitant jonny à
  /// prendre une photo
  Widget takePhotoVideoMsg() {
    return centeredMsg(
      'assets/icon.png',
      widget.noFileText,
      Colors.lightBlue,
    );
  }

  networkImage() {
    return NetworkImage(widget.fileUrl);
  }

  fileImage() {
    return FileImage(widget.file);
  }

  displayFutureVideoCanvas() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the VideoPlayer.
          return howFitIsVideo(widget.photoSize);
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return centeredMsg("assets/icon.png",
              "Appuie sur ▶ pour lancer la vidéo.", Colors.pink);
        }
      },
    );
  }

  SizedBox fullScreenVideo() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        // Use the VideoPlayer widget to display the video.
        child: SizedBox(
            width: _videoPlayerController.value.size?.width ?? 0,
            height: _videoPlayerController.value.size?.height ?? 0,
            child: VideoPlayer(_videoPlayerController)),
      ),
    );
  }

  Center normalSizeVideo() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          // Use the VideoPlayer widget to display the video.
          child: VideoPlayer(_videoPlayerController),
        ),
      ),
    );
  }

  Widget videoIcons() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Column(
        children: <Widget>[
          restartIcon(),
          playPauseIcon(),
        ],
      ),
    );
  }

  playPauseIcon() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: playPauseVideoActions,
      // Display the correct icon depending on the state of the player.
      child: Icon(
        _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
      ),
    );
  }

  void playPauseVideoActions() {
    // Wrap the play or pause in a call to `setState`. This ensures the
    // correct icon is shown
    setState(() {
      // If the video is playing, pause it.
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else {
        // If the video is paused, play it.
        _videoPlayerController.play();
      }
    });
  }

  restartIcon() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: restartActions,
        // Display the correct icon depending on the state of the player.
        child: Icon(
          Icons.replay,
          color: Colors.white,
        ),
      ),
    );
  }

  void restartActions() {
    setState(() {
      _videoPlayerController.seekTo(Duration(seconds: 0));
      
    });
  }
}
