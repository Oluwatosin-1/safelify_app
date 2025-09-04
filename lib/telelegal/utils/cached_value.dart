import 'package:safelify/telelegal/model/clinic_list_model.dart';
import 'package:safelify/telelegal/model/dashboard_model.dart';
import 'package:safelify/telelegal/model/static_data_model.dart';
import 'package:safelify/telelegal/model/upcoming_appointment_model.dart';
import 'package:safelify/telelegal/model/user_model.dart';
import 'package:safelify/telelegal/screens/patient/models/news_model.dart';
import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';

DashboardModel? cachedPatientDashboardModel;
DashboardModel? cachedDoctorDashboardModel;
DashboardModel? cachedReceptionistDashboardModel;
NewsModel? cachedNewsFeed;

List<UpcomingAppointmentModel>? cachedDoctorAppointment;
List<UpcomingAppointmentModel>? cachedReceptionistAppointment;
List<UpcomingAppointmentModel>? cachedPatientAppointment;

List<UserModel>? cachedPatientList;
List<UserModel>? cachedDoctorList;

UserModel? cachedUserData;
List<StaticData?>? cachedStaticData;
List<Clinic>? cachedClinicList;

class CachedData {
  static void storeResponse(
      {Map<String, dynamic>? response,
      List<Map>? listData,
      required String responseKey}) async {
    await setValue(
        responseKey, jsonEncode(response != null ? response : listData),
        print: true);
  }

  static dynamic getCachedData({required String cachedKey}) {
    return getStringAsync(cachedKey).isNotEmpty
        ? jsonDecode(getStringAsync(cachedKey))
        : null;
  }
}
