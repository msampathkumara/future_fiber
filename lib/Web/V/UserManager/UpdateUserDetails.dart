import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/C/Validations.dart';
import 'package:smartwind/C/form_input_decoration.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/V/Home/UserManager/section_list.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';

class UpdateUserDetails extends StatefulWidget {
  late NsUser nsUser;

  UpdateUserDetails(NsUser nsUser, {Key? key}) : super(key: key) {
    this.nsUser = NsUser.fromJson(nsUser.toJson());
  }

  @override
  _UpdateUserDetailsState createState() {
    return _UpdateUserDetailsState();
  }

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _UpdateUserDetailsState extends State<UpdateUserDetails> {
  late NsUser nsUser;
  late NsUser orginalNsUser;

  TextStyle stStyle = const TextStyle(color: Colors.black, fontSize: 18);

  final TextEditingController _phoneNumberControll = TextEditingController();
  final TextEditingController _emaiAddressControll = TextEditingController();
  final TextEditingController _epfNumberControll = TextEditingController();

  Section? selectedSection = Section();

  Uint8List? imageByte;

  String? imagePath;

  var img;

  bool isSaving = false;

  int _userNameCheking = 0;

  bool duplicateNic = false;

  get isNew => nsUser.id == 0;

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;
    orginalNsUser = widget.nsUser;
    _epfNumberControll.text = nsUser.getEpf().toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  File? _image;

  Future getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);

    print(result?.files.single.name);

