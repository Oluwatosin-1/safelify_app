import 'package:flutter/material.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/upcoming_appointment_model.dart';

// ignore: non_constant_identifier_names
List<String> RTLLanguage = ['ar'];

List<WeeklyAppointment> emptyGraphList = [
  WeeklyAppointment(x: locale.lblMonday, y: 0),
  WeeklyAppointment(x: locale.lblTuesday, y: 0),
  WeeklyAppointment(x: locale.lblWednesday, y: 0),
  WeeklyAppointment(x: locale.lblThursday, y: 0),
  WeeklyAppointment(x: locale.lblFriday, y: 0),
  WeeklyAppointment(x: locale.lblSaturday, y: 0),
  WeeklyAppointment(x: locale.lblSunday, y: 0),
];

List<String> userRoles = [locale.lblDoctor, locale.lblClinic]; // Loader Size
double loaderSize = 30;

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(
        id: 0,
        name: locale.lblEnglish,
        languageCode: 'en',
        fullLanguageCode: 'en-US',
        flag: flagsIcUs),
    LanguageDataModel(
        id: 1,
        name: locale.lblArabic,
        languageCode: 'ar',
        fullLanguageCode: 'ar-AR',
        flag: flagsIcAr),
    LanguageDataModel(
        id: 2,
        name: locale.lblHindi,
        languageCode: 'hi',
        fullLanguageCode: 'hi-IN',
        flag: flagsIcIndia),
    LanguageDataModel(
        id: 3,
        name: locale.lblGerman,
        languageCode: 'de',
        fullLanguageCode: 'de-DE',
        flag: flagsIcGermany),
    LanguageDataModel(
        id: 4,
        name: locale.lblFrench,
        languageCode: 'fr',
        fullLanguageCode: 'fr-FR',
        flag: flagsIcFrench),
  ];
}

Future<bool> get isIqonicProduct async => await getPackageName() == packageName;
ThemeMode get appThemeMode =>
    appStore.isDarkModeOn ? ThemeMode.dark : ThemeMode.light;

// local
const receptionistEmail = "calvin@kivicare.com";
const doctorEmail = "doctor@kivicare.com";
const patientEmail = "mike@kivicare.com";

//Demo Password
const loginPassword = "123456";

/* Theme Mode Type */
const THEME_MODE_LIGHT = 0;
const THEME_MODE_DARK = 1;
const THEME_MODE_SYSTEM = 2;

/* DateFormats */
const FORMAT_12_HOUR = 'hh:mm a';
const ONLY_HOUR_MINUTE = 'HH:mm';
const TIME_WITH_SECONDS = 'hh:mm:ss';
const DISPLAY_DATE_FORMAT = 'dd-MMM-yyyy';
const SAVE_DATE_FORMAT = 'yyyy-MM-dd';

const DATE_FORMAT_1 = 'yyyy-MM-DD HH:mm:ss';
const DATE_FORMAT_2 = 'yyyy-MM-DDTHH:mm:ss';

const CONFIRM_APPOINTMENT_FORMAT = "EEEE, MMM dd yyyy";
const GLOBAL_FORMAT = 'dd-MM-yyyy';

// Static DATA
const SERVICE_TYPE = "service_type";

// Holidays
const DOCTOR = "doctor";
const CLINIC = "clinic";

const CLINIC_ID = 'CLINIC_ID';

// User Roles
const UserRoleDoctor = 'doctor';
const UserRolePatient = 'patient';
const UserRoleReceptionist = 'receptionist';

// Shared preferences keys
const USER_NAME = 'USER_NAME';

const USER_PASSWORD = 'USER_PASSWORD';
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const IS_REMEMBER_ME = 'IS_REMEMBER_ME';
const SELECTED_LANGUAGE = "SELECTED_LANGUAGE";
const USER_ID = "USER_ID";
const USER_DATA = "USER_DATA";
const FIRST_NAME = "FIRST_NAME";
const LAST_NAME = "LAST_NAME";
const USER_EMAIL = "USER_EMAIL";
const USER_DOB = 'USER_DOB';
const USER_LOGIN = "USER_LOGIN";
const USER_MOBILE = 'USER_MOBILE';
const USER_GENDER = 'USER_GENDER';
const SELECTED_PROFILE_INDEX = 'SELECTED_PROFILE_INDEX';

