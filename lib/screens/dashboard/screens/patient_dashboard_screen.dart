import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelify/components/app_bar_title_widget.dart';
import 'package:safelify/components/dashboard_profile_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/screens/patient/fragments/patient_appointment_fragment.dart';
import 'package:safelify/screens/patient/fragments/patient_dashboard_fragment.dart';
import 'package:safelify/screens/patient/fragments/patient_encounter_fragments.dart';
import 'package:safelify/fragments/setting_fragment.dart';
import 'package:safelify/screens/woocommerce/screens/product_list_screen.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/constants.dart';
import 'package:safelify/utils/images.dart';
import 'package:safelify/utils/extensions/string_extensions.dart';
import 'package:safelify/utils/extensions/widget_extentions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../controllers/app_controller.dart';
import '../../../widgets/mighty_bottm_nav/fancy_bottom_navigation.dart'; // Assuming this is the correct import

class PatientDashBoardScreen extends StatefulWidget {
  const PatientDashBoardScreen({super.key});

  @override
  _PatientDashBoardScreenState createState() => _PatientDashBoardScreenState();
}

class _PatientDashBoardScreenState extends State<PatientDashBoardScreen> {
  final AppController _appController =
      Get.find(); // Assuming you're using GetX for app state management

  List<Widget> getScreens() {
    return [
      const PatientDashBoardFragment(),
      PatientAppointmentFragment(),
      const EncounterFragment(),
      SettingFragment(),
    ];
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    afterBuildCreated(() {
      View.of(context).platformDispatcher.onPlatformBrightnessChanged = () {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(
              MediaQuery.of(context).platformBrightness == Brightness.light);
        }
      };
    });
  }

  Future<bool> _onWillPop() async {
    // Check if the current index is not the first screen (index 0)
    if (_appController.currentBottomNavIndex.value != 0) {
      _appController.currentBottomNavIndex.value = 0;
      return false; // Prevent default back navigation
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept the back press
      child: Obx(() {
        return Scaffold(
          appBar: _appController.currentBottomNavIndex.value !=
                  getScreens().length - 1
              ? appBarWidget(
                  '',
                  titleWidget: const AppBarTitleWidget(),
                  showBack: true,
                  color: context.scaffoldBackgroundColor,
                  elevation: 0,
                  systemUiOverlayStyle: defaultSystemUiOverlayStyle(context,
                      color: appStore.isDarkModeOn
                          ? context.scaffoldBackgroundColor
                          : appPrimaryColor.withOpacity(0.02),
                      statusBarIconBrightness: appStore.isDarkModeOn
                          ? Brightness.light
                          : Brightness.dark),
                  actions: [
                    DashboardTopProfileWidget(
                      refreshCallback: () => setState(() {}),
                    ),
                  ],
                )
              : null,
          body: getScreens()[_appController.currentBottomNavIndex.value],
          bottomNavigationBar: Obx(() {
            return MightyBottomNavigation(
              initialSelection: _appController.currentBottomNavIndex.value,
              tabs: [
                TabData(
                  iconData: Image.asset(
                    ic_dashboard,
                    height: 25,
                    width: 25,
                  ),
                  title: locale.lblDashboard,
                ),
                TabData(
                  iconData: Image.asset(
                    ic_calendar,
                    height: 25,
                    width: 25,
                  ),
                  title: locale.lblAppointments,
                ),
                TabData(
                  iconData: Image.asset(
                    ic_document,
                    height: 25,
                    width: 25,
                  ),
                  title: locale.lblEncounter,
                ),
                TabData(
                  iconData: Image.asset(
                    ic_more_item,
                    height: 25,
                    width: 25,
                  ),
                  title: locale.lblSettings,
                ),
              ],
              inactiveIconColor: Colors.black54,
              circleColor: primaryColor,
              activeIconColor: Colors.white,
              onTabChangedListener: (position) {
                _appController.currentBottomNavIndex.value = position;
                setState(() {});
              },
            );
          }),
        );
      }),
    );
  }
}
