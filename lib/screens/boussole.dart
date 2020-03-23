import 'package:flutter/material.dart';
import 'package:quizapp/parts/parts.dart';
import 'package:quizapp/services/services.dart';
import '../parts/consts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class Boussole extends StatefulWidget {
  Boussole({Key key}) : super(key: key);

  @override
  _BoussoleState createState() => _BoussoleState();
}

class _BoussoleState extends State<Boussole> with TickerProviderStateMixin {
  /// nous permet d'afficher des snackbar
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  CalendarController _calendarController;

  DateTime _dayChosen;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

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
          return boussolePanel(_screenType, snapshot.data);
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
  /// - soit un calendrier, THINGS_TO_DO
  ///
  /// - soit un écran de création de chose à faire, CREATE_THING_TO_DO
  ///
  /// - soit une carte avec marqueurs, MAP
  int _screenType = THINGS_TO_DO;

  /*

  /// screenType Report => Widget
  /// 
  /// 
  Widget fnForScreenType(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return fnForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return fnForMap(screenType, userReport); 
    } else if (screenType == CREATE_THING_TO_DO) {
      return fnForCreateThing(screenType, userReport); 
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
      key: _scaffoldKey,
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
    } else if (screenType == CREATE_THING_TO_DO) {
      return getBoussoleBarForCreateThing(screenType, userReport);
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
        _screenType = MAP;
      });
    } else if (screenType == MAP) {
      setState(() {
        _screenType = THINGS_TO_DO;
      });
    } else if (screenType == CREATE_THING_TO_DO) {
      setState(() {
        _screenType = THINGS_TO_DO;
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
      return Icons.map;
    } else if (screenType == MAP) {
      return Icons.list;
    } else if (screenType == CREATE_THING_TO_DO) {
      return Icons.list;
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
    } else if (screenType == CREATE_THING_TO_DO) {
      return getBoussoleBodyForCreateThing(screenType, userReport);
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  ///
  /// un calendrier nous permettant d'organiser
  /// des choses à faire au fil du temps.
  ///
  /// en faisant un appui long sur un jour
  /// (aujourd'hui ou futur jour)
  /// on lance un processus de création de chose à faire
  ///
  /// en faisant un appui long sur un jour passé,
  /// on affiche un message expliquant
  /// "La machine à remonter le temps n'a pas encore été inventée (enfin je crois 😄)"
  Widget getBoussoleBodyForThingsToDo(int screenType, Report userReport) {
    return TableCalendar(
      onDayLongPressed: (DateTime dayChosen, List thingsSaved) async {
        addFutureThingToDo(dayChosen, userReport, thingsSaved);
      },
      locale: 'fr_FR',
      availableCalendarFormats: {
        CalendarFormat.month: '1 mois',
        CalendarFormat.twoWeeks: '2 sem.',
        CalendarFormat.week: '1 sem.'
      },
      calendarController: _calendarController,
    );
  }

  /// void => DateTime
  ///
  /// permet d'obtenir une heure choisie par l'utilisateur
  Future<DateTime> getDesiredTime(DateTime dayChosen) {
    /// l'heure actuelle, avec 5 minutes de marge ajoutées
    DateTime currentTime = DateTime.now().add(new Duration(minutes: 5));

    int desiredYear = dayChosen.year;
    int desiredMonth = dayChosen.month;
    int desiredDay = dayChosen.day;
    int desiredHours = currentTime.hour;
    int desiredMinute = currentTime.minute;

    DateTime desiredTime = DateTime(
        desiredYear, desiredMonth, desiredDay, desiredHours, desiredMinute);

    return DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {
        print('change $date');
      },
      onConfirm: (date) {
        print('confirm $date');
      },
      currentTime: desiredTime,
      locale: LocaleType.fr,
    );
  }

  /// DateTime Report List => void
  ///
  ///
  void addFutureThingToDo(
      DateTime dayChosen, Report userReport, List thingsSaved) {
    var today = DateTime.now();

    if (dayChosenIsTodayOrLater(today, dayChosen)) {
      goToCreateThingScreen(dayChosen);
      //addThingToDo(userReport, dayChosen, thingsSaved);
    } else {
      noTimeMachine();
    }
  }

  /// List<NoteToFutureSelf> Report => ListView
  ///
  /// Produit une liste des choses que
  /// l'utilisateur a besoin de faire
  /// éventuellement dans un futur proche
  ListView getListOfThingsToDo(
      List<NoteToFutureSelf> thingsToDo, Report userReport) {
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
    return Text('truc');
  }

  /// screenType Report => Widget
  ///
  /// la carte
  Widget getBoussoleBodyForMap(int screenType, Report userReport) {
    return centeredMsg(
        "assets/icon.png", "La carte sera ici bientôt...", Colors.orange);
  }

  /// screenType Report => Widget
  ///
  /// la barre en bas de l'écran
  Widget getBoussoleBottomBar(int screenType, Report userReport) {
    if (screenType == THINGS_TO_DO) {
      return getBoussoleBottomBarForThingsToDo(screenType, userReport);
    } else if (screenType == MAP) {
      return getBoussoleBottomBarForMap(screenType, userReport);
    } else if (screenType == CREATE_THING_TO_DO) {
      return getBoussoleBottomBarForCreateThing(screenType, userReport);
    } else {
      throw ArgumentError("type d'écran invalide: $screenType");
    }
  }

  /// screenType Report => Widget
  ///
  ///
  Widget getBoussoleBottomBarForThingsToDo(int screenType, Report userReport) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //createThingToDoButton(userReport),
        ],
      ),
    );
  }

  /// screenType Report => Widget
  ///
  ///
  Widget getBoussoleBottomBarForMap(int screenType, Report userReport) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          addTreasureButton(userReport),
        ],
      ),
    );
  }

  /// Report => void
  ///
  /// le bouton permettant d'ajouter un
  /// marqueur sur la carte
  Widget addTreasureButton(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.add_location,
      ),
      onPressed: () {
        nameTreasure(userReport);
      },
    );
  }

  void nameTreasure(Report userReport) {}

  void noTimeMachine() {
    displaySnackbar(
        _scaffoldKey,
        "La machine à remonter le temps n'a pas encore été inventée (enfin je crois 😄)",
        3000);
  }

  /// Report DateTime List<dynamic> => void
  ///
  ///
  Future<void> addThingToDo(Report userReport, DateTime dayChosen) async {
    /// Décris la chose à faire
    String onFaitQuoi = await getUserInput(
      context,
      "Décris ce que tu souhaites faire.",
      "Tu fé koi ?",
      "Fais 50 burpees.",
    );

    fnForOnFaitQuoi(onFaitQuoi, userReport);
  }

  void fnForOnFaitQuoi(String userInput, Report userReport) {
    if (userInput == NO_USER_INPUT) {
      yaRienAFaire(userReport);
    } else if (userInput == EMPTY_USER_INPUT) {
      cVide();
    }

    /// si l'user à écrit une description de ce qu'il veut faire,
    /// on crée un objet dans la db
    else if (userInput.length > 0) {
      var noteToFutureSelf = new NoteToFutureSelf();
      noteToFutureSelf.name = userInput;
      aQuelleHeure(noteToFutureSelf, userReport);
    } else {
      throw Error();
    }
  }

  /// DateTime DateTime => bool
  ///
  /// est ce que on a choisi un jour présent/futur
  bool dayChosenIsTodayOrLater(DateTime today, DateTime dayChosen) {
    var todayDay = today.day;
    var todayMonth = today.month;
    var todayYear = today.year;

    var chosenDay = dayChosen.day;
    var chosenMonth = dayChosen.month;
    var chosenYear = dayChosen.year;

    /*
    print("aujourd'hui: $todayDay");
    print("mois: $todayMonth");
    print("année: $todayYear");

    print("jour choisi: $chosenDay");
    print("mois: $chosenMonth");
    print("année: $chosenYear");
    */

