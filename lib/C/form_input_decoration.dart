import 'package:flutter/material.dart';

class FormInputDecoration {
  static InputDecoration getDeco({hintText, labelText, helperText, Icon? prefixIcon, Icon? icon, String? suffixText}) {
    return InputDecoration(
        suffixText: suffixText,
        icon: icon,
        prefixIcon: prefixIcon,
        helperText: helperText,
        labelText: labelText,
        border: InputBorder.none,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[150],
        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.lightBlueAccent),
          borderRadius: BorderRadius.circular(4.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(4.0),
        ));
  }

  static ButtonStyle buttonStyle({hintText, labelText, helperText, Icon? icon}) {
    return ButtonStyle(
        // padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
        shape:
            MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: const BorderSide(color: Colors.lightBlue))));
  }
}
