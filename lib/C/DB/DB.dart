import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';
import 'package:sqflite/sqflite.dart';

import '../OnlineDB.dart';
import 'DbMigrator.dart';

class DB {
  static Database? db;

  static var _dbName = 'NS_smart_wind.db';

  static Future<Database?> getDB() async {
    db = (db != null ? db : await loadDB());
    return db;
  }

  static Future<void> dropDatabase() async {
    Directory? directory = await getExternalStorageDirectory();
    String path = (directory!.path + "/" + _dbName);
    await deleteDatabase(path);
  }

  static Future<Database> loadDB() async {
    Directory? directory = await getExternalStorageDirectory();
    String path = (directory!.path + "/" + _dbName);
    // String path = (directory.path.split("Android")[0] + "Farm");
    new Directory(path).createSync();
    path += ("/" + _dbName);
    print("path__________");
    print(path);

    var maxMigratedDbVersion = DbMigrator.migrations.keys.reduce(max);
    print('DB version = $maxMigratedDbVersion');
    // await deleteDatabase(path);
    return openDatabase(path, version: maxMigratedDbVersion, onCreate: (Database db, int version) async {
      DbMigrator.migrations.keys.toList()
        ..sort() //make sure to sort
        ..forEach((k) async {
          DbMigrator.migrations[k]!.forEach((script) async {
            print(script);
            await db.execute(script);
          });
        });
    }, onUpgrade: (db, oldVersion, newVersion) async {
      print('updating Database version $oldVersion to $newVersion');
      var curdDbVersion = await getCurrentDbVersion(db);
      var upgradeScripts = new Map.fromIterable(DbMigrator.migrations.keys.where((k) => k > curdDbVersion), key: (k) => k, value: (k) => DbMigrator.migrations[k]);

      if (upgradeScripts.length == 0) return;

      upgradeScripts.keys.toList()
        ..sort() //make sure to sort
        ..forEach((k) async {
          upgradeScripts[k]!.forEach((script) async {
            print(script);
            await db.execute(script);
          });
        });
      _upgradeDbVersion(db, maxMigratedDbVersion);
    });
  }

  static _upgradeDbVersion(Database db, int version) async {
    await db.rawQuery("pragma user_version = $version;");
  }

  static Future<int> getCurrentDbVersion(Database db) async {
    var res = await db.rawQuery('PRAGMA user_version;', null);
    var version = res[0]["user_version"].toString();
    return int.parse(version);
  }

  static Future updateDatabase({context, showLoadingDialog = false, reset = false}) async {
    var loadingWidget = Loading(
      loadingText: "updating Database",
      showProgress: false,
    );
    if (showLoadingDialog && context != null) {
      loadingWidget.show(context);
    }

    var DB = await getDB();
    if (reset) {
      print('reset');
      await DB!.rawQuery("delete from tickets;");
      await DB.rawQuery("delete from factorySections;");
      await DB.rawQuery("delete from users;");
    }
    return getDB()
        .then((value) => value!
                .rawQuery("select "
                    "(select ifnull(max(uptime),0) uptime from tickets) tickets,"
                    "(select ifnull(max(uptime),0) uptime from factorySections) factorySections,"
                    "(select ifnull(max(uptime),0) uptime from users) users")
                .then((value) {
              print("last update on == " + value.toString());
              Map<Object, Object?> xx = value.length > 0 ? value[0] : {'tickets': '0', 'users': '0'};
              print('xxxxxxxxxxxxxxxxxxxxxxxxxxx');
              Map<String, String> uptime = xx.map((key, value) => MapEntry("$key", "$value"));
              print(uptime.toString());

              return OnlineDB.apiGet("data/getData", uptime).then((Response response) async {
                Map res = (json.decode(response.body) as Map);
                print("----------------------------------------------------------------");
                print(res);
                processData(res);

                if (showLoadingDialog && context != null) {
                  loadingWidget.close(context);
                }
                List OnDBChangeCallBacksTemp = [];
                OnDBChangeCallBacksTemp.addAll(OnDBChangeCallBacks);
                for (var i = 0; i < OnDBChangeCallBacksTemp.length; i++) {
                  var x = OnDBChangeCallBacksTemp[i];
                  try {
                    x();
                  } catch (e) {
                    OnDBChangeCallBacks.remove(x);
                  }
                }
              }).onError((error, stackTrace) {
                ErrorMessageView(errorMessage: error.toString()).show(context);
              });
            }))
        .onError((onError, st) {
      print(onError);
      ErrorMessageView(errorMessage: onError.toString()).show(context);
    });
  }

  static List OnDBChangeCallBacks = [];

  static setOnDBChangeListener(callBack) {
    OnDBChangeCallBacks.add(callBack);
  }

  static void processData(Map<dynamic, dynamic> res) {
    if (res.containsKey("tickets")) {
      List tickets = (res["tickets"] ?? []);
      print('tickets = ' + tickets.length.toString());
      insertTickets(tickets);
    }
    if (res.containsKey("deletedTickets")) {
      List deletedTickets = (res["deletedTickets"] ?? []);
      deleteTickets(deletedTickets);
    }
    if (res.containsKey("ticketProgressDetails")) {
      List ticketProgressDetails = (res["ticketProgressDetails"] ?? []);
      insertTicketProgressDetails(ticketProgressDetails);
    }

    if (res.containsKey("users")) {
      List users = (res["users"] ?? []);
      insertUsers(users);
    }
    if (res.containsKey("factorySections")) {
      List factorySections = (res["factorySections"] ?? []);
      insertFactorySections(factorySections);
    }
  }

  static Future<void> insertTickets(List<dynamic> tickets) async {
    await db!.transaction((txn) async {
      Batch batch = txn.batch();
      tickets.forEach((ticket) {
        insertFlags(ticket["flags"] ?? [], batch);
        ticket.remove("flags");
        // print(ticket);
        batch.insert('tickets', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
      });
      await batch.commit(noResult: true);
      print('tickets inserted ');
    });
  }

  static Future<void> deleteTickets(List<dynamic> deletedTickets) async {
    Batch batch = db!.batch();
    deletedTickets.forEach((ticket) {
      batch.delete('tickets', where: 'id = ?', whereArgs: [ticket["id"]]);
    });
    print(await batch.commit(noResult: false));
  }

  static Future<void> insertTicketProgressDetails(List<dynamic> deletedTickets) async {
    Batch batch = db!.batch();
    deletedTickets.forEach((ticket) {
      batch.insert('ticketProgressDetails', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    print(await batch.commit(noResult: false));
  }

  static Future<void> insertFlags(List<dynamic> flags, Batch batch) async {
    flags.forEach((ticket) {
      batch.insert('flags', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  static Future<void> insertUsers(List<dynamic> users) async {
    Batch batch = db!.batch();
    users.forEach((user) {
      insertUserSections(user["id"], user["sections"] ?? [], batch);
      user.remove("sections");
      print(user);
      batch.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    print(await batch.commit(noResult: false));
  }

  static Future<void> insertFactorySections(List<dynamic> factorySections) async {
    Batch batch = db!.batch();
    factorySections.forEach((factorySection) {
      batch.insert('factorySections', factorySection, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    print(await batch.commit(noResult: false));
  }

  static Future<void> insertUserSections(userId, List<dynamic> userSections, Batch? batch) async {
    batch = batch ?? db!.batch();
    userSections.forEach((userSection) {
      batch!.insert('userSections', {"userId": userId, "sectionId": userSection["id"]}, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    print(await batch.commit(noResult: false));
  }
}
