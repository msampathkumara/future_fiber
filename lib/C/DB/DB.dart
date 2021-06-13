import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
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

  static Future updateDatabase({context, showLoadingDialog = false}) async {
    var loadingWidget = Loading(
      loadingText: "updating Database",
      showProgress: false,
    );
    if (showLoadingDialog && context != null) {
      loadingWidget.show(context);
    }
    // await getDB().then((value) => value!.rawQuery("delete from tickets "));
    return getDB().then((value) => value!.rawQuery("select ifnull(max(uptime),0) uptime from tickets; ").then((value) {
          print("last update on == " + value.toString());
          String uptime = value[0]["uptime"].toString();
          return OnlineDB.apiGet("tickets/getProductionPoolTickets", {"uptime": uptime}).then((Response response) async {
            Map res = (json.decode(response.body) as Map);
            List tickets = (res["tickets"] ?? []);
            List deletedTickets = (res["deletedTickets"] ?? []);

            print('tickets = ' + tickets.length.toString());
            print('deletedTickets = ' + deletedTickets.length.toString());

            Batch batch = db!.batch();
            tickets.forEach((ticket) {
              print(ticket);
              batch.insert('tickets', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
            });
            deletedTickets.forEach((ticket) {
              batch.delete('tickets', where: 'id = ?', whereArgs: [ticket["id"]]);
            });
            print(await batch.commit(noResult: false));
            if (showLoadingDialog && context != null) {
              loadingWidget.close(context);
            }
          });
        }));
  }
}
