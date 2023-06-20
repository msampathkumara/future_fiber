import 'package:flutter/material.dart';

import 'StatusBarItem.dart';

class StatusBarProgressIndicator extends StatefulWidget implements StatusBarItem {
  final StatusBarProgressIndicatorController? controller;
  Widget? trailing;

  StatusBarProgressIndicator({this.trailing, Key? key, required this.controller}) : super(key: key);

  @override
  State<StatusBarProgressIndicator> createState() => _StatusBarProgressIndicatorState();
}

class _StatusBarProgressIndicatorState extends State<StatusBarProgressIndicator> with TickerProviderStateMixin {
  late StatusBarProgressIndicatorController controller;

  // late AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState

    // controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 5),
    // )..addListener(() {
    //     setState(() {});
    //   });
    // controller.repeat(reverse: true);

    controller = widget.controller!;
    controller.onProgressChange((progress) {
      // print('onProgressChange $progress');
      setState(() {});
    });
    super.initState();
  }

  double normalize(double value, double min, double max) {
    return ((value - min) / (max - min)).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        padding: const EdgeInsets.only(bottom: 0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
        offset: const Offset(0, -70),
        itemBuilder: (BuildContext context) => [PopupMenuItem(value: 0, enabled: false, child: popupInnerWidget(controller))],
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            child: Container(
                color: Colors.white,
                child: Wrap(children: [
                  widget.trailing ?? Container(),
                  SizedBox(
                    width: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation(Colors.green), value: controller.getProgress / 100, semanticsLabel: 'Linear progress indicator'),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(4.0), child: Text("${controller.getProgress.toStringAsFixed(1)} % ", textScaleFactor: 0.8)),
                ]))));
  }
}

class StatusBarProgressIndicatorController {
  double _progress = 0;

  final List<Function?> _onProgressChange = [];

  double get getProgress => _progress;

  double setValue(double i, totalCount) {
    _progress = normalize(i, 0, totalCount) * 100;
    for (var element in _onProgressChange) {
      try {
        element!(_progress);
      } catch (e) {
        print('$e');
        _onProgressChange.remove(element);
      }
    }
    return _progress;
  }

  void onProgressChange(Null Function(double) onProgressChange) {
    _onProgressChange.add(onProgressChange);
  }

  double normalize(double value, double min, double max) {
    return ((value - min) / (max - min)).clamp(0, 1);
  }
}

class popupInnerWidget extends StatefulWidget {
  final StatusBarProgressIndicatorController controller;

  const popupInnerWidget(this.controller, {Key? key}) : super(key: key);

  @override
  State<popupInnerWidget> createState() => _popupInnerWidgetState();
}

class _popupInnerWidgetState extends State<popupInnerWidget> {
  @override
  void initState() {
    // TODO: implement initState

    widget.controller.onProgressChange((p0) {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      child: ListTile(
        title: const SizedBox(width: 450, child: Text("Adding Tickets to database")),
        trailing: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(backgroundColor: Colors.black12, value: widget.controller.getProgress / 100)),
      ),
    );
  }
}
