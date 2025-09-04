import 'package:flutter/material.dart';
import 'package:safelify/components/app_setting_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/screens/woocommerce/screens/coupon_list_screen.dart';
import 'package:safelify/screens/woocommerce/screens/edit_shop_detail_screen.dart';
import 'package:safelify/screens/woocommerce/screens/order_list_screen.dart';
import 'package:safelify/screens/woocommerce/screens/wish_list_screen.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class CommonShopSettingComponent extends StatelessWidget {
  const CommonShopSettingComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        Divider(
          height: isReceptionist() || isPatient() ? 30 : 40,
          color: context.dividerColor,
        ),
        Text(locale.lblShop, textAlign: TextAlign.center, style: secondaryTextStyle()),
        AppSettingWidget(
          name: locale.lblAddress,
          image: ic_address,
          subTitle: locale.lblAddressSubTitle,
          widget: const EditShopDetailsScreen(),
        ),
        AppSettingWidget(
          name: locale.lblWishList,
          image: ic_wishList_cart,
          widget: const WishListScreen(),
          subTitle: locale.lblWishListSubTitle,
        ),
        AppSettingWidget(
          name: locale.lblOrders,
          image: ic_orders,
          widget: OrderListScreen(),
          subTitle: locale.lblOrdersSubtitle,
        ),
        AppSettingWidget(
          name: locale.lblCoupons,
          image: ic_coupons,
          subTitle: locale.lblCouponsSubtitle,
          widget: const CouponListScreen(),
        ),
      ],
    );
  }
}
