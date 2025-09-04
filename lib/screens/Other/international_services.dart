// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'popUp.dart';
// import '../home_page.dart';
//
// import '../../controllers/auth_controller.dart';
// import '../../utils/global_helpers.dart';
// import '../profile/profile_page.dart';
// import '../styles/styles.dart';
// import '../widgets/app_bar.dart';
// import '../widgets/mighty_button.dart';
//
// const InternationalServicesUpgradePrompt =
//     'To access this feature you will need to upgrade your account.\nYou you like to upgrade your account?';
//
// class InternationalServicesPage extends StatelessWidget {
//   InternationalServicesPage({super.key});
//
//   final AuthController _authController = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: getAppBar(
//         context: context,
//         color: Colors.white,
//         iconColor: primaryColor,
//         title: Text(
//           "Safelify",
//           style: Theme.of(context)
//               .textTheme
//               .displayMedium
//               ?.copyWith(color: primaryColor),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () => Get.to(() => ProfilePage()),
//             icon: Icon(LineIcons.user),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Transform.scale(
//             scale: 1,
//             child: Transform.translate(
//               offset: Offset(0, -40),
//               child: Container(
//                 height: 110,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.all(Radius.elliptical(400, 100)),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: GridView(
//               padding: EdgeInsets.symmetric(horizontal: kdPadding),
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//               children: [
//                 _buildHomePageItem(
//                   bgPath: 'assets/images/rect_blue.png',
//                   iconPath: 'assets/icons/plane.png',
//                   title: 'Airport Protocol\nConcierge',
//                   onTap: () {
//                     // _appController.currentBottomNavIndex.value = 1;
//                     // _showRequestHelpDialogue(
//                     //     context: context, requestType: "Airport Protocol");
//
//                     launchUrlString(
//                       "https://safelify.org/airport-concierge/",
//                       mode: LaunchMode.externalApplication,
//                     );
//                   },
//                 ),
//                 _buildHomePageItem(
//                   bgPath: 'assets/images/rect_red.png',
//                   iconPath: 'assets/icons/consulting.png',
//                   title: 'Elite Services',
//                   onTap: () {
//                     launchUrlString(
//                       "https://safelify.org/elite-services/",
//                       mode: LaunchMode.externalApplication,
//                     );
//                     // _appController.currentBottomNavIndex.value = 1;
//                     // _showRequestHelpDialogue(
//                     //     context: context, requestType: "Car Rental");
//                   },
//                 ),
//                 // _buildHomePageItem(
//                 //   bgPath: 'assets/images/rect_green.png',
//                 //   iconPath: 'assets/icons/driver.png',
//                 //   title: 'Dedicated\nDriver Only',
//                 //   onTap: () {
//                 //     // _appController.currentBottomNavIndex.value = 1;
//                 //     _showRequestHelpDialogue(
//                 //         context: context, requestType: "Driver Only");
//                 //   },
//                 // ),
//                 _buildHomePageItem(
//                   bgPath: 'assets/images/rect_yellow.png',
//                   iconPath: 'assets/icons/balance.png',
//                   title: 'Tele-Legal',
//                   color: Color(0xffa56d51),
//                   onTap: () {
//                     launchUrlString(
//                       "https://telelegal.safelify.org",
//                       mode: LaunchMode.externalApplication,
//                     );
//                     // _appController.currentBottomNavIndex.value = 1;
//                     // _showRequestHelpDialogue(
//                     //     context: context, requestType: "Airport Protocol");
//                   },
//                 ),
//                 _buildHomePageItem(
//                   bgPath: 'assets/images/rect_green.png',
//                   iconPath: 'assets/icons/strethoscope.png',
//                   title: 'Tele-health',
//                   onTap: () {
//                     launchUrlString(
//                       "https://telehealthportal.safelify.org/",
//                       mode: LaunchMode.externalApplication,
//                     );
//                     // _appController.currentBottomNavIndex.value = 1;
//                     // _showRequestHelpDialogue(
//                     //     context: context, requestType: "Tele-health");
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   _buildHomePageItem({
//     required String bgPath,
//     required String iconPath,
//     required String title,
//     required Function() onTap,
//     Color? color,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           image: color == null
//               ? DecorationImage(
//                   image: AssetImage(bgPath),
//                   colorFilter: color != null
//                       ? ColorFilter.mode(color, BlendMode.multiply)
//                       : null,
//                   fit: BoxFit.cover,
//                 )
//               : null,
//           color: color,
//           boxShadow: color != null
//               ? [
//                   BoxShadow(
//                     color: Colors.grey[300]!,
//                     blurRadius: 1,
//                     spreadRadius: 2,
//                   ),
//                 ]
//               : [],
//           border: color != null
//               ? Border.all(width: 9, color: Colors.grey[200]!)
//               : null,
//         ),
//         child: Column(
//           // crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               iconPath,
//               height: 35,
//               width: 35,
//               color: Colors.white,
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               title,
//               style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                   color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   _showRequestHelpDialogue(
//       {required BuildContext context, required String requestType}) async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return MightyPopupDialogue(
//           content: [
//             Container(
//               padding: EdgeInsets.all(kdPadding),
//               alignment: Alignment.center,
//               child: GestureDetector(
//                 onTap: () => Get.back(),
//                 child: CircleAvatar(
//                   backgroundColor: primaryColor,
//                   child: Icon(Icons.clear_rounded, color: Colors.white),
//                 ),
//               ),
//             ),
//             // Text("On Your Action"),
//             Text(
//               "Please confirm if you would like to make a reservation.",
//               textAlign: TextAlign.center,
//             ),
//             Padding(
//               padding:
//                   EdgeInsets.symmetric(vertical: kdPadding, horizontal: 12),
//               child: Obx(() {
//                 return _authController.isRequestingHelp.value
//                     ? getLoading()
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: MightyButton(
//                               text: 'Get In Touch',
//                               onTap: () async {
//                                 if (await confirmed(context,
//                                     "Are you sure you want to make reservation?")) {
//                                   _authController.requestHelp(
//                                       requestType: requestType,
//                                       description: 'send help',
//                                       successMessage: "Request received.");
//                                 }
//                                 // if (Get.find<PermissionsController>()
//                                 //     .canAccessInternationalServices()) {
//                                 //   if (await confirmed(context,
//                                 //       "Are you sure you want to make reservation?")) {
//                                 //     _authController.requestHelp(
//                                 //         requestType: requestType,
//                                 //         description: 'send help',
//                                 //         successMessage: "Request received.");
//                                 //   }
//                                 // } else {
//                                 //   showUpgradeAccountDialogue(context,
//                                 //       InternationalServicesUpgradePrompt);
//                                 // }
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//               }),
//             )
//           ],
//         );
//       },
//     );
//   }
// }
