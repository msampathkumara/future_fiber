import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../C/Api.dart';
import '../../../C/Validations.dart';
import '../../../C/form_input_decoration.dart';

class AddUserEmail extends StatefulWidget {
  final Function onEnd;

  const AddUserEmail(this.onEnd, {Key? key}) : super(key: key);

  @override
  _AddUserEmailState createState() => _AddUserEmailState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddUserEmailState extends State<AddUserEmail> {
  var loading = false;

  String errorMsg = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(children: [
        Center(child: _body()),
        if (loading)
          ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              )),
      ]),
    ));
  }

  var errorMessage = "";

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

  _body() {
    // Build a Form widget using the _formKey created above.
    return Column(
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

                                widget.onEnd();
                              },
                              child: const Text(
                                'Continue',
                                style: TextStyle(color: Colors.white),
                              ))))
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
                    SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: TextButton(
                            onPressed: () {
                              skipEmailVerify();
                            },
                            child: const Text('Skip')))
                  ]));
            })),
      ],
    );
  }

  bool visiblePassword = false;

  void passwordRecovery() {
    forgotPassword = true;
    setState(() {});
  }

  bool forgotPassword = false;
  bool haveProfile = false;

  String userNic = "";

  int retryCount = 0;

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

  void skipEmailVerify() {
    setLoading(true);
    Api.post("user/verifyEmailSkip", {}).then((response) {
      Map data = response.data;
      setLoading(false);
      widget.onEnd();
    });
  }
}
