import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/*
 
*/
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  /* l'user est il logged in ou pas ? (resultat une seule fois) */
  Future<FirebaseUser> get getUser => _auth.currentUser();

  /* l'user est il logged in ou pas ? (listener qui écoute tout changement d'auth) */
  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  /*
  Login l'user avec Google
  */
  Future<FirebaseUser> googleSignIn() async {
    // essaie de login...
    try {
      /* affiche la fenètre popup permettant à 
      l'user de se connecter via un compte google */
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      
      /* contient un access token et un id token
      si la connexion s'est bien passé */
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      /* Pour se connecter à Firebase, nous avons besoin d'un credential
      que nous obtenons ici, grace aux tokens ci dessus */ 
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      /* log in l'user avec firebase
       */
      FirebaseUser user = await _auth.signInWithCredential(credential);
      
      /* enregistre / met a jour l'entry concernant cet 
      user dans la base de données firebase */
      updateUserData(user);

      return user;
    } 
    // en cas de blème pro, print le message d'erreur
    catch (error) {
      print(error);
      return null;
    }
  }

  /*
  Log in l'user anonymement, avec un user id
   */
  Future<FirebaseUser> anonLogin() async {
    // appelle firebase, et demande à firebase de créer un user id
    FirebaseUser user = await _auth.signInAnonymously();
    
    // écrit dans la base de donnée firebase
    // une entry représentant cet user
    updateUserData(user);
    return user;
  }

  /* Ecrit des données dans firestore concernant 
  l'user */
  Future<void> updateUserData(FirebaseUser user) {
    /* retrouve le document de l'user dans 
    la collection 'reports', 
    grace a l'UID de l'user
    (chaque user a un UID qui lui est propre,
    lorsque il est logged in dans firebase */
    DocumentReference reportRef = _db.collection('reports').document(user.uid);

    /* on écrit des infos de base concernant
    l'user, notamment:
    - l'UID (user id) de l'user
    - l'heure a laquelle l'user s'est login
    'merge: true' signifie qu'on veut ajouter
    ces données au dossier de l'user, et non remplacer
    totalement le dossier de l'user */
    return reportRef.setData({
      'uid': user.uid,
      'lastActivity': DateTime.now()
    }, merge: true);

  }

  /* Permet à l'user de log out */
  Future<void> signOut() {
    return _auth.signOut().then((_) {
      _googleSignIn.signOut();
    });
  }

}





