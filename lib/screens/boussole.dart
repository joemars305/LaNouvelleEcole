import 'package:flutter/material.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';
import '../parts/consts.dart';

class Boussole extends StatefulWidget {
  Boussole({Key key}) : super(key: key);

  @override
  _BoussoleState createState() => _BoussoleState();
}

class _BoussoleState extends State<Boussole> {
  var key = GlobalKey();

  /// BuildContext => Widget
  ///
  /// Produit 2 écrans, au choix:
  ///
  /// - un panneau Agenda, affichant une liste des 'choses a faire',
  /// pour chaque jour, nous permettant de créer/modifier/annuler
  /// des 'choses a faire' a un moment donné, a un jour donné.
  ///
  /// - un panneau Carte, qui affiche une carte Google Maps
  /// centrée sur la position actuelle, et possibilité de rajouter des
  /// des marqueurs avec un nom et un type.
  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<Report>(
      stream: Global.reportRef.documentStream,
      builder: (BuildContext context, AsyncSnapshot<Report> snapshot) {
        /// if we received the userReport
        if (snapshot.hasData) {
          return boussolePanel(screenType, snapshot.data);
        }

        /// if something got wrong trying
        /// to get userReport
        else if (snapshot.hasError) {
          return centeredMsg(
              "assets/icon.png",
              "Oups, une erreur est survenue lors du chargement des données utilisateur...",
              Colors.pink);
        }

        /// if we're loading userReport
        else {
          return centeredMsg(
              "assets/icon.png", "Chargement en cours...", Colors.pink);
        }
      },
    );
  }

  /// screenType représente:
  ///
  /// - soit une liste de choses à faire, THINGS_TO_DO
  /// - soit une carte avec marqueurs, MAP
  int screenType = THINGS_TO_DO;


  /*

  /// screenType Report => Widget
  /// 
  /// 
  Widget fnForScreenType(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return fnForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return fnForMap(screenType, userReport); 
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  */

  /// screenType Report => Widget
  /// 
  /// le planing ou la carte, 
  /// interchangeable avec un bouton situé topbar
  Widget boussolePanel(int screenType, Report userReport) {
    return Scaffold(
      key: key,
      appBar: getBoussoleBar(screenType, userReport),
      body: getBoussoleBody(screenType, userReport),
      bottomNavigationBar: getBoussoleBottomBar(screenType, userReport),
    );
  }

  /// screenType Report => Widget
  /// 
  /// La barre en haut de l'écran
  Widget getBoussoleBar(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return getBoussoleBarForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return getBoussoleBarForMap(screenType, userReport); 
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getBoussoleBarForThingsToDo(int screenType, Report userReport) {
    return AppBar(
      title: Text("Tu fé koi ojourdui ?"),
      actions: <Widget>[
        changeScreenTypeButton(screenType),
      ],
    );
  }

  /// screenType => void
  ///
  /// le bouton permettant de passer 
  /// de la carte à la liste de taches, et vice versa
  Widget changeScreenTypeButton(int screenType) {
    return IconButton(
      icon: Icon(
        changeScreenButtonIcon(screenType),
      ),
      onPressed: () {
        changeScreenType(screenType);
      },
    );
  }

  /// screenType => void
  /// 
  /// change d'écran entre carte et liste et vice versa
  void changeScreenType(int screenType) {
    if (screenType == THINGS_TO_DO) {
      setState(() {
        screenType = MAP;
      });
    } else if (screenType == MAP) {
      setState(() {
        screenType = THINGS_TO_DO;
      });
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType => void
  /// 
  /// l'icone 
  IconData changeScreenButtonIcon(int screenType) {
    if (screenType == THINGS_TO_DO) {
      return Icons.list;
    } else if (screenType == MAP) {
      return Icons.map;
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getBoussoleBarForMap(int screenType, Report userReport) {
    return AppBar(
      title: Text("La carte"),
      actions: <Widget>[
        changeScreenTypeButton(screenType),
      ],
    );
  }

  /// screenType Report => Widget
  /// 
  /// le contenu entre top bar et bottom bar
  Widget getBoussoleBody(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return getBoussoleBodyForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return getBoussoleBodyForMap(screenType, userReport); 
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  /// 
  /// la liste de choses à faire
  Widget getBoussoleBodyForThingsToDo(int screenType, Report userReport) {
    var thingsToDo = userReport.notesToFutureSelf;

    return ListView.builder(
      itemCount: thingsToDo.length,
      itemBuilder: (context, index) {
        return singleThingToDo(userReport, index);
      },
    );
  }

  /// Report int => Widget
  /// 
  /// l'étiquette pour une chose à faire
  Widget singleThingToDo(Report userReport, int index) {
    
  }

  /// screenType Report => Widget
  /// 
  /// la carte
  Widget getBoussoleBodyForMap(int screenType, Report userReport) {
    
  }

  /// screenType Report => Widget
  /// 
  /// la barre en bas de l'écran
  Widget getBoussoleBottomBar(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return getBoussoleBottomBarForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return getBoussoleBottomBarForMap(screenType, userReport); 
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getBoussoleBottomBarForThingsToDo(int screenType, Report userReport) {
    
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getBoussoleBottomBarForMap(int screenType, Report userReport) {
    
  }
}
