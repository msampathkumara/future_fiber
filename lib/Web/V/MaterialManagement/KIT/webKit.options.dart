part of 'webKit.dart';

Future<void> showCprOptions(KIT kit, BuildContext context1, BuildContext context, reload) async {
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
              title: Text(kit.ticket?.mo ?? kit.ticket?.oe ?? ''),
              subtitle: Text(kit.ticket?.oe ?? ''),
            ),
            const Divider(),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
              if (AppUser.havePermissionFor(NsPermissions.KIT_ORDER_KITS))
                ListTile(
                    title: const Text("Order"),
                    leading: const Icon(Icons.access_alarm),
                    onTap: () async {
                      Navigator.of(context).pop();
                      showOrderOptions(kit, context1, context, reload);
                    })
            ])))
          ],
        ),
      );
    },
  );
}

Future<void> showOrderOptions(KIT kit, BuildContext context1, BuildContext context, reload) async {
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
              title: Text(kit.ticket?.mo ?? kit.ticket?.oe ?? ''),
              subtitle: Text(kit.ticket?.oe ?? ''),
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
                    order(context, kit, 1, reload);
                  }),
              ListTile(
                  title: const Text("Normal", style: TextStyle(color: Colors.green)),
                  leading: const Icon(Icons.do_not_disturb_on_total_silence, color: Colors.green),
                  onTap: () async {
                    Navigator.of(context).pop();
                    order(context, kit, 0, reload);
                  })
            ])))
          ],
        ),
      );
    },
  );
}

void order(context, KIT kit, int i, reload) {
  ShowMessage('Saving', messageType: MessageTypes.message, icon: Icons.save);

  Api.post(EndPoints.materialManagement_order, {'cprId': kit.id, 'type': i})
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
                  order(context, kit, i, reload);
                }));
      });
}
