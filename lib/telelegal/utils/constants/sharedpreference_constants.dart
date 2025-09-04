// import 'package:nb_utils/nb_utils.dart';

// class SharedPreferenceKey {
//   static const countriesListKey = 'Countries';

//   static const firebaseToken='Firebase Token';

//   //region Address
//   static const latitudeKey = 'Latitude';
//   static const longitudeKey = 'Longitude';
//   static const currentAddressKey = 'Current Address';
//   //endregion

//   //region Payment Keys
//   static const paymentMethodsKey = 'Payment Methods';
//   static const paymentWooCommerceKey = 'paymentWoocommerce';
//   static const paymentRazorPayKey = 'paymentRazorpay';
//   static const paymentStripeKey = 'paymentStripe';
//   static const paymentOfflinePayKey = ' paymentOffline';
//   //endregion

//   //region permission
//   static const userPermissionKey = 'User Permission';
//   //region Appointment Module
//   static const kiviCareAppointmentAddKey = 'kiviCareAppointmentAdd';
//   static const kiviCareAppointmentDeleteKey = 'kiviCareAppointmentDelete';
//   static const kiviCareAppointmentEditKey = 'kiviCareAppointmentEdit';
//   static const kiviCareAppointmentListKey = 'kiviCareAppointmentList';
//   static const kiviCareAppointmentViewKey = 'kiviCareAppointmentView';
//   static const kiviCarePatientAppointmentStatusChangeKey = 'kiviCarePatientAppointmentStatusChange';
//   static const kiviCareAppointmentExportKey = 'kiviCareAppointmentExport';

//   //endregion

//   //region Billing Module
//   static const kiviCarePatientBillAddKey = 'kiviCarePatientBillAdd';
//   static const kiviCarePatientBillDeleteKey = 'kiviCarePatientBillDelete';
//   static const kiviCarePatientBillEditKey = 'kiviCarePatientBillEdit';
//   static const kiviCarePatientBillListKey = 'kiviCarePatientBillList';
//   static const kiviCarePatientBillExportKey = 'kiviCarePatientBillExport';
//   static const kiviCarePatientBillViewKey = 'kiviCarePatientBillView';

//   //endregion

//   //region ClinicModule
//   static const kiviCareClinicAddKey = 'kiviCareClinicAdd';
//   static const kiviCareClinicDeleteKey = 'kiviCareClinicDelete';
//   static const kiviCareClinicEditKey = 'kiviCareClinicEdit';
//   static const kiviCareClinicListKey = 'kiviCareClinicList';
//   static const kiviCareClinicProfileKey = 'kiviCareClinicProfile';
//   static const kiviCareClinicViewKey = 'kiviCareClinicView';

//   //endregion

//   //region ClinicalDetailModule
//   static const kiviCareMedicalRecordsAddKey = 'kiviCareMedicalRecordsAdd';
//   static const kiviCareMedicalRecordsDeleteKey = 'kiviCareMedicalRecordsDelete';
//   static const kiviCareMedicalRecordsEditKey = 'kiviCareMedicalRecordsEdit';
//   static const kiviCareMedicalRecordsListKey = 'kiviCareMedicalRecordsList';
//   static const kiviCareMedicalRecordsViewKey = 'kiviCareMedicalRecordsView';

//   //endregion

//   //region  DashboardModule
//   static const kiviCareDashboardTotalAppointmentKey = 'kiviCareDashboardTotalAppointment';
//   static const kiviCareDashboardTotalDoctorKey = 'kiviCareDashboardTotalDoctor';
//   static const kiviCareDashboardTotalPatientKey = 'kiviCareDashboardTotalPatient';
//   static const kiviCareDashboardTotalRevenueKey = 'kiviCareDashboardTotalRevenue';
//   static const kiviCareDashboardTotalTodayAppointmentKey = 'kiviCareDashboardTotalTodayAppointment';
//   static const kiviCareDashboardTotalServiceKey = 'kiviCareDashboardTotalService';

//   //endregion

//   //region DoctorModule
//   static const kiviCareDoctorAddKey = 'kiviCareDoctorAdd';
//   static const kiviCareDoctorDeleteKey = 'kiviCareDoctorDelete';
//   static const kiviCareDoctorEditKey = 'kiviCareDoctorEdit';
//   static const kiviCareDoctorDashboardKey = 'kiviCareDoctorDashboard';
//   static const kiviCareDoctorListKey = 'kiviCareDoctorList';
//   static const kiviCareDoctorViewKey = 'kiviCareDoctorView';
//   static const kiviCareDoctorExportKey = 'kiviCareDoctorExport';

