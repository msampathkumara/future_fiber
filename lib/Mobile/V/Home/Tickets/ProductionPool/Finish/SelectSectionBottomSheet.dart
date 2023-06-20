import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../../C/Api.dart';
import '../../../../../../C/ServerResponse/Progress.dart';
import '../../../../../../C/ServerResponse/ServerResponceMap.dart';
import '../../../../../../M/EndPoints.dart';
import '../../../../../../globals.dart';

class SelectSectionBottomSheet extends StatefulWidget {
  final int ticketId;
  final Null Function(dynamic _selectedSectionId) param1;

  const SelectSectionBottomSheet(this.ticketId, this.param1, {Key? key}) : super(key: key);

  @override
  State<SelectSectionBottomSheet> createState() => _SelectSectionBottomSheetState();
}

class _SelectSectionBottomSheetState extends State<SelectSectionBottomSheet> {
  List<Progress>? pendingList;

  @override
  void initState() {
    loadData();

    super.initState();
  }

  bool loading = true;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 650,
        width: 500,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ((pendingList ?? []).isEmpty)
                ? const Center(child: Text("Sections Not Found", textScaleFactor: 1, style: TextStyle(color: Colors.red)))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ListView.separated(
                        itemCount: (pendingList ?? []).length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          var e = (pendingList ?? [])[index];
                          return ListTile(
                            title: Text(e.section?.sectionTitle ?? ''),
                            onTap: () {
                              widget.param1(e.section?.id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ));
  }

  CancelToken cancelToken = CancelToken();

  @override
  dispose() {
    try {
      cancelToken.cancel();
    } catch (e) {}
    super.dispose();
  }

  void loadData() {
    Api.get(EndPoints.tickets_getTicketProgress, {"ticketId": widget.ticketId}, cancelToken: cancelToken).then((response) {
      ServerResponseMap res = ServerResponseMap.fromJson((response.data));
      var progressList = res.ticketProgressDetails;

      pendingList = progressList;

      final ids = (pendingList ?? []).map((e) => e.section?.id).toSet();
      (pendingList ?? []).retainWhere((x) => ids.remove(x.section?.id));
      (pendingList ?? []).removeWhere((x) => x.section?.sectionTitle.toLowerCase() == 'finishing');
      loading = false;
      setState(() {});
      print('llll $loading');
    }).catchError((error) {
      error = true;
      loading == false;
      Navigator.of(context).pop();
      snackBarKey.currentState
          ?.showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Something went wrong please try again", style: TextStyle(color: Colors.white))));
    }).whenComplete(() {
      print('done');
      setState(() {});
    });
  }
}
