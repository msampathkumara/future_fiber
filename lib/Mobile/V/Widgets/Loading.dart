import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';

class Loading extends StatefulWidget {
  final String loadingText;
  final bool showProgress;
  final Future? future;

  const Loading({Key? key, this.loadingText = "Loading", this.showProgress = true, this.future}) : super(key: key);

  @override
  LoadingState createState() {
    return LoadingState();
  }

  show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }

  void close(context) {
    Navigator.of(context).pop();
  }
}

class LoadingState extends State<Loading> with TickerProviderStateMixin {
  late AnimationController controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? DialogView(child: _getUi(), width: 200, height: 200) : _getUi();
  }

  onProgressChange(progress) {
    setState(() {
      _progress = progress;
    });
  }

  _getUi() {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Wrap(alignment: WrapAlignment.center, direction: Axis.horizontal, children: [
          if (widget.showProgress)
            _progress > 0
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularPercentIndicator(
                            radius: 50.0, lineWidth: 4.0, percent: (_progress / 100).toDouble(), center: Text("$_progress%", textScaleFactor: 1.5), progressColor: Colors.blue)))
                : const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
          Text(widget.loadingText, textScaleFactor: 1)
        ])));
  }
}
