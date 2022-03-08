import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';

import '../../M/hive.dart';

class UserImage extends StatefulWidget {
  NsUser? nsUser;
  int? nsUserId;
  Color? backgroundColor;
  double radius;

  bool disable;

  UserImage({this.nsUser, this.nsUserId, this.backgroundColor, required this.radius, this.disable = false, key})
      : super(key: key ?? Key('${nsUser?.id}${nsUserId}${nsUser?.uptime}'));

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
      nsUser = HiveBox.usersBox.get(widget.nsUserId);
    } else {
      // loadImage();

    }
    print("${nsUser?.name}   ${nsUser?.isDisabled}");

  }

  @override
  Widget build(BuildContext context) {
    if (widget.disable || nsUser!.isDisabled) {
      return ColorFiltered(
          key: Key("${nsUser?.uptime}"),
          colorFilter: ColorFilter.mode(
            Colors.white,
            BlendMode.saturation,
          ),
          child: getImage());
      // child: CircleAvatar(radius: widget.radius, backgroundImage: _loaded ? img : placeholder, backgroundColor: widget.backgroundColor ?? Colors.transparent));
    }

    return getImage();
  }

  Widget getImage() {
    return CircleAvatar(
        backgroundColor: Colors.white,
        radius: widget.radius,
        child: ClipOval(
            child: CachedNetworkImage(
                imageUrl: Server.getServerApiPath("users/getImage?img=" + nsUser!.img + "&size=${(widget.radius * 3)}"),
                httpHeaders: {"authorization": '${AppUser.getIdToken()}'},
                width: widget.radius * 2,
                height: widget.radius * 2,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Image.asset('assets/images/user.png', fit: BoxFit.cover, width: widget.radius * 2, height: widget.radius * 2);
                },
                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress))));
  }
}
