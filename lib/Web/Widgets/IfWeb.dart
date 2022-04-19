import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IfWeb extends StatelessWidget {
  final Widget child;
  final Widget elseIf;

  const IfWeb({required this.child, required this.elseIf, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? child : elseIf;
  }
}
