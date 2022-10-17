// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:smartwind/C/Api.dart';
// import 'package:smartwind/C/Validations.dart';
// import 'package:smartwind/M/NsUser.dart';
// import 'package:smartwind/M/Section.dart';
// import 'package:smartwind/M/hive.dart';
// import 'package:smartwind/Web/Widgets/DialogView.dart';
//
// import '../../../C/form_input_decoration.dart';
//
// class AddUser extends StatefulWidget {
//   const AddUser({Key? key}) : super(key: key);
//
//   @override
//   State<AddUser> createState() => _AddUserState();
//
//   void show(context) {
//     kIsWeb
//         ? showDialog(
//             context: context,
//             builder: (_) => this,
//           )
//         : Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => this),
//           );
//   }
// }
//
// class _AddUserState extends State<AddUser> {
//   NsUser nsUser = NsUser();
//
//   TextStyle stStyle = const TextStyle(color: Colors.black, fontSize: 18);
//
//   final TextEditingController _phoneNumberControll = TextEditingController();
//   final TextEditingController _emailAddressControll = TextEditingController();
//   final TextEditingController _epfNumberControll = TextEditingController();
//
//   Section? selectedSection = Section();
//
//   Uint8List? imageByte;
//
//   String? imagePath;
//
//   var img;
//
//   bool isSaving = false;
//
//   bool addImageUi = false;
//   bool showFormUi = true;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   File? _image;
//
//   Future getImage() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);
//
//     print(result?.files.single.name);
//
//     if (result?.files.first != null) {
//       if (result!.files.single.bytes != null) {
//         imageByte = result.files.single.bytes;
//       } else {
//         imagePath = result.files.single.path;
//         imageByte = File(imagePath!).readAsBytesSync();
//       }
//       if (!kIsWeb) {
//         imagePath = result.files.single.path;
//       }
//     } else {
//       imagePath = null;
//     }
//     setImage();
//     print('--------------------------------------------------------------------------');
//     setState(() {});
//   }
//
//   var placeholder = const AssetImage('assets/images/userPlaceholder.jpg');
//
//   void setImage() {
//     img = placeholder;
//     if (imagePath != null) {
//       img = FileImage(File(imagePath!));
//     } else if (imageByte != null) {
//       img = MemoryImage(imageByte!);
//     }
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return kIsWeb ? DialogView(child: getDialogUi(), width: 600) : getUi();
//   }
//
//   getUi() {}
//
//   String? dropdownValue;
//
//   Future<void> _showPopupmenu(Offset offset, param0) async {
//     final screenSize = MediaQuery.of(context).size;
//     await showMenu(
//       context: context,
//       position: RelativeRect.fromLTRB(
//         offset.dx,
//         offset.dy,
//         screenSize.width - offset.dx,
//         screenSize.height - offset.dy,
//       ),
//       items: [
//         const PopupMenuItem(value: 1, child: Text("Edit")),
//         const PopupMenuItem(value: 2, child: Text("Remove")),
//       ],
//       elevation: 8.0,
//     ).then((value) {
//       if (value != null) param0(value);
//     });
//   }
//
//   getDialogUi() {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit User")),
//       body: isSaving
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.only(bottom: 16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   if (addImageUi)
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Wrap(direction: Axis.vertical, crossAxisAlignment: WrapCrossAlignment.center, children: [
//                         CircleAvatar(
//                             radius: 150,
//                             foregroundImage: img ?? (nsUser.haveImage ? NetworkImage(nsUser.getImage()) : (img ?? placeholder)),
//                             backgroundImage: const AssetImage("assets/images/userPlaceholder.jpg")),
//                         Row(children: [
//                           SizedBox(width: 170, child: TextButton(onPressed: getImage, child: const Text("Change Profile Picture"))),
//                           if (_image != null) const SizedBox(height: 20, child: VerticalDivider(color: Colors.grey, thickness: 1)),
//                           if (_image != null)
//                             SizedBox(
//                                 width: 170,
//                                 child: TextButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         _image = null;
//                                       });
//                                     },
//                                     child: const Text("Reset", textAlign: TextAlign.left)))
//                         ]),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16.0),
//                           child: Text(
//                             nsUser.name,
//                             textScaleFactor: 1.5,
//                           ),
//                         ),
//                         Text('#${nsUser.uname}', style: const TextStyle(color: Colors.blue))
//                       ]),
//                     ),
//                   if (showFormUi)
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             children: [
//                               Card(
//                                 child: Column(
//                                   children: [
//                                     const ListTile(title: Text("Basic Info"), leading: Icon(Icons.account_box_outlined)),
//                                     Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Column(children: [
//                                         TextFormField(
//                                           initialValue: nsUser.name,
//                                           decoration: FormInputDecoration.getDeco(labelText: "Full Name"),
//                                           onChanged: (text) {
//                                             nsUser.name = text;
//                                           },
//                                         ),
//                                         const SizedBox(height: 16),
//                                         TextFormField(
//                                           initialValue: nsUser.uname,
//                                           decoration: FormInputDecoration.getDeco(labelText: "User Name"),
//                                           onChanged: (text) {
//                                             nsUser.uname = text;
//                                             setState(() {});
//                                           },
//                                         )
//                                       ]),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               Card(
//                                 child: Column(
//                                   children: [
//                                     const ListTile(title: Text("Contacts Details"), leading: Icon(Icons.contact_phone_outlined)),
//                                     Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Column(children: [
//                                         Column(
//                                           children: [
//                                             TextFormField(
//                                                 decoration: FormInputDecoration.getDeco(labelText: "Phone Number", hintText: "Enter phone number", icon: const Icon(Icons.phone)),
//                                                 keyboardType: TextInputType.number,
//                                                 inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
//                                                 controller: _phoneNumberControll,
//                                                 onFieldSubmitted: (t) {
//                                                   nsUser.addPhone(t);
//                                                   _phoneNumberControll.text = "";
//                                                   setState(() {});
//                                                 }),
//                                             Align(
//                                               alignment: Alignment.topLeft,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.only(left: 32.0),
//                                                 child: Wrap(
//                                                     alignment: WrapAlignment.start,
//                                                     children: List.generate(nsUser.getPhonesList().length, (index) {
//                                                       String number = nsUser.getPhonesList()[index];
//                                                       return Padding(
//                                                         padding: const EdgeInsets.all(8.0),
//                                                         child: GestureDetector(
//                                                             onTapDown: (TapDownDetails details) {
//                                                               _showPopupmenu(details.globalPosition, (val) {
//                                                                 if (val == 1) {
//                                                                   _phoneNumberControll.text = number;
//                                                                   nsUser.removePhone(number);
//                                                                 } else {
//                                                                   nsUser.removePhone(number);
//                                                                 }
//                                                                 setState(() {});
//                                                               });
//                                                             },
//                                                             child: Chip(avatar: const Icon(Icons.call_outlined), label: Text(number))),
//                                                       );
//                                                     })),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                         Column(
//                                           children: [
//                                             TextFormField(
//                                                 decoration:
//                                                     FormInputDecoration.getDeco(labelText: "Email Address", icon: const Icon(Icons.email_rounded), hintText: "Enter your Email"),
//                                                 keyboardType: TextInputType.emailAddress,
//                                                 inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
//                                                 validator: (input) => Validations.isValidEmail(input) ? null : "Check your email",
//                                                 controller: _emailAddressControll,
//                                                 onFieldSubmitted: (t) {
//                                                   nsUser.addEmailAddress(t);
//                                                   _emailAddressControll.text = "";
//                                                   setState(() {});
//                                                 }),
//                                             Align(
//                                               alignment: Alignment.topLeft,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.only(left: 32.0),
//                                                 child: Wrap(
//                                                     alignment: WrapAlignment.start,
//                                                     children: List.generate(nsUser.getPhonesList().length, (index) {
//                                                       String number = nsUser.getEmailList()[index];
//                                                       return Padding(
//                                                         padding: const EdgeInsets.all(8.0),
//                                                         child: GestureDetector(
//                                                             onTapDown: (TapDownDetails details) {
//                                                               _showPopupmenu(details.globalPosition, (val) {
//                                                                 if (val == 1) {
//                                                                   _emailAddressControll.text = number;
//                                                                   nsUser.removeEmail(number);
//                                                                 } else {
//                                                                   nsUser.removeEmail(number);
//                                                                 }
//                                                                 setState(() {});
//                                                               });
//                                                             },
//                                                             child: Chip(avatar: const Icon(Icons.call_outlined), label: Text(number))),
//                                                       );
//                                                     })),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ]),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               Card(
//                                 child: Column(
//                                   children: [
//                                     const ListTile(title: Text("Job Details"), leading: Icon(Icons.work_outline_outlined)),
//                                     Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Column(
//                                         children: [
//                                           TextFormField(
//                                               decoration: FormInputDecoration.getDeco(labelText: "EPF", icon: const Icon(Icons.numbers_rounded)),
//                                               keyboardType: TextInputType.number,
//                                               inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
//                                               controller: _epfNumberControll),
//                                           ListTile(
//                                               leading: const Icon(Icons.location_on_outlined),
//                                               title: const Text("Section"),
//                                               subtitle: Column(
//                                                 children: [
//                                                   Row(children: [
//                                                     Padding(
//                                                       padding: const EdgeInsets.only(right: 8.0),
//                                                       child: DropdownButton<String>(
//                                                         isDense: true,
//                                                         hint: const Text("Factory"),
//                                                         value: selectedSection!.factory == "" ? null : selectedSection!.factory,
//                                                         iconSize: 24,
//                                                         elevation: 16,
//                                                         style: const TextStyle(color: Colors.deepPurple),
//                                                         underline: Container(
//                                                           height: 2,
//                                                           color: Colors.deepPurpleAccent,
//                                                         ),
//                                                         onChanged: (String? newValue) {
//                                                           setState(() {
//                                                             selectedSection!.factory = newValue!;
//                                                           });
//                                                         },
//                                                         items: <String>[
//                                                           'Upwind',
//                                                           'OD',
//                                                           'Nylon Standard',
//                                                           'Nylon Custom',
//                                                           'OEM',
//                                                           '38 Upwind',
//                                                           '38 OD',
//                                                           '38 Nylon Standard',
//                                                           '38 Nylon Custom',
//                                                           '38 OEM'
//                                                         ].map<DropdownMenuItem<String>>((String value) {
//                                                           return DropdownMenuItem<String>(value: value, child: SizedBox(width: 150, child: Text(value)));
//                                                         }).toList(),
//                                                       ),
//                                                     ),
//                                                     Padding(
//                                                       padding: const EdgeInsets.all(8.0),
//                                                       child: DropdownButton<String>(
//                                                           iconEnabledColor: const Color(0xFF595959),
//                                                           hint: const Text(
//                                                             "Section",
//                                                             style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 15),
//                                                           ),
//                                                           value: selectedSection!.sectionTitle == "" ? null : selectedSection!.sectionTitle,
//                                                           // icon: const Icon(Icons.arrow_downward),
//                                                           iconSize: 24,
//                                                           elevation: 16,
//                                                           style: const TextStyle(color: Colors.deepPurple),
//                                                           underline: Container(height: 2, color: Colors.deepPurpleAccent),
//                                                           onChanged: (String? newValue) {
//                                                             setState(() {
//                                                               selectedSection!.sectionTitle = newValue!;
//                                                             });
//                                                           },
//                                                           items: <String>[
//                                                             'Cutting',
//                                                             '3D Drawing',
//                                                             'Stickup',
//                                                             'Layout',
//                                                             'Sewing',
//                                                             'Hand Work',
//                                                             'Qc',
//                                                             'Hardware Stores',
//                                                             'Cloth Stores',
//                                                             '3DL',
//                                                             'Textile',
//                                                             'Printing',
//                                                             'SA'
//                                                           ].map<DropdownMenuItem<String>>((String value) {
//                                                             return DropdownMenuItem<String>(
//                                                               value: value,
//                                                               child: SizedBox(width: 150, child: Text(value)),
//                                                             );
//                                                           }).toList()),
//                                                     ),
//                                                     if (selectedSection!.sectionTitle.isNotEmpty && selectedSection!.factory.isNotEmpty)
//                                                       Padding(
//                                                           padding: const EdgeInsets.all(8.0),
//                                                           child: ElevatedButton(
//                                                               onPressed: () {
//                                                                 nsUser.addSection(selectedSection!);
//                                                                 selectedSection = new Section();
//                                                                 setState(() {});
//                                                               },
//                                                               child: const Text("Add")))
//                                                   ]),
//                                                   Align(
//                                                       alignment: Alignment.topLeft,
//                                                       child: Wrap(
//                                                           direction: Axis.horizontal,
//                                                           crossAxisAlignment: WrapCrossAlignment.start,
//                                                           children: List.generate(nsUser.sections.length, (index) {
//                                                             Section section = nsUser.sections[index];
//                                                             return Padding(
//                                                                 padding: const EdgeInsets.only(right: 8.0, bottom: 8),
//                                                                 child: Chip(label: Text("${section.sectionTitle} @ ${section.factory}")));
//                                                           })))
//                                                 ],
//                                               )),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                 ],
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             saveUser();
//           },
//           child: const Icon(Icons.save_outlined)),
//     );
//   }
//
//   Future saveUser() async {
//     isSaving = true;
//     setState(() {});
//     var id = "";
//     if (imageByte != null) {
//       id = await uploadImage();
//     }
//     print('ssssssssssssssssssssss');
//
//     return Api.post("users/updateUser", {"user": nsUser, "image": id}).then((res) async {
//       Map data = res.data;
//       if (data["done"] == true) {
//         if (id != "") {
//           nsUser.img = "$id.jpg";
//         }
//
//         await HiveBox.getDataFromServer();
//
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           backgroundColor: Colors.green,
//           content: Text("User Saved", style: TextStyle(color: Colors.white)),
//         ));
//         Navigator.pop(context, true);
//       } else if (data["error"] != null) {
//         var error = "";
//         if (data["nicUsed"] != null) {
//           error = "NIC already have an account";
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(error, style: const TextStyle(color: Colors.white))));
//       }
//       isSaving = false;
//       setState(() {});
//     }).onError((error, stackTrace) {
//       print(stackTrace);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         backgroundColor: Colors.red,
//         content: Text(error.toString(), style: const TextStyle(color: Colors.white)),
//       ));
//       isSaving = false;
//       setState(() {});
//     });
//   }
//
//   Future<String> uploadImage() async {
//     String fileName = imagePath ?? "".split('/').last;
//     FormData formData = FormData.fromMap({"file": MultipartFile.fromBytes(imageByte!, filename: fileName)});
//
//     var response = await Api.post(("users/saveImage"), {}, formData: formData);
//     print(response.data);
//     return response.data['id'];
//   }
// }
