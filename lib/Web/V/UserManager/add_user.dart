// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:smartwind/C/Validations.dart';
// import 'package:smartwind/C/form_input_decoration.dart';
// import 'package:smartwind/M/AppUser.dart';
// import 'package:smartwind/M/NsUser.dart';
//
//
// Map<String, List<String>> lots = {
//   'Lot 74': [
//     'PRODUCTION - UPWIND',
//     'PRODUCTION-TEXTILES',
//     'PURCHASING',
//     'ORDER TO EXPORT',
//     'EMPLOYEE SERVICES',
//     'MAINTENANCE',
//     'SHIPPING & LOGISTICS',
//     'FINANCE',
//     'ENGINEERING',
//     'EMPLOYEE SUPPORT',
//     'GENERAL',
//     'IT',
//     'PLANNING',
//     'PRODUCTION-3D',
//     'RECRUITMENT & TRAINING',
//     'STORES',
//     'PRODUCTION-PRINTING',
//     'PRODUCTION-GENERAL'
//   ],
//   'Lot 37': ['STORES', 'PRODUCTION - CUTCO', 'PRODUCTION-NC', 'PRODUCTION-GENERAL', 'MAINTENANCE', 'PRODUCTION-3D', 'EMPLOYEE SERVICES'],
//   'Lot 66': ['PRODUCTION-OEM', 'PRODUCTION - NYLON', 'PRODUCTION-BATTEN', 'EMPLOYEE SERVICES'],
//   'Lot 27': ['PRODUCTION-PRINTING'],
//   'Lot 44': [
//     'PRODUCTION-TEXTILES',
//     'PRODUCTION-ONE DESIGN',
//     'RECRUITMENT & TRAINING',
//     'SHIPPING & LOGISTICS',
//     'STORES',
//     'MAINTENANCE',
//     'PRODUCTION-TRAINING CENTER',
//     'EMPLOYEE SERVICES',
//     'MAINTENANCE'
//   ]
// };
//
// class AddUser extends StatefulWidget {
//   final NsUser? user;
//
//   final bool selfEdit;
//
//   final Function(NsUser)? afterSave;
//
//   AddUser({this.user, this.selfEdit = false, this.afterSave, Key? key}) : super(key: key ?? Key("${DateTime.now().microsecondsSinceEpoch}"));
//
//   @override
//   _AddUserState createState() => _AddUserState();
// }
//
// var placeholder = const AssetImage('assets/images/userPlaceholder.jpg');
// String? imagePath;
//
// class _AddUserState extends State<AddUser> {
//   bool isSaving = false;
//
//   Map errors = {};
//
//   late NsUser user;
//
//   final _formKey = GlobalKey<FormState>();
//   bool _edit = false;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     _edit = widget.user != null;
//     user = NsUser();
//     if (widget.user != null) {
//       user = NsUser.fromJson(widget.user?.toJson() ?? NsUser().toJson());
//     }
//     super.initState();
//   }
//
//   final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add User")),
//       body: isSaving
//           ? const Center(child: Text("Saving"))
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 child: Container(
//                   constraints: const BoxConstraints(minWidth: 200, maxWidth: kIsWeb ? 500 : 1000),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Column(
//                           children: [
//                             CircleAvatar(
//                                 radius: 150,
//                                 foregroundImage: img ?? (user.haveImage ? NetworkImage(user.getImage()) : (img ?? placeholder)),
//                                 backgroundImage: const AssetImage("assets/images/userPlaceholder.jpg")),
//                             ElevatedButton(
//                                 onPressed: () async {
//                                   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);
//
//                                   print(result?.files.single.name);
//
//                                   if (result?.files.first != null) {
//                                     if (result!.files.single.bytes != null) {
//                                       imageByte = result.files.single.bytes;
//                                     } else {
//                                       imagePath = result.files.single.path;
//                                       imageByte = File(imagePath!).readAsBytesSync();
//                                     }
//                                     if (!kIsWeb) {
//                                       imagePath = result.files.single.path;
//                                     }
//                                   } else {
//                                     imagePath = null;
//                                   }
//                                   setImage();
//                                   print('--------------------------------------------------------------------------');
//                                   setState(() {});
//                                 },
//                                 child: const Text("Pick image"))
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: TextFormField(
//                               keyboardType: TextInputType.number,
//                               inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
//                               enabled: widget.selfEdit ? false : true,
//                               initialValue: user.nic.replaceAll(RegExp(r'[a-zA-Z]'), ''),
//                               onChanged: (text) {
//                                 if (text.length < 10) {
//                                   text = "${text}v";
//                                 }
//                                 user.nic = text;
//                                 setState(() {});
//                               },
//                               autofocus: false,
//                               style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                               decoration: FormInputDecoration.getDeco(labelText: "NIC", suffixText: user.nic.contains("v") ? "V  " : ""),
//                               validator: (value) {
//                                 if ("$value".length < 10) {
//                                   value = "${value}v";
//                                 }
//
//                                 user.nic = value ?? "";
//                                 return Validations.nic("$value");
//                               }),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: TextFormField(
//                               inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z. ]'))],
//                               enabled: widget.selfEdit ? false : true,
//                               initialValue: user.name,
//                               onChanged: (text) {
//                                 user.name = text;
//                               },
//                               autofocus: false,
//                               style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                               decoration: FormInputDecoration.getDeco(labelText: "Name"),
//                               validator: (value) {
//                                 print('cccccccccccccccccccccccc');
//
//                                 user.name = value ?? "";
//
//                                 return Validations.nameValidate(value, ifEmpty: 'Please enter name', ifInvalid: 'Please enter valid name');
//                               }),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: TextFormField(
//                               inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
//                               enabled: widget.selfEdit ? false : true,
//                               initialValue: user.epf,
//                               onChanged: (text) {
//                                 user.epf = text;
//                               },
//                               autofocus: false,
//                               style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                               decoration: FormInputDecoration.getDeco(labelText: "EPF"),
//                               validator: (value) {
//                                 user.epf = value ?? "";
//                                 // if (value == null || value.isEmpty) {
//                                 //   return 'Please enter user name';
//                                 // }
//                                 return Validations.epfValidation(value);
//                               }),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: TextFormField(
//                               inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
//                               initialValue: user.phone,
//                               onChanged: (text) {
//                                 user.phone = text;
//                               },
//                               autofocus: false,
//                               style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                               decoration: FormInputDecoration.getDeco(labelText: "Phone Numbers", helperText: "Separate with dash(-)"),
//                               validator: (value) {
//                                 user.phone = value ?? "";
//                                 bool err = false;
//                                 "$value".split("-").forEach((element) {
//                                   if (Validations.phoneNumberValidation(element) != null) {
//                                     err = true;
//                                   }
//                                 });
//                                 return err ? "enter valid phone number(s) " : null;
//                               }),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: DropdownButtonFormField<String>(
//                             value: user.loft,
//                             decoration: FormInputDecoration.getDeco(labelText: "Loft"),
//                             isExpanded: true,
//                             items: lots.keys.map((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             }).toList(),
//                             onChanged: (_) {
//                               if (_key.currentState != null) {
//                                 _key.currentState!.reset();
//                               }
//
//                               user.department = null;
//
//                               user.loft = _;
//                               setState(() {});
//                             },
//                             validator: (value) {
//                               return value == null ? "select loft" : null;
//                             },
//                           ),
//                         ),
//                         if (user.loft != null)
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: DropdownButtonFormField(
//                               key: _key,
//                               value: (user.department),
//                               decoration: FormInputDecoration.getDeco(labelText: "Main Department"),
//                               isExpanded: true,
//                               items: (lots[user.loft] ?? []).map((String value) {
//                                 print('**************************A' + value);
//                                 return DropdownMenuItem<String>(
//                                   key: Key("${user.loft}_$value"),
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                               onChanged: (_) {
//                                 print('ccccccccccccccccc ');
//                                 user.department = _ as String?;
//                               },
//                               validator: (value) {
//                                 return value == null ? "select department" : null;
//                               },
//                             ),
//                           ),
//                         if (AppUser.getUser()?.id == user.id)
//                           user.emailVerified == 1
//                               ? Text(user.email)
//                               : SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                       onPressed: () async {
//                                         await Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) => AddUserEmail(() {
//                                                       AppUser.refreshUserData();
//                                                     })));
//                                       },
//                                       child: const Text("Add Email")))
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             if (_formKey.currentState!.validate()) {
//               print(user.toJson());
//               saveUser();
//             }
//           },
//           child: isSaving ? const CircularProgressIndicator() : const Icon(Icons.save_rounded)),
//     );
//   }
//
//   ImageProvider<Object>? img;
//
//   Uint8List? imageByte;
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
//   Future saveUser() async {
//     isSaving = true;
//     setState(() {});
//     var id = "";
//     if (imageByte != null) {
//       id = await uploadImage();
//     }
//     print('ssssssssssssssssssssss');
//
//     return Server.apiPost("users/saveUser", {"user": user, "image": id}).then((res) async {
//       Map data = res.data;
//       if (data["done"] == true) {
//         if (id != "") {
//           user.image = "$id.jpg";
//         }
//
//         await HiveBox.getDataFromServer();
//
//         if (widget.afterSave != null) {
//           widget.afterSave!(user);
//         }
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
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           backgroundColor: Colors.red,
//           content: Text(error, style: const TextStyle(color: Colors.white)),
//         ));
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
//     FormData formData = FormData.fromMap({
//       "file": MultipartFile.fromBytes(imageByte!, filename: fileName),
//     });
//
//     var response = await Server.apiPost(("users/saveImage"), {}, formData: formData);
//     print(response.data);
//     return response.data['id'];
//   }
//
//   Future<Uint8List?> compressImage(Uint8List imgBytes, {required String path, int quality = 70}) async {
//     final input = ImageFile(
//       rawBytes: imgBytes,
//       filePath: path,
//     );
//     Configuration config = Configuration(
//         outputType: ImageOutputType.jpg,
//         // can only be true for Android and iOS while using ImageOutputType.jpg or ImageOutputType.pngÏ
//         useJpgPngNativeCompressor: false,
//         // set quality between 0-100
//         quality: quality);
//     final param = ImageFileConfiguration(input: input, config: config);
//     final output = await compressor.compress(param);
//     print("Input size : ${input.sizeInBytes}");
//     print("Output size : ${output.sizeInBytes}");
//     return output.rawBytes;
//   }
// }
