import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/components/empty_error_state_component.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/components/no_data_found_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/clinic_list_model.dart';
import 'package:safelify/network/clinic_repository.dart';
import 'package:safelify/screens/appointment/appointment_functions.dart';
import 'package:safelify/screens/appointment/components/clinic_list_component.dart';
import 'package:safelify/screens/shimmer/components/doctor_shimmer_component.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants.dart';
import 'package:safelify/utils/extensions/string_extensions.dart';
import 'package:safelify/utils/extensions/widget_extentions.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Step1ClinicSelectionScreen extends StatefulWidget {
  final bool sessionOrEncounter;
  final int? clinicId;

  Step1ClinicSelectionScreen({Key? key, this.sessionOrEncounter = false, this.clinicId});

  @override
  State<Step1ClinicSelectionScreen> createState() => _Step1ClinicSelectionScreenState();
}

class _Step1ClinicSelectionScreenState extends State<Step1ClinicSelectionScreen> {
  Future<List<Clinic>>? future;

  TextEditingController searchCont = TextEditingController();

  List<Clinic> clinicList = [];

  bool isLastPage = false;
  bool showClear = false;
  bool isFirst = true;

  int page = 1;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoading) {
      appStore.setLoading(false);
    }
    appointmentAppStore.setDescription(null);
    appointmentAppStore.setSelectedPatient(null);
    appointmentAppStore.setSelectedClinic(null);
    appointmentAppStore.setSelectedTime(null);
    appointmentAppStore.setSelectedPatientId(null);
    appointmentAppStore.setSelectedDoctor(null);
    appointmentAppStore.clearAll();
    multiSelectStore.clearList();

    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }
    future = getClinicListAPI(
      page: page,
      clinicList: clinicList,
      searchString: searchCont.text.trim(),
      lastPageCallback: (p0) => isLastPage = p0,
    ).then((value) {
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
    searchCont.clear();
    hideKeyboard(context);
    init(showLoader: true);
  }

  Future<void> _launchWhatsApp() async {
    const String whatsAppNumber = '+2348059148033';
    const String message = 'Hello, I need assistance with clinic selection.';
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

  void dispose() {
    appointmentAppStore.setSelectedClinic(null);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.sessionOrEncounter ? locale.lblSelectClinic : locale.lblAddNewAppointment,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        textColor: Colors.white,
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            if (!widget.sessionOrEncounter)
              Column(
                children: [
                  AppTextField(
                    controller: searchCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context: context,
                      hintText: locale.lblSearchClinic,
                      prefixIcon: ic_search.iconImage().paddingAll(16),
                      suffixIcon: showClear
                          ? ic_clear.iconImage().paddingAll(16).appOnTap(
                            () {
                          _onClearSearch();
                        },
                      )
                          : const Offstage(),
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
                  stepCountWidget(
                    name: locale.lblChooseYourClinic,
                    currentCount: 1,
                    totalCount: isDoctor() ? 2 : 3,
                    percentage: isPatient() ? 0.33 : 0.50,
                  ),
                ],
              ).paddingBottom(8),
            SnapHelperWidget<List<Clinic>>(
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
                snap.retainWhere((element) => element.status == ACTIVE_CLINIC_STATUS);
                if (snap.isEmpty && !appStore.isLoading) {
                  return SingleChildScrollView(
                    child: NoDataFoundWidget(
                      text: searchCont.text.isEmpty ? locale.lblNoActiveClinicAvailable : locale.lblCantFindClinicYouSearchedFor,
                    ),
                  ).center();
                }
                return AnimatedListView(
                  itemCount: snap.length,
                  onNextPage: () async {
                    if (!isLastPage) {
                      setState(() {
                        page++;
                      });
                      init(showLoader: true);
                      await 1.seconds.delay;
                    }
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  onSwipeRefresh: () async {
                    init(showLoader: false);
                    await 1.seconds.delay;
                  },
                  padding: const EdgeInsets.only(bottom: 90),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Clinic data = snap[index];
                    if (widget.clinicId != null && widget.sessionOrEncounter) {
                      if (data.id.toInt() == widget.clinicId) {
                        appointmentAppStore.setSelectedClinic(data);
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        if (widget.sessionOrEncounter) {
                          appointmentAppStore.setSelectedClinic(snap[index]);
                        } else {
                          if (appointmentAppStore.mClinicSelected != null ? appointmentAppStore.mClinicSelected!.id.validate() == data.id.validate() : false) {
                            appointmentAppStore.setSelectedClinic(null);
                          } else {
                            appointmentAppStore.setSelectedClinic(data);
                          }
                        }
                      },
                      child: Observer(
                        builder: (context) {
                          bool isSelected = appointmentAppStore.mClinicSelected != null ? appointmentAppStore.mClinicSelected!.id.validate() == data.id.validate() : false;
                          return ClinicListComponent(data: data, isSelected: isSelected);
                        },
                      ),
                    );
                  },
                );
              },
            ).paddingTop(widget.sessionOrEncounter ? 0 : 136),
            LoaderWidget().visible(appStore.isLoading).center()
          ],
        ).paddingOnly(left: 16, right: 16, top: 16);
      }),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 36,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'whatsapp_button_telehealth_step1',
              onPressed: _launchWhatsApp,
              backgroundColor: Colors.green,
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'proceed_button_telehealth_step1',
              label: Text(widget.sessionOrEncounter ? "Proceed" : "Proceed"),
              icon: Icon(widget.sessionOrEncounter ? Icons.done : Icons.arrow_forward_outlined),
              onPressed: () {
                if (widget.sessionOrEncounter) {
                  finish(context, appointmentAppStore.mClinicSelected);
                } else {
                  if (appointmentAppStore.mClinicSelected == null) {
                    toast(locale.lblSelectOneClinic);
                  } else {
                    clinicNavigation(context, clinicId: appointmentAppStore.mClinicSelected!.id.validate().toInt());
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
