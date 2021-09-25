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
  Function(NsUser)? onUserLoad;

  UserImage({this.nsUser, this.nsUserId, this.backgroundColor, this.radius, this.onUserLoad});

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  NsUser? nsUser;
  var img;
  bool _loaded = false;
  var placeholder = AssetImage('assets/images/user.png');

  @override
  void initState() {
    super.initState();
    nsUser = widget.nsUser;

    if (nsUser == null && widget.nsUserId != null) {
      NsUser.fromId(widget.nsUserId).then((value) {
        nsUser = value;
        loadImage();
        if (widget.onUserLoad != null) {
          widget.onUserLoad!(nsUser!);
        }
      });
    } else {
      loadImage();
      if (widget.onUserLoad != null) {
        widget.onUserLoad!(nsUser!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // return CircleAvatar(radius: widget.radius, backgroundImage: getUserImage(nsUser), backgroundColor: widget.backgroundColor ?? Colors.transparent);
    return CircleAvatar(radius: widget.radius, backgroundImage: _loaded ? img : placeholder, backgroundColor: widget.backgroundColor ?? Colors.transparent);
  }

  void loadImage() {
    img = NetworkImage(Server.getServerApiPath("users/getImage?img=" + nsUser!.img + "&size=500"), headers: {"authorization": '${AppUser.getIdToken()}'});
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((info, call) {
          if (mounted) {
            setState(() {
              _loaded = true;
            });
          }
        }, onError: (exception, stack) {
          _loaded = false;
        }));
  }
}
