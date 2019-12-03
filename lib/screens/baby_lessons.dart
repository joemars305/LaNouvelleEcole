import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/services.dart';
import '../shared/shared.dart';

//  l'écran affichant toutes les leçons en cours de création
class BabyLessonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bébé Leçons'),
        backgroundColor: Colors.blue,
        actions: [
          /** le bouton en forme de + qui nous 
           * redirige vers l'écran de création de bébé leçon */
          IconButton(
            icon: Icon(FontAwesomeIcons.plus, color: Colors.green[200]),
            onPressed: () => Navigator.pushNamed(context, '/create_fetus_lesson'),
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
              return Text('Erreur: ${snapshot.error}');
            }

            switch (snapshot.connectionState) {
              /** si stream: null, ce message s'affiche */
              case ConnectionState.none:
                return Text('Aucune données en attente...');

              /** s'affiche lorsque les données sont en cours de chargement */
              case ConnectionState.waiting:
                return Text('Chargement...');

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
                  return Text(userData.uid);
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
  ListView _babyLessonsList(snapshot) {
    return new ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, index) {
        return new BabyLessonItem(snapshot.data.documents[index]);
      },
    );
  }
}

// le layout d'un bébé leçon individuel à l'écran
class BabyLessonItem extends StatelessWidget {
  const BabyLessonItem(this.babyLesson);

  final babyLesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          babyLesson['name'],
        ),
        const SizedBox(height: 8.0),
        Text(
          babyLesson['created_by'],
        ),
      ],
    );
  }
}
