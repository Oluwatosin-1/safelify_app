import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/components/common_shop_setting_component.dart';
import 'package:safelify/components/doctor_recentionist_general_setting_component.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/network/auth_repository.dart';
import 'package:safelify/screens/auth/components/edit_profile_component.dart';
import 'package:safelify/screens/patient/components/general_setting_component.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingFragment extends StatefulWidget {
  @override
  _SettingFragmentState createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: AnimatedScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
            listAnimationType: ListAnimationType.None,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditProfileComponent(refreshCallback: () {
                setState(() {});
              }),
              Divider(
                height: isReceptionist() || isPatient() ? 30 : 40,
                color: context.dividerColor,
              ),
              Text(locale.lblGeneralSetting, textAlign: TextAlign.center, style: secondaryTextStyle()),
              16.height,
              if (isPatient()) GeneralSettingComponent(callBack: () => setState(() {})),
              if (isDoctor() || isReceptionist()) const DoctorReceptionistGeneralSettingComponent(),
              // const CommonShopSettingComponent().visible(appStore.wcNonce.validate().isNotEmpty),
              Column(
                children: [
                  Divider(
                    height: 24,
                    color: context.dividerColor,
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
                          }).whenComplete(() {
                            appStore.setLoading(false);
                          });
                        },
                        title: locale.lblDoYouWantToLogout,
                      );
                    },
                    child: Text(
                      locale.lblLogOut,
                      style: primaryTextStyle(color: primaryColor),
                    ),
                  ).center(),
                ],
              ).visible(appStore.wcNonce.validate().isNotEmpty)
            ],
          ),
        ),
        Positioned(
          child: Column(
            children: [
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
                      });
                    },
                    title: locale.lblDoYouWantToLogout,
                  );
                },
                child: Text(
                  locale.lblLogOut,
                  style: primaryTextStyle(color: primaryColor),
                ),
              ).center(),
            ],
          ),
          bottom: 0,
          left: 16,
          right: 16,
        ).visible(appStore.wcNonce.validate().isEmpty),
        Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
      ],
    );
  }
}
