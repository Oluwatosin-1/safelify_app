import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelify/main.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/app_controller.dart';
import '../screens/Other/admin_contacts_page.dart';
import '../../utils/colors.dart';

class MightyDrawer extends StatelessWidget {
  MightyDrawer({super.key});

  final AppController _appController = Get.find();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      elevation: 5,
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 22.0,
              left: 22.0,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/icons/safe_life_text.png"),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const CircleAvatar(
                    backgroundColor: primaryColor,
                    radius: 15,
                    child: Center(
                      child: Icon(
                        Icons.clear,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          DrawerItem(
            image: 'assets/icons/home.png',
            title: locale.lblHome,
            isSelected: _appController.currentBottomNavIndex.value == 0,
            onTap: () {
              _appController.currentBottomNavIndex.value = 0;
              Get.back();
            },
          ),
          const SizedBox(height: 20),
          DrawerItem(
            image: 'assets/icons/report.png',
            title: locale.lblReport,
            isSelected: _appController.currentBottomNavIndex.value == 1,
            onTap: () {
              _appController.currentBottomNavIndex.value = 1;
              Get.back();
            },
          ),
          const SizedBox(height: 20),
          DrawerItem(
            image: 'assets/icons/workplace.png',
            title: locale.lblNationalDirectories,
            isSelected: false,
            onTap: () {
              Get.to(() => const AdminContactsPage(contactType: 'directories'));
              Get.back();
            },
          ),
          const SizedBox(height: 20),
          DrawerItem(
            image: 'assets/icons/contact.png',
            title: locale.lblContactUs,
            isSelected: false,
            onTap: () {
              const email = 'admin@safelify.org';
              const subject = 'Customer Support';
              const body = 'Hello, I would like to inquire about...';
              final emailUrl =
                  'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
              launchUrlString(emailUrl);
              Get.back();
            },
          ),
          const SizedBox(height: 20),
          DrawerItem(
            image: 'assets/icons/delete.png',
            title: locale.lblDeleteAccount,
            isSelected: false,
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Delete Account"),
                  content: const Text("Are you sure you want to delete your account?"),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _authController.deleteAccount();
                      },
                      child: const Text("Yes, Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          DrawerItem(
            image: 'assets/icons/power.png',
            title: locale.lblLogOut,
            isSelected: false,
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _authController.signOut(context);
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    Key? key,
    required this.image,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.icon,
  }) : super(key: key);

  final String image;
  final String title;
  final bool isSelected;
  final Widget? icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 50),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 4),
              icon ??
                  Image.asset(
                    image,
                    width: 20,
                    height: 20,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}