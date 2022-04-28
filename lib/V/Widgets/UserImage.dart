import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../M/AppUser.dart';
import '../../M/NsUser.dart';

class UserImage extends StatefulWidget {
  final NsUser? nsUser;

  final Color? backgroundColor;
  final double radius;

  final bool disable;

  final double padding;

  UserImage({this.padding = 0, required this.nsUser, this.backgroundColor, required this.radius, this.disable = false, Key? key})
      : super(key: key ?? Key("ui${nsUser?.id}${nsUser?.upon}$radius${nsUser?.deactivate}${nsUser?.img}"));

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  late NsUser nsUser;
  var placeholder = const AssetImage('assets/images/user.png');

  @override
  void initState() {
    super.initState();

    nsUser = widget.nsUser!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disable || nsUser.isDisabled) {
      return Padding(
        padding: EdgeInsets.all(widget.padding),
        child: Stack(
          children: [
            ClipOval(
              child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.saturation,
                  ),
                  child: getImage()),
            ),
            Icon(Icons.no_accounts_rounded, color: Colors.red, size: widget.radius * 0.6)
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: getImage(),
    );
  }

  Widget getImage() {
    return CircleAvatar(
        backgroundColor: Colors.white,
        radius: widget.radius,
        child: ClipOval(
            child: CachedNetworkImage(
                imageUrl: nsUser.getImage(size: widget.radius * 3),
                httpHeaders: {"authorization": '${AppUser.getIdToken()}'},
                width: widget.radius * 2,
                height: widget.radius * 2,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Image.asset('images/userPlaceholder.jpg', fit: BoxFit.cover, width: widget.radius * 2, height: widget.radius * 2);
                },
                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress))));
  }
}
