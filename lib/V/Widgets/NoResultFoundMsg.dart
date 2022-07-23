import 'package:flutter/cupertino.dart';
import 'package:smartwind/res.dart';

class NoResultFoundMsg extends StatelessWidget {
  const NoResultFoundMsg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [Image.asset(Res.noResult), const Text("No Result Found", textScaleFactor: 1)],
    );
  }
}
