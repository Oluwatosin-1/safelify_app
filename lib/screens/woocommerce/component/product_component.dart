import 'package:flutter/material.dart';
import 'package:safelify/components/cached_image_widget.dart';
import 'package:safelify/components/disabled_rating_bar_widget.dart';
import 'package:safelify/components/price_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/woo_commerce/product_detail_model.dart';
import 'package:safelify/model/woo_commerce/product_list_model.dart';
import 'package:safelify/network/shop_repository.dart';
import 'package:safelify/screens/woocommerce/screens/product_detail_screen.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/constants/woocommerce_constants.dart';
import 'package:safelify/utils/extensions/string_extensions.dart';
import 'package:safelify/utils/extensions/widget_extentions.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ProductComponent extends StatefulWidget {
  final ProductListModel product;

  final VoidCallback? refreshCall;

  ProductComponent({Key? key, required this.product, this.refreshCall}) : super(key: key);

  @override
  State<ProductComponent> createState() => _ProductComponentState();
}

class _ProductComponentState extends State<ProductComponent> {
  bool? isWishListed;

  bool? isVisibleCart;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      isWishListed = widget.product.isAddedWishlist;
      isVisibleCart = widget.product.type != ProductTypes.variable && widget.product.type != ProductTypes.grouped && widget.product.type != ProductTypes.external;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void addToCart() {
    appStore.setLoading(true);
    addItemToCart(productId: widget.product.id.validate(), quantity: 1).then((value) {
      toast(locale.successfullyAddedToCart);
      shopStore.setCartCount(value.items.validate().length);
      widget.refreshCall?.call();
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  void removeFromFav() {
    setState(() {
      isWishListed = false;
    });
    toast(locale.lblRemovedFromWishList);
    removeFromWishlist(productId: widget.product.id.validate()).then((value) {
      widget.refreshCall?.call();
    }).catchError((e) {
      setState(() {
        isWishListed = true;
      });
    });
  }

  void addToFavorite() {
    isWishListed = true;
    setState(() {});
    toast(locale.lblAddedToWishList);
    addToWishlist(productId: widget.product.id.validate()).then((value) {
      widget.refreshCall?.call();
    }).catchError((e) {
      setState(() {
        isWishListed = false;
      });
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultRadius)),
      width: context.width() / 2 - 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CachedImageWidget(
                url: widget.product.images.validate().isNotEmpty ? widget.product.images.validate().first.src.validate() : ic_noProduct,
                height: 120,
                width: context.width() / 2 - 24,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRectOnly(
                topRight: defaultRadius.toInt(),
                topLeft: defaultRadius.toInt(),
              ),
              Positioned(
                top: widget.product.onSale.validate() && widget.product.ratingCount.validate() > 0 ? null : 12,
                bottom: widget.product.onSale.validate() && widget.product.ratingCount.validate() > 0 ? 8 : null,
                right: 0,
                child: isWishListed.validate()
                    ? ic_wish_listed
                        .iconImageColored(size: 18, color: Colors.red)
                        .appOnTap(() {
                          removeFromFav();
                        })
                        .paddingLeft(16)
                        .paddingRight(16)
                    : ic_favList
                        .iconImageColored(size: 18, color: Colors.black)
                        .appOnTap(() {
                          addToFavorite();
                        })
                        .paddingLeft(16)
                        .paddingRight(16),
              ),
              Positioned(
                left: 0,
                top: -1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: radiusOnly(
                      bottomRight: defaultRadius,
                      topLeft: defaultRadius,
                    ),
                  ),
                  child: Text(locale.lblSale, style: secondaryTextStyle(size: 10, color: Colors.white)),
                ),
              ).visible(widget.product.onSale.validate()),
              Positioned(
                top: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: boxDecorationDefault(
                    borderRadius: BorderRadius.only(
                      bottomLeft: radiusCircular(),
                      topRight: radiusCircular(),
                    ),
                  ),
                  child: DisabledRatingBarWidget(
                    rating: widget.product.averageRating.validate().toDouble(),
                    size: 14,
                    showRatingText: true,
                    itemCount: 1,
                  ).paddingSymmetric(horizontal: 4, vertical: 3),
                ),
              ).visible(widget.product.ratingCount.validate() > 0)
            ],
          ),
          8.height,
          Marquee(
            child: Text(widget.product.name.validate().capitalizeFirstLetter(), style: boldTextStyle(size: 14)).paddingSymmetric(horizontal: 4),
          ),
          PriceWidget(
            price: widget.product.price.validate(value: '0'),
            salePrice: widget.product.salePrice,
            regularPrice: widget.product.regularPrice,
            showDiscountPercentage: false,
            textSize: 14,
          ).paddingSymmetric(vertical: 4),
          if (isVisibleCart.validate())
            ic_addToCart.iconImageColored().appOnTap(() {
              addToCart();
            })
          else
            Text('', style: secondaryTextStyle()),
          8.height,
        ],
      ),
    ).appOnTap(
      () {
        appStore.setLoading(false);
        ProductDetailScreen(
          productId: widget.product.id.validate(),
          refreshCall: () {
            widget.refreshCall?.call();
          },
        ).launch(
          context,
          duration: pageAnimationDuration,
          pageRouteAnimation: pageAnimation,
        );
      },
      splashColor: appPrimaryColor,
    );
  }
}

class RelatedProductCardComponent extends StatefulWidget {
  final RelatedProductModel product;

  const RelatedProductCardComponent({required this.product});

  @override
  State<RelatedProductCardComponent> createState() => _RelatedProductCardComponentState();
}

class _RelatedProductCardComponentState extends State<RelatedProductCardComponent> {
  late RelatedProductModel product;

  @override
  void initState() {
    product = widget.product;

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        appStore.setLoading(false);
        ProductDetailScreen(productId: product.id.validate()).launch(context, duration: pageAnimationDuration, pageRouteAnimation: pageAnimation);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
        width: context.width() / 2 - 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedImageWidget(
                  url: product.images!.first.src.validate().isNotEmpty ? product.images!.first.src.validate() : ic_noProduct,
                  height: 150,
                  width: context.width() / 2 - 24,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRectOnly(topRight: defaultAppButtonRadius.toInt(), topLeft: defaultAppButtonRadius.toInt()),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: context.primaryColor, borderRadius: radiusOnly(topLeft: defaultAppButtonRadius, bottomRight: defaultAppButtonRadius)),
                  child: Text(locale.lblSale, style: secondaryTextStyle(size: 10, color: Colors.white)),
                ).visible(double.parse(product.regularPrice.validate()) > double.parse(product.salePrice.validate())),
              ],
            ),
            14.height,
            Text(product.name.validate().capitalizeFirstLetter(), style: boldTextStyle(size: 14)).paddingSymmetric(horizontal: 10),
            4.height,
            PriceWidget(
              price: product.price.validate(),
              salePrice: product.salePrice,
              regularPrice: product.regularPrice,
              showDiscountPercentage: false,
            ).paddingSymmetric(horizontal: 10),
            14.height,
          ],
        ),
      ),
    );
  }
}
