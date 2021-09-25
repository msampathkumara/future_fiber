import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'DB/DB.dart';

class FCM {
  static listen(context) {
    FirebaseMessaging.instance.subscribeToTopic('ticketDelete');
    FirebaseMessaging.instance.subscribeToTopic('ticketComplete');
    FirebaseMessaging.instance.subscribeToTopic('file_update');
    FirebaseMessaging.instance.subscribeToTopic('TicketDbReset');
    FirebaseMessaging.instance.subscribeToTopic('userUpdates');
    FirebaseMessaging.instance.subscribeToTopic('resetDb');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("---------------- FCM ------------------");
      print(message.from);

      if (message.from == "/topics/ticketComplete") {
        DB.updateCompletedTicket(context, json.decode(message.data["ticketId"]));
      }else if (message.from == "/topics/resetDb") {
        DB.updateDatabase(context, reset: true);
        print('--------------------------RESEING DATABASE-----------------');
      } else if (json.decode(message.data["FILE_DB_UPDATE"]) != null) {
        DB.updateDatabase(context);
      } else if (json.decode(message.data["updateTicketDB"]) != null) {
        DB.updateDatabase(context, reset: true);
        print('--------------------------RESEING DATABASE-----------------');
      } else if (json.decode(message.data["userUpdates"]) != null) {
        DB.updateDatabase(context, reset: true);
        print('--------------------------UPDATING USER DATABASE-----------------');
      }
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static unsubscribe() {
    FirebaseMessaging.instance.unsubscribeFromTopic('ticketDelete');
    FirebaseMessaging.instance.subscribeToTopic('ticketComplete');
    FirebaseMessaging.instance.subscribeToTopic('file_update');
    FirebaseMessaging.instance.subscribeToTopic('TicketDbReset');
    FirebaseMessaging.instance.subscribeToTopic('userUpdates');
  }
}
