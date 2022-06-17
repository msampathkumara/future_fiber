import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';

class UserDetails extends StatefulWidget {
  final NsUser nsUser;

  const UserDetails(this.nsUser, {Key? key}) : super(key: key);

  @override
  _UserDetailsState createState() {
    return _UserDetailsState();
  }

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _UserDetailsState extends State<UserDetails> {
  late NsUser nsUser;

  TextStyle stStyle = const TextStyle(color: Colors.black, fontSize: 18);

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
    return kIsWeb ? DialogView(width: 1000, child: getUi()) : getUi();
  }

  getUi() {
    return FutureBuilder<String>(
        future: getJwt(), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return SafeArea(
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 1,
                    toolbarHeight: 350,
                    flexibleSpace: Center(
                      child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          UserImage(nsUser: nsUser, radius: 124),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              nsUser.name,
                              textScaleFactor: 1.5,
                            ),
                          ),
                          Text('#${nsUser.uname}', style: const TextStyle(color: Colors.blue)),
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
                                const ListTile(title: Text("Contact Details"), leading: Icon(Icons.contact_phone_outlined)),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      ListTile(
                                          leading: const Icon(Icons.phone_android_outlined),
                                          title: const Text("Phone"),
                                          subtitle: Text(nsUser.phone.split(",").join("\n"), style: stStyle)),
                                      ListTile(
                                        leading: const Icon(Icons.alternate_email_outlined),
                                        title: const Text("Email"),
                                        subtitle: Wrap(direction: Axis.horizontal, spacing: 2, children: nsUser.emails.map((e) => Chip(label: Text(e.email ?? ''))).toList()),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              children: [
                                const ListTile(title: Text("Job Details"), leading: Icon(Icons.work_outline_outlined)),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      ListTile(leading: const Icon(Icons.badge_outlined), title: const Text("EPF"), subtitle: Text(nsUser.epf, style: stStyle)),
                                      ListTile(
                                          leading: const Icon(Icons.domain_outlined),
                                          title: const Text("Section"),
                                          subtitle: Wrap(
                                              spacing: 2,
                                              runSpacing: 2,
                                              direction: Axis.horizontal,
                                              crossAxisAlignment: WrapCrossAlignment.start,
                                              children: List.generate(nsUser.sections.length, (index) {
                                                Section section = nsUser.sections[index];
                                                return Padding(
                                                    padding: const EdgeInsets.only(right: 8.0), child: Chip(label: Text("${section.sectionTitle} @ ${section.factory}")));
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
                  // floatingActionButton: nsUser.isDisabled
                  //     ? null
                  //     : FloatingActionButton(
                  //         onPressed: () {
                  //           UpdateUserDetails(nsUser).show(context);
                  //         },
                  //         child: const Icon(Icons.edit_outlined)),
                ),
              );
            }
          }
        });
  }
}
