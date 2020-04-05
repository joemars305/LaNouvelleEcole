/*import 'package:flutter/material.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';
import '../parts/consts.dart';

class Template extends StatefulWidget {
  Template({Key key}) : super(key: key);

  @override
  _TemplateState createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
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
      appBar: getTemplateBar(screenType, userReport),
      body: getTemplateBody(screenType, userReport),
      bottomNavigationBar: getTemplateBottomBar(screenType, userReport),
    );
  }

  /// screenType Report => Widget
  /// 
  /// La barre en haut de l'écran
  Widget getTemplateBar(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return getTemplateBarForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return getTemplateBarForMap(screenType, userReport); 
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getTemplateBarForThingsToDo(int screenType, Report userReport) {
    
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getTemplateBarForMap(int screenType, Report userReport) {
    
  }

  /// screenType Report => Widget
  /// 
  /// le contenu entre top bar et bottom bar
  Widget getTemplateBody(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return getTemplateBodyForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return getTemplateBodyForMap(screenType, userReport); 
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getTemplateBodyForThingsToDo(int screenType, Report userReport) {
    
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getTemplateBodyForMap(int screenType, Report userReport) {
    
  }

  /// screenType Report => Widget
  /// 
  /// la barre en bas de l'écran
  Widget getTemplateBottomBar(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return getTemplateBottomBarForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return getTemplateBottomBarForMap(screenType, userReport); 
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getTemplateBottomBarForThingsToDo(int screenType, Report userReport) {
    
  }

  /// screenType Report => Widget
  /// 
  /// 
  Widget getTemplateBottomBarForMap(int screenType, Report userReport) {
    
  }
}*/