const USER_CLINIC_NAME = 'USER_CLINIC_NAME';
const USER_CLINIC_IMAGE = 'USER_CLINIC_IMAGE';
const USER_CLINIC_ADDRESS = 'USER_CLINIC_ADDRESS';
const USER_CLINIC_STATUS = 'USER_CLINIC_STATUS';

const USER_DISPLAY_NAME = "USER_DISPLAY_NAME";
const PROFILE_IMAGE = "PROFILE_IMAGE";
const DEMO_DOCTOR = "DEMO_DOCTOR";
const DEMO_RECEPTIONIST = "DEMO_RECEPTIONIST";
const DEMO_PATIENT = "DEMO_PATIENT";
const PASSWORD = "PASSWORD";
const USER_ROLE = "USER_ROLE";
const USER_CLINIC = "USER_CLINIC";
const CACHED_DASHBOARD_MODEL = 'CACHED_DASHBOARD_MODEL';
const CACHED_USER_DATA = 'CACHED_USER_DATA';

const USER_PRO_ENABLED = "USER_PRO_ENABLED";

const GLOBAL_DATE_FORMAT = "GLOBAL_DATE_FORMAT";
const DATE_FORMAT = 'DATE_FORMAT';
const RESTRICT_APPOINTMENT_POST = "RESTRICT_APPOINTMENT_POST";
const RESTRICT_APPOINTMENT_PRE = "RESTRICT_APPOINTMENT_PRE";
const GLOBAL_UTC = 'GLOBAL_UTC';
const CURRENCY = "CURRENCY";
const CURRENCY_POST_FIX = "CURRENCY_POST_FIX";
const CURRENCY_PRE_FIX = 'CURRENCY_PRE_FIX';
const IS_WALKTHROUGH_FIRST = "IS_WALKTHROUGH_FIRST";
const ON = "on";
const OFF = "off";
const SAVE_BASE_URL = "SAVE_BASE_URL";

const PROBLEM = "problem";
const OBSERVATION = "observation";
const NOTE = "note";
const PRESCRIPTION = 'prescription';
const REPORT = 'report';

const UPDATE = "UPDATE";
const DELETE = "DELETE";
const APP_UPDATE = "APP_UPDATE";
const CHANGE_DATE = "CHANGE_DATE";
const DEMO_EMAILS = 'demoEmails';

int titleTextSize = 18;
int fragmentTextSize = 22;

const packageName = "com.safelify.org";

const CACHED_FEEDS_ARTICLES = 'CACHED_FEEDS_ARTICLES';

const DOCTOR_ADD_API_UNSUCCESS_MESSAGE =
    "Sorry, that email address is already used!";

const PLAYER_ID = "PLAYER_ID";

const CURRENCY_SYMBOL = 'CURRENCY_SYMBOL';
const CURRENCY_CODE = 'CURRENCY_CODE';

const RAZOR_PAY_KEY = 'RAZOR_PAY_KEY';
const RAZOR_PAY_SECRET_KEY = 'RAZOR_PAY_SECRET_KEY';

const PAYMENT_WOOCOMMERCE = 'paymentWoocommerce';
const PAYMENT_RAZORPAY = 'paymentRazorpay';
const PAYMENT_STRIPE = 'paymentStripepay';
const PAYMENT_OFFLINE = 'paymentOffline';

//STATUS
const BookedStatus = 'Booked';
const CheckOutStatus = 'Check out';
const CheckInStatus = 'Check in';
const CancelledStatus = 'Cancelled';
const PendingStatus = 'Pending';

const BookedStatusInt = 1;
const CheckOutStatusInt = 3;
const CheckInStatusInt = 4;
const CancelledStatusInt = 0;
const PendingStatusInt = 2;

const ClosedEncounterStatus = 'Closed';
const ActiveEncounterStatus = 'Active';
const InActiveEncounterStatus = 'Inactive';

const ClosedEncounterStatusInt = 0;
const ActiveEncounterStatusInt = 1;
const InActiveEncounterStatusInt = 2;

const ACTIVE_USER_INT_STATUS = 1;
const INACTIVE_USER_INT_STATUS = 0;

const ACTIVE_SERVICE_STATUS = "1";
const INACTIVE_SERVICE_STATUS = "0";

const ACTIVE_CLINIC_STATUS = "1";
const INACTIVE_CLINIC_STATUS = "0";

