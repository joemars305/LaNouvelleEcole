import 'package:firebase_storage/firebase_storage.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';

class Option {
  String value;
  String detail;
  bool correct;

  Option({this.correct, this.value, this.detail});
  Option.fromMap(Map data) {
    value = data['value'];
    detail = data['detail'] ?? '';
    correct = data['correct'];
  }
}

class Question {
  String text;
  List<Option> options;
  Question({this.options, this.text});

  Question.fromMap(Map data) {
    text = data['text'] ?? '';
    options =
        (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();
  }
}

///// Database Collections

class Quiz {
  String id;
  String title;
  String description;
  String video;
  String topic;
  List<Question> questions;

  Quiz(
      {this.title,
      this.questions,
      this.video,
      this.description,
      this.id,
      this.topic});

  factory Quiz.fromMap(Map data) {
    return Quiz(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        topic: data['topic'] ?? '',
        description: data['description'] ?? '',
        video: data['video'] ?? '',
        questions: (data['questions'] as List ?? [])
            .map((v) => Question.fromMap(v))
            .toList());
  }
}

class Topic {
  final String id;
  final String title;
  final String description;
  final String img;
  final List<Quiz> quizzes;

  Topic({this.id, this.title, this.description, this.img, this.quizzes});

  factory Topic.fromMap(Map data) {
    return Topic(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      img: data['img'] ?? 'default.png',
      quizzes: (data['quizzes'] as List ?? [])
          .map((v) => Quiz.fromMap(v))
          .toList(), //data['quizzes'],
    );
  }
}

class Report {
  String uid;
  int total;
  List<BabyLesson> babyLessons;
  Map topics;
  int latestBabyLessonSeen;

  Report(
      {this.uid,
      this.total,
      this.babyLessons,
      this.topics,
      this.latestBabyLessonSeen});

  factory Report.fromMap(Map data) {
    return Report(
      uid: data['uid'] ?? '',
      total: data['total'] ?? 0,
      babyLessons: (data['babyLessons'] as List ?? [])
          .map((v) => BabyLesson.fromMap(v))
          .toList(),
      topics: data['topics'] ?? {},
      latestBabyLessonSeen: data['latestBabyLessonSeen'] ?? 0,
    );
  }

  BabyLesson getLatestBabyLessonSeen() {
    return babyLessons[latestBabyLessonSeen];
  }

  void setLatestBabyLessonSeen(int index) {
    latestBabyLessonSeen = index;
  }

  Map toMap() {
    return {
      'uid': uid ?? '',
      'total': total ?? 0,
      'babyLessons': (babyLessons ?? []).map((v) => v.toMap()).toList(),
      'topics': topics ?? {},
      'latestBabyLessonSeen': latestBabyLessonSeen ?? 0,
    };
  }

  /// nous permet de sauvegarder le Report utilisateur
  void save() {
    Global.reportRef.upsert(toMap());
  }
}

class BabyLesson {
  String name;
  String createdBy;
  String creationDate;
  String category;
  String id;
  List<LessonStep> steps;
  int currentStep;
  List<Item> items;
  bool isMature;
  String thumbnailPath;
  String thumbnailUrl;

  String userIconUrl;

  BabyLesson(
      {this.name,
      this.createdBy,
      this.creationDate,
      this.category,
      this.id,
      this.steps,
      this.currentStep,
      this.items,
      this.isMature,
      this.thumbnailPath,
      this.thumbnailUrl,
      this.userIconUrl});

  factory BabyLesson.fromMap(Map data) {
    return BabyLesson(
      thumbnailPath: data['thumbnailPath'] ?? NO_DATA,
      thumbnailUrl: data['thumbnailUrl'] ?? NO_DATA,
      userIconUrl: data['userIconUrl'] ?? NO_DATA,
      isMature: data['isMature'] ?? NOT_MATURE,
      name: data['name'],
      createdBy: data['createdBy'],
      creationDate: data['creationDate'],
      category: data['category'],
      id: data['id'],
      steps: (data['steps'] as List ?? [new LessonStep()])
          .map((v) => LessonStep.fromMap(v))
          .toList(),
      currentStep: data['currentStep'] ?? 0,
      items: (data['items'] as List ?? []).map((v) => Item.fromMap(v)).toList(),
    );
  }

