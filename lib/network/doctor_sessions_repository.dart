import 'package:safelify/main.dart';
import 'package:safelify/model/doctor_session_model.dart';
import 'package:safelify/network/network_utils.dart';
import 'package:safelify/utils/constants.dart';

//region Doctor Sessions

Future<DoctorSessionModel> getDoctorSessionDataAPI({String? clinicId = ''}) async {
  if (!appStore.isConnectedToInternet) return DoctorSessionModel();
  return DoctorSessionModel.fromJson(await (handleResponse(
      await buildHttpResponse('${ApiEndPoints.settingEndPoint}/${EndPointKeys.getDoctorClinicSessionEndPointKey}?${ConstantKeys.clinicIdKey}=${clinicId != null ? clinicId : ''}'))));
}

Future addDoctorSessionDataAPI(Map request) async {
  return await handleResponse(await buildHttpResponse('${ApiEndPoints.settingEndPoint}/save-doctor-clinic-session', request: request, method: HttpMethod.POST));
}

Future deleteDoctorSessionDataAPI(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/setting/delete-doctor-clinic-session', request: request, method: HttpMethod.POST));
}

//endregion
