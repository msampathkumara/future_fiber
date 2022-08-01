import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DialogView extends StatelessWidget {
  final Widget child;
  final double width;

  final double? height;

  const DialogView({required this.child, this.width = 1000, this.height, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _height = height ?? MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Container(
              width: width,
              height: _height,
              margin: const EdgeInsets.only(top: 64.0, bottom: 64.0),
              constraints: kIsWeb ? BoxConstraints(maxWidth: width, maxHeight: _height) : null,
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.circular(8),
                child: child,
              )),
        ),
      ),
    );
  }
}
