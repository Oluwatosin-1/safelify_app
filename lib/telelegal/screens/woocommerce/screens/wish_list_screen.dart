import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/telelegal/components/loader_widget.dart';
import 'package:safelify/telelegal/components/no_data_found_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/woo_commerce/common_models.dart';
import 'package:safelify/telelegal/model/woo_commerce/product_list_model.dart';
import 'package:safelify/telelegal/model/woo_commerce/wish_list_model.dart';
import 'package:safelify/telelegal/network/shop_repository.dart';
import 'package:safelify/telelegal/screens/shimmer/screen/product_list_shimmer_screen.dart';
import 'package:safelify/telelegal/screens/woocommerce/component/product_component.dart';
import 'package:safelify/telelegal/screens/woocommerce/screens/cart_screen.dart';
import 'package:safelify/telelegal/screens/woocommerce/screens/order_list_screen.dart';
import 'package:safelify/telelegal/screens/woocommerce/screens/product_list_screen.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/constants/woocommerce_constants.dart';
import 'package:safelify/telelegal/utils/extensions/string_extensions.dart';
import 'package:safelify/telelegal/utils/extensions/widget_extentions.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class WishListScreen extends StatefulWidget {
  final bool isFromProductDetail;
  const WishListScreen({this.isFromProductDetail = false});

  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  Future<List<WishList>>? future;

  List<WishList> wishList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool showLoader = false, String? status}) async {
    if (showLoader) appStore.setLoading(true);
    future = getWishList(
      wishList: wishList,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      setState(() {});

      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> onNextPage() async {
    setState(() {
      page++;
    });
    init(showLoader: true);
  }

  Future<void> onRefresh({bool showLoader = false}) async {
    init(showLoader: showLoader);
    return 1.seconds.delay;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (!widget.isFromProductDetail) getDisposeStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(locale.myWishlist,
          textColor: Colors.white,
          systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
          actions: [
            ic_checkList
                .iconImageColored(color: Colors.white, isRoundedCorner: true)
                .appOnTap(() {
              OrderListScreen().launch(context,
                  pageRouteAnimation: pageAnimation,
                  duration: pageAnimationDuration);
            }).paddingTop(shopStore.itemsInCartCount.validate() > 0 ? 8 : 0),
            Stack(
              children: [
                ic_cart
                    .iconImageColored(size: 22, color: Colors.white)
                    .paddingSymmetric(horizontal: 16)
                    .appOnTap(() {
                  CartScreen().launch(context,
                      pageRouteAnimation: pageAnimation,
                      duration: pageAnimationDuration);
                }).paddingTop(
                        shopStore.itemsInCartCount.validate() > 0 ? 8 : 0),
                Positioned(
                  top: -4,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: boxDecorationDefault(
                      color: appSecondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                        '${getIntAsync('${CartKeys.cartItemCountKey} of ${userStore.userName}')}',
                        style:
                            secondaryTextStyle(color: Colors.white, size: 12)),
                  ),
                ).visible(getIntAsync(
                        '${CartKeys.cartItemCountKey} of ${userStore.userName}') >
                    0)
              ],
            )
          ]),
      body: Stack(
        children: [
          AnimatedScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
            physics: AlwaysScrollableScrollPhysics(),
            disposeScrollController: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            listAnimationType: ListAnimationType.None,
            slideConfiguration: SlideConfiguration(verticalOffset: 400),
            onSwipeRefresh: onRefresh,
            onNextPage: onNextPage,
            children: [
              SnapHelperWidget(
                future: future,
                loadingWidget: ProductListScreenShimmer(),
                errorBuilder: (error) {
                  return NoDataFoundWidget(
                    text: error.toString(),
                    iconSize: 150,
                    retryText: locale.clickToRefresh,
                    onRetry: onRefresh,
                  ).center();
                },
                onSuccess: (data) {
                  if (data.isEmpty)
                    return SizedBox(
                      height: context.height() * 0.7,
                      width: context.width(),
                      child: NoDataFoundWidget(
                        text: locale.lblEmptyWishList,
                        retryText: locale.lblViewProducts,
                        onRetry: () {
                          if (widget.isFromProductDetail) {
                            finish(context);
                            finish(context);
                          } else
                            ProductListScreen(
                              refreshCall: () {
                                init();
                              },
                            ).launch(
                              context,
                              duration: pageAnimationDuration,
                              pageRouteAnimation: pageAnimation,
                            );
                        },
                        iconSize: 150,
                      ).center(),
                    );
                  else
                    return Wrap(
                      runSpacing: 16,
                      spacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: data.map((wishListProduct) {
                        ProductListModel product = ProductListModel(
                          id: wishListProduct.proId,
                          name: wishListProduct.name,
                          sku: wishListProduct.sku,
                          type: wishListProduct.proType,
                          price: wishListProduct.price,
                          regularPrice: wishListProduct.regularPrice,
                          salePrice: wishListProduct.salePrice,
                          isAddedWishlist: true,
                          images: wishListProduct.gallery.validate().isNotEmpty
                              ? wishListProduct.gallery
                              : wishListProduct.thumbnail.validate().isNotEmpty
                                  ? [
                                      ImageModel(
                                          src: wishListProduct.full.validate())
                                    ]
                                  : null,
                        );
                        return ProductComponent(
                          product: product,
                          refreshCall: () => init(),
                        );
                      }).toList(),
                    );
                },
              )
            ],
          ),
          Observer(
              builder: (context) =>
                  LoaderWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
