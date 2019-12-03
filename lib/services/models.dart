import 'package:cloud_firestore/cloud_firestore.dart';

/** 
 * Tout le trala 
 * ci-dessous a pour but
 * de nous permettre
 * d'utiliser les données de la 
 * base de donnée firestore
 * en format Dart Class au lieu 
 * d'un objet key: value
 * 
 * AVANTAGES: code + lisible, etc...
 */



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


/**
 * Un dossier contenant entre autres 
 * les bébé tutoriels
 * de l'utilisateur
 */
class Report {
  String uid;
  int total;
  List<BabyLesson> babyLessons;
  Map topics;

  Report({ this.uid, this.total, this.babyLessons, this.topics });

  factory Report.fromMap(Map data) {
    return Report(
      uid: data['uid'] ?? '',
      total: data['total'] ?? 0,
      babyLessons: (data['babyLessons'] as List ?? []).map((v) => BabyLesson.fromMap(v)).toList(),
      topics: data['topics'] ?? {},
    );
  }

  Map toMap() {
    return {
      'uid': uid ?? '',
      'total': total ?? 0,
      'babyLessons': (babyLessons ?? []).map((v) => v.toMap()).toList(),
      'topics': topics ?? {},
    };
  }

}

class BabyLesson {
  String name;
  String createdBy;
  String id;
  
  BabyLesson({ this.name, this.createdBy, this.id });

  factory BabyLesson.fromMap(Map data) {
    
    return BabyLesson(
      name: data['name'],
      createdBy: data['createdBy'],
    );
  }

  Map toMap() {
    return {
      'name': name ?? '',
      'createdBy': createdBy ?? '',
      'id': id ?? '',
    };
  }
}