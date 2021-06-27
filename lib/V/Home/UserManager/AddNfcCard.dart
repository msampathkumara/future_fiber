import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartwind/M/NsUser.dart';

class AddNfcCard extends StatefulWidget {
  NsUser nsUser;

  AddNfcCard(this.nsUser, {Key? key}) : super(key: key);

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
  @override
  void initState() {
    super.initState();

    NfcManager.instance.isAvailable().then((value) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tag.data.toString()),
          ));
        },
      );
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
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
        child: Container(
      height: (height / 3) * 2,
      width: (width / 4) * 3,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Scaffold(
          body: Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 32.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.nsUser.name,
                      textScaleFactor: 1.2,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                  Icon(
                    Icons.nfc_outlined,
                    size: 150,
                    color: Colors.blue,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Scan NFC Card",
                      textScaleFactor: 1.5,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
