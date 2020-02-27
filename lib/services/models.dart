import 'package:firebase_storage/firebase_storage.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';





class Option {
  String value;
  String detail;
  bool correct;

  Option({ this.correct, this.value, this.detail });
  Option.fromMap(Map data) {
    value = data['value'];
    detail = data['detail'] ?? '';
    correct = data['correct'];
  }
}


class Question {
  String text;
  List<Option> options;
  Question({ this.options, this.text });

  Question.fromMap(Map data) {
    text = data['text'] ?? '';
    options = (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();
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

  Quiz({ this.title, this.questions, this.video, this.description, this.id, this.topic });

  factory Quiz.fromMap(Map data) {
    return Quiz(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      topic: data['topic'] ?? '',
      description: data['description'] ?? '',
      video: data['video'] ?? '',
      questions: (data['questions'] as List ?? []).map((v) => Question.fromMap(v)).toList()
    );
  }
  
}


class Topic {
  final String id;
  final String title;
  final  String description;
  final String img;
  final List<Quiz> quizzes;

  Topic({ this.id, this.title, this.description, this.img, this.quizzes });

  factory Topic.fromMap(Map data) {
    return Topic(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      img: data['img'] ?? 'default.png',
      quizzes:  (data['quizzes'] as List ?? []).map((v) => Quiz.fromMap(v)).toList(), //data['quizzes'],
    );
  }

}


 
class Report {
  String uid;
  int total;
  List<BabyLesson> babyLessons;
  Map topics;
  int latestBabyLessonSeen;
  
  Report({ 
    this.uid, 
    this.total, 
    this.babyLessons, 
    this.topics, 
    this.latestBabyLessonSeen 
  });

  factory Report.fromMap(Map data) {
    return Report(
      uid: data['uid'] ?? '',
      total: data['total'] ?? 0,
      babyLessons: (data['babyLessons'] as List ?? []).map((v) => BabyLesson.fromMap(v)).toList(),
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

  BabyLesson({ this.name, this.createdBy, this.creationDate, this.category, this.id, this.steps, this.currentStep, this.items });


  factory BabyLesson.fromMap(Map data) {
    return BabyLesson(
      name: data['name'],
      createdBy: data['createdBy'],
      creationDate: data['creationDate'],
      category: data['category'],
      id: data['id'],
      steps: (data['steps'] as List ?? [new LessonStep()]).map((v) => LessonStep.fromMap(v)).toList(),
      currentStep: data['currentStep'] ?? 0,
      items: (data['items'] as List ?? []).map((v) => Item.fromMap(v)).toList(),
    );
  }

  Future deleteLessonData() async {
    return steps.map((step) async {
      
      var photopath = step.photoFilePath;
      var audiopath = step.audioFilePath;

      var _storage = FirebaseStorage(
        storageBucket: storageBucketUri,
      );

      print('photo path during deletion');
      print(photopath);

      print('audio path during deletion');
      print(audiopath);

      await _storage.ref().child(audiopath).delete();
      
      return await _storage.ref().child(photopath).delete();
    });
  }

  LessonStep getCurrentStep() {
    return steps[currentStep];
  }



  Map toMap() {
    return {
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
  String photoFilePath;
  String photoFileUrl;
  int currentSubstep;


  

  LessonStep({ 
    this.audioFilePath,
    this.audioFileUrl,
    this.photoFilePath,
    this.photoFileUrl, 
    this.currentSubstep, 
  });


  factory LessonStep.fromMap(Map data) {
    return LessonStep(
      audioFilePath: data['audioFilePath'] ?? null,
      photoFilePath: data['photoFilePath'] ?? null,
      audioFileUrl: data['audioFileUrl'] ?? null,
      photoFileUrl: data['photoFileUrl'] ?? null,
      currentSubstep: data['currentSubstep'] ?? 0,
    );
  }

  Map toMap() {
    return {
      'audioFilePath': audioFilePath ?? null,
      'photoFilePath': photoFilePath ?? null,
      'audioFileUrl': audioFileUrl ?? null,
      'photoFileUrl': photoFileUrl ?? null,
      'currentSubstep': currentSubstep ?? 0,
    };
  }

  bool photoTaken() {
    return photoFilePath != null;
  }
}


class Item {
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
