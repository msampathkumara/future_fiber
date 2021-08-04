import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';

class UserImage extends StatefulWidget {
  NsUser? nsUser;
  int? nsUserId;
  Color? backgroundColor;
  double? radius;

  UserImage({this.nsUser, this.nsUserId, this.backgroundColor, this.radius});

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  NsUser? nsUser;

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;

    if (nsUser == null && widget.nsUserId != null) {
      NsUser.fromId(widget.nsUserId).then((value) {
        nsUser = value;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: widget.radius, backgroundImage: getUserImage(nsUser), backgroundColor: widget.backgroundColor ?? Colors.transparent);
  }

  static getUserImage(NsUser? nsUser) {
    return nsUser == null
        ? AssetImage('assets/images/user.png')
        : NetworkImage(Server.getServerApiPath("users/getImage?img=" + nsUser.img + "&size=500"), headers: {"authorization": '${AppUser.getIdToken()}'});
  }
}
