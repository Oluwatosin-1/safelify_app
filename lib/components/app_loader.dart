// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/main.dart';
import 'package:nb_utils/nb_utils.dart';

class AppLoader extends StatelessWidget {
  final bool? visibleOn;
  final double? loaderSize;

  AppLoader({this.visibleOn, this.loaderSize});

  @override
  Widget build(BuildContext context) {
    return LoaderWidget(size: loaderSize).visible(visibleOn ?? appStore.isLoading);
  }
}
