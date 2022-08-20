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
              if (AppUser.havePermissionFor(Permissions.CPR))
                ListTile(
                    title: const Text("Delete CPR"),
                    leading: const Icon(Icons.delete_rounded),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await showDeleteDialog(context1, cpr);
                      reload();
                    })
            ])))
          ],
        ),
      );
    },
  );
}

showDeleteDialog(BuildContext context, CPR cpr) async {
  // DeleteDialog().show(context);

  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Continue"),
    onPressed: () async {
      await delete(cpr, context);
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Delete"),
    content: const Text("Do you really want to delete this cpr?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<void> delete(CPR cpr, BuildContext context) async {
  await Api.post("materialManagement/cpr/delete", {'cpr': cpr.id})
      .then((res) {
        Map data = res.data;
      })
      .whenComplete(() {})
      .catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err.toString()),
            action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  delete(cpr, context);
                })));
      });
}
