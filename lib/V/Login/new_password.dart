import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/C/form_input_decoration.dart';
import 'package:smartwind/M/NsUser.dart';

class NewPassword extends StatefulWidget {
  Null Function() onEnd;
  var userId;

  NewPassword(this.userId, {Key? key, required this.onEnd}) : super(key: key);

  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final NsUser _user = NsUser();
  final _formKey = GlobalKey<FormState>();
  bool visiblePassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: saving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Center(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                            initialValue: 'sam123456',
                            onChanged: (text) {
                              _user.password = text;
                            },
                            onFieldSubmitted: (text) {
                              _user.password = text;
                              if (_formKey.currentState!.validate()) {}
                            },
                            obscureText: !visiblePassword,
                            autofocus: false,
                            style: const TextStyle(fontSize: 15.0, color: Colors.black),
                            decoration: InputDecoration(
                              suffixIconConstraints: const BoxConstraints(minWidth: 5, minHeight: 5),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        visiblePassword = !visiblePassword;
                                      });
                                    },
                                    child: Icon(visiblePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 16, color: Colors.grey)),
                              ),
                              helperText: "Password must contain atlas one letter or one number and length must more than 6 letters",
                              border: InputBorder.none,
                              hintText: 'password',
                              filled: true,
                              fillColor: Colors.grey[150],
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length > 6 && RegExp(r'[a-zA-Z]').hasMatch(value) && RegExp(r'[0-9]').hasMatch(value)) {
                                return null;
                              } else {
                                return "invalid password format";
                              }
                              return null;
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                            initialValue: 'sam123456',
                            onChanged: (text) {
                              passwordReenter = text;
                              setState(() {});
                            },
                            onFieldSubmitted: (text) {
                              passwordReenter = text;
                              if (_formKey.currentState!.validate()) {}
                            },
                            obscureText: !visiblePassword,
                            autofocus: false,
                            style: const TextStyle(fontSize: 15.0, color: Colors.black),
                            decoration: InputDecoration(
                              suffixIconConstraints: const BoxConstraints(minWidth: 5, minHeight: 5),
                              suffixIcon: passwordReenter == _user.password
                                  ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.done_rounded, size: 16, color: Colors.green),
                              )
                                  : null,
                              border: InputBorder.none,
                              hintText: 'password',
                              filled: true,
                              fillColor: Colors.grey[150],
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return passwordReenter == _user.password ? null : "Password mismatch";
                            }),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: FormInputDecoration.buttonStyle(),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      save();
                                    }
                                  },
                                  child: const Text('Continue', style: TextStyle(color: Colors.white)))))
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String passwordReenter = "";

  void save() {
    setState(() {
      saving = true;
    });
    Server.serverPost("user/recoverPassword/savePassword", {"userId": widget.userId, 'password': _user.password}).then((value) {
      Map data = value.data;

      if (data["error"] != null) {
        if (data["unameUsed"] == true) {
          unameOk = false;
        } else if (data["password"] == true) {
          _formKey.currentState!.validate();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["error"], style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
        setState(() {
          saving = true;
        });
      } else {
        widget.onEnd();

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Password saved successfully", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      }
    });
  }

  bool checkingUname = false;
  bool? unameOk = false;
  bool saving = false;
}
