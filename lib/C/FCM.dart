import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartwind/M/AppUser.dart';

import 'DB/hive.dart';

class FCM {
  static StreamSubscription<RemoteMessage>? subscription;

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
      FirebaseMessaging.instance.subscribeToTopic('userUpdate_$userId');
    }
  }

  static setListener(context) {
    subscribe();

    if (subscription != null) {
      subscription?.cancel();
    }

    subscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("---------------- FCM ------------------");
      print(message.from);
      print(message.messageId);
      if (message.from == "/topics/userUpdate_$userId") {
        AppUser.refreshUserData();
      } else if (message.from == "/topics/ticketComplete") {
        if (message.data["ticketId"] != null) {
          await HiveBox.deleteTicket(message.data["ticketId"]);
        }

        HiveBox.getDataFromServer();
      } else if (message.from == "/topics/resetDb") {
        HiveBox.getDataFromServer(clean: true);
        print('--------------------------RESEING DATABASE-----------------');
      } else if (message.from == "/topics/userUpdates") {
        HiveBox.getDataFromServer();
        print('--------------------------UPDATING USER DATABASE-----------------');
      } else if (message.from == "/topics/file_update") {
        if (message.data["standardLibrary"] != null) {
          print('--------------------------standardLibrary-----------------');
          if (message.data["delete"] != null) {
            print('--------------------------delete-----------------');
            // await HiveBox.cleanStandardLibrary();
            HiveBox.getDataFromServer();
          }
        }
        HiveBox.getDataFromServer();
        print('--------------------------UPDATING DATABASE-----------------');
      } else if (message.data["updateTicketDB"] != null) {
        HiveBox.getDataFromServer();
        print('--------------------------RESEING DATABASE-----------------');
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
      await FirebaseMessaging.instance.unsubscribeFromTopic('userUpdate_$userId');
    }
  }
}
