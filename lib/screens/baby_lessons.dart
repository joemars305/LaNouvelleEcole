import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizapp/parts/toolbox.dart';
import '../services/services.dart';
import '../parts/parts.dart';

// l'écran affichant toutes les
// leçons en cours de création
class BabyLessonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return listOfLessonsOrMessage();
  }

  /// si il y a aucun bébé leçon existant,
  /// affiche un message informant l'utilisateur
  ///
  /// si il y en a, affiche la liste de bébé leçons
  StreamBuilder<Report> listOfLessonsOrMessage() {
    return StreamBuilder<Report>(
        /** dans la collection 'reports' ,
         * on surveille le document 
         * relatif à l'utilisateur
        */
        stream: Global.reportRef.documentStream,
        builder: (context, snapshot) {
          var panel;

          /** Si il y une erreur durant la 
           * récup du document utilisateur,
           * affiche l'erreur */
          if (snapshot.hasError) {
            panel = userDataLoadingError(snapshot);
          }

          switch (snapshot.connectionState) {
            /** si stream: null, ce message s'affiche */
            case ConnectionState.none:
              panel = noUserDataMsg();
              break;

            /** s'affiche lorsque les données sont en cours de chargement */
            case ConnectionState.waiting:
              panel = userDataLoadingMsg();
              break;

            /** s'affiche lorsque les données sont chargées */
            default:
              /** Le dossier Report de l'utilisateur
               * (voir la classe Report dans 
               * models.dart pour plus de détails sur ce dossier)
               */
              var userData = snapshot.data;

              print(userData);

              /** la liste de bébé leçons 
               * de l'utilisateur */
              var babyLessons = userData.babyLessons;

              /** Si l'utilisateur à crée au moins 1 bébé leçon... */
              if (babyLessons.length > 0) {
                /** affiche un liste des bébé leçons */
                panel = listOfLessons(userData);
              }
              /** si l'utilisateur n'a pas crée de bébé leçons... */
              else {
                /** affiche un message invitant l'utilisateur
                 * à créer un bébé leçon
                 */
                panel = noLessonsMessage(context);
              }
          }

          return Scaffold(
            appBar: topBar(context),
            /** affiche nos bébés leçons */
            body: panel,
          );
        });
  }

  NoDataMessage noLessonsMessage(BuildContext context) {
    return new NoDataMessage(
      message:
          "Tu n'as pas encore crée de leçon. Pour en créer une, appuie sur le bouton ci-dessous, ou appuie sur + dans la barre en haut de l'écran.",
      buttonIcon: FontAwesomeIcons.babyCarriage,
      buttonText: "Crée une nouvelle leçon",
      imagePath: "assets/covers/baby.png",
      /** lorsque l'utilisateur appuie sur
       * le bouton de création de bébé leçon,
       * il est redirigé vers l'écran
       * de création de bébé leçon,
       * ou il choisis un nom, et une catégorie
       * pour son bébé leçon
       */
      buttonAction: () {
        Navigator.pushNamed(context, '/create_fetus_lesson');
      },
      buttonColor: Colors.pinkAccent,
    );
  }

  Center userDataLoadingMsg() {
    return Center(
      child: Text(
        'Chargement...',
        style: TextStyle(
            //fontFamily: 'ComingSoon',
            ),
      ),
    );
  }

  Center noUserDataMsg() {
    return Center(
        child: Text(
      'Aucune données en attente...',
      style: TextStyle(
          //fontFamily: 'ComingSoon',
          ),
    ));
  }

  Center userDataLoadingError(AsyncSnapshot<Report> snapshot) {
    return Center(
      child: Text(
        'Erreur: ${snapshot.error}',
        style: TextStyle(
            //fontFamily: 'ComingSoon',
            ),
      ),
    );
  }

  AppBar topBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Bébé Leçons',
        style: TextStyle(
            //fontFamily: 'ComingSoon',
            ),
      ),
      backgroundColor: Colors.blue,
      actions: [
        /** le bouton en forme de + qui nous 
         * redirige vers l'écran de création de bébé leçon */
        IconButton(
          icon: Icon(FontAwesomeIcons.plus, color: Colors.green[200]),
          onPressed: () => Navigator.pushNamed(context, '/create_fetus_lesson'),
        )
      ],
    );
  }

  // la liste de bébé leçons a l'écran
  ListView listOfLessons(Report userReport) {
    return new ListView.builder(
      itemCount: userReport.babyLessons.length,
      // crée une liste de bébé leçons
      // qu'on peut supprimer en swipant
      itemBuilder: (context, index) {
        return Dismissible(
          onDismissed: (DismissDirection direction) async {
            await deleteLesson(userReport, index);
          },
          child: babyLessonCard(context, userReport, index),
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
        );
      },
    );
  }

  Widget babyLessonCard(BuildContext context, Report userReport, int index) {
    var babyLesson = userReport.babyLessons[index];
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    var thumbnailUrl = babyLesson.thumbnailUrl;
    var userIconUrl = user.photoUrl;

    return LessonItem(
      thumbnailUrl: thumbnailUrl,
      photoUrl: userIconUrl,
      name: babyLesson.name,
      createdBy: babyLesson.createdBy,
      creationDate: babyLesson.creationDate,
      onTap: () {
        // stocke l'index de ce bébé leçon
        userReport.setLatestBabyLessonSeen(index);
        userReport.save();

        Navigator.pushNamed(
          context,
          '/step_creation',
          /*arguments: ScreenArguments(
            userReport,
            index,
          ),*/
        );
      },
    );
  }
}
