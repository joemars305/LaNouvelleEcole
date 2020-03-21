import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle bottomText = TextStyle(fontFamily: 'ComingSoon');

    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.graduationCap, size: 20),
            title: Text('Leçons', style: bottomText,)),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heart, size: 20),
            title: Text('Favoris', style: bottomText,)),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.compass, size: 20),
            title: Text('Boussole', style: bottomText,)),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.babyCarriage, size: 20),
            title: Text('Bébé leçons', style: bottomText,)),
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
            Navigator.pushNamed(context, '/boussole');
            break;
          case 3:
            Navigator.pushNamed(context, '/baby_lessons');
            break;
        }
      },
    );
  }
}