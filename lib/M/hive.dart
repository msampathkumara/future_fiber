import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/Ticket/CprReport.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/M/User/Email.dart';
import 'package:smartwind/M/user_config.dart';
import 'package:smartwind/main.dart';

import '../C/Api.dart';
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

      Hive.init('${directory.path}/smartwind_${packageInfo.buildNumber}');
    }

    Hive.registerAdapter(NsUserAdapter());
    Hive.registerAdapter(TicketAdapter());
    Hive.registerAdapter(UserConfigAdapter());
    Hive.registerAdapter(SectionAdapter());
    Hive.registerAdapter(UponsAdapter());
    Hive.registerAdapter(StandardTicketAdapter());
    Hive.registerAdapter(LocalFileVersionAdapter());
    Hive.registerAdapter(TicketFlagAdapter());
    Hive.registerAdapter(EmailAdapter());
    Hive.registerAdapter(CprReportAdapter());

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
            HiveBox.getDataFromServer();
          });
          FirebaseDatabase.instance.ref('db_upon').child("ticketComplete").onValue.listen((DatabaseEvent event) {
            HiveBox.updateCompletedTickets();
          });
          FirebaseDatabase.instance.ref('resetDb').onValue.listen((DatabaseEvent event) {
            HiveBox.getDataFromServer(clean: true);
          });
        }
      });
    }

    if (isMaterialManagement) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          FirebaseDatabase.instance.ref('cprUpdate').onValue.listen((DatabaseEvent event) {
            DB.callChangesCallBack(DataTables.cpr);
          });
          FirebaseDatabase.instance.ref('kitUpdate').onValue.listen((DatabaseEvent event) {
            DB.callChangesCallBack(DataTables.kit);
          });
          FirebaseDatabase.instance.ref('resetDb').onValue.listen((DatabaseEvent event) {
            HiveBox.getDataFromServer(clean: true);
          });
        }
      });
    }
  }

  static Future getDataFromServer({clean = false, afterLoad, cleanUsers = false}) async {
    print('__________________________________________________________________________________________________________getDataFromServer');
    if (clean) {
      await userConfigBox.delete('upons');
    }
    Upons uptimes = getUptimes();
    if (cleanUsers) {
      uptimes.users = 0;
    }
    Map<String, dynamic> d = uptimes.toJson();
    d["z"] = DateTime.now().millisecondsSinceEpoch;
    print(uptimes.toJson());

    return Api.get(("data/getData"), d).then((Response response) async {
      print('__________________________________________________________________________________________________________getDataFromServer');
      if (clean) {
        await usersBox.clear();
        await ticketBox.clear();
        await sectionsBox.clear();
        await userPermissions.clear();
        await standardTicketsBox.clear();
      } else if (cleanUsers) {
        await usersBox.clear();
      }

      print('5');
      Map res = response.data;
      print(res["users"]);
      List<NsUser> usersList = NsUser.fromJsonArray(res["users"] ?? []);

      List<Ticket> ticketsList = Ticket.fromJsonArray(res["tickets"] ?? []);

      List<Section> factorySectionsList = Section.fromJsonArray(res["factorySections"] ?? []);
      List<StandardTicket> standardTicketsList = StandardTicket.fromJsonArray(res["standardTickets"] ?? []);

      List<Ticket> deletedTicketsIdsList = Ticket.fromJsonArray(res["deletedTicketsIds"] ?? []);
      List<Ticket> completedTicketsIdsList = Ticket.fromJsonArray(res["completedTickets"] ?? []);

      usersBox.putMany(usersList);

      print('ticketsList length == ${ticketsList.length}');
      print('standardTicketsList length == ${standardTicketsList.length}');
      ticketBox.putMany(ticketsList);
      sectionsBox.putMany(factorySectionsList);
      standardTicketsBox.putMany(standardTicketsList);

      for (var element in deletedTicketsIdsList) {
        ticketBox.delete(element.id);
      }
      for (var element in completedTicketsIdsList) {
        ticketBox.delete(element.id);
      }
      for (var element in ticketsList) {
        if (element.completed == 1) ticketBox.delete(element.id);
      }

      if (usersList.where((element) => element.id == AppUser.getUser()?.id).isNotEmpty) {
        AppUser.refreshUserData();
      }

      bool updated = false;

      if (HiveBox.usersBox.length > 0) {
        DB.callChangesCallBack(DataTables.Users);
        updated = true;
      }
      if (HiveBox.ticketBox.length > 0 || deletedTicketsIdsList.isNotEmpty || completedTicketsIdsList.isNotEmpty) {
        DB.callChangesCallBack(DataTables.Tickets);
        updated = true;
      }
      if (HiveBox.sectionsBox.length > 0) {
        DB.callChangesCallBack(DataTables.Sections);
        updated = true;
      }
      if (standardTicketsList.isNotEmpty) {
        print('xxxxxxxccccccccccccccccccccccccccccccccccc');
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
      setUptimes(res["uptimes"]);
      if (afterLoad != null) {
        afterLoad();
      }
    }).onError((error, stackTrace) {
      print('__________________________________________________________________________________________________________');
      print(error.toString());
      print(stackTrace.toString());
      if (afterLoad != null) {
        afterLoad();
      }
      // ErrorMessageView(errorMessage: error.toString()).show(context);
    });
  }

  static final List<Function> listeners = [];

  static onUpdate(Function function, {List<Collection>? collections}) {
    listeners.add(function);
  }

  static Upons getUptimes() {
    return userConfigBox.get("upons", defaultValue: Upons());
  }

  static setUptimes(upons) {
    var x = {...getUptimes().toJson(), ...upons};
    Map<String, dynamic> xx = Map<String, dynamic>.from(x);
    var upons2 = Upons.fromJson(xx);
    userConfigBox.put("upons", upons2);
  }

  static cleanStandardLibrary() async {
    await standardTicketsBox.clear();
    var i = getUptimes();
    i.standardTickets = 0;
    setUptimes(i.toJson());
  }

  static deleteTicket(data) {
    ticketBox.delete(data);
  }

  static void updateCompletedTickets() {}
}
