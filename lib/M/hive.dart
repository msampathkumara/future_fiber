import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/user_config.dart';

import '../C/Server.dart';
import '../V/Home/UserManager/UserPermissions.dart';
import 'AppUser.dart';
import 'NsUser.dart';
import 'Section.dart';
import 'enums.dart';
import 'up_on.dart';

class HiveBox {
  static late final Box<NsUser> usersBox;
  static late final Box<Ticket> ticketBox;
  static late final Box<Section> sectionsBox;
  static late final Box<StandardTicket> standardTicketsBox;

  static late final Box userConfigBox;

  static late final Box<UserPermissions> userPermissions;

  /// Create an instance of HiveBox to use throughout the app.
  static Future create() async {
    if (kIsWeb) {
      Hive.init('smartwinddb');
    } else {
      var directory = await getApplicationDocumentsDirectory();
      print("dddddddddddddddddddddddd = ${directory.path}");
      Hive.init(directory.path + '/booksDb2');
    }

    Hive.registerAdapter(NsUserAdapter());
    Hive.registerAdapter(TicketAdapter());
    Hive.registerAdapter(UserConfigAdapter());
    Hive.registerAdapter(SectionAdapter());
    Hive.registerAdapter(UponsAdapter());
    Hive.registerAdapter(StandardTicketAdapter());

    usersBox = await Hive.openBox<NsUser>('userBox');
    ticketBox = await Hive.openBox<Ticket>('ticketBox');
    sectionsBox = await Hive.openBox<Section>('sectionsBox');
    userConfigBox = await Hive.openBox('userConfigBox');
    userPermissions = await Hive.openBox<UserPermissions>('userPermissionsBox');
    standardTicketsBox = await Hive.openBox<StandardTicket>('standardTicketsBox');
  }

  static Future getDataFromServer({clean = false}) {
    if (clean) {
      setUptimes(Upons());
    }
    Upons uptimes = getUptimes();
    print(uptimes.toJson());

    return Server.apiGet(("data/getData"), uptimes.toJson()).then((Response response) async {
      print('__________________________________________________________________________________________________________');
      if (clean) {
        await usersBox.clear();
        await ticketBox.clear();
        await sectionsBox.clear();
        await userPermissions.clear();
        await standardTicketsBox.clear();
      }

      print('5');
      Map res = response.data;

      List<NsUser> usersList = NsUser.fromJsonArray(res["users"] ?? []);
      List<Ticket> ticketsList = Ticket.fromJsonArray(res["tickets"] ?? []);
      List<Section> factorySectionsList = Section.fromJsonArray(res["factorySections"] ?? []);
      List<StandardTicket> standardTicketsList = StandardTicket.fromJsonArray(res["standardTickets"] ?? []);

      List<Ticket> deletedTicketsIdsList = Ticket.fromJsonArray(res["deletedTicketsIds"] ?? []);
      List<Ticket> completedTicketsIdsList = Ticket.fromJsonArray(res["completedTicketsIds"] ?? []);

      usersBox.putMany(usersList);
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
      print('__________________________________________________________________________________________________________');
      print(HiveBox.usersBox.length);
      print(HiveBox.ticketBox.length);
      print(HiveBox.sectionsBox.length);
      print(HiveBox.standardTicketsBox.length);
      print('__________________________________________________________________________________________________________');

      callOnUpdates();
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

  static onUpdate(Function function) {
    listeners.add(function);
  }

  static void removeOnUpdate(onupdate) {
    listeners.remove(onupdate);
  }

  static void loadUserBooksList() {}

  static void callOnUpdates() {
    listeners.forEach((element) {
      try {
        element();
      } catch (e) {}
    });
  }

  static Upons getUptimes() {
    return userConfigBox.get("upons", defaultValue: Upons());
  }

  static void setUptimes(Upons upons) {
    print(upons.toJson());
    var x = {...getUptimes().toJson(), ...upons.toJson()};
    var upons2 = Upons.fromJson(x);
    userConfigBox.put("upons", upons2);
  }
}
