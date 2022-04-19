import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/M/user_config.dart';

import '../V/Home/UserManager/UserPermissions.dart';
import 'AppUser.dart';
import 'HiveClass.dart';
import 'LocalFileVersion.dart';
import 'NsUser.dart';
import 'Section.dart';
import 'up_on.dart';

class HiveBox {
  static late final Box<NsUser> usersBox;
  static late final Box<Ticket> ticketBox;
  static late final Box<Section> sectionsBox;
  static late final Box<StandardTicket> standardTicketsBox;
  static late final Box<LocalFileVersion> localFileVersionsBox;

  // static late final Box<TicketFlag> ticketFlagBox;

  static late final Box userConfigBox;

  static late final Box<UserPermissions> userPermissions;

  /// Create an instance of HiveBox to use throughout the app.
  static Future create() async {
    var packageInfo = await PackageInfo.fromPlatform();
    if (kIsWeb) {
      Hive.init('smartwind_${packageInfo.buildNumber}');
    } else {
      var directory = await getApplicationDocumentsDirectory();
      print("dddddddddddddddddddddddd = ${directory.path}");
      Hive.init(directory.path + '/smartwind_${packageInfo.buildNumber}');
      print('build number == ${packageInfo.buildNumber}');
    }

    Hive.registerAdapter(NsUserAdapter());
    Hive.registerAdapter(TicketAdapter());
    Hive.registerAdapter(UserConfigAdapter());
    Hive.registerAdapter(SectionAdapter());
    Hive.registerAdapter(UponsAdapter());
    Hive.registerAdapter(StandardTicketAdapter());
    Hive.registerAdapter(LocalFileVersionAdapter());
    Hive.registerAdapter(TicketFlagAdapter());

    usersBox = await Hive.openBox<NsUser>('userBox');
    ticketBox = await Hive.openBox<Ticket>('ticketBox');
    sectionsBox = await Hive.openBox<Section>('sectionsBox');
    userConfigBox = await Hive.openBox<HiveClass>('userConfigBox');
    userPermissions = await Hive.openBox<UserPermissions>('userPermissionsBox');
    standardTicketsBox = await Hive.openBox<StandardTicket>('standardTicketsBox');
    localFileVersionsBox = await Hive.openBox<LocalFileVersion>('localFileVersionsBox');
    // ticketFlagBox = await Hive.openBox<TicketFlag>('ticketFlagBox');


    if (kIsWeb) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          FirebaseDatabase.instance.ref('db_upon').onValue.listen((DatabaseEvent event) {
            final data = event.snapshot.value;
            print('db_upon___db_upon');
            HiveBox.getDataFromServer();
          });
        }
      });
    }

  }

  static Future getDataFromServer({clean = false}) {
    print('__________________________________________________________________________________________________________getDataFromServer');
    if (clean) {
      setUptimes(Upons());
    }
    Upons uptimes = getUptimes();
    Map<String, dynamic> d = uptimes.toJson();
    d["z"] = DateTime.now().millisecondsSinceEpoch;
    print(uptimes.toJson());

    return OnlineDB.apiGet(("data/getData"), d).then((Response response) async {
      print('__________________________________________________________________________________________________________getDataFromServer');
      if (clean) {
        await usersBox.clear();
        await ticketBox.clear();
        await sectionsBox.clear();
        await userPermissions.clear();
        await standardTicketsBox.clear();
      }

      print('5');
      Map res = response.data;
      print(res["users"]);
      List<NsUser> usersList = NsUser.fromJsonArray(res["users"] ?? []);
      List<Ticket> ticketsList = Ticket.fromJsonArray(res["tickets"] ?? []);
      List<Section> factorySectionsList = Section.fromJsonArray(res["factorySections"] ?? []);
      List<StandardTicket> standardTicketsList = StandardTicket.fromJsonArray(res["standardTickets"] ?? []);

      List<Ticket> deletedTicketsIdsList = Ticket.fromJsonArray(res["deletedTicketsIds"] ?? []);
      List<Ticket> completedTicketsIdsList = Ticket.fromJsonArray(res["completedTicketsIds"] ?? []);

      // usersList.forEach((element) {
      //   print('------------------------------------------------------------------------------------------------');
      //   print(element.toJson());
      // });

      usersBox.putMany(usersList);

      print('ticketsList length == ${ticketsList.length}');
      ticketBox.putMany(ticketsList);
      sectionsBox.putMany(factorySectionsList);
      standardTicketsBox.putMany(standardTicketsList);

      deletedTicketsIdsList.forEach((element) {
        ticketBox.delete(element.id);
      });
      completedTicketsIdsList.forEach((element) {
        ticketBox.delete(element.id);
      });

      if (usersList.where((element) => element.id == AppUser.getUser()?.id).isNotEmpty) {
        AppUser.refreshUserData();
      }

      bool updated = false;

      if (HiveBox.usersBox.length > 0) {
        DB.callChangesCallBack(DataTables.Users);
        updated = true;
      }
      if (HiveBox.ticketBox.length > 0 || deletedTicketsIdsList.length > 0 || completedTicketsIdsList.length > 0) {
        DB.callChangesCallBack(DataTables.Tickets);
        updated = true;
      }
      if (HiveBox.sectionsBox.length > 0) {
        DB.callChangesCallBack(DataTables.Sections);
        updated = true;
      }
      if (HiveBox.standardTicketsBox.length > 0) {
        DB.callChangesCallBack(DataTables.standardTickets);
        updated = true;
      }
      if (updated) {
        DB.callChangesCallBack(DataTables.Any);
      }

      print('__________________________________________________________________________________________________________');
      print(HiveBox.usersBox.length);
      print(HiveBox.ticketBox.length);
      print(HiveBox.sectionsBox.length);
      print(HiveBox.standardTicketsBox.length);
      print('__________________________________________________________________________________________________________');
      print('uptimes : ${res["uptimes"]}');

      // callOnUpdates();
      print("data loaded from server ");
      print(res["uptimes"]);
      setUptimes(Upons.fromJson(res["uptimes"]));
    }).onError((error, stackTrace) {
      print('__________________________________________________________________________________________________________');
      print(error.toString());
      print(stackTrace.toString());
      // ErrorMessageView(errorMessage: error.toString()).show(context);
    });
  }

  static final List<Function> listeners = [];

  static onUpdate(Function function, {List<Collection>? collections}) {
    listeners.add(function);
  }

  // static void removeOnUpdate(onupdate) {
  //   listeners.remove(onupdate);
  // }

  // static void callOnUpdates() {
  //   listeners.forEach((element) {
  //     try {
  //       element();
  //     } catch (e) {}
  //   });
  // }

  static Upons getUptimes() {
    return userConfigBox.get("upons", defaultValue: Upons());
  }

  static void setUptimes(Upons upons) {
    print(upons.toJson());
    var x = {...getUptimes().toJson(), ...upons.toJson()};
    var upons2 = Upons.fromJson(x);
    print("+++++++++++++++++++++++++++++++++++++++++ upons ");
    print(upons2.toJson());
    userConfigBox.put("upons", upons2);
  }
}
