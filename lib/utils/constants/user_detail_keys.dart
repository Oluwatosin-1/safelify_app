import 'dart:convert';

import 'package:safelify/model/user_model.dart';
import 'package:nb_utils/nb_utils.dart';

class UserDetailKeys {
  static const String consumerKey = 'Consumer Key';

  static const String consumerSecretKey = 'Consumer Secret Key';
  static const String userIdKey = 'User Id';
  static const String userNameKey = 'User Name';
  static const String userPasswordKey = 'Password';
  static const String firstNameKey = "First Name";
  static const String lastNameKey = "Last Name";
  static const String displayNameKey = "Display Name";
  static const String emailKey = "Email";
  static const String userDOBKey = 'Date Of Birth';
  static const String userLoginKey = "User Login";
  static const String userContactNoKey = 'Contact Number';
  static const String userGenderKey = 'Gender';
  static const String userClinicKey = 'User Clinic';
  static const String userProfileImageKey = 'User Profile Image';
  static const String userClinicAddress = 'User Clinic Address';
  static const String userClinicStatusKey = 'User Clinic Status';

  static saveUserData(UserModel userData) {
    setValue(userIdKey, userData.userId, print: true);
    setValue(userNameKey, userData.userName, print: true);
    setValue(firstNameKey, userData.firstName, print: true);
    setValue(lastNameKey, userData.lastName, print: true);
    setValue(displayNameKey, userData.displayName, print: true);
    setValue(emailKey, userData.userEmail, print: true);
    setValue(userDOBKey, userData.dob, print: true);
    setValue(userLoginKey, userData.userLogin, print: true);
    setValue(userContactNoKey, userData.mobileNumber, print: true);
    setValue(userGenderKey, userData.gender, print: true);
    setValue(userClinicKey, jsonEncode(userData.clinic.validate().map((e) => e.toJson()).toList()), print: true);
    setValue(userProfileImageKey, userData.profileImage, print: true);
  }

  static removeUserDetailKey() {
    removeKey(userIdKey);
    removeKey(userNameKey);
    removeKey(userPasswordKey);
    removeKey(firstNameKey);
    removeKey(lastNameKey);
    removeKey(displayNameKey);
    removeKey(emailKey);
    removeKey(userDOBKey);
    removeKey(userLoginKey);
    removeKey(userContactNoKey);
    removeKey(userGenderKey);
    removeKey(userClinicKey);
    removeKey(userProfileImageKey);
  }
}
