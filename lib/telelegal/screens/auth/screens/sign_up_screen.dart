import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:safelify/telelegal/components/gender_selection_component.dart';
import 'package:safelify/telelegal/components/loader_widget.dart';
import 'package:safelify/telelegal/config.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/clinic_list_model.dart';
import 'package:safelify/telelegal/network/google_repository.dart';
import 'package:safelify/telelegal/network/patient_list_repository.dart';
import 'package:safelify/telelegal/screens/auth/components/login_register_widget.dart';
import 'package:safelify/telelegal/screens/dashboard/screens/doctor_dashboard_screen.dart';
import 'package:safelify/telelegal/screens/dashboard/screens/patient_dashboard_screen.dart';
import 'package:safelify/telelegal/screens/dashboard/screens/receptionist_dashboard_screen.dart';
import 'package:safelify/telelegal/screens/patient/screens/patient_clinic_selection_screen.dart';
import 'package:safelify/telelegal/screens/auth/screens/map_screen.dart';
import 'package:safelify/telelegal/services/location_service.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/app_widgets.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/extensions/date_extensions.dart';
import 'package:safelify/telelegal/utils/extensions/string_extensions.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';

import '../../../network/auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  GlobalKey<FormState> passwordFormKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController dOBCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();
  TextEditingController selectedClinicCont = TextEditingController();

  TextEditingController addressCont = TextEditingController();

  String? genderValue;
  String? bloodGroup;
  String? selectedClinic;
  String? selectedRole;

  Clinic? selectedClinicData;

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode dOBFocus = FocusNode();
  FocusNode bloodGroupFocus = FocusNode();
  FocusNode roleFocus = FocusNode();
  FocusNode clinicFocus = FocusNode();

  FocusNode genderFocus = FocusNode();

  late DateTime birthDate;

  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() => () {
          setStatusBarColor(
            appStore.isDarkModeOn
                ? context.scaffoldBackgroundColor
                : appPrimaryColor.withOpacity(0.02),
            statusBarIconBrightness:
                appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
          );
        });
  }

  Future<void> _handleSetLocationClick() async {
    final hasPermission = await handlePermission();

    if (!hasPermission) {
      toast(locale.lblPermissionDenied);
      throw locale.lblPermissionDenied;
    }
    if (hasPermission) {
      String? res = await MapScreen(
              latitude: getDoubleAsync(SharedPreferenceKey.latitudeKey),
              latLong: getDoubleAsync(SharedPreferenceKey.longitudeKey))
          .launch(context);

      if (res != null) {
        addressCont.text = res;
        setState(() {});
      }
    }
  }

  Future<void> _handleCurrentLocationClick() async {
    final hasPermission = await handlePermission();

    if (!hasPermission) {
      toast(locale.lblPermissionDenied);
      throw locale.lblPermissionDenied;
    }
    if (hasPermission) {
      appStore.setLoading(true);
      await getUserLocation().then((value) {
        addressCont.clear();
        addressCont.text = value;

        setState(() {});
      }).whenComplete(() {
        appStore.setLoading(false);
      }).catchError((e) {
        log(e);
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  // void signUp() async {
  //   hideKeyboard(context);
  //   if (passwordFormKey.currentState!.validate()) {
  //     passwordFormKey.currentState!.save();
  //   }
  //   if (formKey.currentState!.validate()) {
  //     formKey.currentState!.save();

  //     appStore.setLoading(true);

  //     Map request = {
  //       "first_name": firstNameCont.text.validate(),
  //       "last_name": lastNameCont.text.validate(),
  //       "user_email": emailCont.text.validate(),
  //       "mobile_number": contactNumberCont.text.validate(),
  //       "gender": genderValue.validate().toLowerCase(),
  //       "dob": birthDate.getFormattedDate(SAVE_DATE_FORMAT).validate(),
  //       "user_pass": passwordCont.text,
  //       'role': selectedRole,
  //     };
  //     if (selectedRole == UserRolePatient && bloodGroup.validate().isNotEmpty) {
  //       request.putIfAbsent("blood_group", () => bloodGroup.validate());
  //     }
  //     if (selectedClinicData != null) {
  //       request.putIfAbsent(
  //           'clinic_id', () => selectedClinicData!.id.validate());
  //     }

  //     await addNewUserAPI(request).then((value) async {
  //       toast(value.message.capitalizeFirstLetter().validate());

  //       Map<String, dynamic> req = {
  //         'username': emailCont.text,
  //         'password': passwordCont.text,
  //       };

  //       await loginAPI(req).then((value) async {
  //         if (value != null) {
  //           setValue(USER_NAME, emailCont.text);
  //           setValue(USER_PASSWORD, passwordCont.text);
  //           setValue(IS_REMEMBER_ME, true);

  //           getConfigurationAPI().whenComplete(() {
  //             if (userStore.userRole!.toLowerCase() == UserRoleDoctor) {
  //               doctorAppStore.setBottomNavIndex(0);
  //               toast('${locale.lblLoginSuccessfullyAsADoctor}!! 🎉');
  //               setValue(SELECTED_PROFILE_INDEX, 2);
  //               DoctorDashboardScreen().launch(context,
  //                   isNewTask: true,
  //                   duration: pageAnimationDuration,
  //                   pageRouteAnimation: PageRouteAnimation.Slide);
  //             } else if (userStore.userRole!.toLowerCase() == UserRolePatient) {
  //               toast('${locale.lblLoginSuccessfullyAsAPatient}!! 🎉');
  //               patientStore.setBottomNavIndex(0);
  //               setValue(SELECTED_PROFILE_INDEX, 0);
  //               PatientDashBoardScreen().launch(context,
  //                   isNewTask: true,
  //                   pageRouteAnimation: PageRouteAnimation.Slide,
  //                   duration: pageAnimationDuration);
  //             } else if (userStore.userRole!.toLowerCase() ==
  //                 UserRoleReceptionist) {
  //               setValue(SELECTED_PROFILE_INDEX, 1);
  //               receptionistAppStore.setBottomNavIndex(0);
  //               toast('${locale.lblLoginSuccessfullyAsAReceptionist}!! 🎉');
  //               RDashBoardScreen().launch(context,
  //                   isNewTask: true,
  //                   pageRouteAnimation: PageRouteAnimation.Slide,
  //                   duration: pageAnimationDuration);
  //             } else {
  //               toast(locale.lblWrongUser);
  //             }
  //             appStore.setLoading(false);
  //           }).catchError((e) {
  //             appStore.setLoading(false);

  //             throw e;
  //           });
  //         }
  //       }).catchError((e) {
  //         appStore.setLoading(false);
  //         toast(e.toString().capitalizeFirstLetter());
  //       });
  //     }).catchError((e) {
  //       appStore.setLoading(false);
  //       toast(e.toString().capitalizeFirstLetter());
  //     });
  //   } else {
  //     isFirstTime = !isFirstTime;
  //     setState(() {});
  //   }
  // }

  void signUp({
    required String firstname,
    required String lastname,
    required String email,
    required String contactNo,
    required String dob,
    required String gender,
    required String userPassword,
    required String role,
    required String bloodGroup,
    required String clinicId,
  }) async {
    appStore.setLoading(true);

    Map request = {
      "first_name": firstname,
      "last_name": lastname,
      "user_email": email,
      "mobile_number": contactNo,
      "gender": gender,
      "dob": dob,
      "user_pass": userPassword,
      'role': role,
      'blood_group': bloodGroup,
      'clinic_id': clinicId,
    };
    await addNewUserAPI(request).then((value) async {
      toast(value.message.capitalizeFirstLetter().validate());

      Map<String, dynamic> req = {
        'username': emailCont.text,
        'password': passwordCont.text,
      };

      await loginAPI(req).then((value) async {
        if (value != null) {
          setValue(USER_NAME, emailCont.text);
          setValue(USER_PASSWORD, passwordCont.text);
          setValue(IS_REMEMBER_ME, true);

          getConfigurationAPI().whenComplete(() {
            // if (userStore.userRole!.toLowerCase() == UserRoleDoctor) {
            //   doctorAppStore.setBottomNavIndex(0);
            //   toast('${locale.lblLoginSuccessfullyAsADoctor}!! 🎉');
            //   setValue(SELECTED_PROFILE_INDEX, 2);
            //   DoctorDashboardScreen().launch(context,
            //       isNewTask: true,
            //       duration: pageAnimationDuration,
            //       pageRouteAnimation: PageRouteAnimation.Slide);
            // } else if (userStore.userRole!.toLowerCase() == UserRolePatient) {
            //   toast('${locale.lblLoginSuccessfullyAsAPatient}!! 🎉');
            //   patientStore.setBottomNavIndex(0);
            //   setValue(SELECTED_PROFILE_INDEX, 0);
            //   PatientDashBoardScreen().launch(context,
            //       isNewTask: true,
            //       pageRouteAnimation: PageRouteAnimation.Slide,
            //       duration: pageAnimationDuration);
            // } else if (userStore.userRole!.toLowerCase() ==
            //     UserRoleReceptionist) {
            //   setValue(SELECTED_PROFILE_INDEX, 1);
            //   receptionistAppStore.setBottomNavIndex(0);
            //   toast('${locale.lblLoginSuccessfullyAsAReceptionist}!! 🎉');
            //   RDashBoardScreen().launch(context,
            //       isNewTask: true,
            //       pageRouteAnimation: PageRouteAnimation.Slide,
            //       duration: pageAnimationDuration);
            // } else {
            //   toast(locale.lblWrongUser);
            // }
            appStore.setLoading(false);
          }).catchError((e) {
            appStore.setLoading(false);

            throw e;
          });
        }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString().capitalizeFirstLetter());
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString().capitalizeFirstLetter());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: isFirstTime
              ? AutovalidateMode.disabled
              : AutovalidateMode.onUserInteraction,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    64.height,
                    Image.asset(appIcon, height: 100, width: 100),
                    16.height,
                    RichTextWidget(
                      list: [
                        TextSpan(
                            text: APP_FIRST_NAME,
                            style: boldTextStyle(size: 32, letterSpacing: 1)),
                        TextSpan(
                            text: APP_SECOND_NAME,
                            style:
                                primaryTextStyle(size: 32, letterSpacing: 1)),
                      ],
                    ).center(),
                    32.height,
                    Text(locale.lblSignUpAsPatient,
                        style: secondaryTextStyle(size: 14)),
                    24.height,
                    Row(
                      children: [
                        AppTextField(
                          textStyle: primaryTextStyle(),
                          controller: firstNameCont,
                          textFieldType: TextFieldType.NAME,
                          focus: firstNameFocus,
                          errorThisFieldRequired: locale.lblFirstNameIsRequired,
                          nextFocus: lastNameFocus,
                          decoration: inputDecoration(
                            context: context,
                            labelText: locale.lblFirstName,
                            prefixIcon: ic_user
                                .iconImage(size: 10, color: context.iconColor)
                                .paddingAll(14),
                          ),
                          onFieldSubmitted: (value) {
                            lastNameFocus.requestFocus();
                          },
                        ).expand(),
                        16.width,
                        AppTextField(
                            textStyle: primaryTextStyle(),
                            controller: lastNameCont,
                            textFieldType: TextFieldType.NAME,
                            focus: lastNameFocus,
                            nextFocus: emailFocus,
                            errorThisFieldRequired:
                                locale.lblLastNameIsRequired,
                            decoration: inputDecoration(
                                context: context,
                                labelText: locale.lblLastName,
                                prefixIcon: ic_user
                                    .iconImage(
                                        size: 10, color: context.iconColor)
                                    .paddingAll(14)),
                            onFieldSubmitted: (value) {
                              emailFocus.requestFocus();
                            }).expand(),
                      ],
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      controller: emailCont,
                      textFieldType: TextFieldType.EMAIL,
                      focus: emailFocus,
                      nextFocus: passwordFocus,
                      errorThisFieldRequired: locale.lblEmailIsRequired,
                      onFieldSubmitted: (value) {
                        passwordFocus.requestFocus();
                      },
                      decoration: inputDecoration(
                          context: context,
                          labelText: locale.lblEmail,
                          prefixIcon: ic_message
                              .iconImage(size: 10, color: context.iconColor)
                              .paddingAll(14)),
                    ),
                    16.height,
                    Form(
                      key: passwordFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: passwordCont,
                            focus: passwordFocus,
                            nextFocus: confirmPasswordFocus,
                            textStyle: primaryTextStyle(),
                            errorThisFieldRequired: locale.passwordIsRequired,
                            textFieldType: TextFieldType.PASSWORD,
                            suffixPasswordVisibleWidget: ic_showPassword
                                .iconImage(size: 10, color: context.iconColor)
                                .paddingAll(14),
                            suffixPasswordInvisibleWidget: ic_hidePassword
                                .iconImage(size: 10, color: context.iconColor)
                                .paddingAll(14),
                            decoration: inputDecoration(
                                context: context,
                                labelText: locale.lblPassword),
                            onFieldSubmitted: (value) {
                              confirmPasswordFocus.requestFocus();
                            },
                          ),
                          16.height,
                          AppTextField(
                            controller: confirmPasswordCont,
                            focus: confirmPasswordFocus,
                            textStyle: primaryTextStyle(),
                            nextFocus: contactNumberFocus,
                            errorThisFieldRequired:
                                locale.confirmPasswordIsRequired,
                            textFieldType: TextFieldType.PASSWORD,
                            validator: (value) {
                              if (confirmPasswordCont.text.isEmpty)
                                return locale.confirmPasswordIsRequired;
                              if (passwordCont.text !=
                                  confirmPasswordCont.text) {
                                return locale.lblPwdDoesNotMatch;
                              } else {
                                return null;
                              }
                            },
                            onFieldSubmitted: (value) {
                              contactNumberFocus.requestFocus();
                            },
                            suffixPasswordVisibleWidget: ic_showPassword
                                .iconImage(size: 10, color: context.iconColor)
                                .paddingAll(14),
                            suffixPasswordInvisibleWidget: ic_hidePassword
                                .iconImage(size: 10, color: context.iconColor)
                                .paddingAll(14),
                            decoration: inputDecoration(
                              context: context,
                              labelText: locale.lblConfirmPassword,
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      controller: contactNumberCont,
                      focus: contactNumberFocus,
                      nextFocus: dOBFocus,
                      textFieldType: TextFieldType.PHONE,
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      isValidationRequired: true,
                      errorThisFieldRequired: locale.contactNumberIsRequired,
                      decoration: inputDecoration(
                          context: context,
                          labelText: locale.lblContactNumber,
                          prefixIcon: ic_phone
                              .iconImage(size: 10, color: context.iconColor)
                              .paddingAll(14)),
                      onFieldSubmitted: (value) {
                        dOBFocus.requestFocus();
                      },
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      controller: dOBCont,
                      nextFocus: bloodGroupFocus,
                      focus: dOBFocus,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: locale.lblBirthDateIsRequired,
                      readOnly: true,
                      onFieldSubmitted: (value) {
                        if (selectedRole == UserRolePatient)
                          bloodGroupFocus.requestFocus();
                      },
                      onTap: () {
                        dateBottomSheet(
                          context,
                          onBirthDateSelected: (selectedBirthDate) {
                            if (selectedBirthDate != null) {
                              dOBCont.text = DateFormat(SAVE_DATE_FORMAT)
                                  .format(selectedBirthDate);
                              birthDate = selectedBirthDate;
                              setState(() {});
                            }
                          },
                        );
                      },
                      decoration: inputDecoration(
                          context: context,
                          labelText: locale.lblDOB,
                          prefixIcon: ic_calendar
                              .iconImage(size: 10, color: context.iconColor)
                              .paddingAll(14)),
                    ),
                    16.height,
                    Row(
                      children: [
                        DropdownButtonFormField(
                          icon: const SizedBox.shrink(),
                          isExpanded: true,
                          borderRadius: radius(),
                          focusColor: primaryColor,
                          dropdownColor: context.cardColor,
                          focusNode: roleFocus,
                          autovalidateMode: isFirstTime
                              ? AutovalidateMode.disabled
                              : AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value.isEmptyOrNull) {
                              return locale.roleIsRequired;
                            } else {
                              return null;
                            }
                          },
                          decoration: inputDecoration(
                              context: context,
                              labelText: locale.lblSelectRole,
                              prefixIcon: ic_user
                                  .iconImage(size: 10, color: context.iconColor)
                                  .paddingAll(14)),
                          onChanged: (dynamic role) {
                            selectedRole = role;
                            setState(() {});
                          },
                          items: userRoleList.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              onTap: () {
                                selectedRole = role;
                                if (selectedRole == UserRolePatient) {
                                  bloodGroupFocus.requestFocus();
                                } else {
                                  clinicFocus.requestFocus();
                                }
                                setState(() {});
                              },
                              child: Text(role.capitalizeEachWord(),
                                  style: primaryTextStyle()),
                            );
                          }).toList(),
                        ).expand(),
                        if (selectedRole == UserRolePatient) 16.width,
                        if (selectedRole == UserRolePatient)
                          DropdownButtonFormField(
                            icon: const SizedBox.shrink(),
                            isExpanded: true,
                            borderRadius: radius(),
                            focusColor: primaryColor,
                            dropdownColor: context.cardColor,
                            focusNode: bloodGroupFocus,
                            decoration: inputDecoration(
                                context: context,
                                labelText: locale.lblBloodGroup,
                                prefixIcon: ic_arrow_down
                                    .iconImage(
                                        size: 10, color: context.iconColor)
                                    .paddingAll(14)),
                            onChanged: (dynamic value) {
                              bloodGroup = value;
                            },
                            items: bloodGroupList
                                .map((bloodGroup) => DropdownMenuItem(
                                    value: bloodGroup,
                                    child: Text(bloodGroup,
                                        style: primaryTextStyle())))
                                .toList(),
                          ).expand()
                      ],
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      focus: clinicFocus,
                      controller: selectedClinicCont,
                      isValidationRequired: true,
                      readOnly: true,
                      errorThisFieldRequired: locale.clinicIdRequired,
                      selectionControls: EmptyTextSelectionControls(),
                      decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblSelectClinic,
                        prefixIcon: ic_clinic
                            .iconImage(size: 18, color: context.iconColor)
                            .paddingAll(14),
                      ),
                      validator: (value) {
                        if (selectedClinicData == null)
                          return locale.clinicIdRequired;
                        return null;
                      },
                      maxLines: 1,
                      onTap: () {
                        hideKeyboard(context);
                        PatientClinicSelectionScreen(
                          isForRegistration: true,
                          clinicId: selectedClinicData?.id.toInt(),
                        )
                            .launch(context,
                                pageRouteAnimation: pageAnimation,
                                duration: pageAnimationDuration)
                            .then((value) {
                          if (value != null) {
                            selectedClinicData = value;
                            selectedClinicCont.text =
                                selectedClinicData!.name.validate();

                            setState(() {});
                          } else {}
                        });
                      },
                    ),
                    16.height,
                    GenderSelectionComponent(
                      onTap: (value) {
                        genderValue = value;
                        setState(() {});
                      },
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: addressCont,
                      maxLines: 2,
                      decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblAddress,
                        prefixIcon: ic_location
                            .iconImage(size: 18, color: context.iconColor)
                            .paddingAll(14),
                      ),
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(locale.chooseFromMap,
                              style:
                                  boldTextStyle(color: primaryColor, size: 13)),
                          onPressed: () {
                            _handleSetLocationClick();
                          },
                        ).flexible(),
                        TextButton(
                          onPressed: _handleCurrentLocationClick,
                          child: Text(locale.currentLocation,
                              style:
                                  boldTextStyle(color: primaryColor, size: 13),
                              textAlign: TextAlign.right),
                        ).flexible(),
                      ],
                    ),
                    16.height,
                    AppButton(
                      width: context.width(),
                      shapeBorder:
                          RoundedRectangleBorder(borderRadius: radius()),
                      color: primaryColor,
                      padding: const EdgeInsets.all(16),
                      onTap: signUp,
                      child: Text(locale.lblSubmit,
                          style: boldTextStyle(color: textPrimaryDarkColor)),
                    ),
                    24.height,
                    LoginRegisterWidget(
                      title: locale.lblAlreadyAMember,
                      subTitle: "${locale.lblLogin} ?",
                      onTap: () {
                        finish(context);
                      },
                    ),
                    24.height,
                  ],
                ),
              ),
              Positioned(
                top: -2,
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () {
                    finish(context);
                  },
                ),
              ),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading).center())
            ],
          ),
        ),
      ),
    );
  }
}
