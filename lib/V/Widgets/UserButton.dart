import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/UserManager/UserDetails.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

class UserButton extends StatefulWidget {
  NsUser? nsUser;
  int? nsUserId;
  Color? backgroundColor;
  double? imageRadius;
  Function(NsUser)? onUserLoad;
  Axis? direction;
  bool hideName;

  UserButton({this.nsUser, this.nsUserId, this.imageRadius, this.onUserLoad, this.direction, this.hideName = false});

  @override
  _UserButtonState createState() => _UserButtonState();
}

class _UserButtonState extends State<UserButton> {
  @override
  void initState() {
    super.initState();
    _loadUser().then((value) {
      nsUser = value;
    }).whenComplete(() {
      _loading = false;
      setState(() {});
    });
  }

  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : nsUser == null
            ? Text("user not found")
            : GestureDetector(
                onTap: () {
                  UserDetails.show(context, nsUser);
                },
                child: Wrap(children: [
                  UserImage(nsUser: nsUser, radius: widget.imageRadius ?? 16),
                  if (!widget.hideName)
                    Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4),
                        child: Wrap(
                          direction: Axis.vertical,
                          children: [Text(nsUser!.name), Text("#${nsUser!.uname}", style: TextStyle(color: Colors.blue))],
                        ))
                ], direction: widget.direction ?? Axis.horizontal),
              );

  }

  var nsUser;

  Future<NsUser?> _loadUser() async {
    nsUser = widget.nsUser;
    if (nsUser == null && widget.nsUserId != null) {
      nsUser = await NsUser.fromId(widget.nsUserId);

      if (widget.onUserLoad != null) {
        widget.onUserLoad!(nsUser!);
      }
    } else {
      if (widget.onUserLoad != null) {
        widget.onUserLoad!(nsUser!);
      }
    }
    return Future.value(nsUser);
  }
}
