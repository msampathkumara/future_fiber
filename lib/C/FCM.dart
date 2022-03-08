import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/hive.dart';

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
        HiveBox.getDataFromServer();
      } else if (message.from == "/topics/resetDb") {
        HiveBox.getDataFromServer(clean: true);
        print('--------------------------RESEING DATABASE-----------------');
      } else if (message.from == "/topics/userUpdates") {
        HiveBox.getDataFromServer();
        print('--------------------------UPDATING USER DATABASE-----------------');
      } else if (message.from == "/topics/file_update") {
        HiveBox.getDataFromServer();
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
      await FirebaseMessaging.instance.unsubscribeFromTopic('userUpdate_${userId}');
    }
  }
}
