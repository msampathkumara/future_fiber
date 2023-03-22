import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/DB/TriggerEventTimes.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/Ticket/CprReport.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/M/User/Email.dart';
import 'package:smartwind/C/DB/up_on.dart';
import 'package:smartwind/C/DB/user_config.dart';
import 'package:smartwind/Web/Widgets/StatusBar/StatusBar.dart';
import '../../Web/Widgets/StatusBar/StatusBarProgressIndicator.dart';
import '../Api.dart';
import '../../Mobile/V/Home/UserManager/UserPermissions.dart';
import '../../globals.dart';
import '../../M/AppUser.dart';
import 'HiveClass.dart';
import '../../M/LocalFileVersion.dart';
import '../../M/NsUser.dart';
import '../../M/Section.dart';

class HiveBox {
  static late final Box<NsUser> usersBox;
  static late final Box<Ticket> ticketBox;
  static late final Box<Section> sectionsBox;

  // static late final Box<StandardTicket> standardTicketsBox;
  static late final Box<LocalFileVersion> localFileVersionsBox;
  static late final Box<UserConfig> userConfigBox;
  static late final Box<UserPermissions> userPermissions;

  static StreamSubscription<DatabaseEvent>? userUpdatesListener;
  static StreamSubscription<DatabaseEvent>? resetDbListener;
  static StreamSubscription<DatabaseEvent>? dbUponListener;
  static StreamSubscription<DatabaseEvent>? ticketCompleteListener;

  // static StreamSubscription<DatabaseEvent>? standardLibraryListener;

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
    // Hive.registerAdapter(StandardTicketAdapter());
    Hive.registerAdapter(LocalFileVersionAdapter());
    Hive.registerAdapter(TicketFlagAdapter());
    Hive.registerAdapter(EmailAdapter());
    Hive.registerAdapter(CprReportAdapter());
    Hive.registerAdapter(TriggerEventTimesAdapter());

    usersBox = await Hive.openBox<NsUser>('userBox');
    ticketBox = await Hive.openBox<Ticket>('ticketBox');
    sectionsBox = await Hive.openBox<Section>('sectionsBox');
    userConfigBox = await Hive.openBox<UserConfig>('userConfigBox');
    userPermissions = await Hive.openBox<UserPermissions>('userPermissionsBox');
    // standardTicketsBox = await Hive.openBox<StandardTicket>('standardTicketsBox');
    localFileVersionsBox = await Hive.openBox<LocalFileVersion>('localFileVersionsBox');

    // if (kIsWeb) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        userUpdatesListener?.cancel();
        dbUponListener?.cancel();
        ticketCompleteListener?.cancel();
        // standardLibraryListener?.cancel();
        resetDbListener?.cancel();

        // Map<String, bool> listeningStarted = {};

