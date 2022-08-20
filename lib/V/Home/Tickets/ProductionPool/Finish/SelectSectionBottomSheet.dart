import 'package:flutter/material.dart';

import '../../../../../C/Api.dart';
import '../../../../../C/ServerResponse/Progress.dart';
import '../../../../../C/ServerResponse/ServerResponceMap.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 650,
        width: 500,
        child: pendingList == null
            ? const Center(child: CircularProgressIndicator())
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

  void loadData() {
    Api.get("tickets/getTicketProgress", {"ticketId": widget.ticketId}).then((response) {
      ServerResponseMap res = ServerResponseMap.fromJson((response.data));
      var progressList = res.progressList;

      // pendingList = progressList.where((p) {
      //   return (p.status != 1);
      // }).toList();

      pendingList = progressList;

      final ids = (pendingList ?? []).map((e) => e.section?.id).toSet();
      (pendingList ?? []).retainWhere((x) => ids.remove(x.section?.id));

      setState(() {});
    });
  }
}
