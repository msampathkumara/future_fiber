import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();
Size screenSize = const Size(0, 0);

Color getPrimaryColor(context) => Theme.of(context).primaryColor;
bool isMaterialManagement = false;
