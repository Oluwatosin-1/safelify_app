import 'package:flutter/material.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/widgets/spining_lines.dart';

class LoaderWidget extends StatelessWidget {
  final double? size;

  LoaderWidget({this.size});

  @override
  Widget build(BuildContext context) {
    return SpinKitSpinningLines(color: primaryColor, size: size ?? 56);
  }
}
