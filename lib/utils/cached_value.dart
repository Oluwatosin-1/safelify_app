import 'package:safelify/model/clinic_list_model.dart';
import 'package:safelify/model/dashboard_model.dart';
import 'package:safelify/model/static_data_model.dart';
import 'package:safelify/model/upcoming_appointment_model.dart';
import 'package:safelify/model/user_model.dart';
import 'package:safelify/screens/patient/models/news_model.dart';
import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';

import '../model/encounter_model.dart';

DashboardModel? cachedPatientDashboardModel;
DashboardModel? cachedDoctorDashboardModel;
DashboardModel? cachedReceptionistDashboardModel;
NewsModel? cachedNewsFeed;
const String cachedEncounterListKey = 'cachedEncounterListKey';


List<UpcomingAppointmentModel>? cachedDoctorAppointment;
List<UpcomingAppointmentModel>? cachedReceptionistAppointment;
List<UpcomingAppointmentModel>? cachedPatientAppointment;
List<EncounterModel>? cachedEncounterList;

List<UserModel>? cachedPatientList;
List<UserModel>? cachedDoctorList;

UserModel? cachedUserData;
List<StaticData?>? cachedStaticData;
List<Clinic>? cachedClinicList;

class CachedData {
  static void storeResponse({Map<String, dynamic>? response, List<Map>? listData, required String responseKey}) async {
    await setValue(responseKey, jsonEncode(response != null ? response : listData), print: true);
  }

  static dynamic getCachedData({required String cachedKey}) {
    return getStringAsync(cachedKey).isNotEmpty ? jsonDecode(getStringAsync(cachedKey)) : null;
  }
}
