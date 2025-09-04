import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/telelegal/components/empty_error_state_component.dart';
import 'package:safelify/telelegal/components/loader_widget.dart';
import 'package:safelify/telelegal/components/no_data_found_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/encounter_model.dart';
import 'package:safelify/telelegal/model/user_model.dart';
import 'package:safelify/telelegal/network/encounter_repository.dart';
import 'package:safelify/telelegal/screens/shimmer/screen/encounter_shimmer_screen.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:safelify/telelegal/screens/encounter/screen/add_encounter_screen.dart';
import 'package:safelify/telelegal/screens/encounter/component/encounter_list_component.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';

class PatientEncounterListScreen extends StatefulWidget {
  final UserModel? patientData;

  PatientEncounterListScreen({this.patientData});

  @override
  _PatientEncounterListScreenState createState() =>
      _PatientEncounterListScreenState();
}

class _PatientEncounterListScreenState
    extends State<PatientEncounterListScreen> {
  Future<List<EncounterModel>>? future;

  List<EncounterModel> patientEncounterList = [];

  int total = 0;
  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool showLoader = false}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }

    future = getPatientEncounterList(
      id: widget.patientData!.iD,
      page: page,
      encounterList: patientEncounterList,
      getTotalPatient: (b) => total = b,
      lastPageCallback: (b) => isLastPage = b,
    ).whenComplete(() {
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  bool get isEdit {
    return isVisible(SharedPreferenceKey.kiviCarePatientEncounterEditKey);
  }

  bool get isDelete {
    return isVisible(SharedPreferenceKey.kiviCarePatientEncounterDeleteKey);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "${widget.patientData!.displayName.validate().capitalizeEachWord()} 'Consultation'",
        textColor: Colors.white,
        elevation: 0,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<EncounterModel>>(
            future: future,
            loadingWidget: EncounterShimmerScreen(),
            errorBuilder: (error) {
              return ErrorStateWidget(
                error: error.toString(),
              );
            },
            onSuccess: (snap) {
              if (snap.isEmpty) {
                return NoDataFoundWidget(
                    text: "No Consultation Found at Your Firm ");
              }
              return AnimatedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                disposeScrollController: true,
                listAnimationType: listAnimationType,
                slideConfiguration: SlideConfiguration(verticalOffset: 400),
                onSwipeRefresh: () async {
                  setState(() {
                    page = 1;
                  });
                  init();
                  return await 1.seconds.delay;
                },
                onNextPage: () async {
                  if (!isLastPage) {
                    setState(() {
                      page++;
                    });
                    init(showLoader: true);
                    await 1.seconds.delay;
                  }
                },
                children: [
                  16.height,
                  if (isEdit || isDelete)
                    Text(
                            locale.lblNote.suffixText(value: ' : ') +
                                locale.lblSwipeMassage,
                            style: secondaryTextStyle(
                                size: 10, color: appSecondaryColor))
                        .paddingOnly(left: 20),
                  8.height,
                  AnimatedListView(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snap.length,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      EncounterModel data = snap[index];
                      return GestureDetector(
                        onTap: () {
                          if (isEdit) {
                            AddEncounterScreen(
                                    patientEncounterData: data,
                                    patientId: data.patientId.toInt())
                                .launch(context,
                                    pageRouteAnimation: pageAnimation,
                                    duration: pageAnimationDuration)
                                .then((value) {
                              if (value ?? false) {
                                init();
                              }
                            });
                          }
                        },
                        child: EncounterListComponent(
                          data: data,
                          patientData: widget.patientData,
                          refreshCall: () {
                            init(showLoader: true);
                          },
                        ).paddingSymmetric(vertical: 8),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          Observer(
              builder: (context) =>
                  LoaderWidget().visible(appStore.isLoading).center())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await AddEncounterScreen(patientId: widget.patientData!.iD)
              .launch(context,
                  pageRouteAnimation: pageAnimation,
                  duration: pageAnimationDuration)
              .then((value) {
            if (value ?? false) {
              init(showLoader: true);
            }
          });
        },
      ),
    );
  }
}
