import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../C/Api.dart';

class GeneratePassword extends StatefulWidget {
  final NsUser nsUser;

  const GeneratePassword(this.nsUser, {Key? key}) : super(key: key);

  @override
  State<GeneratePassword> createState() => _GeneratePasswordState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _GeneratePasswordState extends State<GeneratePassword> {
  final randomPasswordGenerator = RandomPasswordGenerator();

  String? _newPassword;

  var loading = false;

  @override
  initState() {
    // _newPassword = randomPasswordGenerator.randomPassword(letters: true, numbers: true, passwordLength: 7);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 500, height: 500, child: getUi()));
  }

  getUi() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.nsUser.name, style: const TextStyle(fontSize: 24)),
              Text(widget.nsUser.uname, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              if (_newPassword != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, bottom: 16, top: 16, right: 24),
                    child: Text(_newPassword!, style: const TextStyle(fontSize: 36, color: Colors.red)),
                  ),
                ),
              SizedBox(
                  width: 200,
                  child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: const Text("generate new password and save", style: TextStyle(color: Colors.white)),
                            action: SnackBarAction(
                                textColor: Colors.white,
                                label: 'continue',
                                onPressed: () {
                                  setState(() {
                                    _newPassword = randomPasswordGenerator.randomPassword(letters: true, numbers: true, specialChar: true, passwordLength: 7);
                                    savePassword();
                                  });
                                })));
                      },
                      child: const Text("Generate Password"))),
              const SizedBox(height: 36),
              if (_newPassword != null && (!kIsWeb))
                SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          FlutterShare.share(title: "OTP", text: _newPassword, chooserTitle: 'Send OTP');
                        },
                        label: const Text("Share"),
                        icon: const Icon(Icons.share_rounded))),
              if (_newPassword != null && (kIsWeb))
                SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _newPassword)).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("password copied to clipboard")));
                          });
                        },
                        label: const Text("Copy"),
                        icon: const Icon(Icons.copy_rounded))),
            ]),
          ),
          if (loading) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }

  void savePassword() {
    setState(() {
      loading = true;
    });
    Api.post(EndPoints.user_recoverPassword_savePassword, {'userId': widget.nsUser.id, 'password': _newPassword}).then((res) {
      setState(() {
        loading = false;
      });
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                savePassword();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