    return (chosenDay >= todayDay) &&
        (chosenMonth >= todayMonth) &&
        (chosenYear >= todayYear);
  }

  void goToCreateThingScreen(DateTime dayChosen) {
    setState(() {
      _screenType = CREATE_THING_TO_DO;
      _dayChosen = dayChosen;
    });
  }

  void goToCalendarScreen() {
    setState(() {
      _screenType = THINGS_TO_DO;
    });
  }

  void goToMapScreen() {
    setState(() {
      _screenType = MAP;
    });
  }

  /// screenType Report => Widget
  ///
  ///
  Widget getBoussoleBarForCreateThing(int screenType, Report userReport) {
    return AppBar(
      leading: goToCalendarScreenIcon(),
      title: Text("On crée un truc !"),
      actions: <Widget>[
        changeScreenTypeButton(screenType),
      ],
    );
  }

  /// screenType Report => Widget
  ///
  ///
  Widget getBoussoleBodyForCreateThing(int screenType, Report userReport) {
    return centeredMsg("assets/icon.png",
        "Appuie sur + pour créer une chose à faire.", Colors.orange);
  }

  /// screenType Report => Widget
  ///
  ///
  Widget getBoussoleBottomBarForCreateThing(int screenType, Report userReport) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // icones homogènement éparpillées
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          createThingToDoButton(userReport),
        ],
      ),
    );
  }

  createThingToDoButton(Report userReport) {
    return IconButton(
      icon: Icon(
        Icons.add,
      ),
      onPressed: () {
        addThingToDo(userReport, _dayChosen);
      },
    );
  }

  backToCalendar() {}

  goToCalendarScreenIcon() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
      ),
      onPressed: () {
        goToCalendarScreen();
      },
    );
  }

  void yaRienAFaire(Report userReport) {
    displaySnackbar(_scaffoldKey, "Ya rien à faire.", 2500);
  }

  void cVide() {
    displaySnackbar(_scaffoldKey, "Il faut écrire quelque chose.", 2500);
  }

  Future<void> aQuelleHeure(
      NoteToFutureSelf noteToFutureSelf, Report userReport) async {
    DateTime chosenTime = await getDesiredTime(_dayChosen);

    handleDesiredTime(chosenTime, noteToFutureSelf, userReport);
  }

  void handleDesiredTime(DateTime chosenTime, NoteToFutureSelf noteToFutureSelf,
      Report userReport) {
    if (chosenTime == NO_DATA) {
      yaRienAFaire(userReport);
    } else {
      noteToFutureSelf.year = chosenTime.year;
      noteToFutureSelf.month = chosenTime.month;
      noteToFutureSelf.day = chosenTime.day;
      noteToFutureSelf.hour = chosenTime.hour;
      noteToFutureSelf.minute = chosenTime.minute;
      noteToFutureSelf.second = chosenTime.second;

      combienDeFois(noteToFutureSelf, userReport);
    }
  }

  Future<void> combienDeFois(
      NoteToFutureSelf noteToFutureSelf, Report userReport) async {
    Choice userChoice = await getUserChoice(
      context,
      "Combien de fois veux-tu faire cette chose ?",
      [
        Choice("Une seule fois.", UNE_SEULE_FOIS),
        Choice("Plusieurs fois.", PLUSIEURS_FOIS),
      ],
    );

    fnForFutureChoice(userChoice, noteToFutureSelf, userReport);
  }

  void fnForFutureChoice(
      Choice choice, NoteToFutureSelf noteToFutureSelf, Report userReport) {
    if (choice == NO_FUTURE_CHOICE) {
      yaRienAFaire(userReport);
    } else if (choice.choiceValue == UNE_SEULE_FOIS) {
      saveNoteToFutureSelf(noteToFutureSelf, userReport);
    } else if (choice.choiceValue == PLUSIEURS_FOIS) {
      faisChosePlusieursFois(noteToFutureSelf, userReport);
    } else {
      throw Error();
    }
  }

  void saveNoteToFutureSelf(
      NoteToFutureSelf noteToFutureSelf, Report userReport) {
    noteToFutureSelf.combienDeFois = UNE_SEULE_FOIS;

    userReport.notesToFutureSelf.add(noteToFutureSelf);

    userReport.save();

    displaySnackbar(_scaffoldKey, "Chose créee avec succès", 3000);
  }

  void faisChosePlusieursFois(
      NoteToFutureSelf noteToFutureSelf, Report userReport) {
    noteToFutureSelf.combienDeFois = PLUSIEURS_FOIS;

    aQuelleIntervale(noteToFutureSelf, userReport);
  }

  Future<void> aQuelleIntervale(
      NoteToFutureSelf noteToFutureSelf, Report userReport) async {
    List<Choice> choices = [
      Choice("Toutes les x minutes.", INTERVAL_X_MINUTES),
      Choice("Toutes les x heures.", INTERVAL_X_HEURES),
      Choice("Toutes les jours.", INTERVAL_QUOTIDIEN),
      Choice("Toutes les x jours.", INTERVAL_X_JOURS),
      Choice("1 fois par semaine.", INTERVAL_HEBDO),
    ];

    Choice userChoice = await getUserChoice(
      context,
      "A quelle fréquence veut tu faire cette chose ?",
      choices,
    );

    fnForInterval(userChoice, noteToFutureSelf, userReport);
  }

  void fnForInterval(
      Choice choice, NoteToFutureSelf noteToFutureSelf, Report userReport) {
    if (choice == NO_FUTURE_CHOICE) {
      yaRienAFaire(userReport);
    } else if (choice.choiceValue == INTERVAL_X_MINUTES) {
      intervalXMinutes(noteToFutureSelf, userReport);
    } else if (choice.choiceValue == INTERVAL_X_HEURES) {
      intervalXHeures(noteToFutureSelf, userReport);
    } else if (choice.choiceValue == INTERVAL_QUOTIDIEN) {
      intervalQuotidien(noteToFutureSelf, userReport);
    } else if (choice.choiceValue == INTERVAL_X_JOURS) {
      intervalXJours(noteToFutureSelf, userReport);
    } else if (choice.choiceValue == INTERVAL_HEBDO) {
      intervalHebdo(noteToFutureSelf, userReport);
    } else {
      throw Error();
    }
  }

  Future<void> intervalXMinutes(
      NoteToFutureSelf noteToFutureSelf, Report userReport) async {
    String userInput = await getUserInput(
      context,
      "Tous les combien de minutes ?",
      "Ecris qté",
      "15",
    );

    fnForXMinutes(noteToFutureSelf, userInput, userReport);
  }

  void fnForXMinutes(
      NoteToFutureSelf noteToFutureSelf, String userInput, Report userReport) {
    if (userInput == NO_USER_INPUT) {
      yaRienAFaire(userReport);
    } else if (userInput == EMPTY_USER_INPUT) {
      cVide();
    } else if (stringIsValidInt(userInput)) {
      int qtyMin = int.tryParse(userInput);

      if (qtyMin > 0) {
        saveIntervalAndTimeUnit(qtyMin, UNITE_MINUTES, noteToFutureSelf, userReport);
      } else {
        displaySnackbar(_scaffoldKey,
            "Oups. Il nous faut une intervale d'une minute ou plus !", 3000);
      }
    } else {
      throw Error();
    }
  }

  Future<void> intervalXHeures(NoteToFutureSelf noteToFutureSelf, Report userReport) async {
    String userInput = await getUserInput(
      context,
      "Toutes les combien d'heures ?",
      "Ecris qté",
      "3",
    );

    fnForXHeures(noteToFutureSelf, userInput, userReport);
  }

  void fnForXHeures( NoteToFutureSelf noteToFutureSelf, String userInput, Report userReport) {
    if (userInput == NO_USER_INPUT) {
      yaRienAFaire(userReport);
    } else if (userInput == EMPTY_USER_INPUT) {
      cVide();
    } else if (stringIsValidInt(userInput)) {
      int qtyHeures = int.tryParse(userInput);

      if (qtyHeures > 0) {
        saveIntervalAndTimeUnit(qtyHeures, UNITE_HEURES, noteToFutureSelf, userReport);
      } else {
        displaySnackbar(_scaffoldKey,
            "Oups. Il nous faut une intervale d'une heure ou plus !", 3000);
      }
    } else {
      throw Error();
    }
  }

  void intervalQuotidien(NoteToFutureSelf noteToFutureSelf, Report userReport) {
    saveIntervalAndTimeUnit(1, UNITE_JOURS, noteToFutureSelf, userReport);
  }

  Future<void> intervalXJours(NoteToFutureSelf noteToFutureSelf, Report userReport) async {
    String userInput = await getUserInput(
      context,
      "Tous les combien de jours ?",
      "Ecris qté",
      "3",
    );

    fnForXJours(noteToFutureSelf, userInput, userReport);
  }

  void fnForXJours( NoteToFutureSelf noteToFutureSelf, String userInput, Report userReport) {
    if (userInput == NO_USER_INPUT) {
      yaRienAFaire(userReport);
    } else if (userInput == EMPTY_USER_INPUT) {
      cVide();
    } else if (stringIsValidInt(userInput)) {
      int qtyJours = int.tryParse(userInput);

      if (qtyJours > 0) {
        saveIntervalAndTimeUnit(qtyJours, UNITE_JOURS, noteToFutureSelf, userReport);
      } else {
        displaySnackbar(_scaffoldKey,
            "Oups. Il nous faut une intervale d'une heure ou plus !", 3000);
      }
    } else {
      throw Error();
    }
  }

  void intervalHebdo(NoteToFutureSelf noteToFutureSelf, Report userReport) {
    saveIntervalAndTimeUnit(7, UNITE_JOURS, noteToFutureSelf, userReport);
  }

  /// int int Report => void
  /// 
  /// sauvegarde la description, l'heure, 
  /// le jour et l'année, la fréquence de répétition,
  /// la longueur de l'intervalle entre chaque notif,
  /// et l'unité de temps utilisée pour chaque intervale,
  /// dans la base de données utilisateur
  void saveIntervalAndTimeUnit(int qtyTempsIntervale, int uniteTempsIntervale, NoteToFutureSelf noteToFutureSelf, Report userReport) {
    noteToFutureSelf.intervaleEntreNotifs = qtyTempsIntervale;
    noteToFutureSelf.uniteDeTemps = uniteTempsIntervale;

    userReport.notesToFutureSelf.add(noteToFutureSelf);

    userReport.save();

    displaySnackbar(_scaffoldKey, "Chose à faire sauvegardée avec succès !", 2500);
  }
}
