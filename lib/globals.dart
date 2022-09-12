import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();
Size screenSize = const Size(0, 0);

Color getPrimaryColor(context) => Theme.of(context).primaryColor;
