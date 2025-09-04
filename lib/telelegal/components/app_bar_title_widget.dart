import 'package:flutter/material.dart';
import 'package:safelify/telelegal/components/time_greeting_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/utils/extensions/string_extensions.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:safelify/telelegal/utils/common.dart';

class AppBarTitleWidget extends StatelessWidget {
  const AppBarTitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(ic_hi, width: 22, height: 22, fit: BoxFit.cover),
            8.width,
            TimeGreetingWidget(
                    userName: isDoctor()
                        ? userStore.firstName
                            .validate()
                            .prefixText(value: 'Lawyer.  ')
                        : userStore.firstName.validate(),
                    separator: ',')
                .expand(),
          ],
        ),
      ],
    );
  }
}
