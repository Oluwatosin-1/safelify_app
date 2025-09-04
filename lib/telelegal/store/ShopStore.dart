import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/woo_commerce/billing_address_model.dart';
import 'package:safelify/telelegal/utils/constants/woocommerce_constants.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'ShopStore.g.dart';

class ShopStore = ShopStoreBase with _$ShopStore;

abstract class ShopStoreBase with Store {
  int? itemsInCartCount = 0;

  BillingAddressModel? billingAddress;

  BillingAddressModel? shippingAddress;

  void setCartCount(int value) {
    itemsInCartCount = value;

    setValue('${CartKeys.cartItemCountKey} of ${userStore.userName}', value);
  }

  void setBillingAddress(BillingAddressModel address) {
    billingAddress = address;
    setValue(CartKeys.billingAddress, address);
  }

  void setShippingAddress(BillingAddressModel address) {
    shippingAddress = address;
    setValue(CartKeys.shippingAddress, address);
  }
}
