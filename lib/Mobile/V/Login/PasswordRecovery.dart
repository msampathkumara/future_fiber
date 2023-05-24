import 'package:deebugee_plugin/DialogView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind_future_fibers/C/Server.dart';
import 'package:smartwind_future_fibers/C/Validations.dart';
import 'package:smartwind_future_fibers/C/form_input_decoration.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';
import 'package:deebugee_plugin/DialogView.dart';
import '../../../M/User/Email.dart';
import '../../../Web/Widgets/DialogView.dart';
import '../../../Web/Widgets/IfWeb.dart';
import '../Widgets/UserImage.dart';
import '../Widgets/message_box.dart';
import 'Login.dart';
import 'new_password.dart';

class PasswordRecovery extends StatefulWidget {
  const PasswordRecovery({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryState createState() => _PasswordRecoveryState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _PasswordRecoveryState extends State<PasswordRecovery> {
  NsUser? user;

  String userNic = "";
  bool userNicEntered = false;
  final _forgotPassFormKey = GlobalKey<FormState>();

  bool _enterOTP = false;

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getUi()));
  }

  getUi() {
    return Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            Builder(builder: (context) {
              if (_enterPassword && user != null) {
                return NewPassword(user!.id, onEnd: () {
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
                                  initialValue: userNic,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                  onChanged: (text) {
                                    userNic = text;
                                    if (text.length < 10) {
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
                                      child: const Text('Continue', style: TextStyle(color: Colors.white)),
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
    print('-------------------------------------------------$userNic');
    setLoading(true);
    Server.serverGet(EndPoints.user_recoverPassword_getUserByNic, {"nic": userNic}).then((value) {
      print('xxxxxxxxxxxxxxxx');
      nicChecked = true;
      Map map = value.data;

      if (map["deactivate"] != null) {
        return showAccountDeactivatedAlertDialog(context);
      } else if (map["locked"] != null) {
        return showAccountLockedAlertDialog(context);
      }

      print(value.data);

      if (map["user"] == null) {} else {
        user = NsUser.fromJson(map["user"]);
        print(user?.emails.first.toJson());
      }
      setLoading(false);
    }).whenComplete(() {
      print('xxxxxxxxxxxxxxxx33');
      setLoading(false);
    }).onError((error, stackTrace) {
      print('xxxxxxxxxxxxxxxx333333');
      print(error);
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
                            child: const Text('Continue', style: TextStyle(color: Colors.white)),
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

  Email? selectedEmail;

  Widget hiui() {
    List<Email> verifiedEmails = user?.emails.where((element) => element.isVerified).toList() ?? [];

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(width: 160, height: 160, child: UserImage(nsUser: user, radius: 160)),
                    ),
                    const Text("HI", textScaleFactor: 1.5),
                    Text(user!.name, textScaleFactor: 1.5),
                    const Divider(),
                    if (verifiedEmails.isEmpty) const Text('You don\'t have any verified email addresses'),
                    const SizedBox(height: 16),
                    if (verifiedEmails.isNotEmpty && verifiedEmails.length == 1)
                      Builder(
                        builder: (BuildContext context) {
                          selectedEmail = verifiedEmails[0];
                          return Wrap(direction: Axis.vertical, alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
                            Padding(padding: const EdgeInsets.all(8.0), child: FilterChip(label: Text('${selectedEmail?.email}'), onSelected: (v) {}, selected: true)),
                            const SizedBox(height: 16),
                            SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                    onPressed: selectedEmail == null
                                        ? null
                                        : () {
                                      sendOtp();
                                    },
                                    child: const Text('Send OTP')))
                          ]);
                        },
                      ),
                    if (verifiedEmails.isNotEmpty && verifiedEmails.length > 1)
                      Wrap(direction: Axis.vertical, alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        const Text('Select email address to send otp', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ...verifiedEmails
                            .map((e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilterChip(
                              label: Text('${e.email}'),
                              onSelected: (v) {
                                setState(() {
                                  selectedEmail = v ? e : null;
                                });
                              },
                              selected: selectedEmail == e),
                        ))
                            .toList(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                              onPressed: selectedEmail == null
                                  ? null
                                  : () {
                                sendOtp();
                              },
                              child: const Text('Send OTP')),
                        )
                      ]),
                    const SizedBox(height: 8),
                    const Divider(),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                            width: 250,
                            child: TextButton(
                                style: FormInputDecoration.buttonStyle(),
                                onPressed: () {
                                  requestOTP();
                                },
                                child: const Text("Send OTP Request to System Admin")))),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                            style: FormInputDecoration.buttonStyle(),
                            onPressed: () {
                              _enterOTP = true;
                              setLoading(false);
                            },
                            child: const Text("Enter OTP")),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  bool _enterPassword = false;

  validateOTP() {
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

    if (_otp.length != 6) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Enter Valid OTP"), backgroundColor: Colors.red));
    }

    setLoading(true);
    print(_otp);
    Server.serverPost(EndPoints.user_recoverPassword_validateOtp, {"userId": user?.id, "otp": _otp}).then((value) {
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
    Server.serverPost(EndPoints.user_recoverPassword_sendOTPToAdmin, {"userId": user?.id}, onlineServer: true).then((value) async {
      print(value);
      await MessageBox.show(context, "", "OTP sent to Admin. please contact Admin.");

      setLoading(false);
    }).onError((error, stackTrace) {
      print(error);
      setLoading(false);
    });
  }

  void sendOtp() {
    setLoading(true);
    Server.serverPost(EndPoints.user_recoverPassword_sendOTP, {"userId": user?.id, 'emailId': selectedEmail?.id}, onlineServer: true).then((value) {
      _enterOTP = true;
      setLoading(false);
    }).onError((error, stackTrace) {
      print(error);
      setLoading(false);
    });
  }
}
