import 'package:flutter/material.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/V/Home/UserManager/UpdateUserDetails.dart';

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

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;
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
                CircleAvatar(radius: 124.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
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
                            ListTile(leading: Icon(Icons.phone_android_outlined), title: Text("Phone"), subtitle: Text(nsUser.contact.split(",").join("\n"), style: stStyle)),
                            ListTile(leading: Icon(Icons.alternate_email_outlined), title: Text("Email"), subtitle: Text(nsUser.emailAddress.split(",").join("\n"), style: stStyle)),
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
                                      return Padding(padding: const EdgeInsets.only(right: 8.0), child: Chip(label: Text(section.sectionTitle + " @ " + section.factory)));
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
}