class ApiHeaders {
  static const cacheControlHeader = 'no-cache';
  static const contentTypeHeaderApplicationJson =
      'application/json; charset=utf-8';
  static const contentTypeHeaderWWWForm = 'application/x-www-form-urlencoded';
  static const acceptHeader = 'application/json; charset=utf-8';

  static const accessControlAllowHeader = 'Access-Control-Allow-Headers';
  static const accessControlAllowOriginHeader = 'Access-Control-Allow-Origin';
  static const headerNonceKey = 'X-WP-Nonce';
  static const headerStoreNonceKey = 'X-WC-Store-API-Nonce';

  static const appVersionKey = 'app_version';

  static const wcNonceKey = 'WC Nonce';
  static const apiNonce = 'Api Nonce';
}

class ApiResponseKeys {
  static const cookieHeaderKey = 'Cookie Header';
  static const setCookieKey = 'set-cookie';
}

class ApiEndPoints {
  static const getConfigurationEndPoint =
      'kivicare/api/v1/user/get-configuration';
  static const appointmentEndPoint = 'kivicare/api/v1/appointment';

  static const saveLanguageApiEndPoint = 'kivicare/api/v1/save-language';
  static const saveAppointmentEndPoint = 'kivicare/api/v2/appointment/save';

  static const updateAppointmentStatusEndPoint =
      'kivicare/api/v1/appointment/update-status';

  static const deleteAppointmentEndPoint = 'kivicare/api/v1/appointment/delete';
  static const getAppointmentEndPoint =
      'kivicare/api/v1/appointment/get-appointment';
  static const getAppointmentTimeSlotsEndpoint =
      'kivicare/api/v1/doctor/appointment-time-slot';
  static const authEndPoint = 'kivicare/api/v1/auth';
  static const userEndpoint = 'kivicare/api/v1/user';
  static const patientEndPoint = 'kivicare/api/v1/patient';
  static const doctorEndPoint = 'kivicare/api/v1/doctor';
  static const receptionistEndPoint = '';

  static const savePaymentEndPoint =
      'kivicare/api/v1/appointment/payment-status';
  static const razorPaymentEndPoint = 'payments';
  static const razorOrderEndPoint = 'orders';
  static const serviceApiEndPoint = 'kivicare/api/v1/service';
  static const clinicApiEndPoint = 'kivicare/api/v1/clinic';
  static const settingEndPoint = 'kivicare/api/v1/setting';
  static const encounterEndPoint = 'kivicare/api/v1/encounter';
  static const newsEndPoint = 'kivicare/api/v1/news';
  static const prescriptionEndPoint = 'kivicare/api/v1/prescription';
  static const reviewEndPoint = 'kivicare/api/v1/review';

  static const billEndPoint = 'kivicare/api/v1/bill';

  static const billDeleteEndPoint = 'kivicare/api/v1/patient/delete-bill';

  static const taxEndPoint = 'kivicare/api/v1/tax/get';
  static const staticDataEndPoint = 'kivicare/api/v1/staticdata';
  //region Woocommerce
  static const productsList = 'wc/v3/products';
  static const productDetailEndPoint = 'wc/v3/products';
  static const productReviews = 'wc/v3/products/reviews';
  static const cartItems = 'wc/store/cart/items';
  static const cart = 'wc/store/cart';
  static const applyCoupon = 'wc/store/cart/apply-coupon';
  static const removeCoupon = 'wc/store/cart/remove-coupon';
  static const coupons = 'wc/v3/coupons';
  static const addCartItems = 'wc/store/cart/add-item';
  static const removeCartItems = 'wc/store/cart/remove-item';
  static const updateCartItems = 'wc/store/cart/update-item';
  static const getPaymentMethods = 'wc/v3/payment_gateways';
  static const categories = 'wc/v3/products/categories';
  static const orders = 'wc/v3/orders';
  static const countries = 'wc/v3/data/countries';
  static const customers = 'wc/v3/customers';

  static const wishlist = 'kivicare/api/v1/kc_wishlist/get';
  static const removeFromWishlist = 'kivicare/api/v1/kc_wishlist/remove';
  static const addToWishlist = 'kivicare/api/v1/kc_wishlist/add';
  //endregion Woocommerce
}

class EndPointKeys {
  static const loginEndPointKey = 'login';

  static const String switchLanguageKey = 'switch-lang';
  static const getDetailEndPointKey = 'get-detail';

