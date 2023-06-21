import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/User/Email.dart';
import 'package:deebugee_plugin/DialogView.dart';

import '../../../../C/Api.dart';
import '../../../../C/Validations.dart';
import '../../../../C/form_input_decoration.dart';

class VerifyEmail extends StatefulWidget {
  final Email email;

  const VerifyEmail(this.email, {Key? key}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _VerifyEmailState extends State<VerifyEmail> {
  String errorMsg = '';

  @override
  void initState() {
    // TODO: implement initState
    email = widget.email.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  getWebUi() {
    return getUi();
  }

  var errorMessage = "";
  var loading = false;

  void setLoading(bool show) {
    setState(() {
      loading = show;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  String email = "";
  bool enterVerificationCode = false;
  bool emailVerified = false;
  String emailVerifyCode = "";
  bool visiblePassword = false;

  void passwordRecovery() {
    forgotPassword = true;
    setState(() {});
  }

  bool forgotPassword = false;
  bool haveProfile = false;

  String userNic = "";

  int retryCount = 0;

  getUi() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
                width: 500,
                child: Builder(builder: (context) {
                  if (emailVerified) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      const Text("Email Verified Successfully", textScaleFactor: 1.2),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: FormInputDecoration.buttonStyle(),
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });

                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Continue', style: TextStyle(color: Colors.white)))))
                    ]);
                  }

                  if (enterVerificationCode) {
                    return Form(
                      key: _formKey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 20.0),
                            text: "Email with email verify code is sent to ",
                            children: <TextSpan>[
                              TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
                              const TextSpan(text: '\n check inbox and enter verify code'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                                onChanged: (text) {
                                  emailVerifyCode = text;

                                  setState(() {
                                    errorMsg = "";
                                  });
                                },
                                autofocus: false,
                                style: const TextStyle(fontSize: 15.0, color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Verify Code',
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
                                  return null;
                                },
                                key: const Key("code")),
                          ),
                        ),
                        if (errorMsg.isNotEmpty) Text(errorMsg, style: const TextStyle(color: Colors.red)),
                        SizedBox(
                          width: 300,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: FormInputDecoration.buttonStyle(),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          verifyCode(emailVerifyCode);
                                        }
                                      },
                                      child: Text(
                                        retryCount > 0 ? 'Try Again (${5 - retryCount})' : 'Continue',
                                        style: const TextStyle(color: Colors.white),
                                      )))),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  enterVerificationCode = false;
                                  errorMsg = "";
                                });
                              },
                              child: const Text('Not received try again', style: TextStyle(color: Colors.grey))),
                        ),
                      ]),
                    );
                  }

                  return Form(
                      key: _emailFormKey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                              onChanged: (text) {
                                email = text;
                              },
                              initialValue: email,
                              autofocus: false,
                              style: const TextStyle(fontSize: 15.0, color: Colors.black),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                  filled: true,
                                  fillColor: Colors.grey[150],
                                  contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10.0)),
                                  enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(10.0))),
                              validator: (value) {
                                return Validations.emailValidate(value);
                              },
                              key: const Key("email")),
                        ),
                        if (errorMsg.isNotEmpty) Text(errorMsg, style: const TextStyle(color: Colors.red)),
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: FormInputDecoration.buttonStyle(),
                                    onPressed: () {
                                      if (_emailFormKey.currentState!.validate()) {
                                        verifyEmail(email);
                                      }
                                    },
                                    child: const Text('Continue', style: TextStyle(color: Colors.white))))),
                        SizedBox(height: 30, width: double.infinity, child: TextButton(onPressed: () {}, child: const Text('Skip')))
                      ]));
                })),
          ],
        ),
      ),
    );
  }

  void verifyCode(code) {
    setLoading(true);
    Api.post("user/verifyEmail", {"verifyCode": code}).then((response) {
      setLoading(false);
      Map data = response.data;

      print("--------------------------------------------------------------------------------");
      print(data);
      print("--------------------------------------------------------------------------------");

      if (data["error"] == true) {
        if (data["notFound"] == true) {
          errorMsg = "Wrong verify code";
        } else if (data["retryCount"] != null && data["retryCount"] > 4) {
          errorMsg = "retry count exceeded, try again in ${data["tryIn"]} min";
        }

        retryCount = (data["retryCount"] ?? 0);
        retryCount = retryCount < 0 ? 0 : retryCount;
      } else {
        emailVerified = true;
      }
      setState(() {});
    });
  }

  void verifyEmail(email) {
    setLoading(true);
    Api.post("user/sendVerifyEmail", {"email": email}).then((response) {
      setLoading(false);
      Map data = response.data;

      if (data["error"] == true) {
        if (data["used"] == true) {
          errorMsg = "email is already used by another user";
        } else if (data["invalid"] == true) {
          errorMsg = "email is already used by another user";
        }
      } else {
        enterVerificationCode = true;
      }
      setState(() {});
    });
  }
}
