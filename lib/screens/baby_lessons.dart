import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
//import 'package:quizapp/screens/screens.dart';
import '../services/services.dart';
import '../shared/shared.dart';

// l'écran affichant toutes les
// leçons en cours de création
class BabyLessonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onPressed: () =>
                Navigator.pushNamed(context, '/create_fetus_lesson'),
          )
        ],
      ),
      /** affiche nos bébés leçons */
      body: StreamBuilder<Report>(
          /** dans la collection 'reports' ,
           * on surveille le document 
           * relatif à l'utilisateur
          */
          stream: Global.reportRef.documentStream,
          builder: (context, snapshot) {
            /** Si il y une erreur durant la 
             * récup du document utilisateur,
             * affiche l'erreur */
            if (snapshot.hasError) {
              return Text(
                'Erreur: ${snapshot.error}',
                style: TextStyle(
                  //fontFamily: 'ComingSoon',
                ),
              );
            }

            switch (snapshot.connectionState) {
              /** si stream: null, ce message s'affiche */
              case ConnectionState.none:
                return Center(
                    child: Text(
                  'Aucune données en attente...',
                  style: TextStyle(
                    //fontFamily: 'ComingSoon',
                  ),
                ));

              /** s'affiche lorsque les données sont en cours de chargement */
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Chargement...',
                    style: TextStyle(
                      //fontFamily: 'ComingSoon',
                    ),
                  ),
                );

              /** s'affiche lorsque les données sont chargées */
              default:
                /** Le dossier Report de l'utilisateur
                 * (voir la classe Report dans 
                 * models.dart pour plus de détails sur ce dossier)
                 */
                var userData = snapshot.data;

                /** la liste de bébé leçons 
                 * de l'utilisateur */
                var babyLessons = userData.babyLessons;

                /** Si l'utilisateur à crée au moins 1 bébé leçon... */
                if (babyLessons.length > 0) {
                  /** affiche un liste des bébé leçons */
                  return babyLessonsList(userData);
                }
                /** si l'utilisateur n'a pas crée de bébé leçons... */
                else {
                  /** affiche un message invitant l'utilisateur
                   * à créer un bébé leçon
                   */
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
            }
          }),
    );
  }

  // la liste de bébé leçons a l'écran
  ListView babyLessonsList(Report userReport) {
    return new ListView.builder(
      itemCount: userReport.babyLessons.length,
      // crée une liste de bébé leçons
      // qu'on peut supprimer en swipant
      itemBuilder: (context, index) {
        return Dismissible(
          onDismissed: (DismissDirection direction) {
            // une fois swipé, on supprime le bébé leçon
            // situé à la position 'index', dans la liste de bébé leçons
            // de l'utilisateur
            userReport.babyLessons.removeAt(index);

            // puis on met à jour le Report
            Global.reportRef.upsert(userReport.toMap());
          },
          child: BabyLessonCard(userReport: userReport, index: index),
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
        );
      },
    );
  }
}

//// le layout d'un bébé leçon individuel 
/// dans la liste de bébé leçons 
class BabyLessonCard extends StatelessWidget {
  // les données utilisateur
  final Report userReport;

  // la position du bébé leçon dans la liste de bébé leçons
  final int index;

  

  BabyLessonCard({this.userReport, this.index});

  @override
  Widget build(BuildContext context) {
    // grab the bébé leçon by the umbilical cord
    BabyLesson babyLesson = userReport.babyLessons[index];
    FirebaseUser user = Provider.of<FirebaseUser>(context);

    return LessonItem(
      photoUrl: user.photoUrl,
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

    /*Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Image.asset("assets/covers/baby.png"),
          ),
          // le nom de la leçon
          title: Text(babyLesson.name,
              style: Theme.of(context).textTheme.headline),
          // les informations a propos de cette leçon
          // (le nom du créateur de cette leçon, la date de création, la catégorie de la leçon)
          subtitle: Text(
              "Crée par " +
                  babyLesson.createdBy +
                  "\n"
                      "Le " +
                  babyLesson.creationDate +
                  "\n" +
                  "Categorie: " +
                  babyLesson.category,
              style: Theme.of(context).textTheme.subhead),
          // lorsque qu'on clique sur cette leçon
          // on va vers l'écran de création d'étapes
          onTap: () {
            Navigator.pushNamed(
              context,
              StepCreation.routeName,
              arguments: ScreenArguments(
                userReport,
                index,
              ),
            );
          },
        ),
      ),
    );*/
  }
}