    if (result?.files.first != null) {
      if (result!.files.single.bytes != null) {
        imageByte = result.files.single.bytes;
      } else {
        imagePath = result.files.single.path;
        imageByte = File(imagePath!).readAsBytesSync();
      }
      if (!kIsWeb) {
        imagePath = result.files.single.path;
      }
    } else {
      imagePath = null;
    }
    setImage();
    print('--------------------------------------------------------------------------');
    setState(() {});
    imageId = '';
  }

  var placeholder = const AssetImage('assets/images/userPlaceholder.jpg');

  void setImage() {
    img = placeholder;
    if (imagePath != null) {
      img = FileImage(File(imagePath!));
    } else if (imageByte != null) {
      img = MemoryImage(imageByte!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? DialogView(child: getDialogUi(), width: 1000) : getUi();
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
        const PopupMenuItem(value: 1, child: Text("Edit")),
        const PopupMenuItem(value: 2, child: Text("Remove")),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) param0(value);
    });
  }

  getDialogUi() {
    return Scaffold(
      appBar: AppBar(title: Text(isNew ? "Add User" : "Edit User")),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(direction: Axis.vertical, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      CircleAvatar(
                          radius: 150,
                          foregroundImage: img ?? (nsUser.haveImage ? NetworkImage(nsUser.getImage()) : (img ?? placeholder)),
                          backgroundImage: const AssetImage("assets/images/userPlaceholder.jpg")),
                      Row(children: [
                        SizedBox(width: 170, child: TextButton(onPressed: getImage, child: Text(isNew ? "Add Profile Picture" : "Change Profile Picture"))),
                        if (_image != null) const SizedBox(height: 20, child: VerticalDivider(color: Colors.grey, thickness: 1)),
                        if (_image != null)
                          SizedBox(
                              width: 170,
                              child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _image = null;
                                    });
                                  },
                                  child: const Text("Reset", textAlign: TextAlign.left)))
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          nsUser.name,
                          textScaleFactor: 1.5,
                        ),
                      ),
                      Text('#${nsUser.uname}', style: const TextStyle(color: Colors.blue))
                    ]),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Card(
                              child: Column(
                                children: [
                                  const ListTile(title: Text("Basic Info"), leading: Icon(Icons.account_box_outlined)),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(children: [
                                      TextFormField(
                                        initialValue: nsUser.name,
                                        decoration: FormInputDecoration.getDeco(labelText: "Full Name"),
                                        onChanged: (text) {
                                          nsUser.name = text;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                          initialValue: nsUser.uname,
                                          decoration: FormInputDecoration.getDeco(labelText: "User Name", suffixIcon: getSusfix(_userNameCheking)),
                                          onChanged: (text) {
                                            nsUser.uname = text;
                                            setState(() {});
                                            check('uname', text);
                                          }),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          initialValue: (nsUser.nic ?? '').replaceAll('v', '').replaceAll('V', ''),
                                          decoration: FormInputDecoration.getDeco(labelText: "NIC", suffixText: (nsUser.nic ?? '').contains("v") ? "V  " : ""),
                                          onChanged: (text) {
                                            nsUser.nic = text;
                                            if (text.length < 10) {
                                              text = "${text}v";
                                            }
                                            nsUser.nic = text;
                                            setState(() {});
                                          },
                                          validator: (value) {
                                            if ("$value".length < 10) {
                                              value = "${value}v";
                                            }
                                            nsUser.nic = value ?? "";
                                            return duplicateNic ? 'Duplicate NIC' : Validations.nic("$value");
                                          })
                                    ]),
                                  )
                                ],
                              ),
                            ),
                            Card(
                              child: Column(
                                children: [
                                  const ListTile(title: Text("Contacts Details"), leading: Icon(Icons.contact_phone_outlined)),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(children: [
                                      Column(
                                        children: [
                                          TextFormField(
                                              decoration: FormInputDecoration.getDeco(labelText: "Phone Number", hintText: "Enter phone number", icon: const Icon(Icons.phone)),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                              controller: _phoneNumberControll,
                                              onFieldSubmitted: (t) {
                                                nsUser.addPhone(t);
                                                _phoneNumberControll.text = "";
                                                setState(() {});
                                              }),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 32.0),
                                              child: Wrap(
                                                  alignment: WrapAlignment.start,
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
                                                          child: Chip(avatar: const Icon(Icons.call_outlined), label: Text(number))),
                                                    );
                                                  })),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Column(
                                        children: [
                                          TextFormField(
                                              decoration:
                                                  FormInputDecoration.getDeco(labelText: "Email Address", icon: const Icon(Icons.email_rounded), hintText: "Enter your Email"),
                                              keyboardType: TextInputType.emailAddress,
                                              validator: (input) => Validations.isValidEmail(input) ? null : "Check your email",
                                              controller: _emaiAddressControll,
                                              onFieldSubmitted: (t) {
                                                nsUser.addEmailAddress(t);
                                                _emaiAddressControll.text = "";
                                                setState(() {});
                                              }),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 32.0),
                                              child: Wrap(
                                                  alignment: WrapAlignment.start,
                                                  children: List.generate(nsUser.getEmailList().length, (index) {
                                                    String number = nsUser.getEmailList()[index];
                                                    return Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: GestureDetector(
                                                          onTapDown: (TapDownDetails details) {
                                                            _showPopupmenu(details.globalPosition, (val) {
                                                              if (val == 1) {
                                                                _emaiAddressControll.text = number;
                                                                nsUser.removeEmail(number);
                                                              } else {
                                                                nsUser.removeEmail(number);
                                                              }
                                                              setState(() {});
                                                            });
                                                          },
                                                          child: Chip(avatar: const Icon(Icons.email_outlined), label: Text(number))),
                                                    );
                                                  })),
                                            ),
                                          )
                                        ],
                                      ),
                                    ]),
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
                                      child: Column(children: [
                                        TextFormField(
                                            decoration: FormInputDecoration.getDeco(labelText: "EPF", icon: const Icon(Icons.numbers_rounded)),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                            onChanged: (t) {
                                              nsUser.epf = int.parse(t);
                                            },
                                            controller: _epfNumberControll,
                                            enabled: isNew),
                                        const SizedBox(height: 20),
                                        ListTile(
                                            leading: const Icon(Icons.location_on_outlined),
                                            title: const Text("Section"),
                                            subtitle: Column(children: [
                                              Row(children: [
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      SectionList(nsUser.sections, (p0) {
                                                        nsUser.sections = p0;
                                                        setState(() {});
                                                      }).show(context);
                                                    },
                                                    child: const Text('Select Section')),
                                                if (selectedSection!.sectionTitle.isNotEmpty && selectedSection!.factory.isNotEmpty)
                                                  Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            nsUser.addSection(selectedSection!);
                                                            selectedSection = Section();
                                                            setState(() {});
                                                          },
                                                          child: const Text("Add")))
                                              ]),
                                              const SizedBox(height: 20),
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Wrap(
                                                      direction: Axis.horizontal,
                                                      crossAxisAlignment: WrapCrossAlignment.start,
                                                      children: List.generate(nsUser.sections.length, (index) {
                                                        Section section = nsUser.sections[index];
                                                        return Padding(
                                                            padding: const EdgeInsets.only(right: 8.0, bottom: 8),
                                                            child: Chip(label: Text("${section.sectionTitle} @ ${section.factory}")));
                                                      })))
                                            ]))
                                      ]))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            saveUser();
          },
          child: const Icon(Icons.save_outlined)),
    );
  }

  var imageId = '';

  Future saveUser() async {
    isSaving = true;
    setState(() {});

    if (imageByte != null && imageId.isEmpty) {
      imageId = await uploadImage();
    }

    print('ssssssssssssssssssssss');

    return Api.post("users/saveUser", {"user": nsUser, "image": imageId}).then((res) async {
      Map data = res.data;
      var duplicates = [];
      if (data["error"] == true) {
        if (data["duplicateNic"] == true) {
          duplicateNic = true;
          duplicates.add('NIC');
        }
        if (data["duplicateUname"] == true) {
          _userNameCheking = 2;
          duplicates.add('User Name');
        }
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.redAccent, content: Text("Error : Duplicate data (${duplicates.join(',')})", style: const TextStyle(color: Colors.white))));
      } else if (data["done"] == true) {
        if (imageId != "") {
          nsUser.img = "$imageId.jpg";
        }

        nsUser = NsUser.fromJson(data["user"]);
        bool isNew = data["isNew"];
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("User Saved", style: TextStyle(color: Colors.white)),
        ));
        Navigator.pop(context, isNew ? nsUser : null);
      } else if (data["error"] != null) {
        var error = "";
        if (data["nicUsed"] != null) {
          error = "NIC already have an account";
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(error, style: const TextStyle(color: Colors.white))));
      }
      isSaving = false;
      setState(() {});
    }).onError((error, stackTrace) {
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(error.toString(), style: const TextStyle(color: Colors.white)),
      ));
      isSaving = false;
      setState(() {});
    });
  }

  Future<String> uploadImage() async {
    String fileName = imagePath ?? "".split('/').last;
    FormData formData = FormData.fromMap({"file": MultipartFile.fromBytes(imageByte!, filename: fileName)});

    var response = await Api.post(("users/saveImage"), {}, formData: formData);
    print(response.data);
    return response.data['id'];
  }

  var _timer;

  check(String key, String value) {
    _userNameCheking = 1;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(const Duration(milliseconds: 1000), () {
      Api.post("users/checkDuplicate", {"k": key, "v": value}).then((res) async {
        print(res.data);
        _userNameCheking = 0;
        if (res.data["duplicate"] == true) {
          _userNameCheking = 2;
        } else {
          _userNameCheking = 3;
        }
        setState(() {});
      });
    });
  }

  getSusfix(c) {
    var x = null;
    c = nsUser.uname.isEmpty ? 0 : c;

    switch (c) {
      case 0:
        x = null;
        break;
      case 1:
        x = const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)));
        break;
      case 2:
        x = const Icon(Icons.error_rounded, color: Colors.red);
        break;
      case 3:
        x = const Icon(Icons.done_rounded, color: Colors.green);
        break;
    }

    return x;
  }

  final _formKey = GlobalKey<FormState>();

  getUi() {
    return Form(child: getDialogUi(), key: _formKey);
  }
}
