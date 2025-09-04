import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/screens/auth/screens/edit_profile_screen.dart';
import 'package:safelify/screens/dashboard/screens/doctor_dashboard_screen.dart';
import 'package:safelify/screens/dashboard/screens/patient_dashboard_screen.dart';
import 'package:safelify/screens/dashboard/screens/receptionist_dashboard_screen.dart';

import 'package:safelify/telelegal/screens/dashboard/screens/doctor_dashboard_screen.dart'
    as dashborad;
import 'package:safelify/telelegal/screens/dashboard/screens/patient_dashboard_screen.dart'
    as dashborad;
import 'package:safelify/telelegal/screens/dashboard/screens/receptionist_dashboard_screen.dart'
    as dashborad;
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants.dart';
import 'package:safelify/utils/images.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'components/cached_image_widget.dart';
import 'components/time_greeting_widget.dart';
import 'config.dart';
import 'controllers/app_controller.dart';
import 'main.dart';
import 'network/google_repository.dart';
import 'widgets/app_bar.dart';
import 'widgets/mighty_drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppController _appController = Get.find();
  bool _isLoading = false; // Add this to manage the loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MightyDrawer(),
      appBar: getAppBar(
        context: context,
        color: Colors.white,
        iconColor: primaryColor,
        title: Text(
          "Safelify",
          style: secondaryTextStyle(size: 16, color: primaryColor),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              EditProfileScreen().launch(context);
            },
            child: Container(
              decoration: boxDecorationDefault(
                color: context.primaryColor,
                border: Border.all(color: white, width: 4),
                shape: BoxShape.circle,
              ),
              padding: userStore.profileImage.validate().isNotEmpty
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 16),
              child: userStore.profileImage.validate().isNotEmpty
                  ? CachedImageWidget(
                      url: userStore.profileImage.validate(),
                      fit: BoxFit.cover,
                      height: 46,
                      width: 46,
                      circle: true,
                      alignment: Alignment.center,
                    )
                  : Image.asset(
                      ic_patient3,
                      fit: BoxFit.cover,
                      height: 46,
                      width: 46,
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Transform.scale(
                scale: 1,
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    height: 110, // Defined size
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(400, 100)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Container(
                    // Add a constrained container around the child widget
                    constraints: const BoxConstraints(
                        maxWidth: 300), // Set appropriate constraints
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset(ic_hi,
                                width: 22, height: 22, fit: BoxFit.cover),
                            const SizedBox(width: 8),
                            TimeGreetingWidget(
                              userName: isDoctor()
                                  ? userStore.firstName
                                      .validate()
                                      .prefixText(value: '')
                                  : userStore.firstName.validate(),
                              separator: ',',
                            ).expand(),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView(
                    padding: const EdgeInsets.symmetric(horizontal: kdPadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      _buildHomePageItem(
                        bgPath: 'assets/images/rect_red.png',
                        iconPath: 'assets/icons/strethoscope.png',
                        title: locale.lblMedicalService,
                        color: Colors.red,
                        onTap: () async {
                          setState(() {
                            _isLoading = true; // Show loading indicator
                          });

                          await getConfigurationAPI().whenComplete(() {
                            String userRole =
                                userStore.userRole?.toLowerCase() ?? '';
                            if (userRole == UserRoleDoctor.toLowerCase()) {
                              doctorAppStore.setBottomNavIndex(0);
                              toast(
                                  '${locale.lblLoginSuccessfullyAsADoctor}!! 🎉');
                              Get.to(() => const DoctorDashboardScreen(),
                                  transition: Transition.fade,
                                  duration: pageAnimationDuration);
                            } else if (userRole ==
                                UserRolePatient.toLowerCase()) {
                              toast(
                                  '${locale.lblLoginSuccessfullyAsAPatient}!! 🎉');
                              patientStore.setBottomNavIndex(0);
                              Get.to(() => const PatientDashBoardScreen(),
                                  transition: Transition.fade,
                                  duration: pageAnimationDuration);
                            } else if (userRole ==
                                UserRoleReceptionist.toLowerCase()) {
                              toast(
                                  '${locale.lblLoginSuccessfullyAsAReceptionist}!! 🎉');
                              receptionistAppStore.setBottomNavIndex(0);
                              Get.to(() => RDashBoardScreen(),
                                  transition: Transition.fade,
                                  duration: pageAnimationDuration);
                            } else {
                              toast(locale.lblWrongUser);
                            }
                          }).catchError((r) {
                            appStore.setLoading(false);
                            setState(() {
                              _isLoading =
                                  false; // Hide loading indicator on error
                            });
                            throw r;
                          }).whenComplete(() {
                            setState(() {
                              _isLoading =
                                  false; // Hide loading indicator when done
                            });
                          });
                        },
                      ),
                      _buildHomePageItem(
                        bgPath: 'assets/images/rect_yellow.png',
                        iconPath: 'assets/icons/balance.png',
                        color: const Color(0xffa56d51),
                        title: locale.lblLegalService,
                        onTap: () async {
                          setState(() {
                            _isLoading = true; // Show loading indicator
                          });
                          if (isDoctor()) {
                            Get.to(() => dashborad.DoctorDashboardScreen(),
                                transition: Transition.fade,
                                duration: pageAnimationDuration);
                          } else if (isPatient()) {
                            Get.to(
                                () => const dashborad.PatientDashBoardScreen(),
                                transition: Transition.fade,
                                duration: pageAnimationDuration);
                          } else {
                            Get.to(() => dashborad.RDashBoardScreen(),
                                transition: Transition.fade,
                                duration: pageAnimationDuration);
                          }
                          setState(() {
                            _isLoading =
                                false; // Hide loading indicator when done
                          });
                        },
                      ),
                      _buildHomePageItem(
                        bgPath: 'assets/images/rect_blue.png',
                        iconPath: 'assets/icons/plane.png',
                        title: locale.lblInternationalService,
                        color: Colors.blue,
                        onTap: () async {
                          launchUrlString(
                            "https://safelify.org/airport-concierge/",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      _buildHomePageItem(
                        bgPath: 'assets/images/rect_red.png',
                        color: Colors.red,
                        iconPath: 'assets/icons/consulting.png',
                        title: locale.lblEliteServices,
                        onTap: () async {
                          launchUrlString(
                            "https://elite.safelify.org",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ],
                  ),
                  GridView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 104, vertical: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      _buildHomePageItem(
                        bgPath: 'assets/images/rect_blue.png',
                        iconPath: 'assets/icons/shield.png',
                        color: const Color(0xff3f47cc),
                        title: locale.lblReportTip,
                        onTap: () {
                          _appController.currentBottomNavIndex.value = 1;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) // Show CircularProgressIndicator if _isLoading is true
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  _buildHomePageItem(
      {required String bgPath,
      required String iconPath,
      required String title,
      required Function() onTap,
      required Color color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: color != null
              ? [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 1,
                    spreadRadius: 2,
                  ),
                ]
              : [],
          border: color != null
              ? Border.all(width: 6, color: Colors.grey[200]!)
              : null,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 35,
              width: 35,
              color: Colors.white,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
