import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import '../../../M/AppUser.dart';
import '../../../Web/Widgets/DialogView.dart';
import '../../../Web/Widgets/IfWeb.dart';

class CurrentUserDetails extends StatefulWidget {
  final NsUser nsUser;

  const CurrentUserDetails(this.nsUser, {Key? key}) : super(key: key);

  @override
  _CurrentUserDetailsState createState() {
    return _CurrentUserDetailsState();
  }

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _CurrentUserDetailsState extends State<CurrentUserDetails> {
  late NsUser nsUser;

  TextStyle stStyle = const TextStyle(color: Colors.black, fontSize: 18);

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;
    final user = FirebaseAuth.instance.currentUser;
    user!.getIdToken().then((t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  getUi() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 350,
        flexibleSpace: Center(
          child: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              UserImage(nsUser: nsUser, radius: 100),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  nsUser.name,
                  textScaleFactor: 1.5,
                ),
              ),
              Text('#' + nsUser.uname, style: const TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                  child: Column(children: [
                const ListTile(title: Text("Contact Details"), leading: Icon(Icons.contact_phone_outlined)),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: [
                      ListTile(
                          leading: const Icon(Icons.phone_android_outlined),
                          title: const Text("Phone"),
                          subtitle: Wrap(children: nsUser.phoneList.map((e) => Padding(padding: const EdgeInsets.only(right: 4.0), child: Chip(label: Text(e)))).toList())),
                      ListTile(
                        leading: const Icon(Icons.alternate_email_outlined),
                        title: const Text("Email"),
                        subtitle: Wrap(
                            // direction: Axis.vertical,
                            children: nsUser.emails
                                .map((e) => Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Chip(
                                        // avatar: e.isNotVerified ? null : const Icon(Icons.done, color: Colors.green),
                                        label: Text("${e.email}"),
                                        onDeleted: e.isNotVerified
                                            ? null
                                            : () {
                                                // VerifyEmail(e).show(context);
                                              },
                                        deleteIcon: e.isNotVerified ? null : const Icon(Icons.error, color: Colors.red))))
                                .toList()),
                        // trailing: IconButton(
                        //     onPressed: () {
                        //       AddUserEmail(() {}).show(context);
                        //     },
                        //     icon: const Icon(Icons.add))
                      ),
                      ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text("Address"), subtitle: Text(nsUser.address.split(",").join("\n"), style: stStyle))
                    ]))
              ])),
              Card(
                child: Column(
                  children: [
                    const ListTile(title: Text("Job Details"), leading: Icon(Icons.work_outline_outlined)),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          ListTile(leading: const Icon(Icons.badge_outlined), title: const Text("EPF"), subtitle: Text(nsUser.epf, style: stStyle)),
                          ListTile(leading: const Icon(Icons.apartment_rounded), title: const Text("Loft"), subtitle: Text(nsUser.loft.toString(), style: stStyle)),
                          ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: const Text("Section"),
                              subtitle: Text(AppUser.getSelectedSection()?.sectionTitle ?? '', style: stStyle))
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getWebUi() {
    return getUi();
  }
}
