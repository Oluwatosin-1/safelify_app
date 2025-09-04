import 'package:flutter/material.dart';
import 'package:safelify/components/app_scaffold.dart';
import 'package:safelify/network/google_repository.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class LanguageScreen extends StatefulWidget {
  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor,
        statusBarIconBrightness: Brightness.light);

    currentIndex = getIntAsync(SELECTED_LANGUAGE, defaultValue: 0);
    setState(() {});
  }

  @override
  void dispose() {
    getDisposeStatusBarColor();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: locale.lblLanguage,
      systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      textColor: Colors.white,
      child: LanguageListWidget(
        widgetType: WidgetType.LIST,
        onLanguageChange: (v) {
          appStore.setLoading(true);
          saveLanguageApi(
                  languageCode: v.fullLanguageCode.validate(
                      value: selectedLanguageDataModel!.fullLanguageCode
                          .validate()))
              .then((value) {
            toast(value.message);
            appStore.setLanguage(v.languageCode!);

            setState(() {});
            print(v);
            appStore.setLoading(false);
            finish(context, true);
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString());
          });
        },
      ),
    );
  }
}
