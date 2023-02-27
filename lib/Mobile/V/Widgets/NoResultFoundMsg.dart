import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/res.dart';

class NoResultFoundMsg extends StatelessWidget {
  final Null Function()? onRetry;

  const NoResultFoundMsg({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Image.asset(Res.noResult),
        const Text("No Result Found", textScaleFactor: 1),
        if (onRetry != null)
          TextButton(
              onPressed: () {
                onRetry!();
              },
              child: const Text("Retry"))
      ],
    );
  }
}
