import 'package:flutter/material.dart';
import 'package:safelify/components/app_common_dialog.dart';
import 'package:safelify/components/app_setting_widget.dart';
import 'package:safelify/components/theme_selection_dialog.dart';
import 'package:safelify/main.dart';
import 'package:safelify/screens/auth/screens/change_password_screen.dart';
import 'package:safelify/screens/language_screen.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class AppSettingComponent extends StatelessWidget {
  final VoidCallback? callSetState;

  AppSettingComponent({this.callSetState});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        AppSettingWidget(
          name: locale.lblSelectTheme,
          image: ic_darkMode,
          subTitle: locale.lblThemeSubTitle,
          onTap: () {
            showInDialog(
              context,
              contentPadding: EdgeInsets.zero,
              shape: dialogShape(),
              builder: (context) {
                return AppCommonDialog(
                  title: locale.lblSelectTheme,
                  child: ThemeSelectionDialog(),
                );
              },
            ).then((value) {
              callSetState?.call();
            });
          },
        ),
        if (isVisible(SharedPreferenceKey.kiviCareChangePasswordKey))
          AppSettingWidget(
            name: locale.lblChangePassword,
            image: ic_unlock,
            widget: ChangePasswordScreen(),
            subTitle: locale.lblChangePasswordSubtitle,
          ),
        AppSettingWidget(
          name: locale.lblLanguage,
          isLanguage: true,
          subTitle: selectedLanguageDataModel!.name.validate(),
          image: selectedLanguageDataModel!.flag.validate(),
          onTap: () async => await LanguageScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
            callSetState?.call();
          }),
        ),
      ],
    );
  }
}
