import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ErrorMessageView extends StatefulWidget {
  late _ErrorMessageViewState state;

  String errorMessage;

  var icon;

  ErrorMessageView({Key? key, required this.errorMessage, this.icon}) : super(key: key);

  @override
  _ErrorMessageViewState createState() {
    state = _ErrorMessageViewState();
    return state;
  }

    show(context) async{
  await  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => this),
    );
  }

  void close(context) {
    Navigator.of(context).pop();
  }
}

class _ErrorMessageViewState extends State<ErrorMessageView> with TickerProviderStateMixin {
  late AnimationController controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
          child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        children: [
          Center(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  widget.icon ?? Icons.error,
                  color: Colors.pink,
                  size: 100.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                )),
          ),
          Text(
            widget.errorMessage,
            textScaleFactor: 1.2,
          ),
        ],
      )),
    );
  }
}
