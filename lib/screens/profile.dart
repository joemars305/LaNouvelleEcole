import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import '../shared/shared.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    /* Provider.of<type>(context) 
    nous permet d'accéder aux 
    données utilisateur partout dans l'appli
    grace a MultiProvider dans main.dart */
    //Report report = Provider.of<Report>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);

    if (user != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(user.displayName ?? 'Guest'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              roundicon(user),
              Text(user.email ?? '',
                  style: Theme.of(context).textTheme.headline),
              Spacer(),
              
              Spacer(),
              /* le bouton de déconnexion */
              FlatButton(
                  child: Text('logout'),
                  color: Colors.red,
                  onPressed: () async {
                    await auth.signOut();
                    /* grace a pushNamedAndRemoveUntil, le bouton back
                  ne va pas nous montrer les écrans que seuls 
                  les users logged in peuvent voir.
                  clean history */
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }),
              Spacer()
            ],
          ),
        ),
      );
    } else {
      return LoadingScreen();
    }
  }

  Container roundicon(FirebaseUser user) {
    if (user.photoUrl != null) {
      return Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.only(top: 50),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(user.photoUrl),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