  void deleteLessonData() async {
    var _storage = FirebaseStorage(
      storageBucket: storageBucketUri,
    );

    if (thumbnailPath != NO_DATA) {
      await _storage.ref().child(thumbnailPath).delete();
    }

    for (var i = 0; i < steps.length; i++) {
      var step = steps[i];
      var photopath = step.photoVideoFilePath;
      var audiopath = step.audioFilePath;

      print('photo path during deletion');
      print(photopath);

      print('audio path during deletion');
      print(audiopath);

      await _storage.ref().child(audiopath).delete();

      await _storage.ref().child(photopath).delete();
    }
  }

  LessonStep getCurrentStep() {
    return steps[currentStep];
  }

  Map toMap() {
    return {
      'thumbnailPath': thumbnailPath ?? NO_DATA,
      'thumbnailUrl': thumbnailUrl ?? NO_DATA,
      'userIconUrl': userIconUrl ?? NO_DATA,
      'isMature': isMature ?? NOT_MATURE,
      'name': name ?? '',
      'createdBy': createdBy ?? '',
      'creationDate': creationDate ?? '',
      'category': category ?? '',
      'id': id ?? '',
      'steps': (steps ?? [new LessonStep()]).map((v) => v.toMap()).toList(),
      'currentStep': currentStep ?? 0,
      'items': (items ?? []).map((v) => v.toMap()).toList(),
    };
  }
}

class LessonStep {
  String audioFilePath;
  String audioFileUrl;
  String photoVideoFilePath;
  String photoVideoFileUrl;
  int currentSubstep;
  int fileType;
  String publicId;

  LessonStep({
    this.audioFilePath,
    this.audioFileUrl,
    this.photoVideoFilePath,
    this.photoVideoFileUrl,
    this.currentSubstep,
    this.fileType,
    this.publicId,
  });



  factory LessonStep.fromMap(Map data) {
    return LessonStep(
      audioFilePath: data['audioFilePath'] ?? NO_DATA,
      photoVideoFilePath: data['photoVideoFilePath'] ?? NO_DATA,
      audioFileUrl: data['audioFileUrl'] ?? NO_DATA,
      photoVideoFileUrl: data['photoVideoFileUrl'] ?? NO_DATA,
      currentSubstep: data['currentSubstep'] ?? 0,
      fileType: data['fileType'] ?? PHOTO_FILE,
      publicId: data['publicId'] ?? NO_DATA,
    );
  }

  Map toMap() {
    return {
      'audioFilePath': audioFilePath ?? NO_DATA,
      'photoVideoFilePath': photoVideoFilePath ?? NO_DATA,
      'audioFileUrl': audioFileUrl ?? NO_DATA,
      'photoVideoFileUrl': photoVideoFileUrl ?? NO_DATA,
      'currentSubstep': currentSubstep ?? 0,
      'publicId': publicId ?? NO_DATA,
      'fileType': fileType ?? PHOTO_FILE,

    };
  }

  bool photoTaken() {
    return photoVideoFilePath != null;
  }
}

class Item {
  String name;
  int qty;
  //List<Item> items;

  Item({
    this.name,
    this.qty,
    /*this.items*/
  });

  factory Item.fromMap(Map data) {
    return Item(
      name: data['name'],
      qty: data['qty'],
      //items: (data['items'] as List ?? []).map((v) => Item.fromMap(v)).toList(),
    );
  }

  Map toMap() {
    return {
      'name': name ?? '',
      'qty': qty ?? 0,
      //'items': (items ?? []).map((v) => v.toMap()).toList(),
    };
  }
}

/*class Item {
  String name;
  int qty;
  //List<Item> items;

  Item({ this.name, this.qty, /*this.items*/ });


  factory Item.fromMap(Map data) {
    return Item(
      name: data['name'],
      qty: data['qty'],
      //items: (data['items'] as List ?? []).map((v) => Item.fromMap(v)).toList(),
    );
  }

  Map toMap() {
    return {
      'name': name ?? '',
      'qty': qty ?? 0,
      //'items': (items ?? []).map((v) => v.toMap()).toList(),
    };
  }
}*/

// Contient entre autres, le Report utilisateur
// que l'on souhaite passer d'un écran à l'autre
class ScreenArguments {
  final Report userReport;
  final int index;

  ScreenArguments(this.userReport, this.index);
}
