import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizapp/parts/consts.dart';
import 'package:quizapp/parts/toolbox.dart';
import 'package:quizapp/shared/bottom_nav.dart';
import 'package:quizapp/shared/lesson_item.dart';
import '../services/services.dart';

class TopicsScreen extends StatefulWidget {
  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  /// _category représente la catégorie de
  /// leçon à afficher
  String _category = NOURRITURE;

  /// nous permet d'afficher des snackbar
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Report>(
      stream: Global.reportRef.documentStream,
      builder: (BuildContext context, AsyncSnapshot<Report> snapshot) {
        var panel;

        /// if we received the userReport
        if (snapshot.hasData) {
          /// affiche la liste de leçons,
          /// ou un NoDataMessage
          panel = listOfLessons(snapshot.data);
        }

        /// if something got wrong trying
        /// to get userReport
        else if (snapshot.hasError) {
          /// inform the user about it
          panel = errorMsg();
        }

        /// if we're loading userReport
        else {
          /// tell johnny to wait
          panel = loadingMsg();
        }

        return Scaffold(
          key: _key,
          appBar: topBar(),
          body: panel,
          bottomNavigationBar: AppBottomNav(),
        );
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

    return listViewLessons(matureFilteredLessons);
  }

  Widget theresNoLessons(Report userReport) {
    return centeredMsg(
      "assets/icon.png",
      "Il n'existe pas encore de leçons.",
      Colors.pink,
    );
  }

  topBar() {
    return AppBar(
      title: titleNavigation(),
      actions: <Widget>[
        profileButton(),
      ],
    );
  }

  Widget titleNavigation() {
    return new GestureDetector(
      onTap: () {
        changeCategoryActions();
      },
      child: new Text(_category),
    );
  }

  listViewLessons(List<BabyLesson> matureFilteredLessons) {
    return ListView.builder(
      // combien d' objets
      itemCount: matureFilteredLessons.length,
      // crée une liste d'items
      // qu'on peut supprimer en swipant
      itemBuilder: (context, index) {
        var babyLesson = matureFilteredLessons[index];
        var user = Provider.of<FirebaseUser>(context);
        var thumbnailUrl = babyLesson.thumbnailUrl;

        return LessonItem(
          thumbnailUrl: thumbnailUrl,
          photoUrl: user.photoUrl,
          name: babyLesson.name,
          createdBy: babyLesson.createdBy,
          creationDate: babyLesson.creationDate,
          onTap: () {
            print("coké");
          },
        );
      },
    );
  }

  profileButton() {
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
    var choices = categories.map((category) {
      return Choice(category, category);
    }).toList();

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
        return noCategoryChoice();
      } else {
        return handleCategoryChange(choice);
      }
    });
  }

  void handleCategoryChange(Choice choice) {
    setState(() {
      _category = choice.choiceValue;
    });
  }

  void noCategoryChoice() {
    displaySnackbar(_key, "On ne change pas de catégorie !", 2500);
  }
}
