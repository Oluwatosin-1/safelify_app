import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:safelify/app_theme.dart';
import 'package:safelify/config.dart';
import 'package:safelify/firebase_options.dart';
import 'package:safelify/locale/app_localizations.dart';
import 'package:safelify/locale/base_language_key.dart';
import 'package:safelify/locale/language_en.dart';
import 'package:safelify/model/language_model.dart';
import 'package:safelify/network/auth_repository.dart';
import 'package:safelify/screens/patient/store/patient_store.dart';
import 'package:safelify/screens/splash_screen.dart';
import 'package:safelify/store/AppStore.dart';
import 'package:safelify/store/AppointmentAppStore.dart';
import 'package:safelify/telelegal/store/AppointmentAppStore.dart' as tele2;
import 'package:safelify/screens/doctor/store/DoctorAppStore.dart';
import 'package:safelify/store/ListAppStore.dart';
import 'package:safelify/store/MultiSelectStore.dart';
import 'package:safelify/telelegal/store/MultiSelectStore.dart' as tele1;
import 'package:safelify/screens/receptionist/store/ReceptionistAppStore.dart';
import 'package:safelify/store/PermissionStore.dart';
import 'package:safelify/store/ShopStore.dart';
import 'package:safelify/store/UserStore.dart';
import 'package:safelify/telelegal/store/UserStore.dart' as tele;
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants.dart';
import 'package:safelify/utils/push_notification_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/comments_controller.dart';
import 'controllers/notifications_controller.dart';
import 'controllers/report_controller.dart';
import 'utils/app_common.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('${FirebaseMsgConst.notificationDataKey} : ${message.data}');
  log('${FirebaseMsgConst.notificationKey} : ${message.notification}');
  log('${FirebaseMsgConst.notificationTitleKey} : ${message.notification!.title}');
  log('${FirebaseMsgConst.notificationBodyKey} : ${message.notification!.body}');
}

late PackageInfoData packageInfo;

tele.UserStore userStore1 = tele.UserStore();
tele2.AppointmentAppStore appointmentAppStore1 = tele2.AppointmentAppStore();
tele1.MultiSelectStore multiSelectStore1 = tele1.MultiSelectStore();

AppStore appStore = AppStore();
PatientStore patientStore = PatientStore();
ListAppStore listAppStore = ListAppStore();
AppointmentAppStore appointmentAppStore = AppointmentAppStore();

MultiSelectStore multiSelectStore = MultiSelectStore();

DoctorAppStore doctorAppStore = DoctorAppStore();
ReceptionistAppStore receptionistAppStore = ReceptionistAppStore();
PermissionStore permissionStore = PermissionStore();
ShopStore shopStore = ShopStore();

UserStore userStore = UserStore();
ListAnimationType listAnimationType = ListAnimationType.FadeIn;
PageRouteAnimation pageAnimation = PageRouteAnimation.Fade;
PageRouteAnimation signInAnimation = PageRouteAnimation.Scale;

Duration pageAnimationDuration = const Duration(milliseconds: 500);

List<String> paymentMethodList = [];
List<String> paymentMethodImages = [];
List<String> paymentModeList = [];

BaseLanguage locale = LanguageEn();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    log('------FIREBASE INITIALIZATION COMPLETED-----------');
    PushNotificationService().initFirebaseMessaging();
  }).catchError((e) {
    log('------FIREBASE INITIALIZATION ERROR-----------\n${e.toString()}');
  });

  defaultBlurRadius = 0;
  defaultSpreadRadius = 0.0;
  defaultAppBarElevation = 2;
  appBarBackgroundColorGlobal = primaryColor;
  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  defaultAppButtonElevation = 0.0;
  passwordLengthGlobal = 5;
  defaultRadius = 12;
  defaultLoaderAccentColorGlobal = primaryColor;

  await initialize(aLocaleLanguageList: languageList());

  setupRemoteConfig().then((value) {
    log('------FIREBASE REMOTE CONFIG COMPLETED-----------');
  }).catchError((e) {
    log('------FIREBASE REMOTE CONFIG ERROR-----------');
  });

  appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  await defaultValue();

  HttpOverrides.global = HttpOverridesSkipCertificate();

  packageInfo = await getPackageInfo();
  Get.put(AppController());
  Get.put(AuthController());
  // Removed Get.put(EmergencyContactController());
  Get.put(ReportController());
  Get.put(CommentsController());
  Get.put(ChatController());
  Get.put(NotificationsController());

  appStore.setAppVersion(packageInfo.versionName.validate());

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == THEME_MODE_LIGHT) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == THEME_MODE_DARK) {
    appStore.setDarkMode(true);
  }
  Stripe.publishableKey =
  "pk_test_51NciUxEAe9tDkzIqH2WV5jSYAvYY2DlnxpXCMjOYtb0xP243b8qFizTVM2hd9EOAygiBZ4HAg9ctMyNbO4A1KjFS00aCasNzys";

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((event) {
      appStore.setInternetStatus(!event.contains(ConnectivityResult.none));
    });

    removePermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => GetMaterialApp(
        title: APP_NAME,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        navigatorKey: navigatorKey,
        supportedLocales: Language.languagesLocale(),
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode),
        localizationsDelegates: const [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}