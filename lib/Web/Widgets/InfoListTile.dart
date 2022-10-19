import 'package:flutter/cupertino.dart';

class InfoListTile extends StatelessWidget {
  final String name;
  final String value;

  const InfoListTile(this.name, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(name), Text(value)],
      ),
    );
  }
}
