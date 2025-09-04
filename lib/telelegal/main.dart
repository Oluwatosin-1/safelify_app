// import 'dart:async';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:safelify/telelegal/app_theme.dart';
// import 'package:safelify/telelegal/config.dart';
// import 'package:safelify/telelegal/locale/app_localizations.dart';
// import 'package:safelify/telelegal/locale/base_language_key.dart';
// import 'package:safelify/telelegal/locale/language_en.dart';
// import 'package:safelify/telelegal/model/language_model.dart';
// import 'package:safelify/telelegal/network/auth_repository.dart';
// import 'package:safelify/telelegal/screens/patient/store/patient_store.dart';
// import 'package:safelify/telelegal/screens/splash_screen.dart';
// import 'package:safelify/telelegal/store/AppStore.dart';
// import 'package:safelify/telelegal/store/AppointmentAppStore.dart';
// import 'package:safelify/telelegal/screens/doctor/store/DoctorAppStore.dart';
// import 'package:safelify/telelegal/store/ListAppStore.dart';
// import 'package:safelify/telelegal/store/MultiSelectStore.dart';
// import 'package:safelify/telelegal/screens/receptionist/store/ReceptionistAppStore.dart';
// import 'package:safelify/telelegal/store/PermissionStore.dart';
// import 'package:safelify/telelegal/store/ShopStore.dart';
// import 'package:safelify/telelegal/store/UserStore.dart';
// import 'package:safelify/telelegal/utils/colors.dart';
// import 'package:safelify/telelegal/utils/common.dart';
// import 'package:safelify/telelegal/utils/constants.dart';
// import 'package:safelify/telelegal/utils/push_notification_service.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'network/services/default_firebase_config.dart';
// import 'utils/app_common.dart';

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   log('${FirebaseMsgConst.notificationDataKey} : ${message.data}');
//   log('${FirebaseMsgConst.notificationKey} : ${message.notification}');
//   log('${FirebaseMsgConst.notificationTitleKey} : ${message.notification!.title}');
//   log('${FirebaseMsgConst.notificationBodyKey} : ${message.notification!.body}');
// }

// late PackageInfoData packageInfo;

// AppStore appStore = AppStore();
// PatientStore patientStore = PatientStore();
// ListAppStore listAppStore = ListAppStore();
// AppointmentAppStore appointmentAppStore = AppointmentAppStore();
// MultiSelectStore multiSelectStore = MultiSelectStore();
// DoctorAppStore doctorAppStore = DoctorAppStore();
// ReceptionistAppStore receptionistAppStore = ReceptionistAppStore();
// PermissionStore permissionStore = PermissionStore();
// ShopStore shopStore = ShopStore();

// UserStore userStore = UserStore();
// ListAnimationType listAnimationType = ListAnimationType.FadeIn;
// PageRouteAnimation pageAnimation = PageRouteAnimation.Fade;
// PageRouteAnimation signInAnimation = PageRouteAnimation.Scale;

// Duration pageAnimationDuration = const Duration(milliseconds: 500);

// List<String> paymentMethodList = [];
// List<String> paymentMethodImages = [];
// List<String> paymentModeList = [];

// BaseLanguage locale = LanguageEn();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions)
//       .then((value) {})
//       .then((value) async {
//     log('------FIREBASE INITIALIZATION COMPLETED-----------');
//     await PushNotificationService().initFirebaseMessaging();
//   }).catchError((e) {
//     log('------FIREBASE INITIALIZATION ERROR-----------\n${e.toString()}');
//   });

//   defaultBlurRadius = 0;
//   defaultSpreadRadius = 0.0;

//   defaultAppBarElevation = 2;
//   appBarBackgroundColorGlobal = primaryColor;
//   appButtonBackgroundColorGlobal = primaryColor;

//   defaultAppButtonTextColorGlobal = Colors.white;
//   defaultAppButtonElevation = 0.0;
//   passwordLengthGlobal = 5;
//   defaultRadius = 12;
//   defaultLoaderAccentColorGlobal = primaryColor;

//   await initialize(aLocaleLanguageList: languageList());

//   setupRemoteConfig().then((value) {
//     log('------FIREBASE REMOTE CONFIG COMPLETED-----------');
//   }).catchError((e) {
//     log('------FIREBASE REMOTE CONFIG ERROR-----------');
//   });

//   appStore.setLanguage(
//       getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));
//   appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

//   await defaultValue();

//   HttpOverrides.global = HttpOverridesSkipCertificate();

//   packageInfo = await getPackageInfo();

//   appStore.setAppVersion(packageInfo.versionName.validate());

//   int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
//   if (themeModeIndex == THEME_MODE_LIGHT) {
//     appStore.setDarkMode(false);
//   } else if (themeModeIndex == THEME_MODE_DARK) {
//     appStore.setDarkMode(true);
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     Connectivity().onConnectivityChanged.listen((event) {
//       appStore.setInternetStatus(!event.contains(ConnectivityResult.none));
//     });

//     removePermission();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Observer(
//       builder: (_) => MaterialApp(
//         title: APP_NAME,
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: appStore.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
//         debugShowCheckedModeBanner: false,
//         home: SplashScreen(),
//         navigatorKey: navigatorKey,
//         supportedLocales: Language.languagesLocale(),
//         localeResolutionCallback: (locale, supportedLocales) => locale,
//         locale: Locale(appStore.selectedLanguageCode),
//         localizationsDelegates: const [
//           AppLocalizations(),
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//         ],
//       ),
//     );
//   }
// }
