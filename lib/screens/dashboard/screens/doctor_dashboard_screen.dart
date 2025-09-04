import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/components/app_bar_title_widget.dart';
import 'package:safelify/components/dashboard_profile_widget.dart';
import 'package:safelify/screens/doctor/fragments/dashboard_fragment.dart';
import 'package:safelify/screens/doctor/fragments/appointment_fragment.dart';
import 'package:safelify/screens/dashboard/fragments/patient_list_fragment.dart';
import 'package:safelify/fragments/setting_fragment.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/extensions/string_extensions.dart';
import 'package:safelify/utils/extensions/widget_extentions.dart';
import 'package:safelify/utils/images.dart';
import 'package:safelify/widgets/mighty_bottm_nav/fancy_bottom_navigation.dart'; // Import MightyBottomNavigation

import '../../../controllers/app_controller.dart';
import '../../../main.dart';
import '../../../utils/constants.dart'; // Assuming GetX Controller is being used

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final AppController _appController =
      Get.find(); // For managing state using GetX
  int currentTabIndex = 0; // To manage tab index locally

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

  List<Widget> getScreens() {
    return [
      DashboardFragment(),
      AppointmentFragment(),
      PatientListFragment(),
      SettingFragment(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: currentTabIndex != getScreens().length - 1
            ? appBarWidget(
                '',
                titleWidget: const AppBarTitleWidget(),
                showBack: false,
                color: context.scaffoldBackgroundColor,
                elevation: 0,
                systemUiOverlayStyle: defaultSystemUiOverlayStyle(
                  context,
                  color: appStore.isDarkModeOn
                      ? context.scaffoldBackgroundColor
                      : appPrimaryColor.withOpacity(0.02),
                  statusBarIconBrightness: appStore.isDarkModeOn
                      ? Brightness.light
                      : Brightness.dark,
                ),
                actions: [
                  ic_shop
                      .iconImageColored(size: 28)
                      .paddingAll(14)
                      .appOnTap(() {
                    // Handle action
                  }).visible(appStore.wcNonce.validate().isNotEmpty),
                  DashboardTopProfileWidget(
                    refreshCallback: () => setState(() {}),
                  )
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
                title: "Dashboard",
              ),
              TabData(
                iconData: Image.asset(
                  ic_calendar,
                  height: 25,
                  width: 25,
                ),
                title: "Appointments",
              ),
              TabData(
                iconData: Image.asset(
                  ic_patient,
                  height: 25,
                  width: 25,
                ),
                title: "Patients",
              ),
              TabData(
                iconData: Image.asset(
                  ic_more_item,
                  height: 25,
                  width: 25,
                ),
                title: "Settings",
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
    });
  }
}
