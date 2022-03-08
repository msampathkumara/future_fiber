import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/C/Validations.dart';
import 'package:smartwind/C/form_input_decoration.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import '../../C/OnlineDB.dart';
import 'new_password.dart';

class PasswordRecovery extends StatefulWidget {
  const PasswordRecovery({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryState createState() => _PasswordRecoveryState();
}

class _PasswordRecoveryState extends State<PasswordRecovery> {
  NsUser? user;

  String userNic = "";
  bool userNicEntered = false;
  final _forgotPassFormKey = GlobalKey<FormState>();

  bool _enterOTP = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Builder(builder: (context) {
          if (_enterPassword && user != null) {
            return NewPassword(user?.id, onEnd: () {
              Navigator.pop(context, true);
            });
          }

          if (_enterOTP) {
            return otpUi();
          } else if (user != null) {
            return hiui();
          } else {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 300,
                    child: Form(
                      key: _forgotPassFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                              onChanged: (text) {
                                userNic = text;
                                if ("$text".length < 10) {
                                  text = "${text}v";
                                }
                                userNic = text;
                                setState(() {});
                              },
                              decoration: FormInputDecoration.getDeco(labelText: "NIC", suffixText: userNic.contains("v") ? "V  " : ""),
                              validator: (value) {
                                if ("$value".length < 10) {
                                  value = "${value}v";
                                }

                                userNic = value ?? "";
                                return Validations.nic("$value");
                              },
                              autofocus: false,
                              style: const TextStyle(fontSize: 15.0, color: Colors.black),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: FormInputDecoration.buttonStyle(),
                                  onPressed: () {
                                    if (_forgotPassFormKey.currentState!.validate()) {
                                      checkNic();
                                    }
                                  },
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }),
        if (_loading) Container(color: Colors.white, child: const Center(child: CircularProgressIndicator())),
      ],
    ));
  }

  bool nicChecked = false;

  void checkNic() {
    setLoading(true);
    OnlineDB.apiGet("user/getUserByNic", {"nic": userNic}).then((value) {
      nicChecked = true;
      Map map = value.data;
      print(value.data);

      if (map["user"] == null) {
      } else {
        user = NsUser.fromJson(map["user"]);
      }
      setLoading(false);
    }).onError((error, stackTrace) {
      setLoading(false);
    });
  }

  bool _loading = false;

  void setLoading(bool bool) {
    setState(() {
      _loading = bool;
    });
  }

  String _otp = "";

  Widget otpUi() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: Form(
                key: _forgotPassFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                        onChanged: (text) {
                          _otp = text;
                        },
                        decoration: FormInputDecoration.getDeco(labelText: "OTP"),
                        validator: (value) {
                          return _otp.length == 6 ? null : "Invalid OTP";
                        },
                        autofocus: false,
                        style: const TextStyle(fontSize: 15.0, color: Colors.black),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: FormInputDecoration.buttonStyle(),
                            onPressed: () {
                              if (_forgotPassFormKey.currentState!.validate()) {
                                validateOTP();
                              }
                            },
                            child: const Text(
                              'Continue',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget hiui() {
    return Container(
      color: Colors.white,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 160,
              child: UserImage(nsUser: user, radius: 160),
            ),
          ),
          const Text("HI", textScaleFactor: 1.5),
          Text(user!.name, textScaleFactor: 1.5),
          const SizedBox(height: 8),
          if (user?.emailVerified == 1)
            Flexible(
                child: Text(
              "click continue to send otp to your email address \n ${user?.email}",
              textScaleFactor: 1,
              textAlign: TextAlign.center,
            )),
          if (user?.emailVerified == 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: FormInputDecoration.buttonStyle(),
                onPressed: () {
                  sendOtp();
                },
                child: const Text("Send OTP"),
              ),
            ),
          const Divider(),
          const Flexible(child: Text("Send OTP Request to Librarian", textScaleFactor: 1)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: FormInputDecoration.buttonStyle(),
              onPressed: () {
                requestOTP();
              },
              child: const Text("Send Request"),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: FormInputDecoration.buttonStyle(),
              onPressed: () {
                _enterOTP = true;
                setLoading(false);
              },
              child: const Text("Enter OTP"),
            ),
          ),
        ],
      )),
    );
  }

  bool _enterPassword = false;

  validateOTP() {
    if (_otp.length != 6) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Enter Valid OTP"), backgroundColor: Colors.red));
    }

    setLoading(true);
    print(_otp);
    OnlineDB.apiPost("user/recoverPassword/validateOtp", {"userId": user?.id, "otp": _otp}).then((value) {
      Map data = value.data;
      if (data.containsKey("done")) {
        _enterPassword = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Enter Valid OTP"), backgroundColor: Colors.red));
      }

      setLoading(false);
    }).onError((error, stackTrace) {
      setLoading(false);
    });
  }

  void requestOTP() {
    setLoading(true);
    OnlineDB.apiGet("user/recoverPassword/sendOTPToLibrarian", {"userId": user?.id}).then((value) async {
      // await MessageBox.show(context, "", "OTP sent to Admin. please contact Librarian.");

      setLoading(false);
    }).onError((error, stackTrace) {
      setLoading(false);
    });
  }

  void sendOtp() {
    setLoading(true);
    OnlineDB.apiGet("user/recoverPassword/sendOTP", {"userId": user?.id}).then((value) {
      _enterOTP = true;
      setLoading(false);
    }).onError((error, stackTrace) {
      setLoading(false);
    });
  }
}
