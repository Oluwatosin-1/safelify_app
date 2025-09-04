import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/telelegal/components/app_bar_title_widget.dart';
import 'package:safelify/telelegal/components/dashboard_profile_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/screens/patient/fragments/patient_appointment_fragment.dart';
import 'package:safelify/telelegal/screens/patient/fragments/patient_dashboard_fragment.dart';
import 'package:safelify/telelegal/fragments/setting_fragment.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';

import '../../../../widgets/mighty_bottm_nav/fancy_bottom_navigation.dart';
import '../../patient/fragments/patient_consultation_screen.dart';

class PatientDashBoardScreen extends StatefulWidget {
  const PatientDashBoardScreen({super.key});

  @override
  _PatientDashBoardScreenState createState() => _PatientDashBoardScreenState();
}

class _PatientDashBoardScreenState extends State<PatientDashBoardScreen> {
  double iconSize = 24;

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
      PatientDashBoardFragment(),
      PatientAppointmentFragment(),
      const ConsultationListScreen(),
      SettingFragment(),
    ];
  }

  bool get showAppointment {
    return isVisible(SharedPreferenceKey.kiviCareAppointmentListKey);
  }

  bool get showDashboard {
    return isVisible(SharedPreferenceKey.kiviCareDashboardKey);
  }

  Future<bool> _onWillPop() async {
    // Check if the current index is not the first screen (index 0)
    if (patientStore.bottomNavIndex != 0) {
      // If not, set the bottomNavIndex to 0 (go to the first screen)
      setState(() {
        patientStore.setBottomNavIndex(0);
      });
      return false; // Prevent default back navigation
    } else {
      // If on the first screen, allow the default back navigation (exit)
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept the back press
      child: Observer(
        builder: (context) {
          if (patientStore.bottomNavIndex >= getScreens().length) {
            patientStore.setBottomNavIndex(getScreens().length - 1);
          }
          Color disableIconColor =
              appStore.isDarkModeOn ? Colors.white : secondaryTxtColor;
          return Scaffold(
            appBar: patientStore.bottomNavIndex != getScreens().length - 1
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
                      )
                    ],
                  )
                : null,
            body: getScreens()[patientStore.bottomNavIndex],
            bottomNavigationBar: MightyBottomNavigation(
              tabs: [
                if (showDashboard)
                  TabData(
                    iconData: Image.asset(ic_dashboard,
                        height: iconSize,
                        width: iconSize,
                        color: disableIconColor),
                    title: locale.lblDashboard,
                  ),
                if (showAppointment)
                  TabData(
                    iconData: Image.asset(ic_calendar,
                        height: iconSize,
                        width: iconSize,
                        color: disableIconColor),
                    title: locale.lblAppointments,
                  ),
                TabData(
                  iconData: Image.asset(ic_document,
                      height: iconSize,
                      width: iconSize,
                      color: disableIconColor),
                  title: locale.lblConsultation,
                ),
                TabData(
                  iconData: Image.asset(ic_more_item,
                      height: iconSize,
                      width: iconSize,
                      color: disableIconColor),
                  title: locale.lblSettings,
                ),
              ],
              onTabChangedListener: (index) {
                patientStore.setBottomNavIndex(index);
                setState(() {});
              },
              initialSelection: patientStore.bottomNavIndex,
            ),
          );
        },
      ),
    );
  }
}
