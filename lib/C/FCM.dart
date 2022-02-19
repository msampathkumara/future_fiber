import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartwind/M/AppUser.dart';

import 'DB/DB.dart';

class FCM {
  static get userId => AppUser.getUser()?.id;

  static subscribe() async {
    FirebaseMessaging.instance.subscribeToTopic('ticketDelete');
    FirebaseMessaging.instance.subscribeToTopic('ticketComplete');
    FirebaseMessaging.instance.subscribeToTopic('file_update');
    FirebaseMessaging.instance.subscribeToTopic('TicketDbReset');
    FirebaseMessaging.instance.subscribeToTopic('userUpdates');
    FirebaseMessaging.instance.subscribeToTopic('resetDb');

    var userId = AppUser.getUser()?.id;
    if (AppUser.getUser() != null) {
      FirebaseMessaging.instance.subscribeToTopic('userUpdate_${userId}');
    }
  }

  static setListener(context) {
    subscribe();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("---------------- FCM ------------------");
      print(message.from);
      print(message.messageId);
      if (message.from == "/topics/userUpdate_$userId") {
        AppUser.refreshUserData();
      } else if (message.from == "/topics/ticketComplete") {
        DB.updateCompletedTicket(context, json.decode(message.data["ticketId"]));
      } else if (message.from == "/topics/resetDb") {
        DB.updateDatabase(context, reset: true);
        print('--------------------------RESEING DATABASE-----------------');
        // } else if (json.decode(message.data["FILE_DB_UPDATE"]) != null) {
      } else if (message.from == "/topics/file_update") {
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

  static unsubscribe() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('ticketDelete');
    await FirebaseMessaging.instance.unsubscribeFromTopic('ticketComplete');
    await FirebaseMessaging.instance.unsubscribeFromTopic('file_update');
    await FirebaseMessaging.instance.unsubscribeFromTopic('TicketDbReset');
    await FirebaseMessaging.instance.unsubscribeFromTopic('userUpdates');
    var userId = AppUser.getUser()?.id;
    if (AppUser.getUser() != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('userUpdate_${userId}');
    }
  }
}
