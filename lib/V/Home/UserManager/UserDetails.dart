import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/V/Home/UserManager/UpdateUserDetails.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

class UserDetails extends StatefulWidget {
  NsUser nsUser;

  UserDetails(this.nsUser, {Key? key}) : super(key: key);

  @override
  _UserDetailsState createState() {
    return _UserDetailsState();
  }

  static show(context, nsUser) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetails(nsUser)),
    );
  }
}

class _UserDetailsState extends State<UserDetails> {
  late NsUser nsUser;

  TextStyle stStyle = TextStyle(color: Colors.black, fontSize: 18);

  late String idToken;

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getJwt() async {
    final user = FirebaseAuth.instance.currentUser;
    idToken = await user!.getIdToken();
    return (idToken);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<String>(
        future: getJwt(), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
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
                          UserImage(nsUser: nsUser,radius: 124),
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
                                      ListTile(
                                          leading: Icon(Icons.phone_android_outlined), title: Text("Phone"), subtitle: Text(nsUser.phone.split(",").join("\n"), style: stStyle)),
                                      ListTile(
                                          leading: Icon(Icons.alternate_email_outlined),
                                          title: Text("Email"),
                                          subtitle: Text(nsUser.emailAddress.split(",").join("\n"), style: stStyle)),
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
                                      ListTile(
                                          leading: Icon(Icons.domain_outlined),
                                          title: Text("Section"),
                                          subtitle: Wrap(
                                              direction: Axis.horizontal,
                                              crossAxisAlignment: WrapCrossAlignment.start,
                                              children: List.generate(nsUser.sections.length, (index) {
                                                Section section = nsUser.sections[index];
                                                return Padding(
                                                    padding: const EdgeInsets.only(right: 8.0), child: Chip(label: Text(section.sectionTitle + " @ " + section.factory)));
                                              }))),
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
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      UpdateUserDetails.show(context, nsUser);
                    },
                    child: Icon(Icons.edit_outlined),
                  ),
                ),
              );
          }
        });
  }
}
