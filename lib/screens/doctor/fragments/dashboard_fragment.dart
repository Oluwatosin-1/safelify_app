import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:safelify/components/empty_error_state_component.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/dashboard_model.dart';
import 'package:safelify/network/dashboard_repository.dart';
import 'package:safelify/screens/doctor/components/dashboard_fragment_analytics_component.dart';
import 'package:safelify/screens/doctor/components/dashboard_fragment_appointment_component.dart';
import 'package:safelify/screens/doctor/components/dashboard_fragment_chart_component.dart';
import 'package:safelify/screens/shimmer/screen/doctor_dashboard_shimmer_fragment.dart';
import 'package:safelify/utils/cached_value.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardModel>? future;

  @override
  void initState() {
    super.initState();
    String res = getStringAsync(SharedPreferenceKey.cachedDashboardDataKey).validate();
    if (res.isNotEmpty) {
      cachedDoctorDashboardModel = DashboardModel.fromJson(jsonDecode(getStringAsync(SharedPreferenceKey.cachedDashboardDataKey)));
    }
    init();
  }

  void init({bool showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);
    future = getUserDashBoardAPI().then((value) {
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant DashboardFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SnapHelperWidget<DashboardModel>(
        initialData: cachedDoctorDashboardModel,
        future: future,
        errorBuilder: (error) {
          return NoDataWidget(
            imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
            title: error.toString(),
          );
        },
        errorWidget: ErrorStateWidget(),
        loadingWidget: DoctorDashboardShimmerFragment(),
        onSuccess: (data) {
          return AnimatedScrollView(
            children: [
              DashboardFragmentAnalyticsComponent(data: data).center().paddingSymmetric(vertical: 16, horizontal: 16),
              DashboardFragmentChartComponent(data: data),
              if (isVisible(SharedPreferenceKey.kiviCareAppointmentListKey))
                DashboardFragmentAppointmentComponent(
                  data: data,
                  callback: () {
                    init();
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
