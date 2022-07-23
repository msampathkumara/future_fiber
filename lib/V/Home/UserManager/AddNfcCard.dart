import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hex/hex.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

class AddNfcCard extends StatefulWidget {
  final NsUser nsUser;

  const AddNfcCard(this.nsUser, {Key? key}) : super(key: key);

  @override
  _AddNfcCardState createState() {
    return _AddNfcCardState();
  }

  static show(context, nsUser) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNfcCard(nsUser)),
    );
  }
}

class _AddNfcCardState extends State<AddNfcCard> {
  bool _dupicate = false;

  @override
  void initState() {
    super.initState();

    NfcManager.instance.isAvailable().then((value) {
      print("NFC = *****************************************ssss");
      loading = false;
      startNfcSession();
      setState(() {});
    }).onError((error, stackTrace) {
      print("*****************************************ssss");
      print(error);
    }).catchError((e) {
      print("*****************************************");
      print(e);
    });
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.stopSession();
  }

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
        child: Container(
          height: (height / 3) * 2,
      width: (width / 4) * 3,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserImage(
                  nsUser: widget.nsUser,
                  radius: 50,
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Text(widget.nsUser.name, textScaleFactor: 1.2),
                      Text("#${widget.nsUser.uname}", textScaleFactor: 1, style: const TextStyle(color: Colors.blue))
                    ])),
                const SizedBox(height: 64),
                if (!loading && !_dupicate) const Icon(Icons.nfc_outlined, size: 150, color: Colors.blue),
                if (!loading && !_dupicate) const Padding(padding: EdgeInsets.all(16.0), child: Text("Scan NFC Card", textScaleFactor: 1.5, textAlign: TextAlign.center)),
                if (loading) const CircularProgressIndicator(color: Colors.blue),
                if (!loading && _dupicate)
                  Column(children: [
                    Text(" This card is assign to another user. do you want to remove this card from that user and assign this card to #${widget.nsUser.uname}",
                        textScaleFactor: 1, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await save(true);
                              setState(() {});
                            },
                            child: const Text("Yes", textScaleFactor: 1.3)),
                        const SizedBox(width: 24),
                        ElevatedButton(
                            onPressed: () async {
                              nfcCode = null;
                              startNfcSession();
                              setState(() {});
                            },
                            child: const Text("No", textScaleFactor: 1.3))
                      ],
                    )
                  ])
              ],
            ),
          ),
        ),
      ),
    ));
  }

  void startNfcSession() {
    _dupicate = false;
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        loading = true;
        List<int> l = NfcA.from(tag)!.identifier;
        nfcCode = HEX.encode(l);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(nfcCode.toString()),
        // ));
        NfcManager.instance.stopSession();
        setState(() {});
        await save(false);
        setState(() {});
      },
    );
  }

  var nfcCode;

  Future<void> save(bool confirm) async {
    await OnlineDB.apiPost("users/setNfcCard", {"nfc": nfcCode, "userId": widget.nsUser.id, "confirm": confirm}).then((value) {
      print("value.statusCode == ${value.data.toString()}");
      loading = false;
      Map data = value.data;

      if (data["duplicate"] != null && data["duplicate"]) {
        _dupicate = true;
      } else {
        _dupicate = false;
      }
      if (data["done"] != null && data["done"]) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context, {});
        });
      }
    }).onError((DioError error, stackTrace) async {
      loading = false;
      print(stackTrace);
      await ErrorMessageView(errorMessage: error.message.toString()).show(context);
      startNfcSession();
    });
  }
}
