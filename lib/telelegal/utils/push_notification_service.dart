import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'common.dart';

class PushNotificationService {
  Future<void> initFirebaseMessaging() async {
    await FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    )
        .then((value) async {
      log('------Request Notification Permission COMPLETED-----------');
      if (value.authorizationStatus == AuthorizationStatus.authorized) {
        await registerNotificationListeners().then((value) {
          log('------Notification Listener REGISTRATION COMPLETED-----------');
        }).catchError((e) {
          log('------Notification Listener REGISTRATION ERROR-----------');
        });

        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);

        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
                alert: true, badge: true, sound: true)
            .then((value) {
          log('------setForegroundNotificationPresentationOptions COMPLETED-----------');
        }).catchError((e) {
          log('------setForegroundNotificationPresentationOptions ERROR-----------');
        });
        ;
      }
    }).catchError((e) {
      log('------Request Notification Permission ERROR-----------');
    });
    ;
  }

  Future<void> registerFCMAndTopics() async {
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        Future.delayed(const Duration(seconds: 3), () async {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        });
      }
      log("${FirebaseMsgConst.apnsNotificationTokenKey}\n$apnsToken");
    }
    FirebaseMessaging.instance.getToken().then((token) {
      log("${FirebaseMsgConst.fcmNotificationTokenKey}\n$token");
      subScribeToTopic();
    });
  }

  Future<void> subScribeToTopic() async {
    if (isDoctor()) {
      await FirebaseMessaging.instance
          .subscribeToTopic(
              "${FirebaseMsgConst.doctorWithUnderscoreKey}${userStore.userId}")
          .then((value) {
        log("${FirebaseMsgConst.topicSubscribed}${FirebaseMsgConst.doctorWithUnderscoreKey}${userStore.userId}");
      });
    } else if (isReceptionist()) {
      await FirebaseMessaging.instance
          .subscribeToTopic(
              "${FirebaseMsgConst.receptionistWithUnderscoreKey}${userStore.userId}")
          .then((value) {
        log("${FirebaseMsgConst.topicSubscribed}${FirebaseMsgConst.receptionistWithUnderscoreKey}${userStore.userId}");
      });
    } else {
      await FirebaseMessaging.instance
          .subscribeToTopic(
              "${FirebaseMsgConst.patientWithUnderscoreKey}${userStore.userId}")
          .then((value) {
        log("${FirebaseMsgConst.topicSubscribed}${FirebaseMsgConst.patientWithUnderscoreKey}${userStore.userId}");
      });
    }
  }

  Future<void> unsubscribeFirebaseTopic() async {
    if (isDoctor()) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(
              "${FirebaseMsgConst.doctorWithUnderscoreKey}${userStore.userId}")
          .then((value) {
        log("${FirebaseMsgConst.topicUnSubscribed}${FirebaseMsgConst.doctorWithUnderscoreKey}${userStore.userId}");
      });
    } else if (isReceptionist()) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(
              "${FirebaseMsgConst.receptionistWithUnderscoreKey}${userStore.userId}")
          .then((value) {
        log("${FirebaseMsgConst.topicUnSubscribed}${FirebaseMsgConst.receptionistWithUnderscoreKey}${userStore.userId}");
      });
    } else {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(
              "${FirebaseMsgConst.patientWithUnderscoreKey}${userStore.userId}")
          .then((value) {
        log("${FirebaseMsgConst.topicUnSubscribed}${FirebaseMsgConst.patientWithUnderscoreKey}${userStore.userId}");
      });
    }
  }

  void handleNotificationClick(RemoteMessage message,
      {bool isForeGround = false}) {
    printLogsNotificationData(message);

    if (isForeGround) {
      showNotification(
          currentTimeStamp(),
          message.notification!.title.validate(),
          message.notification!.body.validate(),
          message);
    } else {
      try {
        if (message.data.containsKey(FirebaseMsgConst.additionalDataKey)) {
          final additionalData =
              message.data[FirebaseMsgConst.additionalDataKey];
          if (message.data.containsKey(FirebaseMsgConst.idKey)) {
            int? notId = message.data[FirebaseMsgConst.idKey];
          }
        }
        if (isPatient()) patientStore.setBottomNavIndex(1);
        if (isDoctor()) doctorAppStore.setBottomNavIndex(1);
      } catch (e) {
        log('${FirebaseMsgConst.notificationErrorKey}: $e');
      }
    }
  }

  Future<void> registerNotificationListeners() async {
    FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        handleNotificationClick(message, isForeGround: true);
      }, onError: (e) {
        log("${FirebaseMsgConst.onMessageListen} $e");
      });

      // replacement for onResume: When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleNotificationClick(message);
      }, onError: (e) {
        log("${FirebaseMsgConst.onMessageOpened} $e");
      });

      // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
      FirebaseMessaging.instance.getInitialMessage().then(
          (RemoteMessage? message) {
        if (message != null) {
          handleNotificationClick(message);
        }
      }, onError: (e) {
        log("${FirebaseMsgConst.onGetInitialMessage} $e");
      });
    }).onError((error, stackTrace) {
      log("${FirebaseMsgConst.onGetInitialMessage} $error");
    });
  }

  void showNotification(
      int id, String title, String message, RemoteMessage remoteMessage) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    //code for background notification channel
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      FirebaseMsgConst.notificationChannelIdKey,
      FirebaseMsgConst.notificationChannelNameKey,
      importance: Importance.high,
      enableLights: true,
      playSound: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_onesignal_default');

    var iOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      // onDidReceiveLocalNotification: (id, title, body, payload) {
      //   handleNotificationClick(remoteMessage, isForeGround: true);
      // },
    );
    var macOS = iOS;

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: iOS, macOS: macOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      handleNotificationClick(remoteMessage);
    });

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        FirebaseMsgConst.notificationChannelIdKey,
        FirebaseMsgConst.notificationChannelNameKey,
        importance: Importance.high,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        playSound: true,
        priority: Priority.high,
        icon: '@drawable/ic_stat_onesignal_default',
        channelShowBadge: true,
        colorized: true);

    var darwinPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentSound: true,
      presentBanner: true,
      presentBadge: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );

    flutterLocalNotificationsPlugin.show(
        id, title, message, platformChannelSpecifics);
  }

  void printLogsNotificationData(RemoteMessage message) {
    log('${FirebaseMsgConst.notificationDataKey} : ${message.data}');
    log('${FirebaseMsgConst.notificationTitleKey} : ${message.notification!.title}');
    log('${FirebaseMsgConst.notificationBodyKey} : ${message.notification!.body}');
    log('${FirebaseMsgConst.messageDataCollapseKey} : ${message.collapseKey}');
    log('${FirebaseMsgConst.messageDataMessageIdKey} : ${message.messageId}');
    log('${FirebaseMsgConst.messageDataMessageTypeKey} : ${message.messageType}');
  }
}
