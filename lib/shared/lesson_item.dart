/**
 * représente le panneau publicitaire 
 * d'une leçon individuelle
 * 
 * donne des infos sur la leçon
 * qui l'a créee, etc...
 */

import 'package:flutter/material.dart';
import 'package:quizapp/parts/consts.dart';

class LessonItem extends StatelessWidget {
  final String thumbnailUrl;
  final String photoUrl;
  final String name;
  final String creationDate;
  final String createdBy;
  final Function onTap;

  final double userIconWidth = 50;
  final double userIconHeight = 50;

  LessonItem(
      {this.photoUrl,
      this.thumbnailUrl,
      this.createdBy,
      this.creationDate,
      this.name,
      this.onTap});

  // l'image de la leçon,
  // ainsi que les infos sur la leçon
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.all(8.0),
        decoration: outerFrameDecoration(),
        child: thumbnailAndInfoColumn(),
      ),
      onTap: onTap,
    );
  }

  Column thumbnailAndInfoColumn() {
    return Column(
      children: [
        thumbnailSection(),
        infoSection(),
      ],
    );
  }

  BoxDecoration outerFrameDecoration() {
    return BoxDecoration(
      color: Colors.cyan,
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    );
  }

  // tout ce qu'il ya sous la photo
  // (une photo de profil du compte google de l'user
  // , et des infos sur la leçon)
  Widget infoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(top: 20),
      decoration: infoSectionDecoration(),

      // a row of 2 items
      // (a round user profile,
      //  and a column of lesson info)
      child: userPhotoAndInfo(),
    );
  }

  Row userPhotoAndInfo() {
    return Row(
      // start permet d'aligner le
      // contenu des rows entre eux
      // (la photo de profil et le texte),
      // en haut de l'espace attribué à chaque row
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // the round google user profile
        googleUserPic(),
        infoLayout(),
      ],
    );
  }

  ///
  ///
  /// the column of lesson info
  ///
  /// Putting a Column inside an
  /// Expanded widget stretches the
  /// column to use all remaining
  /// free space in the row.
  ///
  /// Setting the crossAxisAlignment
  /// property to CrossAxisAlignment.start
  /// positions the column at the start
  /// of the row.
  ///
  Expanded infoLayout() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* the name of the lesson */
          lessonName(),
          /** the name of the google account
           * of the user who made this lessson
           */
          createdByWho(),
          /** the Date Of Birth of the lesson
           */
          createdWhen(),
        ],
      ),
    );
  }

  Text createdWhen() {
    return Text(
      "Crée le: " + creationDate,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Bitter'),
    );
  }

  Text createdByWho() {
    return Text(
      "Crée par: " + createdBy,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontFamily: 'Bitter',
      ),
    );
  }

  Container lessonName() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        name,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'ComingSoon'),
      ),
    );
  }

  Container googleUserPic() {
    return Container(
      width: userIconWidth,
      height: userIconHeight,
      margin: EdgeInsets.only(right: 25),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(photoUrl),
        ),
      ),
    );
  }

  BoxDecoration infoSectionDecoration() {
    return BoxDecoration(
      color: Colors.deepOrange,
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    );
  }

  // le layout de l'image de la leçon
  Widget thumbnailSection() {
    return Container(
      height: 175,
      width: 350,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),

      child: FadeInImage(
        placeholder: nyanCat(),
        image: thumbnailImage(),
      ),
    );
  }

  nyanCat() {
    return AssetImage(
      'assets/nyan.gif',
    );
  }

  thumbnailImage() {
    if (thumbnailUrl != NO_DATA) {
      return NetworkImage(thumbnailUrl);
    } else {
      return AssetImage("assets/maslow.jpg");
    }
  }
}
