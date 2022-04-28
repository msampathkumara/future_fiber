part of 'webCpr.dart';

Future<void> showCprOptions(CPR cpr, BuildContext context1, BuildContext context) async {
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
                    })
            ])))
          ],
        ),
      );
    },
  );
}
