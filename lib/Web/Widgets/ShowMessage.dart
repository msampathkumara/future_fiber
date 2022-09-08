import 'package:flutter/material.dart';

import '../../globals.dart';

enum MessageTypes { error, message, success }

extension MessageTypesExtension on MessageTypes {
  String getValue() {
    return (this).toString().split('.').last;
  }

  MaterialColor getColor() {
    switch (this) {
      case MessageTypes.error:
        return Colors.red;

      case MessageTypes.message:
        return Colors.blue;

      case MessageTypes.success:
        return Colors.green;
    }
  }
}

ShowMessage(String message,
    {MessageTypes messageType = MessageTypes.message, IconData? icon, Color? iconColor, bool closeButton = false, Duration? duration, SnackBarAction? action}) {
  var s = _textSize(message, const TextStyle());

  snackBarKey.currentState?.showSnackBar(SnackBar(
      content: Row(children: [
        if (icon != null) Icon(icon, color: iconColor ?? Colors.white),
        SizedBox(width: 16, height: s.height),
        Flexible(child: Text(message)),
        if (closeButton) const Spacer(),
        if (closeButton)
          TextButton(
              onPressed: () {
                snackBarKey.currentState?.hideCurrentSnackBar();
              },
              child: const Text("Close"))
      ]),
      action: action,
      behavior: SnackBarBehavior.floating,
      backgroundColor: messageType.getColor(),
      duration: duration ?? const Duration(milliseconds: 1500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      width: s.width + 100 + (closeButton ? 200 : 0)));
}

Size _textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: screenSize.width - 200);
  return textPainter.size;
}
