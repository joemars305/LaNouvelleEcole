import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leçons favorites'), backgroundColor: Colors.blue),

      body: Center(child: Text('Vos favoris...'),),
    );
  }
}