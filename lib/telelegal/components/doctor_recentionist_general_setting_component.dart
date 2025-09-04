import 'package:flutter/material.dart';
import 'package:safelify/telelegal/components/app_setting_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/screens/doctor/screens/holiday/holiday_list_screen.dart';
import 'package:safelify/telelegal/screens/doctor/screens/service/service_list_screen.dart';
import 'package:safelify/telelegal/screens/doctor/screens/sessions/doctor_session_list_screen.dart';
import 'package:safelify/telelegal/screens/encounter/screen/encounter_list_screen.dart';
import 'package:safelify/telelegal/screens/patient/screens/my_bill_records_screen.dart';
import 'package:safelify/telelegal/screens/patient/screens/review/rating_view_all_screen.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';

class DoctorReceptionistGeneralSettingComponent extends StatelessWidget {
  const DoctorReceptionistGeneralSettingComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 16,
      runSpacing: 16,
      children: [
        if (isVisible(SharedPreferenceKey.kiviCareServiceListKey))
          AppSettingWidget(
            name: locale.lblServices,
            image: ic_services,
            widget: ServiceListScreen(),
            subTitle: locale.lblServicesYouProvide,
          ),
        if (isVisible(SharedPreferenceKey.kiviCareClinicScheduleKey))
          AppSettingWidget(
            name: locale.lblHoliday,
            image: ic_holiday,
            widget: HolidayScreen(),
            subTitle: locale.lblScheduledHolidays,
          ),
        if (isVisible(SharedPreferenceKey.kiviCareDoctorSessionListKey))
          AppSettingWidget(
            name: locale.lblSessions,
            image: ic_calendar,
            widget: DoctorSessionListScreen(),
            subTitle: locale.lblAvailableSession,
          ),
        if (isVisible(SharedPreferenceKey.kiviCarePatientEncounterListKey))
          AppSettingWidget(
            name: locale.lblEncounters,
            image: ic_services,
            widget: EncounterListScreen(),
            subTitle: locale.lblYourAllEncounters,
          ),
        if (isProEnabled() &&
            isVisible(SharedPreferenceKey.kiviCarePatientBillListKey))
          AppSettingWidget(
            name: locale.lblBillingRecords,
            image: ic_bill,
            widget: MyBillRecordsScreen(),
            subTitle: locale.lblGetYourAllBillsHere,
          ),
        if (isProEnabled() &&
            isDoctor() &&
            isVisible(SharedPreferenceKey.kiviCarePatientReviewGetKey))
          AppSettingWidget(
            name: locale.lblRatingsAndReviews,
            image: ic_rateUs,
            widget: RatingViewAllScreen(doctorId: userStore.userId.validate()),
            subTitle: locale.lblWhatYourCustomersSaysAboutYou,
          ),
      ],
    );
  }
}
