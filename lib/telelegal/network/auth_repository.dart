import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/base_response.dart';
import 'package:safelify/telelegal/model/clinic_list_model.dart';
import 'package:safelify/telelegal/model/user_model.dart';
import 'package:safelify/telelegal/network/network_utils.dart';
import 'package:safelify/screens/auth/screens/sign_in_screen.dart';
import 'package:safelify/telelegal/utils/cached_value.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/constants/app_constants.dart';
import 'package:safelify/telelegal/utils/constants/user_detail_keys.dart';
import 'package:safelify/telelegal/utils/constants/woocommerce_constants.dart';
import 'package:safelify/telelegal/utils/push_notification_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/utils/constants/sharedpreference_constants.dart';

Future<UserModel?> loginAPI(Map<String, dynamic> req) async {
  BaseResponses response =
      BaseResponses.fromJson(await handleResponse(await buildHttpResponse(
    '${ApiEndPoints.authEndPoint}/${EndPointKeys.loginEndPointKey}',
    request: req,
    method: HttpMethod.POST,
    requiredToken: false,
  )));
  if (response.userData != null) {
    UserModel value = response.userData!;
    cachedUserData = value;

    appStore.setLoggedIn(true);
    appStore.setApiNonce(value.apiNonce.validate());

    appStore.setPassword(req['password']);

    setValue(PASSWORD, req['password']);
    setValue(USER_LOGIN, value.userName.validate());
    setValue(USER_DATA, jsonEncode(value));

    userStore1.setUserData(value, initialize: true);
    userStore1.setConsumerKey(value.consumerKey.validate());
    userStore1.setConsumerSecret(value.consumerSecretKey.validate());
    userStore1.setUserEmail(value.userEmail.validate(), initialize: true);
    userStore1.setUserProfile(value.profileImage.validate(), initialize: true);
    userStore1.setUserId(value.userId.validate(), initialize: true);
    userStore1.setFirstName(value.firstName.validate(), initialize: true);
    userStore1.setLastName(value.lastName.validate(), initialize: true);
    userStore1.setRole(value.role.validate(), initialize: true);
    userStore1.setUserDisplayName(value.userDisplayName.validate(),
        initialize: true);
    userStore1.setUserMobileNumber(value.mobileNumber.validate(),
        initialize: true);
    userStore1.setUserGender(value.gender.validate(), initialize: true);
    userStore1.setUserName(value.userName.validate(), initialize: true);

    if (value.clinic.validate().isNotEmpty) {
      Clinic defaultClinic = value.clinic.validate().first;
      appStore.setCurrency(defaultClinic.extra!.currencyPrefix.validate(),
          initialize: true);
      userStore1.setClinicId(defaultClinic.id.validate(), initialize: true);

      if (isReceptionist() || isPatient()) {
        userStore1.setUserClinic(value.clinic.validate().first);
        userStore1.setUserClinicImage(
            value.clinic.validate().first.profileImage.validate(),
            initialize: true);
        userStore1.setUserClinicName(
            value.clinic.validate().first.name.validate(),
            initialize: true);
        userStore1.setUserClinicStatus(
            value.clinic.validate().first.status.validate(value: '1'),
            initialize: true);
        String clinicAddress = '';

        if (value.clinic.validate().first.address.validate().isNotEmpty) {
          clinicAddress = value.clinic.validate().first.address.validate();
        }
        if (value.city.validate().isNotEmpty) {
          clinicAddress += ',${value.clinic.validate().first.city.validate()}';
        }
        if (value.country.validate().isNotEmpty) {
          clinicAddress +=
              ' ,${value.clinic.validate().first.country.validate()}';
        }
        userStore1.setUserClinicAddress(clinicAddress, initialize: true);
      }
    }

    PushNotificationService().registerFCMAndTopics();

    return value;
  } else {
    if (parseHtmlString(response.message).contains('Error'))
      throw parseHtmlString(response.message);
  }
}

Future<BaseResponses> changePasswordAPI(Map<String, dynamic> request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse(
    '${ApiEndPoints.userEndpoint}/${EndPointKeys.changePwdEndPointKey}',
    request: request,
    method: HttpMethod.POST,
  )));
}

Future<BaseResponses> deleteAccountPermanently() async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse(
    '${ApiEndPoints.authEndPoint}/${EndPointKeys.deleteEndPointKey}',
    method: HttpMethod.DELETE,
  )));
}

