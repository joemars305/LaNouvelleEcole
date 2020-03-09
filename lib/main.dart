import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'package:provider/provider.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {  
    /* La librairie Provider nous permet d'avoir accès 
    au données de l'user partout dans notre application,
    grâce au MultiProvider, wrapped autour de MaterialApp.
    MultiProvider nous permet d'avoir acces a des valeurs, ou des Stream
    partout dans l'appli */
    return MultiProvider(
      providers: [
        StreamProvider<Report>.value(
          value: Global.reportRef.documentStream,
          catchError: (_, __) => null,
        ),
        StreamProvider<FirebaseUser>.value(
          value: AuthService().user,
          catchError: (_, __) => null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner:  false,
        // Firebase Analytics
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
        ],

        // Les différentes routes
        // que nous pouvons prendre
        // dans cette application
        routes: {
          '/': (context) => LoginScreen(),
          '/topics': (context) => TopicsScreen(),
          '/baby_lessons': (context) => BabyLessonsScreen(),
          '/profile': (context) => ProfileScreen(),
          '/favorites': (context) => FavoritesScreen(),
          '/create_fetus_lesson': (context) => CreateFetusPage(),
          '/step_creation': (context) => StepCreation(),
          '/pick_video': (context) => PickPhotoVideo(),
          '/lesson_viewer': (context) => LessonViewer(),
        },

        // Les différents styles dispos
        // globalement dans l'appli
        theme: ThemeData(
          fontFamily: 'ComingSoon',
          bottomAppBarTheme: BottomAppBarTheme(
            color: Colors.black87,
          ),
          brightness: Brightness.dark,
          textTheme: TextTheme(
            // le style par défaut d'un Text()
            // par ex: le texte d'accueil
            // 'Ici commence l'école du futur...'
            // est body1
            body1: TextStyle(fontSize: 22),

            
            //body2: TextStyle(fontSize: 16),

            // le style du texte d'un bouton
            button: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
            
            // met le texte en gras
            headline: TextStyle(fontWeight: FontWeight.bold),

            // utile pour différencier 
            // deux textes , 
            // en appliquant une couleur différente
            subhead: TextStyle(color: Colors.grey),
          ),
          buttonTheme: ButtonThemeData(),
        ),
      ),
    );
  }
}
