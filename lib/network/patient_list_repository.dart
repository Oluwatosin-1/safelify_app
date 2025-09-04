import 'dart:convert';

import 'package:safelify/config.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/base_response.dart';
import 'package:safelify/model/patient_list_model.dart';
import 'package:safelify/model/user_model.dart';
import 'package:safelify/network/network_utils.dart';
import 'package:safelify/screens/patient/models/news_model.dart';
import 'package:safelify/utils/app_common.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';
import 'package:nb_utils/nb_utils.dart';

Future<NewsModel> getNewsListAPI() async {
  if (!appStore.isConnectedToInternet) {
    return NewsModel();
  }
  NewsModel newsModelData = NewsModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/news/get-news-list'))));

  return newsModelData;
}

Future<List<UserModel>> getPatientListAPI({
  String? searchString,
  required int page,
  Function(bool)? lastPageCallback,
  Function(int)? getTotalPatient,
  required List<UserModel> patientList,
  int? clinicId,
  int? doctorId,
}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }

  List<String> params = [];

  if (searchString.validate().isNotEmpty) params.add('s=$searchString');
  if (clinicId != null) params.add('clinic_id=$clinicId');
  if (doctorId != null) params.add('doctor_id=$doctorId');

  PatientListModel res = PatientListModel.fromJson(await handleResponse(await buildHttpResponse(getEndPoint(endPoint: 'kivicare/api/v1/patient/get-list', page: page, params: params))));

  getTotalPatient?.call(res.total.validate().toInt());

  if (page == 1) patientList.clear();

  lastPageCallback?.call(res.patientData.validate().length != PER_PAGE);

  patientList.addAll(res.patientData.validate());

  appStore.setLoading(false);

  if (isReceptionist()) {
    setValue(SharedPreferenceKey.cachedReceptionistPatientListKey, jsonEncode(patientList.validate().map((e) => e.toJson()).toList()));
  } else {
    setValue(SharedPreferenceKey.cachedDoctorPatientListKey, jsonEncode(patientList.validate().map((e) => e.toJson()).toList()));
  }
  return patientList;
}

//Add patient

Future<BaseResponses> addNewUserAPI(Map request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/auth/registration', request: request, method: HttpMethod.POST)));
}

Future updatePatientDataAPI(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/user/profile-update', request: request, method: HttpMethod.POST));
}

// End Patient
