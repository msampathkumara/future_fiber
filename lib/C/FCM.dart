import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartwind/M/AppUser.dart';

import '../globals.dart';
import 'DB/hive.dart';

class FCM {
  static StreamSubscription<RemoteMessage>? subscription;

  static int? get userId => AppUser.getUser()?.id;

  static subscribe() async {
    FirebaseMessaging.instance.subscribeToTopic('${appFlavor}_ticketDelete');
    FirebaseMessaging.instance.subscribeToTopic('${appFlavor}_ticketComplete');
    FirebaseMessaging.instance.subscribeToTopic('${appFlavor}_file_update');
    FirebaseMessaging.instance.subscribeToTopic('${appFlavor}_TicketDbReset');
    FirebaseMessaging.instance.subscribeToTopic('${appFlavor}_userUpdates');
    FirebaseMessaging.instance.subscribeToTopic('${appFlavor}_resetDb');

    var userId = AppUser.getUser()?.id;
    if (AppUser.getUser() != null) {
      FirebaseMessaging.instance.subscribeToTopic('${appFlavor}_userUpdate_$userId');
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

      if (message.from == "/topics/${appFlavor}_userUpdate_$userId") {
        AppUser.refreshUserData();
      } else if (message.from == "/topics/${appFlavor}_ticketComplete") {
        if (message.data["ticketId"] != null) {
          await HiveBox.deleteTicket(message.data["ticketId"]);
        }
        HiveBox.getDataFromServer();
      } else if (message.from == "/topics/${appFlavor}_resetDb") {
        HiveBox.getDataFromServer(clean: true);
        print('--------------------------RESEING DATABASE-----------------');
      } else if (message.from == "/topics/${appFlavor}_userUpdates") {
        HiveBox.getDataFromServer();
        print('--------------------------UPDATING USER DATABASE-----------------');
      } else if (message.from == "/topics/${appFlavor}_file_update") {
        print('file_update ====================================================================== >>> ');

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
    await FirebaseMessaging.instance.unsubscribeFromTopic('${appFlavor}_ticketDelete');
    await FirebaseMessaging.instance.unsubscribeFromTopic('${appFlavor}_ticketComplete');
    await FirebaseMessaging.instance.unsubscribeFromTopic('${appFlavor}_file_update');
    await FirebaseMessaging.instance.unsubscribeFromTopic('${appFlavor}_TicketDbReset');
    await FirebaseMessaging.instance.unsubscribeFromTopic('${appFlavor}_userUpdates');
    var userId = AppUser.getUser()?.id;
    if (AppUser.getUser() != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('${appFlavor}_userUpdate_$userId');
    }
  }
}