Future<void> logout({bool isTokenExpired = false}) async {
  if (!isTokenExpired) {
    await removeKey(ApiResponseKeys.cookieHeaderKey);
    await removeKey(ApiHeaders.wcNonceKey);
    await removeKey(ApiHeaders.apiNonce);
    await removeKey(AppKeys.passwordKey);
  }

  PushNotificationService().unsubscribeFirebaseTopic();

  await removeKey(USER_ID);
  await removeKey(FIRST_NAME);
  await removeKey(LAST_NAME);
  await removeKey(USER_EMAIL);
  await removeKey(USER_DISPLAY_NAME);
  await removeKey(PROFILE_IMAGE);
  await removeKey(USER_MOBILE);
  await removeKey(USER_GENDER);
  await removeKey(USER_ROLE);

  await removeKey(USER_DATA);
  await removeKey(PLAYER_ID);
  await removeKey(CartKeys.shippingAddress);
  await removeKey(CartKeys.billingAddress);

  appStore.setPlayerId('');

  await SharedPreferenceKey.removeCacheKeys();
  await UserDetailKeys.removeUserDetailKey();
  await removeKey(SharedPreferenceKey.firebaseToken);

  removePermission();

  userStore1.setClinicId('');
  appStore.setLoggedIn(false);
  appStore.setLoading(false);
  paymentMethodList.clear();
  paymentMethodImages.clear();
  paymentModeList.clear();

  push(SignInScreen(),
      isNewTask: true,
      pageRouteAnimation: signInAnimation,
      duration: Duration(milliseconds: 600));
}

void removePermission() {
  removeKey(SharedPreferenceKey.userPermissionKey);
  removeKey(SharedPreferenceKey.kiviCareAppointmentAddKey);
  removeKey(SharedPreferenceKey.kiviCareAppointmentDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareAppointmentEditKey);
  removeKey(SharedPreferenceKey.kiviCareAppointmentListKey);
  removeKey(SharedPreferenceKey.kiviCareAppointmentViewKey);
  removeKey(SharedPreferenceKey.kiviCarePatientAppointmentStatusChangeKey);
  removeKey(SharedPreferenceKey.kiviCareAppointmentExportKey);
  removeKey(SharedPreferenceKey.kiviCarePatientBillAddKey);
  removeKey(SharedPreferenceKey.kiviCarePatientBillDeleteKey);
  removeKey(SharedPreferenceKey.kiviCarePatientBillEditKey);
  removeKey(SharedPreferenceKey.kiviCarePatientBillListKey);
  removeKey(SharedPreferenceKey.kiviCarePatientBillExportKey);
  removeKey(SharedPreferenceKey.kiviCarePatientBillViewKey);
  removeKey(SharedPreferenceKey.kiviCareClinicAddKey);
  removeKey(SharedPreferenceKey.kiviCareClinicDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareClinicEditKey);
  removeKey(SharedPreferenceKey.kiviCareClinicListKey);
  removeKey(SharedPreferenceKey.kiviCareClinicProfileKey);
  removeKey(SharedPreferenceKey.kiviCareClinicViewKey);
  removeKey(SharedPreferenceKey.kiviCareMedicalRecordsAddKey);
  removeKey(SharedPreferenceKey.kiviCareMedicalRecordsDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareMedicalRecordsEditKey);
  removeKey(SharedPreferenceKey.kiviCareMedicalRecordsListKey);
  removeKey(SharedPreferenceKey.kiviCareMedicalRecordsViewKey);
  removeKey(SharedPreferenceKey.kiviCareDashboardTotalAppointmentKey);
  removeKey(SharedPreferenceKey.kiviCareDashboardTotalDoctorKey);
  removeKey(SharedPreferenceKey.kiviCareDashboardTotalPatientKey);
  removeKey(SharedPreferenceKey.kiviCareDashboardTotalRevenueKey);
  removeKey(SharedPreferenceKey.kiviCareDashboardTotalTodayAppointmentKey);
  removeKey(SharedPreferenceKey.kiviCareDashboardTotalServiceKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorAddKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorEditKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorDashboardKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorListKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorViewKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorExportKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEncounterAddKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEncounterDeleteKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEncounterEditKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEncounterExportKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEncounterListKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEncountersKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEncounterViewKey);
  removeKey(SharedPreferenceKey.kiviCareEncountersTemplateAddKey);
  removeKey(SharedPreferenceKey.kiviCareEncountersTemplateDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareEncountersTemplateEditKey);
  removeKey(SharedPreferenceKey.kiviCareEncountersTemplateListKey);
  removeKey(SharedPreferenceKey.kiviCareEncountersTemplateViewKey);
  removeKey(SharedPreferenceKey.kiviCareClinicScheduleKey);
  removeKey(SharedPreferenceKey.kiviCareClinicScheduleAddKey);
  removeKey(SharedPreferenceKey.kiviCareClinicScheduleDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareClinicScheduleEditKey);
  removeKey(SharedPreferenceKey.kiviCareClinicScheduleExportKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorSessionAddKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorSessionEditKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorSessionListKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorSessionDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareDoctorSessionExportKey);
  removeKey(SharedPreferenceKey.kiviCareChangePasswordKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReviewAddKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReviewDeleteKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReviewEditKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReviewGetKey);
  removeKey(SharedPreferenceKey.kiviCareDashboardKey);
  removeKey(SharedPreferenceKey.kiviCarePatientAddKey);
  removeKey(SharedPreferenceKey.kiviCarePatientDeleteKey);
  removeKey(SharedPreferenceKey.kiviCarePatientClinicKey);
  removeKey(SharedPreferenceKey.kiviCarePatientProfileKey);
  removeKey(SharedPreferenceKey.kiviCarePatientEditKey);
  removeKey(SharedPreferenceKey.kiviCarePatientListKey);
  removeKey(SharedPreferenceKey.kiviCarePatientExportKey);
  removeKey(SharedPreferenceKey.kiviCarePatientViewKey);
  removeKey(SharedPreferenceKey.kiviCareReceptionistProfileKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReportKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReportAddKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReportEditKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReportViewKey);
  removeKey(SharedPreferenceKey.kiviCarePatientReportDeleteKey);
  removeKey(SharedPreferenceKey.kiviCarePrescriptionAddKey);
  removeKey(SharedPreferenceKey.kiviCarePrescriptionDeleteKey);
  removeKey(SharedPreferenceKey.kiviCarePrescriptionEditKey);
  removeKey(SharedPreferenceKey.kiviCarePrescriptionViewKey);
  removeKey(SharedPreferenceKey.kiviCarePrescriptionListKey);
  removeKey(SharedPreferenceKey.kiviCarePrescriptionExportKey);
  removeKey(SharedPreferenceKey.kiviCareServiceAddKey);
  removeKey(SharedPreferenceKey.kiviCareServiceDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareServiceEditKey);
  removeKey(SharedPreferenceKey.kiviCareServiceExportKey);
  removeKey(SharedPreferenceKey.kiviCareServiceListKey);
  removeKey(SharedPreferenceKey.kiviCareServiceViewKey);
  removeKey(SharedPreferenceKey.kiviCareStaticDataAddKey);
  removeKey(SharedPreferenceKey.kiviCareStaticDataDeleteKey);
  removeKey(SharedPreferenceKey.kiviCareStaticDataEditKey);
  removeKey(SharedPreferenceKey.kiviCareStaticDataExportKey);
  removeKey(SharedPreferenceKey.kiviCareStaticDataListKey);
  removeKey(SharedPreferenceKey.kiviCareStaticDataViewKey);
}

