
// Create a Form widget.
import 'package:flutter/material.dart';

class HorizontalForm extends StatefulWidget {
  const HorizontalForm({
    Key key,
    @required this.onClick,
    @required this.visible,
    @required this.fillerFormMsg,
    @required this.emptyFormMsg,
    @required this.buttonText,
  }) : super(key: key);

  //final File _image;
  final Function onClick;

  final bool visible;

  final String fillerFormMsg;

  final String emptyFormMsg;

  final String buttonText;

  @override
  HorizontalFormState createState() {
    return HorizontalFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class HorizontalFormState extends State<HorizontalForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCus tomFormState>.
  final _formKey = GlobalKey<FormState>();

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return Container();
    }

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.go,
                onFieldSubmitted: (text) {
                  if (_formKey.currentState.validate()) {
                    // If the form is not empty, display a Snackbar.
                    
                    widget.onClick(text);
                  }
                },
                controller: myController,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: widget.fillerFormMsg,
                    fillColor: Colors.white70),
                validator: (value) {
                  if (value.isEmpty) {
                    return widget.emptyFormMsg;
                  }
                  return null;
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: RaisedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false
                // otherwise.*
                if (_formKey.currentState.validate()) {
                  // If the form is not empty, display a Snackbar.
                  
                  widget.onClick(myController.text);
                }
              },
              child: Text(widget.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}