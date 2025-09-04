import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelify/main.dart';
import 'package:safelify/screens/Other/emergency_contact_page.dart';
import 'package:safelify/screens/Other/report_page.dart';
import 'package:safelify/screens/Other/safelify_reports_page.dart';
import 'package:safelify/utils/colors.dart';

import '../controllers/app_controller.dart';
import 'home_page.dart';
import 'widgets/mighty_bottm_nav/fancy_bottom_navigation.dart';

class MainPage extends StatelessWidget {
  final AppController _appController = Get.find();

  final tabs = [
    HomePage(),
    const ReportPage(),
    const SafeLifyReports(),
    EmergencyContactPage()
  ];

  MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: tabs[_appController.currentBottomNavIndex.value],
        extendBody: true,
        bottomNavigationBar: Obx(() {
          return MightyBottomNavigation(
            initialSelection: _appController.currentBottomNavIndex.value,
            tabs: [
              TabData(
                iconData: Image.asset(
                  'assets/icons/home.png',
                  height: 25,
                  width: 25,
                ),
                title: locale.lblHome,
              ),
              TabData(
                iconData: Image.asset(
                  'assets/icons/report.png',
                  height: 25,
                  width: 25,
                ),
                title: locale.lblReport,
              ),
              TabData(
                iconData: Image.asset(
                  'assets/icons/community.png',
                  color: Colors.black54,
                  height: 25,
                  width: 25,
                ),
                title: locale.lblCommunity,
              ),
              TabData(
                iconData: Image.asset(
                  'assets/icons/user_shield.png',
                  height: 25,
                  width: 25,
                ),
                title: locale.lblContact,
              ),
            ],
            inactiveIconColor: Colors.black54,
            circleColor: primaryColor,
            activeIconColor: Colors.white,
            onTabChangedListener: (position) {
              _appController.currentBottomNavIndex.value = position;
              // _appController.currentBottomNavIndex.refresh();
            },
          );
        }),
      );
    });
  }
}
