import 'package:flutter/material.dart';
import 'package:safelify/components/cached_image_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/screens/auth/screens/edit_profile_screen.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardTopProfileWidget extends StatelessWidget {
  final VoidCallback? refreshCallback;

  DashboardTopProfileWidget({this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if ((isReceptionist() || isDoctor()) || (isPatient() && isVisible(SharedPreferenceKey.kiviCarePatientProfileKey)))
          EditProfileScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
            refreshCallback?.call();
          });
      },
      child: Container(
        decoration: boxDecorationDefault(color: context.primaryColor, border: Border.all(color: white, width: 3), shape: BoxShape.circle),
        margin: EdgeInsets.only(
          right: isRTL ? 0 : 14,
          left: isRTL ? 14 : 0,
        ),
        child: userStore.profileImage.validate().isNotEmpty
            ? CachedImageWidget(
                url: userStore.profileImage.validate(),
                fit: BoxFit.cover,
                height: 38,
                width: 38,
                circle: true,
                alignment: Alignment.center,
              )
            : PlaceHolderWidget(
                shape: BoxShape.circle,
                height: 38,
                width: 38,
                alignment: Alignment.center,
                child: Text(userStore.firstName.validate(value: 'P')[0].capitalizeFirstLetter(), style: boldTextStyle(color: Colors.black)),
              ),
      ),
    );
  }
}
