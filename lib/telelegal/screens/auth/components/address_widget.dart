import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/screens/auth/screens/map_screen.dart';
import 'package:safelify/telelegal/services/location_service.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';

class AddressWidget extends StatefulWidget {
  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  TextEditingController addressCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController postalCodeCont = TextEditingController();

  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode postalCodeFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.lblAddressDetail,
            style: boldTextStyle(color: context.primaryColor, size: 18)),
        Divider(color: viewLineColor),
        Wrap(
          runSpacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text(locale.chooseFromMap,
                      style: boldTextStyle(color: primaryColor, size: 13)),
                  onPressed: () {
                    _handleSetLocationClick();
                  },
                ).flexible(),
                TextButton(
                  onPressed: _handleCurrentLocationClick,
                  child: Text(locale.currentLocation,
                      style: boldTextStyle(color: primaryColor, size: 13),
                      textAlign: TextAlign.right),
                ).flexible(),
              ],
            ),
            16.height,
            Row(
              children: [
                AppTextField(
                  controller: countryCont,
                  focus: countryFocus,
                  nextFocus: cityFocus,
                  textFieldType: TextFieldType.OTHER,
                  decoration: inputDecoration(
                      context: context, labelText: locale.lblCountry),
                ).expand(),
                16.width,
                AppTextField(
                  controller: cityCont,
                  focus: cityFocus,
                  textInputAction: TextInputAction.next,
                  nextFocus: postalCodeFocus,
                  textFieldType: TextFieldType.OTHER,
                  decoration: inputDecoration(
                      context: context, labelText: locale.lblCity),
                ).expand(),
              ],
            ),
            AppTextField(
              controller: postalCodeCont,
              focus: postalCodeFocus,
              textInputAction: TextInputAction.done,
              textFieldType: TextFieldType.OTHER,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allows digits
              ],
              decoration: inputDecoration(
                  context: context, labelText: locale.lblPostalCode),
            ),
          ],
        ).paddingTop(8)
      ],
    );
  }
}
