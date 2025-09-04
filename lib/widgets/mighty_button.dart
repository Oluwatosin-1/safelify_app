import 'package:flutter/material.dart';

import '../config.dart';
import '../utils/colors.dart';

class MightyButton extends StatelessWidget {
  MightyButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundGradient = primaryColor,
  }) : super(key: key);

  final String text;
  final void Function() onTap;
  Color? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kdBorderRadius),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundGradient,
          borderRadius: BorderRadius.circular(kdBorderRadius),
        ),
        child: FittedBox(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,//,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
