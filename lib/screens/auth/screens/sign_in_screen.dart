import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safelify/components/app_common_dialog.dart';
import 'package:safelify/components/app_logo.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/demo_login_model.dart';
import 'package:safelify/network/auth_repository.dart';
import 'package:safelify/network/google_repository.dart';
import 'package:safelify/screens/auth/components/login_register_widget.dart';
import 'package:safelify/screens/auth/screens/sign_up_screen.dart';
import 'package:safelify/telelegal/network/auth_repository.dart' as teleLegal;
import 'package:safelify/utils/app_widgets.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants.dart';
import 'package:safelify/utils/constants/woocommerce_constants.dart';
import 'package:safelify/utils/extensions/string_extensions.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main_page.dart';
import '../components/forgot_password_dailog_component.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isRemember = false;
  bool isFirstTime = true;

  List<DemoLoginModel> demoLoginData = demoLoginList();

  int? selectedIndex;

  final LocalAuthentication auth = LocalAuthentication();
  bool _supportState = false;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      setStatusBarColor(
        appStore.isDarkModeOn
            ? context.scaffoldBackgroundColor
            : appPrimaryColor.withOpacity(0.02),
        statusBarIconBrightness:
        appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
      );
    });

    init();
  }

  Future<void> init() async {
    if (getBoolAsync(IS_REMEMBER_ME)) {
      isRemember = true;
      emailCont.text = getStringAsync(USER_NAME);
      passwordCont.text = getStringAsync(USER_PASSWORD);
      selectedIndex = getIntAsync(SELECTED_PROFILE_INDEX);
    }
    await _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    bool canCheck = await auth.canCheckBiometrics;
    setState(() => _supportState = canCheck);

    if (getBoolAsync(IS_REMEMBER_ME) && canCheck) {
      await _authenticate();
    }
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to login',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        emailCont.text = getStringAsync(USER_NAME);
        passwordCont.text = getStringAsync(USER_PASSWORD);
        selectedIndex = getIntAsync(SELECTED_PROFILE_INDEX);
        await saveForm();
      }
    } catch (e) {
      if (Get.context != null) {
        toast(e.toString());
      }
    }
  }

  Future<void> saveForm() async {
    if (appStore.isLoading) return;

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      hideKeyboard(context);
      appStore.setLoading(true);

      try {
        // Step 1: Firebase Sign-In
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCont.text.trim(),
          password: passwordCont.text.trim(),
        );

        User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          // Step 2: Fetch user data from Firestore
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          if (userSnapshot.exists) {
            // Fetch and store Firestore data
            Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

            // Prepare API login request
            Map<String, dynamic> req = {
              'username': emailCont.text,
              'password': passwordCont.text,
            };

            // Step 3: Await logins in parallel (independent)
            var telehealthFuture = loginAPI(req);
            var telelegalFuture = teleLegal.loginAPI(req);

            List<dynamic> results = await Future.wait([telehealthFuture, telelegalFuture]);

            var telehealthValue = results[0];
            var telelegalValue = results[1];

            if (telehealthValue != null && telelegalValue != null) {
              // Store credentials if 'Remember me' is selected
              if (isRemember) {
                await setValue(USER_NAME, emailCont.text);
                await setValue(USER_PASSWORD, passwordCont.text);
                await setValue(IS_REMEMBER_ME, true);
                await setValue(SELECTED_PROFILE_INDEX, selectedIndex);
              }

              // Step 4: Call config sequentially after auth
              try {
                await getConfigurationAPI();
              } catch (configError) {
                if (Get.context != null) {
                  toast("Configuration fetch failed: $configError");
                }
              }

              // Process shared logic
              shopStore.setCartCount(getIntAsync(
                  '${CartKeys.cartItemCountKey} of ${userStore1.userName}'));

              String userRole = userStore1.userRole?.toLowerCase() ?? '';
              if (userRole == UserRoleDoctor.toLowerCase()) {
                doctorAppStore.setBottomNavIndex(0);
                if (Get.context != null) {
                  toast('Login Successful!! 🎉');
                }
                Get.offAll(() => MainPage());
              } else if (userRole == UserRolePatient.toLowerCase()) {
                patientStore.setBottomNavIndex(0);
                if (Get.context != null) {
                  toast('Login Successful!! 🎉');
                }
                Get.offAll(() => MainPage());
              } else if (userRole == UserRoleReceptionist.toLowerCase()) {
                receptionistAppStore.setBottomNavIndex(0);
                if (Get.context != null) {
                  toast('Login Successful!! 🎉');
                }
                Get.offAll(() => MainPage());
              } else {
                if (Get.context != null) {
                  toast(locale.lblWrongUser);
                }
              }
              appStore.setLoading(false);
            } else {
              appStore.setLoading(false);
              if (Get.context != null) {
                toast("Login failed for one or more services.");
              }
            }
          } else {
            appStore.setLoading(false);
            if (Get.context != null) {
              toast("User data not found in Firestore.");
            }
          }
        }
      } catch (e) {
        appStore.setLoading(false);
        if (Get.context != null) {
          toast(e.toString());
        }
      }
    } else {
      isFirstTime = !isFirstTime;
      setState(() {});
    }
  }

  Future<void> forgotPasswordDialog(BuildContext context) async {
    await showInDialog(
      context,
      shape: RoundedRectangleBorder(borderRadius: radius()),
      contentPadding: EdgeInsets.zero,
      backgroundColor: context.scaffoldBackgroundColor,
      builder: (context) {
        return AppCommonDialog(
          title: locale.lblForgotPassword,
          child: ForgotPasswordDialogComponent()
              .cornerRadiusWithClipRRect(defaultRadius),
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    emailCont.dispose();
    passwordCont.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: isFirstTime
                ? AutovalidateMode.disabled
                : AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  36.height,
                  AppLogo(),
                  Text(locale.lblSignInToContinue, style: secondaryTextStyle())
                      .center(),
                  60.height,
                  AppTextField(
                    controller: emailCont,
                    focus: emailFocus,
                    nextFocus: passwordFocus,
                    textStyle: primaryTextStyle(),
                    textFieldType: TextFieldType.EMAIL,
                    errorThisFieldRequired: locale.lblEmailIsRequired,
                    decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblEmail,
                        suffixIcon: ic_user
                            .iconImage(size: 18, color: context.iconColor)
                            .paddingAll(14)),
                  ),
                  24.height,
                  AppTextField(
                    controller: passwordCont,
                    focus: passwordFocus,
                    textStyle: primaryTextStyle(),
                    textFieldType: TextFieldType.PASSWORD,
                    errorThisFieldRequired: locale.passwordIsRequired,
                    suffixPasswordVisibleWidget: ic_showPassword
                        .iconImage(size: 10, color: context.iconColor)
                        .paddingAll(14),
                    suffixPasswordInvisibleWidget: ic_hidePassword
                        .iconImage(size: 10, color: context.iconColor)
                        .paddingAll(14),
                    decoration: inputDecoration(
                        context: context, labelText: locale.lblPassword),
                  ),
                  4.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          4.width,
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Checkbox(
                              activeColor: appSecondaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius(4)),
                              value: isRemember,
                              onChanged: (value) async {
                                isRemember = value.validate();
                                setState(() {});
                              },
                            ),
                          ),
                          8.width,
                          TextButton(
                            onPressed: () {
                              isRemember = !isRemember;
                              setState(() {});
                            },
                            child: Text(locale.lblRememberMe,
                                style: secondaryTextStyle()),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          forgotPasswordDialog(context).then((value) {
                            appStore.setLoading(false);
                          });
                        },
                        child: Text(
                          locale.lblForgotPassword,
                          style: secondaryTextStyle(
                              color: appSecondaryColor,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  if (_supportState) ...[
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.fingerprint,
                            size: 40,
                            color: primaryColor,
                          ),
                          onPressed: _authenticate,
                        ),
                      ],
                    ),
                  ],
                  24.height,
                  AppButton(
                    width: context.width(),
                    shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                    onTap: () {
                      saveForm();
                    },
                    color: primaryColor,
                    padding: const EdgeInsets.all(16),
                    child: Text(locale.lblSignIn,
                        style: boldTextStyle(color: textPrimaryDarkColor)),
                  ),
                  40.height,
                  LoginRegisterWidget(
                    title: locale.lblNewMember,
                    subTitle: locale.lblSignUp,
                    onTap: () {
                      const SignUpScreen().launch(context,
                          pageRouteAnimation: pageAnimation,
                          duration: pageAnimationDuration);
                    },
                  ),
                ],
              ),
            ),
          ),
          Observer(
              builder: (context) =>
                  LoaderWidget().visible(appStore.isLoading).center())
        ],
      ),
    );
  }
}