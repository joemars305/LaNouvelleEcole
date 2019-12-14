import 'package:flutter/material.dart';
import '../services/services.dart';

/**
 * WISHLIST:
 * 
 * - 
 */

/** création d'étapes */
class StepCreation extends StatelessWidget {
  static const routeName = '/step_creation';

  

  @override
  Widget build(BuildContext context) {
    // Contient le Report utilisateur
    // ainsi que la position du bébé 
    // leçon dans la liste de bébé leçons dans le Report
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;

    int index = args.index;

    Report userReport = args.userReport;

    return Scaffold(
      appBar: AppBar(title: Text('Etape ' + index.toString()), backgroundColor: Colors.blue),

      body: Center(child: Text('Etapes...'),),
    );
  }
}