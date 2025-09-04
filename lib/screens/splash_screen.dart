import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:safelify/components/app_logo.dart';
import 'package:safelify/config.dart';
import 'package:safelify/main.dart';
import 'package:safelify/main_page.dart';
import 'package:safelify/network/google_repository.dart';
import 'package:safelify/network/network_utils.dart';
import 'package:safelify/screens/auth/screens/sign_in_screen.dart';
import 'package:safelify/screens/walkThrough/walk_through_screen.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants.dart';
import 'package:safelify/utils/constants/app_constants.dart';
import 'package:safelify/utils/constants/woocommerce_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
      if (themeModeIndex == THEME_MODE_SYSTEM) { // Fixed typo: THEME_MODE_SaYSTEM -> THEME_MODE_SYSTEM
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
      }
      setStatusBarColor(
        appStore.isDarkModeOn ? context.scaffoldBackgroundColor : appPrimaryColor.withOpacity(0.02),
        statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
      );
    });

    try {
      // Removed premature instantiation of EmergencyContactController
      // It will be instantiated lazily when EmergencyContactPage is accessed

      await Future.delayed(const Duration(seconds: 2));

      await checkIsAppInReview();

      if (!getBoolAsync(IS_WALKTHROUGH_FIRST, defaultValue: false)) {
        await WalkThroughScreen().launch(
          context,
          isNewTask: true,
          pageRouteAnimation: pageAnimation,
          duration: pageAnimationDuration,
        );
      } else if (appStore.isLoggedIn) {
        try {
          shopStore.setCartCount(getIntAsync('${CartKeys.cartItemCountKey} of ${userStore.userName}'));
          await getConfigurationAPI().timeout(const Duration(seconds: 10));

          if (isDoctor()) {
            await MainPage().launch(
              context,
              isNewTask: true,
              pageRouteAnimation: signInAnimation,
              duration: pageAnimationDuration,
            );
          } else if (isPatient()) {
            await MainPage().launch(
              context,
              isNewTask: true,
              pageRouteAnimation: signInAnimation,
              duration: pageAnimationDuration,
            );
          } else {
            await MainPage().launch(
              context,
              isNewTask: true,
              pageRouteAnimation: signInAnimation,
              duration: pageAnimationDuration,
            );
          }
        } catch (e) {
          log('Configuration error: $e');
          if (Get.context != null) {
            toast('Failed to fetch configuration. Please sign in.');
          }
          await const SignInScreen().launch(
            context,
            isNewTask: true,
            pageRouteAnimation: pageAnimation,
            duration: pageAnimationDuration,
          );
        }
      } else {
        await const SignInScreen().launch(
          context,
          isNewTask: true,
          pageRouteAnimation: pageAnimation,
          duration: pageAnimationDuration,
        );
      }
    } catch (e) {
      log('SplashScreen init error: $e');
      if (Get.context != null) {
        toast('An error occurred. Please try again.');
      }
      await const SignInScreen().launch(
        context,
        isNewTask: true,
        pageRouteAnimation: pageAnimation,
        duration: pageAnimationDuration,
      );
    }
  }

  Future<void> checkIsAppInReview() async {
    try {
      final remoteConfig = await setupFirebaseRemoteConfig().timeout(const Duration(seconds: 10));
      if (isIOS) {
        await setValue(AppKeys.hasInReviewKey, remoteConfig.getBool(AppKeys.hasInReviewAppStore));
      } else if (isAndroid) {
        await setValue(AppKeys.hasInReviewKey, remoteConfig.getBool(AppKeys.hasInReviewPlayStore));
      }
    } catch (e) {
      log('checkIsAppInReview error: $e');
      if (Get.context != null) {
        toast('Failed to check app review status: $e');
      }
    }
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
                Text('v ${packageInfo.versionName.validate()}', style: secondaryTextStyle(size: 16), textAlign: TextAlign.center),
                8.height,
                Text(COPY_RIGHT_TEXT, style: secondaryTextStyle(size: 12), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}