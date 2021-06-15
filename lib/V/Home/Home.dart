import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/CurrentUser/CurrentUserDetails.dart';
import 'package:smartwind/V/Home/UserManager/UserManager.dart';
import 'package:smartwind/V/Login/Login.dart';

import 'Tickets/FinishedGoods/FinishedGoods.dart';
import 'Tickets/ProductionPool/ProductionPool.dart';
import 'Tickets/StandardFiles/StandardFiles.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class _HomeState extends State<Home> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NsUser? nsUser = new NsUser();

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic('file_update');
    DB.updateDatabase();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (json.decode(message.data["FILE_DB_UPDATE"]) != null) {
        DB.updateDatabase();
      }
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      var u = prefs.getString("user");
      print(u);
      if (u != null) {
        setState(() {
          nsUser = NsUser.fromJson(json.decode(u));
        });
      } else {
        _logout();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  var _selection;

  void _showMarkedAsDoneSnackbar(bool? isMarkedAsDone) {
    if (isMarkedAsDone ?? false)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Marked as done!'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 150,
          title: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: ListTile(
              leading: CircleAvatar(radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
              title: Text(nsUser!.name, textScaleFactor: 1.2),
              subtitle: Text("@ ${nsUser!.sectionName}"),
              trailing: _currentUserOprionMenu(),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentUserDetails(nsUser!)));
              },
            ),
          ),
        ),
        body: Center(
          child: Wrap(
            direction: Axis.vertical,
            children: [
              _OpenContainerWrapper(
                transitionType: ContainerTransitionType.fade,
                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                  return _ExampleCard(openContainer: openContainer);
                },
                onClosed: _showMarkedAsDoneSnackbar,
              ),

              // OpenContainer<String>(
              //   openBuilder: (_, closeContainer) => SearchPage(closeContainer),
              //   onClosed: (res) => setState(() {
              //     searchString = res;
              //   }),
              //   tappable: false,
              //   closedBuilder: (_, openContainer) => SearchBar(
              //     searchString: searchString,
              //     openContainer: openContainer,
              //   ),
              // ),
              // Container(
              //     height: 200,
              //     width: 200,
              //     child: Card(
              //         child: InkWell(
              //             onTap: () {
              //               show(ProductionPool());
              //             },
              //             splashColor: Colors.green,
              //             child: Center(
              //                 child: Wrap(direction: Axis.horizontal, crossAxisAlignment: WrapCrossAlignment.center, children: [
              //               Container(
              //                   height: 170,
              //                   child: Center(
              //                       child: CircleAvatar(radius: 70.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent))),
              //               Center(child: Text("Production Pool")),
              //             ]))))),
              // ElevatedButton(onPressed: () => show(FinishedGoods()), child: Text("Finished Goods")),
              // ElevatedButton(onPressed: () => show(StandardFiles()), child: Text("Standard Library")),
              // ElevatedButton(onPressed: () => show(UserManager()), child: Text("User Manager")),
              // ElevatedButton(onPressed: () => show(ProductionPool()), child: Text("CPR")),
              // ElevatedButton(
              //   onPressed: () async {
              //     _logout();
              //   },
              //   child: Text("Logout"),
              // )
            ],
          ),
        ),
      ),
    );
  }

  void show(Widget window) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => window));
  }

  Future<void> _logout() async {
    FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
  }

  _currentUserOprionMenu() {
    return PopupMenuButton<WhyFarther>(
      onSelected: (WhyFarther result) {
        setState(() {
          _selection = result;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
        const PopupMenuItem<WhyFarther>(
          value: WhyFarther.harder,
          child: Text('Working a lot harder'),
        ),
        const PopupMenuItem<WhyFarther>(
          value: WhyFarther.smarter,
          child: Text('Being a lot smarter'),
        ),
        const PopupMenuItem<WhyFarther>(
          value: WhyFarther.selfStarter,
          child: Text('Being a self-starter'),
        ),
        const PopupMenuItem<WhyFarther>(
          value: WhyFarther.tradingCharter,
          child: Text('Placed in charge of trading charter'),
        ),
      ],
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    required this.closedBuilder,
    required this.transitionType,
    required this.onClosed,
  });

  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool?> onClosed;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return const _DetailsPage();
      },
      onClosed: onClosed,
      tappable: false,
      closedBuilder: closedBuilder,
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.openContainer});

  final VoidCallback openContainer;

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black38,
              child: Center(
                child: Image.asset(
                  'assets/placeholder_image.png',
                  width: 100,
                ),
              ),
            ),
          ),
          const ListTile(
            title: Text('Title'),
            subtitle: Text('Secondary text'),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur '
              'adipiscing elit, sed do eiusmod tempor.',
              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _InkWellOverlay extends StatelessWidget {
  const _InkWellOverlay({
    this.openContainer,
    this.width,
    this.height,
    this.child,
  });

  final VoidCallback? openContainer;
  final double? width;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        onTap: openContainer,
        child: child,
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  const _DetailsPage({this.includeMarkAsDoneButton = true});

  final bool includeMarkAsDoneButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details page'),
        actions: <Widget>[
          if (includeMarkAsDoneButton)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () => Navigator.pop(context, true),
              tooltip: 'Mark as done',
            )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black38,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(70.0),
              child: Image.asset(
                'assets/placeholder_image.png',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Title',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.black54,
                        fontSize: 30.0,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Colors.black54,
                        height: 1.5,
                        fontSize: 16.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
