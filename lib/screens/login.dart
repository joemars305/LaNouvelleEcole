import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import '../shared/shared.dart';
import '../services/services.dart';

///
///
/// Ceci représente l'écran d'accueil que l'on
/// voit quand on à pas encore crée un compte,
/// et quand on est pas connecté a Google
/// 
class LoginScreen extends StatefulWidget {
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();

    /** Si l'user est déja logged in, redirigeons le
     * vers l'écran des categories de leçons
     */
    auth.getUser.then(
      (user) {
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/topics');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold est la base sur laquelle
    // on crée le layout de notre appli.
    // il nous permet d'ajouter des drawers,
    // des messages Snackbar, etc...
    return Scaffold(
      // représente la surface totale de
      // l'écran de l'utilisateur,
      // en dessous de la barre en haut de l'écran
      // (heure, icones etc).
      body: Container(
        padding: EdgeInsets.all(25),
        // une liste verticale de
        // tous les éléments de l'écran
        // de login.
        child: ListView(
          children: <Widget>[
            /** le logo  */
            Image.asset(
              'assets/icon.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            /** espace vital */
            Container(
              height: 30,
            ),
            /** Le titre */
            Text(
              'La Nouvelle Ecole ❤️',
              style: TextStyle(
                //fontFamily: 'ComingSoon',
                fontSize: 30,
              ),
              
              textAlign: TextAlign.center,
            ),
            /** espace vital */
            Container(
              height: 30,
            ),
            /** 
             * le texte descriptif 
             * */
            Text(
              "Ici commence l'école du futur. L'école qui apprend à chaque citoyen, de 7 à 77 ans, à subvenir à ses besoins vitaux.",
              style: TextStyle(fontFamily: 'ComingSoon'),
              textAlign: TextAlign.center,
            ),
            /** espace vital */
            Container(
              height: 30,
            ),
            /** Le bouton pour se connecter via Google */
            LoginButton(
              text: 'Connexion avec Google',
              icon: FontAwesomeIcons.google,
              color: Colors.black45,
              loginMethod: auth.googleSignIn,
              font: 'Bitter',
            ),
            /** Le bouton pour se connecter anonymement */
            //LoginButton(text: 'Connexion anonyme', loginMethod: auth.anonLogin)
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;
  final String font;

  const LoginButton(
      {Key key, this.text, this.icon, this.color, this.loginMethod, this.font})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: () async {
          var user = await loginMethod();
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/topics');
          }
        },
        label: Expanded(
          child: Text(
            '$text', 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontFamily: font,
            ),
          ),
        ),
      ),
    );
  }
}
