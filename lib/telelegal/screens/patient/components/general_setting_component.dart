import 'package:flutter/material.dart';
import 'package:safelify/telelegal/components/app_setting_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/screens/encounter/screen/encounter_list_screen.dart';
import 'package:safelify/telelegal/screens/patient/screens/my_bill_records_screen.dart';
import 'package:safelify/telelegal/screens/patient/screens/my_report_screen.dart';
import 'package:safelify/telelegal/screens/patient/screens/patient_clinic_selection_screen.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';

class GeneralSettingComponent extends StatelessWidget {
  final VoidCallback? callBack;
  GeneralSettingComponent({this.callBack});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 16,
      runSpacing: 16,
      children: [
        if (isVisible(SharedPreferenceKey.kiviCarePatientEncounterListKey))
          AppSettingWidget(
            name: "Consultation",
            image: ic_services,
            widget: EncounterListScreen(),
            subTitle: "Your consultation",
          ),
        if (isVisible(SharedPreferenceKey.kiviCarePatientReportKey))
          AppSettingWidget(
            name: "Report",
            image: ic_reports,
            widget: MyReportsScreen(),
            subTitle: locale.lblYourReports,
          ),
        if (isVisible(SharedPreferenceKey.kiviCarePatientBillListKey) &&
            isProEnabled())
          AppSettingWidget(
            name: locale.lblBillingRecords,
            image: ic_bill,
            widget: MyBillRecordsScreen(),
            subTitle: locale.lblYourBills,
          ),
        if (isVisible(SharedPreferenceKey.kiviCarePatientClinicKey))
          AppSettingWidget(
            name: "Choose your Firm",
            image: ic_clinic,
            widget: PatientClinicSelectionScreen(callback: () {
              callBack?.call();
            }),
            subTitle: "Choose your favourite Firm",
          ),
      ],
    );
  }
}
