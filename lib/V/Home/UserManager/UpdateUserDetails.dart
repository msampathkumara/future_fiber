import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartwind/C/Validations.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';

class UpdateUserDetails extends StatefulWidget {
  late NsUser nsUser;

  UpdateUserDetails(NsUser nsUser) {
    this.nsUser = NsUser.fromJson(nsUser.toJson());
  }

  @override
  _UpdateUserDetailsState createState() {
    return _UpdateUserDetailsState();
  }

  static show(context, nsUser) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateUserDetails(nsUser)),
    );
  }
}

class _UpdateUserDetailsState extends State<UpdateUserDetails> {
  late NsUser nsUser;

  TextStyle stStyle = TextStyle(color: Colors.black, fontSize: 18);

  TextEditingController _phoneNumberControll = new TextEditingController();
  TextEditingController _emaiAddressControll = new TextEditingController();
  TextEditingController _epfNumberControll = new TextEditingController();

  Section? selectedSection = new Section();

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;
  }

  @override
  void dispose() {
    super.dispose();
  }

  File? _image;

  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = new File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          toolbarHeight: 400,
          flexibleSpace: Center(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_image != null) CircleAvatar(radius: 124.0, backgroundImage: Image.file(_image!).image, backgroundColor: Colors.transparent),
                if (_image == null) CircleAvatar(radius: 124.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
                Row(
                  children: [
                    SizedBox(
                      child: TextButton(onPressed: getImage, child: Text("Change Profile Picture")),
                      width: 170,
                    ),
                    if (_image != null) SizedBox(
                      child: VerticalDivider(color: Colors.grey, thickness: 1),
                      height: 20,
                    ),
                    if (_image != null)  SizedBox(
                        child: TextButton(
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            child: Text(
                              "Reset",
                              textAlign: TextAlign.left,
                            )),
                        width: 170)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    nsUser.name,
                    textScaleFactor: 1.5,
                  ),
                ),
                Text('#' + nsUser.uname, style: TextStyle(color: Colors.blue)),
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
                      ListTile(title: Text("Basic Info"), leading: Icon(Icons.account_box_outlined)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          ListTile(
                              // leading: Icon(Icons.phone_android_outlined),
                              subtitle: Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {});
                            },
                            child: TextFormField(
                              initialValue: nsUser.name,
                              decoration: new InputDecoration(labelText: "Full Name"),
                              // controller: _nameFieldControll,
                              onChanged: (text) {
                                nsUser.name = text;
                              },
                            ),
                          )),
                          ListTile(
                              // leading: Icon(Icons.phone_android_outlined),
                              subtitle: Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {});
                            },
                            child: TextFormField(
                              initialValue: nsUser.uname,
                              decoration: new InputDecoration(labelText: "User Name"),
                              // controller: _unameFieldControll,
                              onChanged: (text) {
                                nsUser.uname = text;
                                setState(() {});
                              },
                            ),
                          )),
                        ]),
                      )
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(title: Text("Phone Details"), leading: Icon(Icons. contact_phone_outlined)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          ListTile(
                              leading: Icon(Icons.phone_android_outlined),
                              title: Text("Phone"),
                              subtitle: Column(
                                children: [
                                  TextFormField(
                                    decoration: new InputDecoration(labelText: "Enter your number"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                    controller: _phoneNumberControll,
                                    onFieldSubmitted: (t) {
                                      nsUser.addPhone(t);
                                      _phoneNumberControll.text = "";
                                    },
                                  ),
                                  Row(
                                      children: List.generate(nsUser.getPhonesList().length, (index) {
                                    String number = nsUser.getPhonesList()[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                          onTapDown: (TapDownDetails details) {
                                            _showPopupmenu(details.globalPosition, (val) {
                                              if (val == 1) {
                                                _phoneNumberControll.text = number;
                                                nsUser.removePhone(number);
                                              } else {
                                                nsUser.removePhone(number);
                                              }
                                              setState(() {});
                                            });
                                          },
                                          child: Chip(avatar: Icon(Icons.call_outlined), label: Text(number))),
                                    );
                                  }))
                                ],
                              )),
                          ListTile(
                              leading: Icon(Icons.alternate_email_outlined),
                              title: Text("Email"),
                              subtitle: Column(children: [
                                TextFormField(
                                  decoration: new InputDecoration(labelText: "Enter your Email"),
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (input) => Validations.isValidEmail(input) ? null : "Check your email",
                                  controller: _emaiAddressControll,
                                  onFieldSubmitted: (t) {
                                    nsUser.addEmailAddress(t);
                                    _emaiAddressControll.text = "";
                                  },
                                ),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                        direction: Axis.horizontal,
                                        crossAxisAlignment: WrapCrossAlignment.start,
                                        // runSpacing: 5.0,
                                        // spacing: 5.0,
                                        children: List.generate(nsUser.getEmailList().length, (index) {
                                          String email = nsUser.getEmailList()[index];
                                          return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: GestureDetector(
                                                  onTapDown: (TapDownDetails details) {
                                                    _showPopupmenu(details.globalPosition, (val) {
                                                      if (val == 1) {
                                                        _emaiAddressControll.text = email;
                                                        nsUser.removeEmail(email);
                                                      } else {
                                                        nsUser.removeEmail(email);
                                                      }
                                                      setState(() {});
                                                    });
                                                  },
                                                  child: Chip(avatar: Icon(Icons.alternate_email_outlined), label: Text(email))));
                                        })))
                              ])),
                          // ListTile(leading: Icon(Icons.location_on_outlined), title: Text("Address"), subtitle: TextFormField(controller: _emaiAddressControll)),
                        ]),
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
                            ListTile(
                                leading: Icon(Icons.badge_outlined),
                                subtitle: TextFormField(
                                    decoration: new InputDecoration(labelText: "EPF"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                    controller: _epfNumberControll)),
                            ListTile(
                                leading: Icon(Icons.location_on_outlined),
                                title: Text("Section"),
                                subtitle: Column(
                                  children: [
                                    Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: DropdownButton<String>(
                                          isDense: true,
                                          hint: Text("Factory"),
                                          value: selectedSection!.factory == "" ? null : selectedSection!.factory,
                                          iconSize: 24,
                                          elevation: 16,
                                          style: const TextStyle(color: Colors.deepPurple),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedSection!.factory = newValue!;
                                            });
                                          },
                                          items: <String>['Upwind', 'OD', 'Nylon', 'OEM'].map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: SizedBox(width: 150, child: Text(value)),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DropdownButton<String>(
                                            iconEnabledColor: Color(0xFF595959),
                                            hint: Text(
                                              "Section",
                                              style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 15),
                                            ),
                                            value: selectedSection!.sectionTitle == "" ? null : selectedSection!.sectionTitle,
                                            // icon: const Icon(Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: const TextStyle(color: Colors.deepPurple),
                                            underline: Container(height: 2, color: Colors.deepPurpleAccent),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedSection!.sectionTitle = newValue!;
                                              });
                                            },
                                            items: <String>[
                                              'Cutting',
                                              '3D Drawing',
                                              'Stickup',
                                              'Layout',
                                              'Sewing',
                                              'Hand Work',
                                              'Qc',
                                              'Hardware Stores',
                                              'Cloth Stores',
                                              '3DL',
                                              'Textile',
                                              'Printing',
                                              'SA'
                                            ].map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: SizedBox(width: 150, child: Text(value)),
                                              );
                                            }).toList()),
                                      ),
                                      if (selectedSection!.sectionTitle.isNotEmpty && selectedSection!.factory.isNotEmpty)
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  nsUser.addSection(selectedSection!);
                                                  selectedSection = new Section();
                                                  setState(() {});
                                                },
                                                child: Text("Add")))
                                    ]),
                                    Align(
                                        alignment: Alignment.topLeft,
                                        child: Wrap(
                                            direction: Axis.horizontal,
                                            crossAxisAlignment: WrapCrossAlignment.start,
                                            children: List.generate(nsUser.sections.length, (index) {
                                              Section section = nsUser.sections[index];
                                              return Padding(padding: const EdgeInsets.only(right: 8.0), child: Chip(label: Text(section.sectionTitle + " @ " + section.factory)));
                                            })))
                                  ],
                                )),
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
        floatingActionButton: FloatingActionButton(onPressed: () {

        }, child: Icon(Icons.save_outlined)),
      ),
    );
  }

  String? dropdownValue;

  Future<void> _showPopupmenu(Offset offset, param0) async {
    final screenSize = MediaQuery.of(context).size;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        screenSize.width - offset.dx,
        screenSize.height - offset.dy,
      ),
      items: [
        PopupMenuItem(value: 1, child: Text("Edit")),
        PopupMenuItem(value: 2, child: Text("Remove")),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) param0(value);
    });
  }
}