//   //endregion

//   //region EncounterPermissionModule
//   static const kiviCarePatientEncounterAddKey = 'kiviCarePatientEncounterAdd';
//   static const kiviCarePatientEncounterDeleteKey = 'kiviCarePatientEncounterDelete';
//   static const kiviCarePatientEncounterEditKey = 'kiviCarePatientEncounterEdit';
//   static const kiviCarePatientEncounterExportKey = 'kiviCarePatientEncounterExport';
//   static const kiviCarePatientEncounterListKey = 'kiviCarePatientEncounterList';
//   static const kiviCarePatientEncountersKey = 'kiviCarePatientEncounters';
//   static const kiviCarePatientEncounterViewKey = 'kiviCarePatientEncounterView';

//   //endregion

//   //region EncountersTemplateModule
//   static const kiviCareEncountersTemplateAddKey = 'kiviCareEncountersTemplateAdd';
//   static const kiviCareEncountersTemplateDeleteKey = 'kiviCareEncountersTemplateDelete';
//   static const kiviCareEncountersTemplateEditKey = 'kiviCareEncountersTemplateEdit';
//   static const kiviCareEncountersTemplateListKey = 'kiviCareEncountersTemplateList';
//   static const kiviCareEncountersTemplateViewKey = 'kiviCareEncountersTemplateView';

//   //endregion

//   //region HolidayModule
//   static const kiviCareClinicScheduleKey = 'kiviCareClinicSchedule';
//   static const kiviCareClinicScheduleAddKey = 'kiviCareClinicScheduleAdd';
//   static const kiviCareClinicScheduleDeleteKey = 'kiviCareClinicScheduleDelete';
//   static const kiviCareClinicScheduleEditKey = 'kiviCareClinicScheduleEdit';
//   static const kiviCareClinicScheduleExportKey = 'kiviCareClinicScheduleExport';

//   // endregion

//   // region SessionModule
//   static const kiviCareDoctorSessionAddKey = 'kiviCareDoctorSessionAdd';
//   static const kiviCareDoctorSessionEditKey = 'kiviCareDoctorSessionEdit';
//   static const kiviCareDoctorSessionListKey = 'kiviCareDoctorSessionList';
//   static const kiviCareDoctorSessionDeleteKey = 'kiviCareDoctorSessionDelete';
//   static const kiviCareDoctorSessionExportKey = 'kiviCareDoctorSessionExport';

//   // endregion

//   //region OtherModule
//   static const kiviCareChangePasswordKey = 'kiviCareChangePassword';
//   static const kiviCarePatientReviewAddKey = 'kiviCarePatientReviewAdd';
//   static const kiviCarePatientReviewDeleteKey = 'kiviCarePatientReviewDelete';
//   static const kiviCarePatientReviewEditKey = 'kiviCarePatientReviewEdit';
//   static const kiviCarePatientReviewGetKey = 'kiviCarePatientReviewGet';
//   static const kiviCareDashboardKey = 'kiviCareDashboard';

//   //endregion

//   //region PatientModule
//   static const kiviCarePatientAddKey = 'kiviCarePatientAdd';
//   static const kiviCarePatientDeleteKey = 'kiviCarePatientDelete';
//   static const kiviCarePatientClinicKey = 'kiviCarePatientClinic';
//   static const kiviCarePatientProfileKey = 'kiviCarePatientProfile';
//   static const kiviCarePatientEditKey = 'kiviCarePatientEdit';
//   static const kiviCarePatientListKey = 'kiviCarePatientList';
//   static const kiviCarePatientExportKey = 'kiviCarePatientExport';
//   static const kiviCarePatientViewKey = 'kiviCarePatientView';

//   //endregion

//   //region ReceptionistModule
//   static const kiviCareReceptionistProfileKey = 'kiviCareReceptionistProfile';

//   //endregion

//   //region ReportModule
//   static const kiviCarePatientReportKey = 'kiviCarePatientReport';
//   static const kiviCarePatientReportAddKey = 'kiviCarePatientReportAdd';
//   static const kiviCarePatientReportEditKey = 'kiviCarePatientReportEdit';
//   static const kiviCarePatientReportViewKey = 'kiviCarePatientReportView';
//   static const kiviCarePatientReportDeleteKey = 'kiviCarePatientReportDelete';

