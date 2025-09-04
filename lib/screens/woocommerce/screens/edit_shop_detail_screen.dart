import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/woo_commerce/billing_address_model.dart';
import 'package:safelify/model/woo_commerce/customer_model.dart';
import 'package:safelify/network/shop_repository.dart';
import 'package:safelify/screens/woocommerce/component/address_form_component.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/cached_value.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:safelify/utils/constants/woocommerce_constants.dart';
import 'package:safelify/utils/extensions/widget_extentions.dart';
import 'package:nb_utils/nb_utils.dart';

BillingAddressModel billingAddress = BillingAddressModel();
BillingAddressModel shippingAddress = BillingAddressModel();

bool isSameAddress = false;

class EditShopDetailsScreen extends StatefulWidget {
  final bool isFromCheckout;

  final VoidCallback? callback;
  const EditShopDetailsScreen({Key? key, this.isFromCheckout = false, this.callback}) : super(key: key);

  @override
  State<EditShopDetailsScreen> createState() => _EditShopDetailsScreenState();
}

class _EditShopDetailsScreenState extends State<EditShopDetailsScreen> {
  CustomerModel details = CustomerModel();
  bool isSame = false;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    await getCustomer().then((value) {
      details = value;
      if (value.billing!.firstName.validate().isEmpty) {
        value.billing!.firstName = value.firstName;
      }

      if (value.billing!.lastName.validate().isEmpty) {
        value.billing!.lastName = value.lastName;
      }

      if (value.shipping!.firstName.validate().isEmpty) {
        value.shipping!.firstName = value.firstName;
      }

      if (value.shipping!.lastName.validate().isEmpty) {
        value.shipping!.lastName = value.lastName;
      }

      billingAddress = value.billing ?? BillingAddressModel();
      shippingAddress = value.shipping ?? BillingAddressModel();
      setState(() {});

      storeData(shipping: shippingAddress.toJson(), billing: billingAddress.toJson());
      getCountriesApi();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void storeData({required Map<String, dynamic>? shipping, Map<String, dynamic>? billing}) {
    if (billing != null) CachedData.storeResponse(responseKey: CartKeys.billingAddress, response: billing);
    if (shipping != null) CachedData.storeResponse(responseKey: CartKeys.shippingAddress, response: shipping);
  }

  Future<void> getCountriesApi() async {
    await getCountries().then((value) {
      if (countriesList.isNotEmpty) {
        countriesList.clear();
      }
      countriesList.addAll(value);
      setValue(SharedPreferenceKey.countriesListKey, jsonEncode(value.map((e) => e.toJson())));

      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      log('e.toString(): ${e.toString()}');
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (!widget.isFromCheckout) getDisposeStatusBarColor();
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblEditAddressDetails,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpansionTile(
                  title: Text(locale.billingAddress, style: boldTextStyle()),
                  children: <Widget>[
                    AddressFormComponent(
                      data: billingAddress,
                      isBilling: true,
                    ),
                  ],
                  backgroundColor: context.cardColor,
                  collapsedBackgroundColor: context.cardColor,
                  childrenPadding: EdgeInsets.symmetric(horizontal: 16),
                ).cornerRadiusWithClipRRect(defaultRadius),
                16.height,
                Row(
                  children: [
                    Checkbox(
                      shape: RoundedRectangleBorder(borderRadius: radius(4)),
                      activeColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
                      value: isSame,
                      onChanged: (val) {
                        isSame = val.validate();
                        if (val.validate()) {
                          shippingAddress = billingAddress;
                        } else {
                          shippingAddress = BillingAddressModel();
                        }
                        setState(() {});
                      },
                    ),
                    Text(locale.billingAndShippingAddresses, style: secondaryTextStyle()).appOnTap(() {
                      isSame = !isSame;
                      if (isSame) {
                        shippingAddress = billingAddress;
                      } else {
                        shippingAddress = BillingAddressModel();
                      }
                      setState(() {});
                    }).expand()
                  ],
                ),
                16.height,
                ExpansionTile(
                  childrenPadding: EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: context.cardColor,
                  collapsedBackgroundColor: context.cardColor,
                  title: Text(locale.shippingAddress, style: boldTextStyle()),
                  children: <Widget>[
                    AddressFormComponent(
                      data: shippingAddress,
                    ),
                  ],
                ).cornerRadiusWithClipRRect(defaultRadius),
              ],
            ),
          ),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading))
        ],
      ),
      bottomNavigationBar: Observer(
        builder: (_) => AppButton(
          text: locale.lblUpdate,
          onTap: () async {
            appStore.setLoading(true);

            Map<String, dynamic> request = {"billing": billingAddress, "shipping": !isSame ? shippingAddress : billingAddress};

            updateCustomer(request: request).then((value) {
              details = value;
              isSameAddress = isSame;
              setState(() {});
              CachedData.storeResponse(responseKey: CartKeys.billingAddress, response: billingAddress.toJson());
              CachedData.storeResponse(responseKey: CartKeys.shippingAddress, response: shippingAddress.toJson());
              toast(locale.lblUpdatedSuccessfully);
              widget.callback?.call();
              finish(context);
              appStore.setLoading(false);
            }).catchError((e) {
              appStore.setLoading(false);

              if (e.toString() == "Invalid parameter(s): billing") {
                toast("locale.enterValidDetails");
              } else {
                log(e.toString());
                toast(locale.lblSomethingWentWrong, print: true);
              }
            });
          },
        ).paddingAll(16).visible(!appStore.isLoading),
      ),
    );
  }
}
