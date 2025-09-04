import 'package:flutter/material.dart';
import 'package:safelify/telelegal/components/app_setting_widget.dart';
import 'package:safelify/telelegal/config.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/network/auth_repository.dart';
import 'package:safelify/telelegal/screens/about_us_screen.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/cached_value.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OtherSettingsComponent extends StatelessWidget {
  const OtherSettingsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        AppSettingWidget(
          name: locale.lblTermsAndCondition,
          image: ic_termsAndCondition,
          subTitle: locale.lblTermsConditionSubTitle,
          onTap: () {
            if (userStore.termsEndConditionUrl.validate().isNotEmpty)
              launchUrlCustomTab(userStore.termsEndConditionUrl.validate());
            else
              launchUrlCustomTab(TERMS_AND_CONDITION_URL);
          },
        ),
        AppSettingWidget(
          name: locale.lblAboutUs,
          image: ic_aboutUs,
          widget: AboutUsScreen(),
          subTitle: locale.lblAboutKiviCare,
        ),
        AppSettingWidget(
          name: locale.lblRateUs,
          image: ic_rateUs,
          subTitle: locale.lblRateUsSubTitle,
          onTap: () async {
            if (isAndroid)
              commonLaunchUrl(
                  playStoreBaseURL +
                      await getPackageInfo()
                          .then((value) => value.packageName.validate()),
                  launchMode: LaunchMode.externalApplication);
            else if (isIOS)
              commonLaunchUrl(APPSTORE_APP_LINK,
                  launchMode: LaunchMode.externalApplication);
          },
        ),
        AppSettingWidget(
          image: ic_helpAndSupport,
          name: locale.lblHelpAndSupport,
          subTitle: locale.lblHelpAndSupportSubTitle,
          onTap: () {
            launchUrlCustomTab(SUPPORT_URL);
          },
        ),
        AppSettingWidget(
          name: locale.lblShare + " " + APP_NAME,
          image: ic_share,
          subTitle: locale.lblReachUsMore,
          onTap: () async {
            if (isIOS)
              Share.share('${locale.lblShare} $APP_NAME\n\n$APPSTORE_APP_LINK');
            else
              Share.share(
                  '${locale.lblShare} $APP_NAME app\n\n$playStoreBaseURL${await getPackageInfo().then((value) => value.packageName.validate())}');
          },
        ),
        AppSettingWidget(
          name: locale.lblDeleteAccount,
          image: ic_delete_icon,
          subTitle: locale.lblDeleteAccountSubTitle,
          onTap: () async {
            showConfirmDialogCustom(
              context,
              customCenterWidget: Container(
                child: Stack(
                  children: [
                    defaultPlaceHolder(
                      context,
                      DialogType.DELETE,
                      136.0,
                      context.width(),
                      appSecondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: radius()),
                    ),
                    Positioned(
                      left: 42,
                      bottom: 12,
                      right: 16,
                      child: Text(locale.lblDeleteAccountNote,
                          style: secondaryTextStyle(
                              size: 10, color: appSecondaryColor)),
                    )
                  ],
                ),
              ),
              dialogType: DialogType.DELETE,
              negativeText: locale.lblNo,
              positiveText: locale.lblYes,
              onAccept: (c) {
                ifNotTester(context, () {
                  appStore.setLoading(true);

                  deleteAccountPermanently().then((value) async {
                    toast(value.message);
                    if (isDoctor()) {
                      cachedDoctorAppointment = null;
                      cachedDoctorAppointment = [];
                      cachedPatientList = [];
                    }
                    if (isReceptionist()) {
                      cachedReceptionistAppointment = null;
                      cachedDoctorList = [];
                      cachedPatientList = [];
                    }
                    if (isPatient()) {
                      cachedPatientAppointment = [];
                      cachedPatientAppointment = null;
                      cachedNewsFeed = null;
                      cachedPatientDashboardModel = null;
                    }
                    await removeKey(IS_REMEMBER_ME);

                    appStore.setLoading(true);

                    logout();
                  }).catchError((e) {
                    appStore.setLoading(false);
                    throw e;
                  });
                });
              },
              title: locale.lblDoYouWantToDeleteAccountPermanently,
            );
          },
        ),
        AppSettingWidget(
          name: locale.lblAppVersion,
          image: ic_app_version,
          subTitle: packageInfo.versionName,
        ),
        TextButton(
          onPressed: () {
            showConfirmDialogCustom(
              context,
              primaryColor: primaryColor,
              negativeText: locale.lblCancel,
              positiveText: locale.lblYes,
              onAccept: (c) {
                appStore.setLoading(true);

                logout().catchError((e) {
                  appStore.setLoading(false);

                  throw e;
                }).whenComplete(() => appStore.setLoading(false));
              },
              title: locale.lblDoYouWantToLogout,
            );
          },
          child: Text(
            locale.lblLogOut,
            style: primaryTextStyle(color: primaryColor),
          ),
        ).center()
      ],
    );
  }
}