//   //endregion

//   //region PrescriptionPermissionModule
//   static const kiviCarePrescriptionAddKey = 'kiviCarePrescriptionAdd';
//   static const kiviCarePrescriptionDeleteKey = 'kiviCarePrescriptionDelete';
//   static const kiviCarePrescriptionEditKey = 'kiviCarePrescriptionEdit';
//   static const kiviCarePrescriptionViewKey = 'kiviCarePrescriptionView';
//   static const kiviCarePrescriptionListKey = 'kiviCarePrescriptionList';
//   static const kiviCarePrescriptionExportKey = 'kiviCarePrescriptionExport';

//   //endregion

//   //region ServiceModule
//   static const kiviCareServiceAddKey = 'kiviCareServiceAdd';
//   static const kiviCareServiceDeleteKey = 'kiviCareServiceDelete';
//   static const kiviCareServiceEditKey = 'kiviCareServiceEdit';
//   static const kiviCareServiceExportKey = 'kiviCareServiceExport';
//   static const kiviCareServiceListKey = 'kiviCareServiceList';
//   static const kiviCareServiceViewKey = 'kiviCareServiceView';

//   //endregion

//   // region StaticDataModule
//   static const kiviCareStaticDataAddKey = 'kiviCareStaticDataAdd';
//   static const kiviCareStaticDataDeleteKey = 'kiviCareStaticDataDelete';
//   static const kiviCareStaticDataEditKey = 'kiviCareStaticDataEdit';
//   static const kiviCareStaticDataExportKey = 'kiviCareStaticDataExport';
//   static const kiviCareStaticDataListKey = 'kiviCareStaticDataList';
//   static const kiviCareStaticDataViewKey = 'kiviCareStaticDataView';

//   // endregion

//   //endregion

//   //region CacheKeys
//   static const cachedDashboardDataKey = 'Cached Dashboard Data';
//   static const cachedReceptionistPatientListKey = 'Cached Receptionist Patient List';
//   static const cachedReceptionistDoctorListKey = 'Cached Receptionist Doctor List';
//   static const cachedDoctorPatientListKey = 'Cached Doctor Patient List';

//   static const cachedAppointmentListKey = 'Cached Appointment List';

//   static const cachedNewsFeedListKey = 'Cached News List';
//   //endregion

//   //region remove Cache Keys
//   static removeCacheKeys() {
//     removeKey(cachedDashboardDataKey);
//     removeKey(cachedReceptionistPatientListKey);
//     removeKey(cachedReceptionistDoctorListKey);
//     removeKey(cachedDoctorPatientListKey);
//     removeKey(cachedNewsFeedListKey);
//     removeKey(cachedAppointmentListKey);
//   }