        dbUponListener = FirebaseDatabase.instance.ref('db_upon').onValue.listen((DatabaseEvent event) async {
          print('authStateChanges -> db_upon');
          UserConfig userConfig = await getUserConfig();

          Map upon = event.snapshot.value as Map;

          print('upon[resetDb]== ${upon['resetDb']}==${userConfig.triggerEventTimes.resetDb}');

          if (!mapEquals(userConfig.triggerEventTimes.dbUpon, upon)) {
            printWarning('db_upon updated');
            if (userConfig.triggerEventTimes.resetDb != upon['resetDb']) {
              printWarning('Reset Database');
              HiveBox.getDataFromServer(clean: true, cancelable: false);
              userConfig.triggerEventTimes.resetDb = upon['resetDb'];
              printWarning('Reset Database Done');
            } else {
              await HiveBox.getDataFromServer(clean: false);
            }
          }
          userConfig.triggerEventTimes.dbUpon = upon;

          // printWarning('${userConfig.triggerEventTimes.dbUpon} event.snapshot.value == ${event.snapshot.value}');
          if (userConfig.isInBox) {
            await userConfig.save();
          } else {
            await HiveBox.userConfigBox.put(0, userConfig);
          }
        });
        // ticketCompleteListener = FirebaseDatabase.instance.ref('db_upon').child("ticketComplete").onValue.listen((DatabaseEvent event) {
        //   print('authStateChanges -> ticketComplete');
        //   //
        //   if (listeningStarted['ticketComplete'] == true) {
        //     HiveBox.updateCompletedTickets();
        //   }
        //   listeningStarted['ticketComplete'] = true;
        // });
        // standardLibraryListener = FirebaseDatabase.instance.ref('db_upon').child("standardLibrary").onValue.listen((DatabaseEvent event) async {
        //   print('authStateChanges -> standardLibrary');
        //   if (listeningStarted['standardLibrary'] == true) {
        //     await HiveBox.cleanStandardLibrary();
        //     await HiveBox.getDataFromServer();
        //     DB.callChangesCallBack(DataTables.standardTickets);
        //   }
        //   listeningStarted['standardLibrary'] = true;
        // });
        // resetDbListener = FirebaseDatabase.instance.ref('resetDb').onValue.listen((DatabaseEvent event) {
        //   print('authStateChanges -> resetDb');
        //   if (listeningStarted['resetDb'] == true) {
        //     HiveBox.getDataFromServer(clean: true);
        //   }
        // });
      }
    });
    // }

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

  static bool pendingGetDataFromServer = false;
  static bool pendingNextGetDataFromServer = false;
  static CancelToken cancelToken = CancelToken();

  static Future getDataFromServer({clean = false, afterLoad, cleanUsers = false, cancelable = true}) async {
    print('__________________________________________________________________________________________________________getDataFromServer');

    if (clean) {
      await resetUptimes();
      print('up times reset');
    }
    UserConfig userConfig = await getUserConfig();

    if (userConfig.user == null) {
      return;
    }

    print('user == ${userConfig.user?.toJson()}');
    if (cleanUsers) {
      userConfig.upon.users = 0;
    }
    Map<String, dynamic> d = userConfig.upon.toJson();
    d["z"] = DateTime.now().millisecondsSinceEpoch;
    print("clean: ${clean} ,, uptimes.toJson() : ${d}");

    if (AppUser.isNotLogged) {
      print('user not logged in not calling to server ');
      return null;
    }
    // if (cancelable) {
    cancelToken.cancel();
    cancelToken = CancelToken();
    // }
    return Api.get((EndPoints.data_getData), d, cancelToken: cancelable ? cancelToken : null).then((Response response) async {
      print('__________________________________________________________________________________________________________Api ->> getDataFromServer');
      await getUserConfig();
      if (clean) {
        await usersBox.clear();
        await ticketBox.clear();
        await sectionsBox.clear();
        await userPermissions.clear();
        // await standardTicketsBox.clear();
      } else if (cleanUsers) {
        await usersBox.clear();
      }

      // print('5');
      Map res = response.data;
      // print(res["users"]);
      List<NsUser> usersList = NsUser.fromJsonArray(res["users"] ?? []);

      List<Ticket> ticketsList = Ticket.fromJsonArray(res["tickets"] ?? []);

      List<Section> factorySectionsList = Section.fromJsonArray(res["factorySections"] ?? []);
      List<StandardTicket> standardTicketsList = StandardTicket.fromJsonArray(res["standardTickets"] ?? []);

      List<Ticket> deletedTicketsIdsList = Ticket.fromJsonArray(res["deletedTicketsIds"] ?? []);
      List<Ticket> completedTicketsIdsList = Ticket.fromJsonArray(res["completedTickets"] ?? []);
      Stopwatch stopwatch = Stopwatch()..start();
      await usersBox.putMany(usersList, afterAdd: (list) {
        if (list.isNotEmpty) {
          printError(' DB.callChangesCallBack(DataTables.users)');
          DB.callChangesCallBack(DataTables.users);
        }
      });
      print('usersBox.putMany executed in ${stopwatch.elapsed}');
      stopwatch.reset();

      print('usersBox length == ${usersList.length}');
      print('ticketsList length == ${ticketsList.length}');
      print('standardTicketsList length == ${standardTicketsList.length}');

      if (ticketsList.isNotEmpty) {
        StatusBarProgressIndicatorController statusBarProgressIndicatorController = StatusBarProgressIndicatorController();
        var _statusBarProgressIndicator = StatusBarProgressIndicator(trailing: const Icon(Icons.dns_rounded, color: Colors.red), controller: statusBarProgressIndicatorController);
        StatusBar.getController().addWidget(_statusBarProgressIndicator);

        ticketBox.putMany(ticketsList, onItemAdded: (index, object) async {
          if (kIsWeb) double progress = statusBarProgressIndicatorController.setValue(index + 1.0, ticketsList.length);
          // print('add $index');
        }).then((List<HiveClass> list) async {
          print('tickets saved');
          int maxValue = ticketBox.values.map((e) => e.uptime).reduce(max);
          print('$maxValue __uptimes max');
          var upt = await getUserConfig();
          upt.upon.tickets = maxValue;
          await upt.save();
          // await setUptimes({'tickets': maxValue});

          if (ticketsList.isNotEmpty || deletedTicketsIdsList.isNotEmpty || completedTicketsIdsList.isNotEmpty) {
            DB.callChangesCallBack(DataTables.tickets);
          }

          StatusBar.getController().removeWidget(_statusBarProgressIndicator);
        });
      }

      await sectionsBox.putMany(factorySectionsList, afterAdd: (list) {
        if (list.isNotEmpty) DB.callChangesCallBack(DataTables.sections);
      });
      print('sectionsBox.putMany executed in ${stopwatch.elapsed}');
      stopwatch.reset();

      print('standardTicketsBox.putMany executed in ${stopwatch.elapsed}');
      stopwatch.reset();

      print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> done putting');

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

      if (usersList.isNotEmpty ||
          factorySectionsList.isNotEmpty ||
          standardTicketsList.isNotEmpty ||
          ticketsList.isNotEmpty ||
          deletedTicketsIdsList.isNotEmpty ||
          completedTicketsIdsList.isNotEmpty) {
        DB.callChangesCallBack(DataTables.any);
      }
      await getUserConfig();
      print('__________________________________________________________________________________________________________');
      print(HiveBox.usersBox.length);
      print(HiveBox.ticketBox.length);
      print(HiveBox.sectionsBox.length);

      print('__________________________________________________________________________________________________________');
      print('uptimes : ${res["uptimes"]}');

      // callOnUpdates();
      print("data loaded from server ");
      print(res["uptimes"]);
      await getUserConfig();
      await setUptimes(res["uptimes"]);
      if (afterLoad != null) {
        afterLoad();
      }
      pendingGetDataFromServer = false;
    }).onError((error, stackTrace) {
      print('__________________________________________________________________________________________________________');
      print(error.toString());
      print(stackTrace.toString());
      if (afterLoad != null) {
        afterLoad();
      }
      pendingGetDataFromServer = false;
      // ErrorMessageView(errorMessage: error.toString()).show(context);
    });
  }

  static final List<Function> listeners = [];

  static onUpdate(Function function, {List<Collection>? collections}) {
    listeners.add(function);
  }

  // static Future<Upons> getUptimes() async {
  //   print('await getUserConfig()).upon.toJson() : ${(await getUserConfig()).upon.toJson()}');
  //
  //   return (await getUserConfig()).upon;
  // }

  // static TriggerEventTimes getTriggerEventTimes() {
  //   return userConfigBox.get(0, defaultValue: UserConfig())?.triggerEventTimes ?? TriggerEventTimes();
  // }

  static Future<UserConfig> getUserConfig() async {
    print('getUserConfig call');
    UserConfig x = userConfigBox.get(0, defaultValue: UserConfig()) ?? UserConfig();
    if (!x.isInBox) {
      print('UserConfig not found, creating...');
      await HiveBox.userConfigBox.put(0, x);
    }

    print('uuuuuuuuuuuuu == ${x.user}');

    return x.isInBox ? x : userConfigBox.get(0, defaultValue: UserConfig()) ?? UserConfig();
  }

  static setUptimes(upons) async {
    UserConfig userConfig = await HiveBox.getUserConfig();

    var x = {...((await getUserConfig()).upon).toJson(), ...upons};
    Map<String, dynamic> xx = Map<String, dynamic>.from(x);
    var upons2 = Upons.fromJson(xx);
    // UserConfig userConfig = userConfigBox.get(0, defaultValue: UserConfig()) ?? UserConfig();
    userConfig.upon = upons2;
    await userConfig.save();
    // userConfigBox.put(0, userConfig);
    print('xxFirebaseAuth.instance.currentUser == ${userConfig.user?.toJson()}');
  }

  static resetUptimes() async {
    UserConfig userConfig = await getUserConfig();
    userConfig.upon = Upons();
    userConfig.save();
    // userConfigBox.put(0, userConfig);
  }

  static deleteTicket(data) {
    ticketBox.delete(data);
  }

  static void updateCompletedTickets() {}

  static Future<void> cleanDb() async {
    await usersBox.clear();
    await ticketBox.clear();
    await sectionsBox.clear();
    await userPermissions.clear();
  }
}
