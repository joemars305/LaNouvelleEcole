import 'package:flutter/material.dart';
import 'package:quizapp/parts/consts.dart';
import 'package:quizapp/parts/toolbox.dart';
import '../services/services.dart';

class TopicsScreen extends StatefulWidget {
  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  /// _category représente la catégorie de
  /// leçon à afficher
  String _category = TOUTES_CATEGORIES;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Report>(
      stream: Global.reportRef.documentStream,
      builder: (BuildContext context, AsyncSnapshot<Report> snapshot) {
        /// if we received the userReport
        if (snapshot.hasData) {
          /// affiche la liste de leçons,
          /// ou un NoDataMessage
          return listOfLessons(snapshot.data);
        }

        /// if something got wrong trying
        /// to get userReport
        else if (snapshot.hasError) {
          /// inform the user about it
          return errorMsg();
        }

        /// if we're loading userReport
        else {
          /// tell johnny to wait
          return loadingMsg();
        }
      },
    );
  }

  /// si il existe des lecons à afficher,
  /// affiche les,
  ///
  /// sinon, affiche un NoDataMessage
  Widget listOfLessons(Report userReport) {
    if (theresLessonsToDisplay(userReport)) {
      return displayLessons(userReport);
    } else {
      return theresNoLessons(userReport);
    }
  }

  /// affiche un message sur fond violet
  /// informant l'user qu'un problème est survenu
  /// lors du chargement des données utilisateur
  Widget errorMsg() {
    return centeredMsg(
      'assets/icon.png',
      "Oups il y a un problème lors du chargement des données utilisateur...",
      Colors.green,
    );
  }

  /// affiche un message sur fond rose
  ///  invitant jonny à
  /// patienter
  Widget loadingMsg() {
    return centeredMsg(
      'assets/icon.png',
      "Veuillez patienter svp...",
      Colors.purple,
    );
  }

  //// si il existe 1 ou plusieurs bébé leçons
  /// matures, il faut les afficher
  bool theresLessonsToDisplay(Report userReport) {
    /// the mature baby lessons of the correct category
    List matureFilteredLessons = getMatureFilteredLessons(userReport);

    /// how many of them exist ?
    var qtyMatureBabyLessons = matureFilteredLessons.length;

    return qtyMatureBabyLessons > 0;
  }

  List<BabyLesson> getMatureLessons(Report userReport) {
    return userReport.babyLessons.where((babyLesson) {
      return babyLesson.isMature;
    }).toList();
  }

  List<BabyLesson> getMatureFilteredLessons(Report userReport) {
    return userReport.babyLessons.where((babyLesson) {
      return babyLesson.isMature && babyLesson.category == _category;
    }).toList();
  }

  /// affiche les bébé leçons matures,
  /// classés par catégorie.
  ///
  ///
  /// par défaut, on affiche tout,
  /// mais on peut classer les leçons
  /// par catégorie. topbar
  Widget displayLessons(Report userReport) {
    var matureFilteredLessons = getMatureFilteredLessons(userReport);

    return Scaffold(
      appBar: topBar(userReport),
      body: listViewLessons(matureFilteredLessons),
    );
  }

  Widget theresNoLessons(Report userReport) {
    return centeredMsg(
      "assets/icon.png",
      "Il n'existe pas encore de leçons.",
      Colors.pink,
    );
  }

  topBar(Report userReport) {
    return AppBar(
      title: titleNavigation(userReport),
      actions: <Widget>[
        profileButton(userReport),
      ],
    );
  }

  Widget titleNavigation(Report userReport) {
    return new GestureDetector(
      onTap: () {
        changeCategoryActions();
      },
      child: new Text(_category),
    );
  }

  listViewLessons(List<BabyLesson> matureFilteredLessons) {}

  profileButton(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.supervised_user_circle,
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/profile');
      },
    );
  }

  changeCategoryActions() {
    Future<Choice> userChoice = getUserChoice(
      context,
      "Tu veux voir les leçons de quelle catégorie ?",
      choices,
    );

    fnForCategoryChoice(userChoice);
  }

  void fnForCategoryChoice(Future<Choice> futureChoice) {
    futureChoice.then((choice) {
      if (choice == NO_FUTURE_CHOICE) {
        return noChoice();
      } else {
        return doSomethingWChoice();
      }
    });
  }
}
