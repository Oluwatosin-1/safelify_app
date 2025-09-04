import 'package:flutter/material.dart';
import 'package:safelify/telelegal/components/app_logo.dart';
import 'package:safelify/telelegal/config.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/network/google_repository.dart';
import 'package:safelify/telelegal/network/network_utils.dart';
import 'package:safelify/screens/auth/screens/sign_in_screen.dart';
import 'package:safelify/telelegal/screens/dashboard/screens/doctor_dashboard_screen.dart';
import 'package:safelify/telelegal/screens/dashboard/screens/patient_dashboard_screen.dart';
import 'package:safelify/telelegal/screens/dashboard/screens/receptionist_dashboard_screen.dart';
import 'package:safelify/telelegal/screens/walkThrough/walk_through_screen.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/constants/app_constants.dart';
import 'package:safelify/telelegal/utils/constants/woocommerce_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    afterBuildCreated(() {
      int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.dark);
      }
      setStatusBarColor(
        appStore.isDarkModeOn
            ? context.scaffoldBackgroundColor
            : appPrimaryColor.withOpacity(0.02),
        statusBarIconBrightness:
            appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
      );
    });

    await 2.seconds.delay;
    checkIsAppInReview();

    if (!getBoolAsync(IS_WALKTHROUGH_FIRST, defaultValue: false)) {
      WalkThroughScreen().launch(context,
          isNewTask: true,
          pageRouteAnimation: pageAnimation,
          duration: pageAnimationDuration); // User is for first time.
    } else {
      if (appStore.isLoggedIn) {
        shopStore.setCartCount(getIntAsync(
            '${CartKeys.cartItemCountKey} of ${userStore.userName}'));
        getConfigurationAPI().then((v) {
          if (isDoctor()) {
            DoctorDashboardScreen().launch(context,
                isNewTask: true,
                pageRouteAnimation: signInAnimation,
                duration: pageAnimationDuration); // User is Doctor
          } else if (isPatient()) {
            PatientDashBoardScreen().launch(context,
                isNewTask: true,
                pageRouteAnimation: signInAnimation,
                duration: pageAnimationDuration); // User is Patient
          } else {
            RDashBoardScreen().launch(context,
                isNewTask: true,
                pageRouteAnimation: signInAnimation,
                duration: pageAnimationDuration); // User is Receptionist
          }
        }).catchError((r) {
          appStore.setLoading(false);

          throw r;
        });
      } else {
        SignInScreen().launch(context,
            isNewTask: true,
            pageRouteAnimation: pageAnimation,
            duration: pageAnimationDuration);
      }
    }
  }

  Future<void> checkIsAppInReview() async {
    await setupFirebaseRemoteConfig().then((remoteConfig) async {
      if (isIOS) {
        await setValue(AppKeys.hasInReviewKey,
            remoteConfig.getBool(AppKeys.hasInReviewAppStore),
            print: true);
      } else if (isAndroid) {
        await setValue(AppKeys.hasInReviewKey,
            remoteConfig.getBool(AppKeys.hasInReviewPlayStore),
            print: true);
      }
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppLogo(size: 125).center(),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('v ${packageInfo.versionName.validate()}',
                    style: secondaryTextStyle(size: 16),
                    textAlign: TextAlign.center),
                8.height,
                Text(COPY_RIGHT_TEXT,
                    style: secondaryTextStyle(size: 12),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
