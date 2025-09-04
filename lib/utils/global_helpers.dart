import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/utils/colors.dart';

import '../config.dart';

void showMightySnackBar({required String message, Color color = primaryColor}) {
  if (Get.context != null) {
    Get.showSnackbar(GetSnackBar(
      snackPosition: SnackPosition.BOTTOM,
      message: message,
      duration: const Duration(seconds: 5),
      leftBarIndicatorColor: color,
      margin: const EdgeInsets.all(kdPadding),
    ));
  } else {
    log('Cannot show snackbar: Context is null. Message: $message');
  }
}

getLoading() {
  return const Center(
    // child: LoadingAnimationWidget.stretchedDots(
    //     color: primaryColor, size: 30),
  );
}

void printApiResponse(String text) {
  log('\x1B[33m$text\x1B[0m');
}

const stEmailKey = 'EmailKey';
const stPasswordKey = "PasswordKey";
const stMobileKey = "MobileKey";
const stUserData = "MobileKey";
storeAuthData(Map<String, dynamic> user) async {
  final box = GetStorage();
  await box.write(stUserData, jsonEncode(user));
}

Future<Map<String, dynamic>> getAuthDataFromLocalStorage() async {
  final box = GetStorage();
  // final fcmToken = await FirebaseMessaging.instance.getToken();

  printApiResponse("Local user :: ${box.read(stUserData)}");

  return jsonDecode(box.read(stUserData));
}

Future<bool> isFirstTimeLogin() async {
  var box = GetStorage('LoginContainer');

  String? isFirstTimeLogin = box.read('firstTimeLogin');
  printApiResponse("FIRST TIME LOGIN $isFirstTimeLogin");
  if (isFirstTimeLogin == null) {
    await box.write('firstTimeLogin', 'false');
    return true;
  }
  return false;
}
