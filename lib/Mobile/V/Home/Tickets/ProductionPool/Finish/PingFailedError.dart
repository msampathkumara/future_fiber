import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

class PingFailedError extends StatefulWidget {
  const PingFailedError({Key? key}) : super(key: key);

  @override
  State<PingFailedError> createState() => _PingFailedErrorState();

  Future show(context) {
    return showDialog(context: context, builder: (_) => this);
  }
}

class _PingFailedErrorState extends State<PingFailedError> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DialogView(height: 300, child: getWebUi()),
    );
  }

  Scaffold getWebUi() {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("You are not in factory network or ERP server is not working. do you want to continue finish without finish on ERP system ?",
                    style: TextStyle(fontSize: 24))),
            Wrap(
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text("Yes")),
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("No"))
              ],
            )
          ],
        ),
      ),
    ));
  }

  getUi() {
    return getWebUi();
  }
}
