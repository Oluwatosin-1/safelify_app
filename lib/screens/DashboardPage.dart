// // lib/pages/dashboard_page.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:safelify/screens/doctor/doctor_dashboard_screen.dart';
// import 'package:safelify/screens/patient/p_dashboard_screen.dart';
// import '../controllers/app_controller.dart';
// import '../main.dart';
// import '../utils/constants.dart';
// import '../utils/enums.dart';
//
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final AppController appController = Get.find<AppController>();
//
//     // Add a small delay to ensure that the widget is fully built
//     Future.delayed(Duration.zero, () {
//       String? userRole = appStore.userRole;
//       AppType appType = appController.appType.value; // Use the common AppType
//
//       if (userRole != null) {
//         if (userRole.toLowerCase() == UserRoleDoctor.toLowerCase()) {
//           Get.to(() => const DoctorDashboardScreen(), transition: Transition.rightToLeft);
//         } else if (userRole.toLowerCase() == UserRolePatient.toLowerCase()) {
//           Get.to(() => const PatientDashBoardScreen(), transition: Transition.rightToLeft);
//         } else {
//           Get.snackbar("Error", "Role not recognized");
//         }
//       } else {
//         Get.snackbar("Error", "User role is not set");
//       }
//     });
//
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(), // Show loading indicator while determining role
//       ),
//     );
//   }
// }