//   //region Remove Permission
//   static removePermissionKey() {
//     removeKey(userPermissionKey);
//     removeKey(kiviCareAppointmentAddKey);
//     removeKey(kiviCareAppointmentDeleteKey);
//     removeKey(kiviCareAppointmentEditKey);
//     removeKey(kiviCareAppointmentListKey);
//     removeKey(kiviCareAppointmentViewKey);
//     removeKey(kiviCarePatientAppointmentStatusChangeKey);
//     removeKey(kiviCareAppointmentExportKey);
//     removeKey(kiviCarePatientBillAddKey);
//     removeKey(kiviCarePatientBillDeleteKey);
//     removeKey(kiviCarePatientBillEditKey);
//     removeKey(kiviCarePatientBillListKey);
//     removeKey(kiviCarePatientBillExportKey);
//     removeKey(kiviCarePatientBillViewKey);
//     removeKey(kiviCareClinicAddKey);
//     removeKey(kiviCareClinicDeleteKey);
//     removeKey(kiviCareClinicEditKey);
//     removeKey(kiviCareClinicListKey);
//     removeKey(kiviCareClinicProfileKey);
//     removeKey(kiviCareClinicViewKey);
//     removeKey(kiviCareMedicalRecordsAddKey);
//     removeKey(kiviCareMedicalRecordsDeleteKey);
//     removeKey(kiviCareMedicalRecordsEditKey);
//     removeKey(kiviCareMedicalRecordsListKey);
//     removeKey(kiviCareMedicalRecordsViewKey);
//     removeKey(kiviCareDashboardTotalAppointmentKey);
//     removeKey(kiviCareDashboardTotalDoctorKey);
//     removeKey(kiviCareDashboardTotalPatientKey);
//     removeKey(kiviCareDashboardTotalRevenueKey);
//     removeKey(kiviCareDashboardTotalTodayAppointmentKey);
//     removeKey(kiviCareDashboardTotalServiceKey);
//     removeKey(kiviCareDoctorAddKey);
//     removeKey(kiviCareDoctorDeleteKey);
//     removeKey(kiviCareDoctorEditKey);
//     removeKey(kiviCareDoctorDashboardKey);
//     removeKey(kiviCareDoctorListKey);
//     removeKey(kiviCareDoctorViewKey);
//     removeKey(kiviCareDoctorExportKey);
//     removeKey(kiviCarePatientEncounterAddKey);
//     removeKey(kiviCarePatientEncounterDeleteKey);
//     removeKey(kiviCarePatientEncounterEditKey);
//     removeKey(kiviCarePatientEncounterExportKey);
//     removeKey(kiviCarePatientEncounterListKey);
//     removeKey(kiviCarePatientEncountersKey);
//     removeKey(kiviCarePatientEncounterViewKey);
//     removeKey(kiviCareEncountersTemplateAddKey);
//     removeKey(kiviCareEncountersTemplateDeleteKey);
//     removeKey(kiviCareEncountersTemplateEditKey);
//     removeKey(kiviCareEncountersTemplateListKey);
//     removeKey(kiviCareEncountersTemplateViewKey);
//     removeKey(kiviCareClinicScheduleKey);
//     removeKey(kiviCareClinicScheduleAddKey);
//     removeKey(kiviCareClinicScheduleDeleteKey);
//     removeKey(kiviCareClinicScheduleEditKey);
//     removeKey(kiviCareClinicScheduleExportKey);
//     removeKey(kiviCareDoctorSessionAddKey);
//     removeKey(kiviCareDoctorSessionEditKey);
//     removeKey(kiviCareDoctorSessionListKey);
//     removeKey(kiviCareDoctorSessionDeleteKey);
//     removeKey(kiviCareDoctorSessionExportKey);
//     removeKey(kiviCareChangePasswordKey);
//     removeKey(kiviCarePatientReviewAddKey);
//     removeKey(kiviCarePatientReviewDeleteKey);
//     removeKey(kiviCarePatientReviewEditKey);
//     removeKey(kiviCarePatientReviewGetKey);
//     removeKey(kiviCareDashboardKey);
//     removeKey(kiviCarePatientAddKey);
//     removeKey(kiviCarePatientDeleteKey);
//     removeKey(kiviCarePatientClinicKey);
//     removeKey(kiviCarePatientProfileKey);
//     removeKey(kiviCarePatientEditKey);
//     removeKey(kiviCarePatientListKey);
//     removeKey(kiviCarePatientExportKey);
//     removeKey(kiviCarePatientViewKey);
//     removeKey(kiviCareReceptionistProfileKey);
//     removeKey(kiviCarePatientReportKey);
//     removeKey(kiviCarePatientReportAddKey);
//     removeKey(kiviCarePatientReportEditKey);
//     removeKey(kiviCarePatientReportViewKey);
//     removeKey(kiviCarePatientReportDeleteKey);
//     removeKey(kiviCarePrescriptionAddKey);
//     removeKey(kiviCarePrescriptionDeleteKey);
//     removeKey(kiviCarePrescriptionEditKey);
//     removeKey(kiviCarePrescriptionViewKey);
//     removeKey(kiviCarePrescriptionListKey);
//     removeKey(kiviCarePrescriptionExportKey);
//     removeKey(kiviCareServiceAddKey);
//     removeKey(kiviCareServiceDeleteKey);
//     removeKey(kiviCareServiceEditKey);
//     removeKey(kiviCareServiceExportKey);
//     removeKey(kiviCareServiceListKey);
//     removeKey(kiviCareServiceViewKey);
//     removeKey(kiviCareStaticDataAddKey);
//     removeKey(kiviCareStaticDataDeleteKey);
//     removeKey(kiviCareStaticDataEditKey);
//     removeKey(kiviCareStaticDataExportKey);
//     removeKey(kiviCareStaticDataListKey);
//     removeKey(kiviCareStaticDataViewKey);
//   }
//   //endregion
// }
