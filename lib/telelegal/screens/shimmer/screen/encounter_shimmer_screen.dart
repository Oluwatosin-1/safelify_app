import 'package:flutter/material.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/screens/shimmer/components/shimmer_component.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class EncounterShimmerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedWrap(
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.start,
      listAnimationType: listAnimationType,
      children: List.generate(
        8,
        (index) => ShimmerComponent(
          child: Container(
            width: context.width(),
            padding: EdgeInsets.all(16),
            decoration:
                shimmerBoxInputDecoration(borderRadiusValue: defaultRadius),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: List.generate(
                    3,
                    (index) => ShimmerComponent(
                      baseColor: shimmerLightBaseColor.withOpacity(0.4),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration:
                            boxDecorationDefault(borderRadius: radius()),
                      ),
                    ),
                  ),
                ).expand(flex: 4),
                16.width,
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerComponent(
                      baseColor: shimmerLightBaseColor.withOpacity(0.4),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: boxDecorationDefault(
                          borderRadius: radius(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    ShimmerComponent(
                      baseColor: shimmerLightBaseColor.withOpacity(0.4),
                      child: Container(
                        margin: EdgeInsets.only(top: 22),
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration:
                            boxDecorationDefault(borderRadius: radius()),
                      ),
                    ),
                  ],
                ).expand(flex: 1)
              ],
            ),
          ),
        ),
      ),
    ).paddingSymmetric(horizontal: 16, vertical: 16);
  }
}
