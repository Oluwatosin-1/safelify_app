import 'package:flutter/material.dart';
import 'package:safelify/screens/shimmer/components/shimmer_component.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class CouponShimmerComponent extends StatelessWidget {
  const CouponShimmerComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerComponent(
      child: Container(
        width: context.width() - 32,
        margin: EdgeInsets.only(left: isRTL ? 0 : 16, right: isRTL ? 16 : 0),
        decoration: shimmerBoxInputDecoration(borderRadiusValue: defaultRadius),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerComponent(
                  baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
                  child: Container(
                    decoration: boxDecorationDefault(),
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                  ),
                ),
                ShimmerComponent(
                  baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
                  child: Container(
                    decoration: boxDecorationDefault(),
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  ),
                )
              ],
            ).paddingSymmetric(vertical: 8),
            Row(
              children: [
                Column(
                  children: [
                    ShimmerComponent(
                      baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
                      child: Container(
                        decoration: boxDecorationDefault(),
                        padding: EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                      ),
                    ),
                    ShimmerComponent(
                      baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
                      child: Container(
                        decoration: boxDecorationDefault(),
                        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                        margin: EdgeInsets.symmetric(vertical: 8),
                      ),
                    )
                  ],
                ).expand(),
                16.width,
                Column(
                  children: [
                    ShimmerComponent(
                      baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
                      child: Container(
                        decoration: boxDecorationDefault(),
                        padding: EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                      ),
                    ),
                    ShimmerComponent(
                      baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
                      child: Container(
                        decoration: boxDecorationDefault(),
                        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                        margin: EdgeInsets.symmetric(vertical: 8),
                      ),
                    )
                  ],
                ).expand()
              ],
            ).paddingSymmetric(vertical: 8),
            ShimmerComponent(
              baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
              child: Container(
                decoration: boxDecorationDefault(),
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                margin: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            ShimmerComponent(
              baseColor: shimmerPrimaryBaseColor.withOpacity(0.4),
              child: Container(
                decoration: boxDecorationDefault(),
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                margin: EdgeInsets.symmetric(vertical: 8),
              ),
            ).paddingOnly(right: 140)
          ],
        ),
      ),
    );
  }
}
