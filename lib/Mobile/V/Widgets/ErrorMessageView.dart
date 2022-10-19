import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Web/Widgets/DialogView.dart';

class ErrorMessageView extends StatefulWidget {
  final String errorMessage;
  final IconData? icon;

  const ErrorMessageView({Key? key, required this.errorMessage, this.icon}) : super(key: key);

  @override
  _ErrorMessageViewState createState() {
    return _ErrorMessageViewState();
  }

  show(context) async {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }

  void close(context) {
    Navigator.of(context).pop();
  }
}

class _ErrorMessageViewState extends State<ErrorMessageView> with TickerProviderStateMixin {
  late AnimationController controller;

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
    return kIsWeb ? DialogView(child: _getUi(), width: 500, height: 300) : _getUi();
  }

  _getUi() {
    return Scaffold(
      appBar: AppBar(),
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
