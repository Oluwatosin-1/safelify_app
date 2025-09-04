import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/components/empty_error_state_component.dart';
import 'package:safelify/components/internet_connectivity_widget.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/components/no_data_found_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/network/appointment_repository.dart';
import 'package:safelify/screens/appointment/appointment_functions.dart';
import 'package:safelify/screens/appointment/components/appointment_widget.dart';
import 'package:safelify/screens/doctor/fragments/appointment_fragment.dart';
import 'package:safelify/components/appointment_fragment_status_compoent.dart';
import 'package:safelify/screens/shimmer/screen/appointment_fragment_shimmer.dart';
import 'package:safelify/utils/cached_value.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:safelify/model/upcoming_appointment_model.dart';

class PatientAppointmentFragment extends StatefulWidget {
  @override
  _PatientAppointmentFragmentState createState() => _PatientAppointmentFragmentState();
}

class _PatientAppointmentFragmentState extends State<PatientAppointmentFragment> {
  Future<List<UpcomingAppointmentModel>>? future;

  int selectIndex = 0;

  List<UpcomingAppointmentModel> appointmentList = [];

  int page = 1;
  bool isLastPage = false;

  StreamSubscription? updateAppointmentApi;

  @override
  void initState() {
    super.initState();
    appStore.setStatus('All');

    String res = getStringAsync(SharedPreferenceKey.cachedAppointmentListKey);
    if (res.isNotEmpty) {
      cachedPatientAppointment = (jsonDecode(res) as List).map((e) => UpcomingAppointmentModel.fromJson(e)).toList();
    }

    updateAppointmentApi = appointmentStreamController.stream.listen((streamData) {
      setState(() {
        page = 1;
      });

      init();
    });
    init();
  }

  void init({bool showLoader = false}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }
    future = getPatientAppointmentList(
      userStore.userId.validate(),
      appointmentList: appointmentList,
      status: appStore.mStatus,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  String getEmptyText() {
    if (selectIndex == 0) {
      return locale.lblNoAppointmentsFound;
    } else if (selectIndex == 1) {
      return locale.lblNoLatestAppointmentFound;
    } else if (selectIndex == 2) {
      return locale.lblNoPendingAppointmentFound;
    } else if (selectIndex == 3) {
      return locale.lblNoCompletedAppointmentFound;
    } else if (selectIndex == 4) {
      return locale.lblNoCancelledAppointmentFound;
    } else if (selectIndex == 5) {
      return locale.lblNoAppointmentsFound;
    } else {
      return locale.lblNoAppointmentsFound;
    }
  }

  Future<void> changeStatus(int index) async {
    if (index == 0) {
      appStore.setStatus('All');
    } else if (index == 1) {
      appStore.setStatus('1');
    } else if (index == 2) {
      appStore.setStatus('2');
    } else if (index == 3) {
      appStore.setStatus('3');
    } else if (index == 4) {
      appStore.setStatus('0');
    } else if (index == 5) {
      appStore.setStatus('Past');
    }

    init(showLoader: true);
  }

  Future<void> _onSwipeRefresh() async {
    setState(() {
      page = 1;
    });
    init();

    return await 800.milliseconds.delay;
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
  void didUpdateWidget(covariant PatientAppointmentFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (updateAppointmentApi != null) {
      updateAppointmentApi!.cancel().then((value) {
        log("============== Stream Cancelled ==============");
        appStore.setLoading(false);
      });
    }
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppointmentFragmentStatusComponent(
            selectedIndex: selectIndex,
            callForStatusChange: (index) {
              appStore.setLoading(true);
              selectIndex = index;
              changeStatus(index);
              setState(() {});
            },
          ),
          InternetConnectivityWidget(
            child: SnapHelperWidget<List<UpcomingAppointmentModel>>(
              future: future,
              initialData: cachedPatientAppointment,
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: error.toString(),
                );
              },
              errorWidget: const ErrorStateWidget(),
              loadingWidget: AppointmentFragmentShimmer(),
              onSuccess: (snap) {
                return AnimatedListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snap.length,
                    disposeScrollController: true,
                    onSwipeRefresh: () {
                      return _onSwipeRefresh();
                    },
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    onNextPage: () {
                      _onNextPage();
                    },
                    shrinkWrap: true,
                    listAnimationType: listAnimationType,
                    slideConfiguration: SlideConfiguration(verticalOffset: 400),
                    itemBuilder: (_, index) {
                      return AppointmentWidget(
                        upcomingData: snap[index],
                        refreshCall: () {
                          init();
                        },
                      ).paddingSymmetric(vertical: 8);
                    }).visible(snap.isNotEmpty, defaultWidget: snap.isEmpty && !appStore.isLoading ? NoDataFoundWidget(text: getEmptyText()).center() : const Offstage());
              },
            ).paddingTop(100),
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading).center())
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Create \n Appointment"),
        icon: const Icon(Icons.add),
        onPressed: () {
          appointmentWidgetNavigation(context);
        },
      ).visible(isVisible(SharedPreferenceKey.kiviCareAppointmentAddKey)),
    );
  }
}
