import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/telelegal/components/empty_error_state_component.dart';
import 'package:safelify/telelegal/components/internet_connectivity_widget.dart';
import 'package:safelify/telelegal/components/loader_widget.dart';
import 'package:safelify/telelegal/components/no_data_found_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/service_model.dart';
import 'package:safelify/telelegal/network/service_repository.dart';
import 'package:safelify/telelegal/screens/doctor/screens/service/add_service_screen.dart';
import 'package:safelify/telelegal/screens/doctor/screens/service/components/service_widget.dart';
import 'package:safelify/telelegal/screens/shimmer/components/services_shimmer_component.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/extensions/string_extensions.dart';
import 'package:safelify/telelegal/utils/extensions/widget_extentions.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';


class ServiceListScreen extends StatefulWidget {
  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  Future<List<ServiceData>>? future;

  TextEditingController searchCont = TextEditingController();

  List<ServiceData> serviceList = [];
  int total = 0;
  int page = 1;

  bool isLastPage = false;
  bool showClear = false;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }

    future = getServiceListAPI(
      searchString: searchCont.text,
      id: isReceptionist()
          ? userStore.userClinicId.validate().toInt()
          : userStore.userId.validate(),
      perPages: 50,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      appStore.setLoading(false);
      if (searchCont.text.isNotEmpty) {
        showClear = true;
      } else {
        showClear = false;
      }
      setState(() {});
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      setState(() {});
      throw e;
    });
  }

  Future<void> _onClearSearch() async {
    hideKeyboard(context);

    searchCont.clear();
    init(showLoader: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    getDisposeStatusBarColor();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ServiceListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: appBarWidget(
          locale.lblServices,
          textColor: Colors.white,
          systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
          actions: [],
        ),
        body: InternetConnectivityWidget(
          retryCallback: () async {
            init();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: searchCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context: context,
                      hintText: locale.lblSearchServices,
                      prefixIcon: ic_search.iconImage().paddingAll(16),
                      suffixIcon: !showClear
                          ? Offstage()
                          : ic_clear.iconImage().paddingAll(16).appOnTap(
                              () async {
                                _onClearSearch();
                              },
                              borderRadius: radius(),
                            ),
                    ),
                    onChanged: (newValue) {
                      if (newValue.isEmpty) {
                        showClear = false;
                        _onClearSearch();
                      } else {
                        Timer(pageAnimationDuration, () {
                          init(showLoader: true);
                        });
                        showClear = true;
                      }
                      setState(() {});
                    },
                    onFieldSubmitted: (searchString) async {
                      hideKeyboard(context);
                      init(showLoader: true);
                    },
                  ),
                  16.height,
                  Text('${locale.lblNote} : ${locale.lblTapMsg}',
                      style: secondaryTextStyle(
                          size: 10, color: appSecondaryColor)),
                ],
              ).paddingSymmetric(horizontal: 16, vertical: 16),
              SnapHelperWidget<List<ServiceData>>(
                future: future,
                errorBuilder: (p0) {
                  return ErrorStateWidget(
                    error: p0.toString(),
                  );
                },
                loadingWidget: AnimatedWrap(
                  runSpacing: 16,
                  spacing: 16,
                  listAnimationType: listAnimationType,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: List.generate(
                    4,
                    (index) => ServicesShimmerComponent(
                        isForDoctorServicesList: isDoctor()),
                  ),
                ).paddingSymmetric(horizontal: 16, vertical: 16),
                onSuccess: (snap) {
                  if (snap.isEmpty && !appStore.isLoading) {
                    return SingleChildScrollView(
                      child: NoDataFoundWidget(
                        iconSize:
                            searchCont.text.isNotEmpty && appStore.isLoading
                                ? 60
                                : 160,
                        text: searchCont.text.isNotEmpty
                            ? locale.lblCantFindServiceYouSearchedFor
                            : locale.lblNoServicesFound,
                      ),
                    ).center();
                  }

                  return AnimatedScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
                    disposeScrollController: true,
                    listAnimationType: ListAnimationType.None,
                    physics: AlwaysScrollableScrollPhysics(),
                    slideConfiguration: SlideConfiguration(verticalOffset: 400),
                    onSwipeRefresh: () async {
                      init(showLoader: true);
                      return await 1.seconds.delay;
                    },
                    onNextPage: () async {
                      setState(() {
                        page++;
                      });
                      init(showLoader: true);
                      await 1.seconds.delay;
                    },
                    children: [
                      AnimatedWrap(
                        spacing: 16,
                        runSpacing: 16,
                        direction: Axis.horizontal,
                        listAnimationType: listAnimationType,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        itemCount: snap.length,
                        itemBuilder: (p0, index) {
                          ServiceData data = snap[index];

                          return GestureDetector(
                            onTap: () async {
                              if (isVisible(
                                  SharedPreferenceKey.kiviCareServiceEditKey))
                                await AddServiceScreen(
                                        serviceData: data,
                                        callForRefresh: () {
                                          init();
                                        })
                                    .launch(context,
                                        pageRouteAnimation: pageAnimation,
                                        duration: pageAnimationDuration)
                                    .then((value) {
                                  if (value ?? false) {
                                    init();
                                  }
                                });
                            },
                            child: ServiceWidget(data: data),
                          );
                        },
                      ),
                    ],
                  );
                },
              ).paddingTop(isDoctor() ? 102 : 100),
              LoaderWidget().visible(appStore.isLoading).center()
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            if (appStore.isConnectedToInternet) {
              await AddServiceScreen()
                  .launch(context,
                      pageRouteAnimation: pageAnimation,
                      duration: pageAnimationDuration)
                  .then((value) {
                if (value ?? false) {
                  init();
                  setState(() {});
                }
              });
            } else {
              toast(locale.lblNoInternetMsg);
            }
          },
        ).visible(isVisible(SharedPreferenceKey.kiviCareServiceAddKey)),
      );
    });
  }
}
