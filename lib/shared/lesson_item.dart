
/**
 * représente le panneau publicitaire 
 * d'une leçon individuelle
 * 
 * donne des infos sur la leçon
 * qui l'a créee, etc...
 */

import 'package:flutter/material.dart';


class LessonItem extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String creationDate;
  final String createdBy;
  final Function onTap;

  final double userIconWidth = 50;
  final double userIconHeight = 50;

  LessonItem(
      {this.photoUrl,
      this.createdBy,
      this.creationDate,
      this.name,
      this.onTap});

  // l'image de la leçon,
  // ainsi que les infos sur la leçon
  @override
  Widget build(BuildContext context) {
    Widget infoSection = getInfoSectionLayout();
    Widget imageSection = getImageSectionLayout();

    return InkWell(
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Column(
          children: [
            imageSection,
            infoSection,
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  // tout ce qu'il ya sous la photo
  // (une photo de profil du compte google de l'user
  // , et des infos sur la leçon)
  Widget getInfoSectionLayout() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),

      // a row of 2 items
      // (a round user profile,
      //  and a column of lesson info)
      child: Row(
        // start permet d'aligner le
        // contenu des rows entre eux
        // (la photo de profil et le texte),
        // en haut de l'espace attribué à chaque row
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // the round google user profile
          Container(
            width: userIconWidth,
            height: userIconHeight,
            margin: EdgeInsets.only(right: 25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(photoUrl),
              ),
            ),
          ),

          /**
         * 
         * the column of lesson info
         * 
         * Putting a Column inside an 
         * Expanded widget stretches the 
         * column to use all remaining 
         * free space in the row. 
         * 
         * Setting the crossAxisAlignment 
         * property to CrossAxisAlignment.start 
         * positions the column at the start 
         * of the row.
         */
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* the name of the lesson */
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ComingSoon'
                    ),
                  ),
                ),
                /** the name of the google account
               * of the user who made this lessson
               */
                Text(
                  "Crée par: " + createdBy,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Bitter',
                  ),
                ),
                /** the Date Of Birth of the lesson
               */
                Text(
                  "Crée le: " + creationDate,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Bitter'
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // le layout de l'image de la leçon
  Widget getImageSectionLayout() {
    return Container(
      height: 175,
      //padding: EdgeInsets.only(left: 50, right: 50, top: 5, bottom: 5,),

      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),

      child: Container(
        decoration: new BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/maslow.jpg"),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
