import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';

class GenerateOTP extends StatefulWidget {
  final NsUser nsUser;

  const GenerateOTP(this.nsUser, {Key? key}) : super(key: key);

  @override
  State<GenerateOTP> createState() => _GenerateOTPState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _GenerateOTPState extends State<GenerateOTP> {
  String? _otp;

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 500, height: 500, child: getWebUi()));
  }

  getWebUi() {
    return getUi();
  }

  bool loading = false;

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
              const SizedBox(height: 50),
              if (_otp == null)
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                      onPressed: () {
                        getOTP();
                      },
                      child: const Text("Get OTP")),
                ),
              if (_otp != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, bottom: 16, top: 16, right: 24),
                    child: Text("$_otp", style: const TextStyle(fontSize: 36, color: Colors.red)),
                  ),
                ),
              const SizedBox(height: 36),
              if (_otp != null && (!kIsWeb))
                SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          FlutterShare.share(title: "OTP", text: _otp, chooserTitle: 'Send OTP');
                        },
                        label: const Text("Share"),
                        icon: const Icon(Icons.share_rounded))),
              if (_otp != null && (kIsWeb))
                SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _otp)).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP copied to clipboard")));
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

  void getOTP() {
    Api.get("users/getOTP", {'userId': widget.nsUser.id}).then((res) {
      Map data = res.data;
      _otp = data['otp'];
      print(data);
      setState(() {});
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                getOTP();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
