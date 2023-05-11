// import 'package:flutter/material.dart';
// import 'package:smartwind_future_fibers/M/EndPoints.dart';
// import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
//
// import '../../../../../C/Api.dart';
// import '../../../../../C/form_input_decoration.dart';
// import '../../../../../M/UserRFCredentials.dart';
//
// class AddRFCredentials extends StatefulWidget {
//   const AddRFCredentials({Key? key}) : super(key: key);
//
//   @override
//   State<AddRFCredentials> createState() => _AddRFCredentialsState();
//
//   Future show(context) {
//     return showDialog(context: context, builder: (_) => this);
//   }
// }
//
// class _AddRFCredentialsState extends State<AddRFCredentials> {
//   final key = GlobalKey<FormState>();
//   UserRFCredentials userRFCredentials = UserRFCredentials();
//
//   @override
//   Widget build(BuildContext context) {
//     return DialogView(
//       child: getUi(),
//       height: 400,
//       width: 400,
//     );
//   }
//
//   getUi() {
//     return Container(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Center(
//           child: saving
//               ? const CircularProgressIndicator()
//               : SizedBox(
//                   width: 300,
//                   child: Form(
//                     key: key,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text("RF Credentials", textScaleFactor: 1.2),
//                         const SizedBox(height: 24),
//                         TextFormField(
//                           onChanged: (text) {
//                             userRFCredentials.uname = text;
//                           },
//                           decoration: FormInputDecoration.getDeco(labelText: "User Name"),
//                           validator: (value) {
//                             return "$value".isNotEmpty ? null : "Invalid User Name";
//                           },
//                           autofocus: false,
//                           style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           onChanged: (text) {
//                             userRFCredentials.pword = text;
//                           },
//                           decoration: FormInputDecoration.getDeco(labelText: "Password"),
//                           validator: (value) {
//                             return "$value".isNotEmpty ? null : "Invalid Password";
//                           },
//                           autofocus: false,
//                           style: const TextStyle(fontSize: 15.0, color: Colors.black),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: ElevatedButton(
//                                 onPressed: () {
//                                   if (key.currentState!.validate()) {
//                                     saveRfCred();
//                                   }
//                                 },
//                                 child: const Text("Save")))
//                       ],
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
//
//   bool saving = false;
//
//   void saveRfCred() {
//     setState(() {
//       saving = true;
//     });
//     Api.post(EndPoints.users_saveRfCredentials, userRFCredentials.toJson()).then((res) {
//       Navigator.of(context).pop(userRFCredentials);
//     }).whenComplete(() {
//       setState(() {
//         saving = false;
//       });
//     }).catchError((err) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(err.toString()),
//           action: SnackBarAction(
//               label: 'Retry',
//               onPressed: () {
//                 saveRfCred();
//               })));
//       setState(() {
//         // _dataLoadingError = true;
//       });
//     });
//   }
// }
