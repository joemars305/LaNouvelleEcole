import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quizapp/parts/consts.dart';
import '../services/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

const nommeTonFetus = "Détails sur le bébé";
const messageNameBaby = "Donne un nom à ta leçon.";
const messageCategoryBaby = "Catégorie ?";
const iconPath = "assets/covers/baby.png";

// l'écran ou on crée un bébé leçon,
// puis on l'ajoute a notre base de données
class CreateFetusPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _CreateFetusPageState();
}

class _CreateFetusPageState extends State<CreateFetusPage> {
  // le nom de cette leçon
  String _name;

  // dans quelle catégorie se situe cette leçon
  String currentCategory = NOURRITURE;

  // utile pour le fonctionnement du TextFormField
  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          nommeTonFetus,
          style: TextStyle(
              //fontFamily: 'ComingSoon',
              ),
        ),
      ),
      // showForm() affiche les différents
      // forms nécessaire à la récupération d'infos
      // sur le bébé que l'utilisateur veut créer
      body: showForm(),
    );
  }

  // le logo de bébé leçon
  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset(iconPath),
        ),
      ),
    );
  }

  // la ou on écrit le nom du bébé
  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: true,
        decoration: new InputDecoration(
            hintText: 'Comment faire/fabriquer/cultiver ...',
            labelText: messageNameBaby,
            icon: new Icon(
              FontAwesomeIcons.smile,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Il faut nommer cette leçon' : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

  // le menu de sélection de catégorie du bébé leçon
  Widget showCategoriesDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              icon: const Icon(Icons.color_lens),
              labelText: messageCategoryBaby,
            ),
            isEmpty: currentCategory == '',
            child: new DropdownButtonHideUnderline(
              child: new DropdownButton(
                value: currentCategory,
                isDense: true,
                onChanged: (String newValue) {
                  setState(() {
                    currentCategory = newValue;
                    state.didChange(newValue);
                  });
                },
                items: categories.map((String value) {
                  return new DropdownMenuItem(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  // un formulaire recueillant les
  // infos de base sur le bébé leçon
  Widget showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              // le logo de bébé
              showLogo(),
              // la ou on écrit le nom du bébé
              showNameInput(),
              // la ou on choisit la catégorie du bébé
              showCategoriesDropdown(),
              // le bouton de validation/création du bébé
              // dans la base de données
              showPrimaryButton(),
            ],
          ),
        ));
  }

  // le bouton de création du bébé
  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(15.0, 45.0, 15.0, 0.0),
        child: SizedBox(
          height: 60.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.pinkAccent,
            child: new Text(
              'Crée bébé leçon',
              style: new TextStyle(
                fontSize: 25.0,
                color: Colors.white,
                fontFamily: 'Lobster',
              ),
            ),
            // quand on appuie sur le bouton,
            // on vérifie que l'user à écrit un nom,
            // si tout est OK, on crée un
            // bébé leçon dans
            // la base de données, puis on retourne
            // vers l'écran des bébé leçons
            onPressed: validateAndSave,
          ),
        ));
  }

  Future<bool> validateAndSave() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      print("nom: $_name");
      print("catégorie: $currentCategory");

      saveBabyLesson();

      return true;
    }
    return false;
  }

  // sauvegarde le bébé lesson dans
  // la liste de bébé leçons de l'utilisateur
  Future<bool> saveBabyLesson() async {
    try {
      // un objet contenant des infos sur l'utilisateur
      // on a besoin de cela pour obtenir le pseudo
      // de l'utilisateur
      FirebaseUser user = Provider.of<FirebaseUser>(context);

      // le dossier Report de cet utilisateur
      Report userReport = await Global.reportRef.getDocument();

      // la date de naissance du bébé leçon
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd-MM-yyyy').format(now);

      // un bébé leçon fraichement crée
      // sous forme d'objet
      // (voir models.dart pour plus de détails sur BabyLesson)
      BabyLesson newLesson = new BabyLesson(
        name: _name,
        createdBy: user.displayName,
        creationDate: formattedDate,
        category: currentCategory,
        userIconUrl: user.photoUrl,
      );

      // ajoute ce bébé leçon dans la liste
      // de bébé leçons du Report de l'utilisateur
      userReport.babyLessons.add(newLesson);

      // Remplace l'ancien Report dans la base de données
      // avec ce nouveau Report agrémenté d'un nouveau bébé leçon
      userReport.save();

      // dirige toi vers l'écran précédent
      // (celui des bébé leçons)
      Navigator.pop(context);

      return true;
    } catch (error) {
      /** */
      print(error);
      return false;
    }
  }
}
