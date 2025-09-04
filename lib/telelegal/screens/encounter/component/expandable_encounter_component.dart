import 'package:flutter/material.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/encounter_model.dart';
import 'package:safelify/telelegal/screens/encounter/component/encounter_expandable_view.dart';
import 'package:safelify/telelegal/utils/extensions/enums.dart';
import 'package:safelify/telelegal/utils/extensions/string_extensions.dart';
import 'package:safelify/telelegal/utils/extensions/widget_extentions.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/constants.dart';

class ExpandableEncounterComponent extends StatefulWidget {
  final String title;
  final EncounterTypeEnum encounterType;
  final EncounterModel encounterData;
  bool isExpanded;
  final VoidCallback? refreshCallBack;
  EncounterTypeValues? encounterTypeValue;

  ExpandableEncounterComponent(
      {required this.title,
      required this.encounterType,
      this.refreshCallBack,
      required this.encounterData,
      this.encounterTypeValue,
      required this.isExpanded});

  @override
  _ExpandableEncounterComponentState createState() =>
      _ExpandableEncounterComponentState();
}

class _ExpandableEncounterComponentState
    extends State<ExpandableEncounterComponent> {
  String getTitle() {
    switch (widget.title) {
      case PROBLEM:
        return locale.lblProblems;
      case OBSERVATION:
        return locale.lblObservation;
      case NOTE:
        return locale.lblNotes;
      case PRESCRIPTION:
        return "Observation";
      case REPORT:
        return "Case File";
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.isExpanded = !widget.isExpanded;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        decoration: boxDecorationDefault(
            color: context.cardColor, borderRadius: radius()),
        child: AnimatedCrossFade(
          firstChild: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getTitle(), style: secondaryTextStyle(size: 16)),
              (widget.isExpanded ? ic_arrow_up : ic_arrow_down)
                  .iconImage(size: 16, color: context.iconColor)
                  .paddingAll(14)
                  .appOnTap(() {
                widget.isExpanded = !widget.isExpanded;
                setState(() {});
              }),
            ],
          ),
          secondChild: Stack(
            children: [
              Column(
                children: [
                  Divider(thickness: 1, color: context.dividerColor, height: 2),
                  4.height,
                  EncounterExpandableView(
                    encounterType: widget.title,
                    encounterData: widget.encounterData,
                    callForRefresh: () async {
                      widget.refreshCallBack?.call();
                    },
                  ),
                ],
              ).paddingTop(40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title.capitalizeFirstLetter(),
                      style: secondaryTextStyle(size: 16)),
                  (widget.isExpanded ? ic_arrow_up : ic_arrow_down)
                      .iconImage(size: 16, color: context.iconColor)
                      .paddingAll(14)
                      .appOnTap(() {
                    widget.isExpanded = !widget.isExpanded;
                    setState(() {});
                  }),
                ],
              ),
            ],
          ),
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: 400.milliseconds,
          firstCurve: Curves.bounceInOut,
        ),
      ),
    );
  }
}
