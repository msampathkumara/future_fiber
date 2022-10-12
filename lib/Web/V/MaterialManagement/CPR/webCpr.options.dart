part of 'webCpr.dart';

Future<void> showCprOptions(CPR cpr, BuildContext context1, BuildContext context, reload) async {
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 400,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ListTile(
              title: Text(cpr.ticket?.mo ?? cpr.ticket?.oe ?? ''),
              subtitle: Text(cpr.ticket?.oe ?? ''),
            ),
            const Divider(),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
              if (AppUser.havePermissionFor(NsPermissions.CPR_DELETE_CPR))
                ListTile(
                    title: const Text("Delete CPR"),
                    leading: const Icon(Icons.delete_rounded),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await showDeleteDialog(context1, cpr, reload);
                    }),
              ListTile(
                  title: const Text("Order"),
                  leading: const Icon(Icons.access_alarm),
                  onTap: () async {
                    Navigator.of(context).pop();
                    showOrderOptions(cpr, context1, context, reload);
                  })
            ])))
          ],
        ),
      );
    },
  );
}

Future<void> showOrderOptions(CPR cpr, BuildContext context1, BuildContext context, reload) async {
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 400,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ListTile(
              title: Text(cpr.ticket?.mo ?? cpr.ticket?.oe ?? ''),
              subtitle: Text(cpr.ticket?.oe ?? ''),
            ),
            const Divider(),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
              ListTile(
                  title: const Text("Urgent", style: TextStyle(color: Colors.red)),
                  leading: const Icon(Icons.do_not_disturb_on_total_silence, color: Colors.red),
                  onTap: () async {
                    Navigator.of(context).pop();
                    order(context, cpr, 1, reload);
                  }),
              ListTile(
                  title: const Text("Normal", style: TextStyle(color: Colors.green)),
                  leading: const Icon(Icons.do_not_disturb_on_total_silence, color: Colors.green),
                  onTap: () async {
                    Navigator.of(context).pop();
                    order(context, cpr, 0, reload);
                  })
            ])))
          ],
        ),
      );
    },
  );
}

void order(context, CPR cpr, int i, reload) {
  ShowMessage('Saving', messageType: MessageTypes.message, icon: Icons.save);

  Api.post(EndPoints.materialManagement_cpr_order, {'cprId': cpr.id, 'type': i})
      .then((res) {
        Map data = res.data;
        ShowMessage('Saved', messageType: MessageTypes.success, icon: Icons.save);
        reload();
      })
      .whenComplete(() {})
      .catchError((err) {
        ShowMessage('Something went wrong',
            duration: const Duration(seconds: 30),
            messageType: MessageTypes.error,
            icon: Icons.error,
            closeButton: true,
            action: SnackBarAction(
                label: "Retry",
                textColor: Colors.white,
                onPressed: () {
                  order(context, cpr, i, reload);
                }));
      });
}

showDeleteDialog(BuildContext context, CPR cpr, reload) async {
  // show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete"),
        content: const Text("Do you really want to delete this cpr?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Continue"),
            onPressed: () async {
              delete(cpr, context, reload);
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

Future<void> delete(CPR cpr, BuildContext context, reload) async {
  await Api.post(EndPoints.materialManagement_cpr_delete, {'cpr': cpr.id})
      .then((res) {
        Map data = res.data;
        reload();
      })
      .whenComplete(() {})
      .catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err.toString()),
            action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  delete(cpr, context, reload);
                })));
      });
}
