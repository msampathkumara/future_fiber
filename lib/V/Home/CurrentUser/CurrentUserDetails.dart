import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/NsUser.dart';

class CurrentUserDetails extends StatefulWidget {
  final NsUser nsUser;

  CurrentUserDetails(this.nsUser, {Key? key}) : super(key: key);

  @override
  _CurrentUserDetailsState createState() {
    return _CurrentUserDetailsState();
  }
}

class _CurrentUserDetailsState extends State<CurrentUserDetails> {
  late NsUser nsUser;

  TextStyle stStyle = TextStyle(color: Colors.black, fontSize: 18);

  var idToken;

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;
    final user = FirebaseAuth.instance.currentUser;
    user!.getIdToken().then((t) {
      idToken = t;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          toolbarHeight: 350,
          flexibleSpace: Center(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                    radius: 124.0,
                    backgroundImage: idToken != null
                        ? NetworkImage(Server.getServerApiPath("users/getImage?img=" + nsUser.img + "&size=1000"), headers: {"authorization": '$idToken'})
                        : NsUser.getDefaultImage(),
                    backgroundColor: Colors.transparent),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    nsUser.name,
                    textScaleFactor: 1.5,
                  ),
                ),
                Text('#' + nsUser.uname, style: TextStyle(color: Colors.blue)),
                // Wrap(
                //   direction: Axis.horizontal,
                //   crossAxisAlignment: WrapCrossAlignment.center,
                //   children: [
                //     // Chip(avatar: CircleAvatar(backgroundColor: Colors.grey.shade800, child: const Text('AB')), label: const Text('Aaron Burr')),
                //     Chip(avatar: Icon(Icons.maps_home_work_outlined), label: Text(nsUser.sectionName)),
                //     Chip(avatar: Icon(Icons.person_outlined), label: Text(nsUser.utype)),
                //   ],
                // )
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
                  child: Column(
                    children: [
                      ListTile(title: Text("Contact Details"), leading: Icon(Icons.contact_phone_outlined)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ListTile(leading: Icon(Icons.phone_android_outlined), title: Text("Phone"), subtitle: Text(nsUser.phone.split(",").join("\n"), style: stStyle)),
                            ListTile(
                                leading: Icon(Icons.alternate_email_outlined), title: Text("Email"), subtitle: Text(nsUser.emailAddress.split(",").join("\n"), style: stStyle)),
                            ListTile(leading: Icon(Icons.location_on_outlined), title: Text("Address"), subtitle: Text(nsUser.emailAddress.split(",").join("\n"), style: stStyle)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(title: Text("Job Details"), leading: Icon(Icons.work_outline_outlined)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ListTile(leading: Icon(Icons.badge_outlined), title: Text("EPF"), subtitle: Text(nsUser.epf, style: stStyle)),
                            ListTile(leading: Icon(Icons.alternate_email_outlined), title: Text("Loft"), subtitle: Text(nsUser.loft.toString(), style: stStyle)),
                            ListTile(leading: Icon(Icons.location_on_outlined), title: Text("Section"), subtitle: Text(nsUser.sectionName, style: stStyle)),
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
      ),
    );
  }
}
