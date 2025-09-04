import 'package:flutter/material.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class ViewAllLabel extends StatelessWidget {
  final String label;
  final String? subLabel;
  final List? list;
  final num viewAllShowLimit;
  final VoidCallback? onTap;
  final int? labelSize;
  final int? subLabelSize;

  ViewAllLabel(
      {required this.label,
      this.subLabel,
      this.onTap,
      this.viewAllShowLimit = 4,
      this.labelSize,
      this.list,
      this.subLabelSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: boldTextStyle(size: labelSize ?? titleTextSize)),
            if (subLabel != null) 2.height,
            if (subLabel != null)
              Text(subLabel.validate(),
                  style: secondaryTextStyle(size: subLabelSize ?? 12)),
          ],
        ).expand(),
        TextButton(
          onPressed: (list == null ? true : isViewAllVisible(list!))
              ? () {
                  onTap?.call();
                }
              : null,
          child: (list == null ? true : isViewAllVisible(list!))
              ? Text(locale.lblViewAll,
                  style: secondaryTextStyle(color: appSecondaryColor))
              : const SizedBox(),
        )
      ],
    );
  }

  bool isViewAllVisible(List list) => list.length >= viewAllShowLimit;
}
