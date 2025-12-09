import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/telelegal/components/empty_error_state_component.dart';
import 'package:safelify/telelegal/components/loader_widget.dart';
import 'package:safelify/telelegal/components/no_data_found_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/user_model.dart';
import 'package:safelify/telelegal/network/doctor_repository.dart';
import 'package:safelify/telelegal/screens/appointment/appointment_functions.dart';
import 'package:safelify/screens/receptionist/screens/doctor/component/doctor_list_component.dart';
import 'package:safelify/telelegal/screens/shimmer/components/doctor_shimmer_component.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/extensions/string_extensions.dart';
import 'package:safelify/telelegal/utils/extensions/widget_extentions.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Step2DoctorSelectionScreen extends StatefulWidget {
  final int? clinicId;
  final bool isForAppointment;
  final int? doctorId;

  const Step2DoctorSelectionScreen(
      {this.clinicId, this.isForAppointment = false, this.doctorId});

  @override
  _Step2DoctorSelectionScreenState createState() =>
      _Step2DoctorSelectionScreenState();
}

class _Step2DoctorSelectionScreenState extends State<Step2DoctorSelectionScreen> {
  Future<List<UserModel>>? future;

  TextEditingController searchCont = TextEditingController();

  List<UserModel> doctorList = [];

  bool isLastPage = false;
  bool showClear = false;

  int page = 1;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoading) {
      appStore.setLoading(false);
    }
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }

    future = getDoctorListWithPagination(
      searchString: searchCont.text,
      clinicId: widget.clinicId,
      doctorList: doctorList,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      if (value.validate().isNotEmpty) {
        listAppStore.addDoctor(value);
      }
      if (searchCont.text.isNotEmpty) {
        showClear = true;
      } else {
        showClear = false;
      }
      setState(() {});
      appStore.setLoading(false);
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

  Future<void> _launchWhatsApp() async {
    const String whatsAppNumber = '+2348059148033';
    const String message = 'Hello, I need assistance with lawyer selection.';
    final url = 'https://wa.me/$whatsAppNumber?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      toast('Could not launch WhatsApp');
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appointmentAppStore.setSelectedDoctor(null);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        !widget.isForAppointment.validate() ? 'Select Lawyer' : locale.lblAddNewAppointment,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            if (widget.isForAppointment)
              Column(
                children: [
                  AppTextField(
                    controller: searchCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context: context,
                      hintText: 'Search Lawyer',
                      prefixIcon: ic_search.iconImage().paddingAll(16),
                      suffixIcon: showClear
                          ? ic_clear.iconImage().paddingAll(16).appOnTap(() async {
                        _onClearSearch();
                      })
                          : const Offstage(),
                    ),
                    onChanged: (newValue) {
                      if (newValue.isEmpty) {
                        showClear = false;
                        _onClearSearch();
                      } else {
                        Timer(const Duration(milliseconds: 500), () {
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
                  stepCountWidget(
                    name: 'Choose Your Lawyer',
                    currentCount: isPatient() ? 2 : 1,
                    totalCount: isReceptionist() ? 2 : 3,
                    percentage: isPatient() ? 0.66 : 0.50,
                  ),
                ],
              ).paddingSymmetric(vertical: 8),
            SnapHelperWidget<List<UserModel>>(
              future: future,
              loadingWidget: AnimatedWrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(4, (index) => DoctorShimmerComponent()),
              ),
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: error.toString(),
                );
              },
              errorWidget: const ErrorStateWidget(),
              onSuccess: (snap) {
                snap.retainWhere((element) => element.userStatus.toInt() == ACTIVE_USER_INT_STATUS);
                if (snap.isEmpty && !appStore.isLoading) {
                  return SingleChildScrollView(
                    child: NoDataFoundWidget(
                      text: searchCont.text.isEmpty
                          ? 'No Active Lawyer Available'
                          : 'Can\'t find the lawyer you searched for',
                    ),
                  ).center();
                }
                return AnimatedListView(
                  itemCount: snap.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  onSwipeRefresh: () async {
                    init(showLoader: false);
                    await 1.seconds.delay;
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
                  itemBuilder: (context, index) {
                    UserModel data = snap[index];
                    if (widget.doctorId != null && data.iD == widget.doctorId) {
                      appointmentAppStore.setSelectedDoctor(data);
                    }
                    return GestureDetector(
                      onTap: () {
                        if (appointmentAppStore.mDoctorSelected != null &&
                            appointmentAppStore.mDoctorSelected!.iD.validate() == data.iD.validate()) {
                          appointmentAppStore.setSelectedDoctor(null);
                        } else {
                          appointmentAppStore.setSelectedDoctor(data);
                        }
                      },
                      child: Observer(builder: (context) {
                        return DoctorListComponent(
                          data: data,
                          isSelected: appointmentAppStore.mDoctorSelected?.iD.validate() == data.iD.validate(),
                        ).paddingSymmetric(vertical: 8);
                      }),
                    );
                  },
                );
              },
            ).paddingTop(widget.isForAppointment ? 142 : 0),
            LoaderWidget().visible(appStore.isLoading).center(),
          ],
        ).paddingOnly(left: 16, right: 16, top: 16);
      }),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 36,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'whatsapp_button_telelegal_step2',
              onPressed: _launchWhatsApp,
              backgroundColor: Colors.green,
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'proceed_button_telelegal_step2',
              label: Text(widget.isForAppointment ? 'Proceed' : 'Done'),
              icon: Icon(widget.isForAppointment ? Icons.arrow_forward_outlined : Icons.done),
              onPressed: () {
                if (appointmentAppStore.mDoctorSelected == null) {
                  toast('Select One Lawyer');
                } else {
                  if (!widget.isForAppointment.validate()) {
                    finish(context, appointmentAppStore.mDoctorSelected);
                  } else {
                    doctorNavigation(
                      context,
                      clinicId: widget.clinicId.validate().toInt(),
                      doctorId: appointmentAppStore.mDoctorSelected!.iD.validate(),
                    ).then((value) {});
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
