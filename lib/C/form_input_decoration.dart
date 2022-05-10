import 'package:flutter/material.dart';

class FormInputDecoration {
  static InputDecoration getDeco({hintText, labelText, labelStyle, helperText, Icon? prefixIcon, Icon? icon, String? suffixText, Widget? suffixIcon}) {
    return InputDecoration(
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        icon: icon,
        prefixIcon: prefixIcon,
        helperText: helperText,
        labelText: labelText,
        labelStyle: labelStyle,
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

  static InputDecoration getDeco1({hintText, labelText, labelStyle, helperText, Icon? prefixIcon, Icon? icon, String? suffixText, Widget? suffixIcon}) {
    return InputDecoration(
      isDense: true,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      icon: icon,
      prefixIcon: prefixIcon,
      helperText: helperText,
      labelText: labelText,
      labelStyle: labelStyle,
      hintText: hintText,
      fillColor: Colors.grey[150],
      // contentPadding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.8),
        ),
      ),
      // enabledBorder: UnderlineInputBorder(
      //   borderSide: const BorderSide(color: Colors.grey),
      //   borderRadius: BorderRadius.circular(4.0),
      // ),
      border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), gapPadding: 0),
    );
  }

  static ButtonStyle buttonStyle({hintText, labelText, helperText, Icon? icon}) {
    return ButtonStyle(
        // padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
        shape:
            MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: const BorderSide(color: Colors.lightBlue))));
  }
}