  static const deleteDoctorEndPointKey = 'delete-doctor';

  static const getDoctorClinicSessionEndPointKey = 'get-doctor-clinic-session';

  static const getEncounterDetailEndPointKey = 'get-encounter-detail';

  static const getDashboardKey = 'get-dashboard';

  static const switchClinicEndPointKey = 'switch-clinic';

  static const getListEndPointKey = 'get-list';

  static const forgetPwdEndPointKey = 'forgot-password';

  static const billDetailEndPointKey = 'bill-details';

  static const addBillEndPointKey = 'add-bill';

  static const listEndPointKey = 'list';

  static const updateProfileEndPointKey = 'profile-update';
  static const getAppointmentEndPointKey = 'get-appointment';

  static const changePwdEndPointKey = 'change-password';

  static const deleteEndPointKey = 'delete';

  static const getAppointmentCountEndPointKey = 'get-appointment-count';

  static const managePlayerIdEndPointKey = 'manage-user-player-ids';

  static const String addDoctorEndPointKey = 'add-doctor';
}

class ConstantKeys {
  static const isStripePayKey = 'isStripePayment';

  static const stripeKeyPaymentKey = 'stripeKeyPayment';
  static const pageKey = 'page';
  static const limitKey = 'limit';

  static const typeKey = 'type';

  static const dateKey = 'date';

  static const startKey = 'start';

  static const endKey = 'end';

  static const playerIdKey = 'player_id';

  static const firebaseTokenKey = 'firebase_token';

  static const loggedOutKey = 'logged_out';

  static const doctorsKey = 'doctors';
  static const chargesKey = 'charges';
  static const clinicIdKey = 'clinic_id';
  static const doctorIdKey = 'doctor_id';

  static const visitTypeKey = 'visit_type';

  static const billIdKey = 'bill_id';

  static const patientIdKey = 'patient_id';

  static const encounterIdKey = 'encounter_id';
  static const statusKey = 'status';
  static const durationKey = 'duration';
  static const isTelemedKey = 'is_telemed';
  static const isMultipleKey = 'is_multiple_selection';

  static const mappingTableIdKey = 'mapping_table_id';
  static const serviceMappingIdKey = 'service_mapping_id';

  static const statusKeyAll = 'All';

  static const appointmentReportKey = 'appointment_report_';

  static const capitalIDKey = 'ID';

  static const lowerIdKey = 'id';

  static const attachmentCountsKey = 'attachment_count';

  static const multiPartRequestKey = 'Multipart Request';

  static const localeKey = 'locale';

  static const languageCodeKey = 'language_code';

  static const paymentFailedKey = 'failed';
  static const paymentCapturedKey = 'captured';

  // Payment Keys constant

  static const paymentWooCommerceKey = 'paymentWoocommerce';
  static const paymentRazorPayKey = 'paymentRazorpay';
  static const paymentStripeKey = 'paymentStripe';
  static const paymentOfflinePayKey = ' paymentOffline';
}

class FirebaseMsgConst {
//region Firebase Notification
  static const additionalDataKey = 'additional_data';
  static const idKey = 'id';
  static const notificationKey = 'Notification';

  static const onMessageListen = "Error On Message Listen";
  static const onMessageOpened = "Error On Message Opened App";
  static const onGetInitialMessage = 'Error On Get Initial Message';

  static const messageDataCollapseKey = 'MessageData Collapse Key';

  static const messageDataMessageIdKey = 'MessageData Message Id';

  static const messageDataMessageTypeKey = 'MessageData Type';
  static const notificationDataKey = 'Notification Data';

  static const fcmNotificationTokenKey = 'FCM Notification Token';
  static const apnsNotificationTokenKey = 'APNS Notification Token';
  static const notificationErrorKey = 'Notification Error';
  static const notificationTitleKey = 'Notification Title';
  static const notificationBodyKey = 'Notification Body';

  static const notificationChannelIdKey = 'notification';
  static const notificationChannelNameKey = 'Notification';

  static const patientWithUnderscoreKey = 'patient_';
  static const receptionistWithUnderscoreKey = 'receptionist_';
  static const doctorWithUnderscoreKey = 'doctor_';
  static const topicSubscribed = 'Topic Subscribed---->';
  static const topicUnSubscribed = 'Topic UnSubscribed---->';

//endregion
}
