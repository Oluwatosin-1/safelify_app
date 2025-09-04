import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safelify/app_theme.dart';
import 'package:safelify/components/loader_widget.dart';
import 'package:safelify/components/ul_widget.dart';
import 'package:safelify/components/view_all_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/user_model.dart';
import 'package:safelify/network/auth_repository.dart';
import 'package:safelify/network/doctor_repository.dart';
import 'package:safelify/screens/patient/screens/review/component/review_widget.dart';
import 'package:safelify/screens/patient/screens/review/rating_view_all_screen.dart';
import 'package:safelify/screens/receptionist/components/qualification_item_widget.dart';
import 'package:safelify/screens/receptionist/screens/doctor/add_doctor_screen.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:safelify/utils/extensions/string_extensions.dart';
import 'package:safelify/utils/extensions/widget_extentions.dart';
import 'package:safelify/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorDetailScreen extends StatefulWidget {
  final UserModel doctorData;
  final VoidCallback? refreshCall;

  DoctorDetailScreen({Key? key, this.refreshCall, required this.doctorData}) : super(key: key);

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  ScrollController controller = ScrollController();
  late UserModel doctor;

  double topPosition = 250;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.dark);
    });

    getDoctorData(showLoader: isPatient() || isReceptionist() ? true : false);
  }

  Future<void> getDoctorData({bool showLoader = true}) async {
    doctor = widget.doctorData;

    if (widget.doctorData.doctorId.validate().isNotEmpty && widget.doctorData.doctorId.validate().toInt() != 0) {
      doctor.iD = widget.doctorData.doctorId.toInt();
    }
    if (showLoader) {
      appStore.setLoading(true);
    }
    getSingleUserDetailAPI(doctor.iD.validate()).then((value) {
      appStore.setLoading(false);

      if (value.iD == null) value.iD = doctor.iD;
      if (value.available == null) value.available = doctor.available;
      if (doctor.ratingList.validate().isNotEmpty) value.ratingList = doctor.ratingList;

      if (value.displayName == null) value.displayName = '${value.firstName} ${value.lastName.validate()}';
      doctor = value;
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString());
      log("GET DOCTOR ERROR : ${e.toString()} ");
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> deleteDoctor(int doctorId) async {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.DELETE,
      title: locale.lblDoYouWantToDeleteDoctor,
      onAccept: (p0) {
        Map<String, dynamic> request = {
          "doctor_id": doctorId,
        };

        appStore.setLoading(true);

        deleteDoctorAPI(request).then((value) {
          appStore.setLoading(false);
          toast(locale.lblDoctorDeleted);
          finish(context, true);
          finish(context, true);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
          throw e;
        });

        appStore.setLoading(false);
      },
    );
  }

  bool get isEdit {
    return isVisible(SharedPreferenceKey.kiviCareDoctorEditKey);
  }

  bool get isDelete {
    return isVisible(SharedPreferenceKey.kiviCareDoctorDeleteKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: controller,
            shrinkWrap: false,
            slivers: <Widget>[
              Theme(
                data: appStore.isDarkModeOn ? AppTheme.darkTheme : AppTheme.lightTheme,
                child: SliverAppBar(
                  leading: BackButton(color: Colors.black),
                  systemOverlayStyle: defaultSystemUiOverlayStyle(context),
                  expandedHeight: context.height() / 2 - 48,
                  backgroundColor: context.scaffoldBackgroundColor,
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return FlexibleSpaceBar(
                        background: SizedBox(
                          height: context.height() / 2 - 32,
                          child: Stack(
                            children: [
                              Container(
                                height: context.height() * 0.40,
                                width: context.width(),
                                alignment: Alignment.bottomCenter,
                                decoration: boxDecorationDefault(
                                  borderRadius: BorderRadius.zero,
                                  color: doctor.profileImage.validate().isNotEmpty ? null : context.scaffoldBackgroundColor,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: List.generate(10, (index) => Colors.black.withAlpha(index * 32)),
                                  ),
                                  image: doctor.profileImage.validate().isNotEmpty
                                      ? DecorationImage(
                                    image: NetworkImage(doctor.profileImage.validate()),
                                    fit: BoxFit.cover,
                                  )
                                      : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(ic_doctor),
                                    colorFilter: appStore.isDarkModeOn ? null : ColorFilter.mode(appPrimaryColor.withOpacity(0.6), BlendMode.dstOver),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: context.height() * 0.40 - 32,
                                right: 24,
                                left: 24,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  width: context.width(),
                                  decoration: boxDecorationDefault(color: context.primaryColor),
                                  child: Column(
                                    children: [
                                      if (doctor.displayName.validate().isNotEmpty)
                                        RichTextWidget(
                                          list: [
                                            TextSpan(text: doctor.displayName.validate(), style: boldTextStyle(color: Colors.white, size: 18)),
                                            if (doctor.qualifications.validate().isNotEmpty)
                                              TextSpan(
                                                text: doctor.qualifications!.map((e) => e.degree.validate().capitalizeFirstLetter()).toList().join(' - ').prefixText(value: ' (').suffixText(value: ')'),
                                                style: primaryTextStyle(color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      if (doctor.noOfExperience.validate().toInt() != 0)
                                        Text(

                                          "${locale.lblExperiencePractitioner} " + '${doctor.noOfExperience.validate().toInt() > 1 ? doctor.noOfExperience.validate() + ' ${locale.lblYears}' : ' '
                                              '${locale.lblYear}'}',
                                          style: secondaryTextStyle(color: Colors.white),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  actions: [
                    if (isReceptionist())
                      PopupMenuButton(
                        enabled: true,
                        icon: FaIcon(Icons.more_vert, color: Colors.black87),
                        itemBuilder: (context) {
                          return [
                            if (isEdit)
                              PopupMenuItem(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(Icons.edit, size: 18, color: Colors.green),
                                    Text(locale.lblEdit, style: secondaryTextStyle()).paddingLeft(4),
                                  ],
                                ).appOnTap(
                                      () async {
                                    ifTester(
                                      context,
                                          () async {
                                        await AddDoctorScreen(
                                          doctorData: doctor,
                                          refreshCall: () {
                                            widget.refreshCall?.call();
                                            getDoctorData();
                                          },
                                        ).launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then(
                                              (value) => (value) {
                                            widget.refreshCall?.call();
                                            getDoctorData();
                                          },
                                        );
                                      },
                                      userEmail: doctor.userEmail.validate(),
                                    );
                                  },
                                ),
                              ),
                            if (isDelete)
                              PopupMenuItem(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FaIcon(Icons.delete, size: 18, color: Colors.red),
                                        FittedBox(child: Text(locale.lblDelete, style: secondaryTextStyle())).paddingLeft(4),
                                      ],
                                    ).appOnTap(() {
                                      ifTester(context, () => deleteDoctor(doctor.iD.validate()), userEmail: doctor.userEmail.validate());
                                    })
                                  ],
                                ),
                              ),
                          ];
                        },
                        color: context.cardColor,
                        constraints: BoxConstraints(
                          maxHeight: 100,
                          maxWidth: 80,
                        ),
                      ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    if (doctor.specialties.validate().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.lblSpecialities, style: boldTextStyle()),
                          16.height,
                          Container(
                            decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(defaultRadius), color: context.cardColor),
                            padding: EdgeInsets.all(12),
                            child: ULWidget(
                              children: List.generate(doctor.specialties.validate().length, (index) => Text('${doctor.specialties.validate()[index].label.validate()}',style: primaryTextStyle()),),
                            ),
                          ),
                        ],
                      ).paddingOnly(left: 16,right: 16,bottom: 16),
                    if (doctor.qualifications.validate().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.lblQualification, style: boldTextStyle()),
                          Wrap(
                            spacing: 6,
                            children: doctor.qualifications.validate().map((element) {
                              return QualificationItemWidget(
                                data: element,
                                showAdd: false,
                                onEdit: () {},
                              );
                            }).toList(),
                          )
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.lblVisitingDays, style: boldTextStyle()),
                        16.height,
                        Container(
                          decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(defaultRadius), color: context.cardColor),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ic_calendar.iconImage(size: 20, color: appSecondaryColor),
                              22.width,
                              if (doctor.available.validate().isNotEmpty)
                                Text(
                                  doctor.available.validate().split(',').join(' - ').capitalizeEachWord(),
                                  style: primaryTextStyle(),
                                ).expand()
                              else
                                Text("Dr. ${doctor.displayName} ${locale.lblWeekDaysDataNotFound}", style: primaryTextStyle()).expand(),
                            ],
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16, vertical: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.lblContact, style: boldTextStyle()),
                        10.height,
                        Container(
                          decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(defaultRadius), color: context.cardColor),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ic_message.iconImage(color: appSecondaryColor, size: 20),
                                  22.width,
                                  Text(doctor.userEmail.validate(), style: primaryTextStyle()).expand(),
                                ],
                              ),
                              12.height,
                              Row(
                                children: [
                                  ic_phone.iconImage(color: greenColor, size: 20),
                                  22.width,
                                  Text(doctor.mobileNumber.validate(), style: primaryTextStyle()).expand(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16, vertical: 12),
                    if (isProEnabled() && doctor.ratingList.validate().isNotEmpty)
                      AnimatedScrollView(
                        padding: EdgeInsets.only(bottom: 60),
                        listAnimationType: ListAnimationType.None,
                        children: [
                          ViewAllLabel(
                            label: locale.lblRatingsAndReviews,
                            labelSize: 16,
                            subLabel: '${locale.lblKnowWhatYourPatientsSaysAboutYou} ${doctor.displayName.validate().prefixText(value: 'Dr. ')}',
                            viewAllShowLimit: 5,
                            list: doctor.ratingList.validate(),
                            onTap: () {
                              RatingViewAllScreen(doctorId: doctor.iD.validate()).launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration);
                            },
                          ),
                          16.height,
                          if (doctor.ratingList.validate().isNotEmpty)
                            ...doctor.ratingList.validate().map((e) {
                              return ReviewWidget(
                                data: e,
                                addMargin: false,
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor),
                              ).visible(
                                e.patientName.validate().isNotEmpty,
                              );
                            }).toList()
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                  ],
                ),
              ),
            ],
          ),
          Observer(builder: (context) => LoaderWidget().center().visible(appStore.isLoading),)
        ],
        
      ),
    );
  }
}
