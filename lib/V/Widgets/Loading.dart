import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Loading extends StatefulWidget {
  late _LoadingState state;

  var loadingText;

  var showProgress;

  Loading({Key? key, this.loadingText = "Loading", this.showProgress = true}) : super(key: key);

  @override
  _LoadingState createState() {
    state = _LoadingState();
    return state;
  }

  void setProgress(progress) {
    state.onProgressChange(progress);
  }

  void show(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => this),
    );
  }

  void close(context) {
    Navigator.of(context).pop();
  }
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  late AnimationController controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                : Center(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )),
          Text(widget.loadingText, textScaleFactor: 1)
        ])));
  }

  onProgressChange(progress) {
    setState(() {
      _progress = progress;
    });
  }
}
