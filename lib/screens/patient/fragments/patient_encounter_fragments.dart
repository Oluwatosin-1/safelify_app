import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/components/internet_connectivity_widget.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/components/no_data_found_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/network/encounter_repository.dart';
import 'package:safelify/screens/encounter/component/encounter_component.dart';
import 'package:safelify/screens/shimmer/screen/encounter_shimmer_screen.dart';
import 'package:safelify/utils/cached_value.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:safelify/model/encounter_model.dart';


class EncounterFragment extends StatefulWidget {
  const EncounterFragment({super.key});

  @override
  _EncounterFragmentState createState() => _EncounterFragmentState();
}

class _EncounterFragmentState extends State<EncounterFragment> {
  Future<List<EncounterModel>>? future;

  List<EncounterModel> encounterList = [];
  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    String res = getStringAsync(SharedPreferenceKey.cachedEncounterListKey);
    if (res.isNotEmpty) {
      cachedEncounterList = (jsonDecode(res) as List).map((e) => EncounterModel.fromJson(e)).toList();
    }
    init();
  }

  Future<void> init({bool showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);

    future = getPatientEncounterList(
      id: userStore.userId.validate(),
      page: page,
      encounterList: encounterList,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      setValue(SharedPreferenceKey.cachedEncounterListKey, jsonEncode(value.map((e) => e.toJson()).toList()));
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
    setState(() {});
  }

  Future<void> _onSwipeRefresh() async {
    setState(() {
      page = 1;
    });
    init();

    return await 2.seconds.delay;
  }

  Future<void> _onNextPage() async {
    if (!isLastPage) {
      setState(() {
        page++;
      });
      init(showLoader: true);
      await 1.seconds.delay;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InternetConnectivityWidget(
            child: SnapHelperWidget<List<EncounterModel>>(
              future: future,
              initialData: cachedEncounterList,
              loadingWidget: EncounterShimmerScreen(),
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: error.toString(),
                );
              },
              onSuccess: (snap) {
                return AnimatedListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snap.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),  // Adjust padding as needed
                  onSwipeRefresh: () {
                    return _onSwipeRefresh();
                  },
                  onNextPage: () {
                    _onNextPage();
                  },
                  listAnimationType: listAnimationType,
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  itemBuilder: (_, index) {
                    return EncounterComponent(
                      data: snap[index],
                      deleteEncounter: null,  // Remove delete callback
                    ).paddingSymmetric(vertical: 8);
                  },
                ).visible(
                  snap.isNotEmpty,
                  defaultWidget: snap.isEmpty && !appStore.isLoading
                      ? NoDataFoundWidget(text: locale.lblNoEncounterFound).center()
                      : const Offstage(),
                );
              },
            ).paddingTop(0),  // Remove padding if no space is needed
          ),
          Observer(
            builder: (context) {
              return LoaderWidget().visible(appStore.isLoading).center();
            },
          ),
        ],
      ),
     );
  }
}