Future<UserModel> getSingleUserDetailAPI(int? id) async {
  return UserModel.fromJson(await (handleResponse(await buildHttpResponse(
      '${ApiEndPoints.userEndpoint}/${EndPointKeys.getDetailEndPointKey}?${ConstantKeys.capitalIDKey}=$id'))));
}

//Post API Change

Future<BaseResponses> forgotPasswordAPI(Map<String, dynamic> request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse(
    '${ApiEndPoints.userEndpoint}/${EndPointKeys.forgetPwdEndPointKey}',
    request: request,
    method: HttpMethod.POST,
  )));
}

Future<UserModel?> updateProfileAPI(
    {required Map<String, dynamic> data,
    File? profileImage,
    File? doctorSignature}) async {
  var multiPartRequest = await getMultiPartRequest(
      '${ApiEndPoints.userEndpoint}/${EndPointKeys.updateProfileEndPointKey}');

  multiPartRequest.fields.addAll(await getMultipartFields(val: data));

  multiPartRequest.headers.addAll(buildHeaderTokens());

  if (profileImage != null) {
    multiPartRequest.files
        .add(await MultipartFile.fromPath('profile_image', profileImage.path));
  }

  if (doctorSignature != null) {
    String convertedImage = await convertImageToBase64(doctorSignature);
    multiPartRequest.files
        .add(MultipartFile.fromString('signature_img', convertedImage));
  }
  appStore.setLoading(true);

  await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
    appStore.setLoading(false);

    UserModel data = UserModel.fromJson(temp['data']);
    cachedUserData = data;

    userStore1.setFirstName(data.firstName.validate(), initialize: true);
    userStore1.setLastName(data.lastName.validate(), initialize: true);
    userStore1.setUserMobileNumber(data.mobileNumber.validate(),
        initialize: true);
    if (data.profileImage != null) {
      userStore1.setUserProfile(data.profileImage.validate(), initialize: true);
    }
    toast(temp['message'], print: true);
    finish(getContext, true);
    return data;
  }, onError: (error) {
    toast(error.toString(), print: true);
    appStore.setLoading(false);
  });
  return null;
}

//region CommonFunctions
Future<Map<String, String>> getMultipartFields(
    {required Map<String, dynamic> val}) async {
  Map<String, String> data = {};

  val.forEach((key, value) {
    data[key] = '$value';
  });

  return data;
}

Future<List<MultipartFile>> getMultipartImages(
    {required List<File> files, required String name}) async {
  List<MultipartFile> multiPartRequest = [];

  await Future.forEach<File>(files, (element) async {
    int i = files.indexOf(element);

    multiPartRequest.add(await MultipartFile.fromPath('$name$i', element.path));
  });

  return multiPartRequest;
}

//endregion
