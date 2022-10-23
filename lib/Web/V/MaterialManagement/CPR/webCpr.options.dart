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
              if (AppUser.havePermissionFor(NsPermissions.CPR_OREDR_CPR))
                ListTile(
                    title: const Text("Order"),
                    leading: const Icon(Icons.access_alarm),
                    onTap: () async {
                      Navigator.of(context).pop();
                      showOrderOptions(CprType.cpr, cpr, cpr.ticket, context1, context, reload);
                    })
            ])))
          ],
        ),
      );
    },
  );
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
