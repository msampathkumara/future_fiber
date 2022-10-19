import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static Database? db;


  static List<DbChangeCallBack> onDBChangeCallBacks = [];

  static DbChangeCallBack setOnDBChangeListener(callBack, context, {collection = DataTables.none}) {
    print('DbChangeCallBack $collection ');
    var dbChangeCallBack = DbChangeCallBack(callBack, context, collection);
    onDBChangeCallBacks.add(dbChangeCallBack);
    return dbChangeCallBack;
  }

  static Future<void> deleteTickets(List<dynamic> deletedTickets) async {
    Batch batch = db!.batch();

    for (var ticket in deletedTickets) {
      batch.delete('tickets', where: 'id = ?', whereArgs: [ticket["id"]]);
    }

    print(await batch.commit(noResult: false));
  }

  static Future<void> insertTicketProgressDetails(List<dynamic> deletedTickets) async {
    Batch batch = db!.batch();
    for (var ticket in deletedTickets) {
      batch.insert('ticketProgressDetails', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    print(await batch.commit(noResult: false));
  }

  static Future<void> insertFlags(List<dynamic> flags, Batch batch) async {
    for (var ticket in flags) {
      batch.insert('flags', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertUsers(List<dynamic> users) async {
    Batch batch = db!.batch();
    for (var user in users) {
      insertUserSections(user["id"], user["sections"] ?? [], batch);
      user.remove("sections");
      print(user);
      batch.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    print(await batch.commit(noResult: false));
  }

  static Future<void> insertFactorySections(List<dynamic> factorySections) async {
    Batch batch = db!.batch();
    for (var factorySection in factorySections) {
      batch.insert('factorySections', factorySection, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    print(await batch.commit(noResult: false));
  }

  static Future<void> insertUserSections(userId, List<dynamic> userSections, Batch? batch) async {
    batch = batch ?? db!.batch();
    for (var userSection in userSections) {
      batch.insert('userSections', {"userId": userId, "sectionId": userSection["id"]}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    print(await batch.commit(noResult: false));
  }

  static callChangesCallBacks(Map<dynamic, dynamic> res) {
    List keys = res.keys.toList();
    print('callChangesCallBacks');

    List<DbChangeCallBack> onDBChangeCallBacksTemp = [];
    onDBChangeCallBacksTemp.addAll(onDBChangeCallBacks);
    for (var i = 0; i < onDBChangeCallBacksTemp.length; i++) {
      var x = onDBChangeCallBacksTemp[i];
      print('CallBack=== ${x.collection}');
      try {
        if (x.isDisposed()) {
          print('CallBack=== isDisposed ');
          onDBChangeCallBacks.remove(x);
        } else if (x.collection == DataTables.none || keys.contains(x.collection.toShortString())) {
          print('CallBack=== call ');
          x.callBack();
          print('${x.collection}');
        } else {
          x.callBack();
        }
      } catch (e) {
        print("EEEEEEEE");
        onDBChangeCallBacks.remove(x);
      }
    }
  }

  static callChangesCallBack(DataTables table) {
    List<DbChangeCallBack> onDBChangeCallBacksTemp = [];
    onDBChangeCallBacksTemp.addAll(onDBChangeCallBacks);
    for (var i = 0; i < onDBChangeCallBacksTemp.length; i++) {
      var x = onDBChangeCallBacksTemp[i];

      try {
        if (x.isDisposed()) {
          onDBChangeCallBacks.remove(x);
        } else if (x.collection == DataTables.none || table == x.collection) {
          x.callBack();
        }
      } catch (e) {
        onDBChangeCallBacks.remove(x);
      }
    }
  }

// static Future<void> updateCompletedTicket(context, ticketId) async {
//   var db = await getDB();
//   await db!.delete("tickets", where: 'id=?', whereArgs: [ticketId]);
//   callChangesCallBack(DataTables.Tickets);
// }
}

enum DataTables { none, users, tickets, standardTickets, sections, any, cpr, kit, appUser }

class DbChangeCallBack {
  DataTables collection;
  bool disposed = false;
  Function callBack;
  BuildContext context;

  DbChangeCallBack(this.callBack, this.context, this.collection);

  void dispose() {
    disposed = true;
  }

  bool isDisposed() {
    return disposed;
  }
}

extension ParseToString on DataTables {
  String toShortString() {
    return (this).toString().split('.').last.toLowerCase();
  }
}
