import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/** La barre de navigation en bas de TopicsScreen */
class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.graduationCap, size: 20),
            title: Text('Leçons')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heart, size: 20),
            title: Text('Favoris')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.babyCarriage, size: 20),
            title: Text('Bébé leçons')),
      ].toList(),
      fixedColor: Colors.deepPurple[200],
      onTap: (int idx) {
        switch (idx) {
          case 0:
            // do nuttin
            break;
          case 1:
            Navigator.pushNamed(context, '/favorites');
            break;
          case 2:
            Navigator.pushNamed(context, '/baby_lessons');
            break;
        }
      },
    );
  }
}