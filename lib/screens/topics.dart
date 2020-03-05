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
    return StreamBuilder<List<Report>>(
      initialData: [],
      stream: Global.reportsRef.streamData(),
      builder: (BuildContext context, AsyncSnapshot<List<Report>> snapshot) {
        /// le contenu de l'écran sous la top bar
        var panel;

        /// if there's data, and there's
        /// mature lessons
        if (snapshot.hasData) {
          /// tous les Report utilisateurs
          var userReports = snapshot.data;

          /// une liste de leçons a afficher
          List<BabyLesson> matureLessons =
              getMatureFilteredLessons(userReports);

          /// si il existe des leçons matures
          /// parmi les bébé leçons des utilisateurs
          /// affiche ces leçons,
          if (theresLessonsToDisplay(userReports)) {
            panel = listViewLessons(matureLessons);
          }

          /// sinon, affiche un
          /// NoDataMessage
          else {
            panel = theresNoLessons();
          }
        }

        /// if something got wrong trying
        /// to get userReports
        else if (snapshot.hasError) {
          print(snapshot.error);
          
          /// inform the user about it
          panel = errorMsg();
        }

        /// if we're loading userReports
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
  bool theresLessonsToDisplay(List<Report> userReports) {
    /// the mature baby lessons of the correct category,
    /// for all users
    List matureFilteredLessons = getMatureFilteredLessons(userReports);

    /// how many of them exist ?
    var qtyMatureBabyLessons = matureFilteredLessons.length;

    return qtyMatureBabyLessons > 0;
  }

  /// on veut tous les bébé leçons matures
  /// de tous les utilisateurs de la communauté,
  /// seulement si ils sont de la bonne catégorie
  List<BabyLesson> getMatureFilteredLessons(List<Report> userReports) {
    /// a list of the all the baby lessons of all the users
    List<BabyLesson> allBabyLessons = getAllBabyLessons(userReports);

    /// filter this shit out
    return filteredBabyLessons(allBabyLessons);
  }

  List<BabyLesson> getAllBabyLessons(List<Report> userReports) {
    return userReports
        .map((userReport) {
          return userReport.babyLessons;
        })
        .expand((listOfBabies) => listOfBabies)
        .toList();
  }

  Widget theresNoLessons() {
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

  List<BabyLesson> filteredBabyLessons(List<BabyLesson> allBabyLessons) {
    return allBabyLessons.where((babyLesson) {
      return babyLesson.isMature && babyLesson.category == _category;
    }).toList();
  }
}
