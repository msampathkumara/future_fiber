import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/res.dart';

import '../../../M/AppUser.dart';
import '../../../M/NsUser.dart';

class UserImage extends StatefulWidget {
  final NsUser? nsUser;

  final Color? backgroundColor;
  final double radius;

  final bool disable;

  final double padding;

  UserImage({this.padding = 0, required this.nsUser, this.backgroundColor, required this.radius, this.disable = false, Key? key})
      : super(key: key ?? Key("ui${nsUser?.id}${nsUser?.upon}$radius${nsUser?.deactivate}${nsUser?.img}${nsUser?.locked}"));

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  late NsUser nsUser;
  var placeholder = const AssetImage(Res.user);

  @override
  void initState() {
    super.initState();

    nsUser = widget.nsUser!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disable || nsUser.isDeactivated) {
      return SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: Padding(
          padding: EdgeInsets.all(widget.padding),
          child: Stack(
            children: [
              ClipOval(
                child: FutureBuilder(
                    future: getImage(),
                    builder: (context, AsyncSnapshot d) {
                      return d.hasData
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.saturation,
                              ),
                              child: d.data)
                          : const CircularProgressIndicator();
                    }),
              ),
              Icon(Icons.no_accounts_rounded, color: Colors.red, size: widget.radius * 0.6),
              if (nsUser.isLocked) Positioned(right: 0, top: 0, child: Icon(Icons.lock, color: Colors.red, size: widget.radius * 0.6))
            ],
          ),
        ),
      );
    }

    return SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: Padding(
            padding: EdgeInsets.all(widget.padding),
            child: FutureBuilder(future: getImage(), builder: (context, AsyncSnapshot d) => d.hasData ? d.data : const CircularProgressIndicator())));
  }

  Future<Widget> getImage() async {
    return CircleAvatar(
        backgroundColor: Colors.white,
        radius: widget.radius,
        child: Stack(
          children: [
            ClipOval(
                child: CachedNetworkImage(
                    imageUrl: await nsUser.getImage(size: widget.radius * 3),
                    httpHeaders: {"authorization": '${AppUser.getIdToken()}'},
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return Image.asset(Res.userPlaceholder, fit: BoxFit.cover, width: widget.radius * 2, height: widget.radius * 2);
                    },
                    progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress))),
            if (nsUser.isLocked) Positioned(right: 0, top: 0, child: Icon(Icons.lock, color: Colors.red, size: widget.radius * 0.6))
          ],
        ));
  }
}
