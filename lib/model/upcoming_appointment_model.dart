import 'package:intl/intl.dart';
import 'package:safelify/model/rating_model.dart';
import 'package:safelify/model/tax_model.dart';
import 'package:safelify/utils/common.dart';
import 'package:safelify/utils/extensions/date_extensions.dart';
import 'package:safelify/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constants.dart';

class UpcomingAppointmentModel {
  String? appointmentEndDate;
  String? appointmentEndTime;
  String? appointmentStartDate;
  String? appointmentStartTime;
  String? clinicId;
  String? clinicName;
  String? createdAt;
  String? description;
  String? doctorId;
  String? doctorName;
  String? encounterId;
  num? encounterStatus;
  String? id;
  String? patientId;
  String? patientName;
  String? status;
  String? visitLabel;
  List<VisitType>? visitType;
  ZoomData? zoomData;
  num? allServiceCharges;
  List<AppointmentReport>? appointmentReport;
  String? discountCode;
  String? doctorProfileImg;
  String? patientProfileImg;
  bool? videoConsultation;
  RatingData? doctorRating;
  String? paymentMethod;
  String? appointmentGlobalStartDate;

  TaxModel? taxData;

  String? googleMeetData;

  //Extra? extra;

  // Local Variable

  String get getAppointmentDisplayDate => appointmentGlobalStartDate
      .validate()
      .getFormattedDate(CONFIRM_APPOINTMENT_FORMAT);

  String get getDisplayAppointmentTime =>
      "${appointmentStartTime.validate().getFormattedTime()} - ${appointmentEndTime.validate().getFormattedTime()}";

  String get getAppointmentTime => DateFormat(ONLY_HOUR_MINUTE)
      .parse(appointmentStartTime.validate())
      .getFormattedDate(FORMAT_12_HOUR);

  String get getAppointmentStartDate => appointmentStartDate.validate();

  String get getAppointmentSaveDate => appointmentStartDate.validate();

  String get getVisitTypesInString =>
      visitType.validate().map((e) => e.serviceName.validate()).join(", ");

  String get getProfileImage =>
      isPatient() ? doctorProfileImg.validate() : patientProfileImg.validate();

  String get appointmentDateFormat =>
      "$getAppointmentStartDate   •   $getDisplayAppointmentTime";

  UpcomingAppointmentModel({
    this.appointmentEndDate,
    this.appointmentEndTime,
    this.appointmentStartDate,
    this.appointmentStartTime,
    this.doctorRating,
    this.clinicId,
    this.clinicName,
    this.createdAt,
    this.encounterStatus,
    this.description,
    this.doctorId,
    this.doctorName,
    this.encounterId,
    this.id,
    this.patientId,
    this.patientName,
    this.status,
    this.visitLabel,
    this.visitType,
    this.zoomData,
    this.allServiceCharges,
    this.doctorProfileImg,
    this.patientProfileImg,
    this.appointmentReport,
    this.discountCode,
    this.appointmentGlobalStartDate,
    this.videoConsultation,
    this.paymentMethod,
    this.googleMeetData,
    this.taxData,
  });

  factory UpcomingAppointmentModel.fromJson(Map<String, dynamic> json) {
    return UpcomingAppointmentModel(
      appointmentEndDate: json['appointment_end_date'],
      appointmentEndTime: json['appointment_end_time'],
      appointmentStartDate: json['appointment_start_date'],
      appointmentGlobalStartDate: json['start_date'],
      appointmentStartTime: json['appointment_start_time'],
      clinicId: json['clinic_id'],
      clinicName: json['clinic_name'],
      encounterStatus: json['encounter_status'],
      doctorProfileImg: json['doctor_profile_img'],
      patientProfileImg: json['patient_profile_img'],
      createdAt: json['created_at'],
      description: json['description'],
      taxData:
          json['tax_data'] != null ? TaxModel.fromJson(json['tax_data']) : null,
      appointmentReport: json['appointment_report'] != null
          ? (json['appointment_report'] as List)
              .map((i) => AppointmentReport.fromJson(i))
              .toList()
          : [],
      visitType: json['visit_type'] != null
          ? (json['visit_type'] as List)
              .map((i) => VisitType.fromJson(i))
              .toList()
          : [],
      doctorId: json['doctor_id'],
      discountCode: json['discount_code'],
      doctorName: json['doctor_name'],
      encounterId: json['encounter_id'],
      id: json['id'],
      allServiceCharges: json['all_service_charges'].runtimeType == String
          ? (json['all_service_charges'] as String).toDouble()
          : json['all_service_charges'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      status: json['status'],
      visitLabel: json['visit_label'],
      zoomData: json['zoom_data'] != null
          ? new ZoomData.fromJson(json['zoom_data'])
          : null,
      doctorRating: json['review'] != null
          ? new RatingData.fromJson(json['review'])
          : null,
      paymentMethod: json['payment_mode'],
      googleMeetData: json['google_meet_data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointment_end_date'] = appointmentEndDate;
    data['appointment_end_time'] = appointmentEndTime;
    data['appointment_start_date'] = appointmentStartDate;
    data['appointment_start_time'] = appointmentStartTime;
    data['clinic_id'] = clinicId;
    data['clinic_name'] = clinicName;
    data['created_at'] = createdAt;
    data['description'] = description;
    data['doctor_id'] = doctorId;
    data['encounter_status'] = encounterStatus;
    data['doctor_name'] = doctorName;
    data['doctor_profile_img'] = doctorProfileImg;
    data['patient_profile_img'] = patientProfileImg;
    data['encounter_id'] = encounterId;
    data['id'] = id;
    data['patient_id'] = patientId;
    data['all_service_charges'] = patientId;
    data['patient_name'] = patientName;
    data['status'] = status;
    data['discount_code'] = discountCode;
    data['start_date'] = appointmentGlobalStartDate;
    data['payment_mode'] = paymentMethod;
    data['google_meet_data'] = googleMeetData;
    data['tax_data'] = taxData;

    if (appointmentReport != null) {
      data['appointment_report'] =
          appointmentReport!.map((v) => v.toJson()).toList();
    }
    data['visit_label'] = visitLabel;
    if (visitType != null) {
      data['visit_type'] = visitType!.map((v) => v.toJson()).toList();
    }

    if (zoomData != null) {
      data['zoom_data'] = zoomData!.toJson();
    }
    if (doctorRating != null) {
      data['review'] = doctorRating!.toJson();
    }
    return data;
  }
}

class AppointmentReport {
  int? id;
  var url;

  AppointmentReport({this.id, this.url});

  factory AppointmentReport.fromJson(Map<String, dynamic> json) {
    return AppointmentReport(
      id: json['id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    return data;
  }
}

class WeeklyAppointment {
  String? x;
  int? y;

  WeeklyAppointment({this.x, this.y});

  factory WeeklyAppointment.fromJson(Map<String, dynamic> json) {
    return WeeklyAppointment(
      x: json['x'],
      y: json['y'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['x'] = x;
    data['y'] = y;
    return data;
  }
}

class VisitType {
  String? id;
  String? serviceId;
  String? serviceName;
  String? charges;

  VisitType({this.id, this.serviceId, this.serviceName, this.charges});

  factory VisitType.fromJson(Map<String, dynamic> json) {
    return VisitType(
      id: json['id'],
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      charges: json['charges'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['charges'] = charges;
    return data;
  }
}

class ZoomData {
  String? id;
  String? appointmentId;
  String? zoomId;
  String? zoomUuid;
  String? startUrl;
  String? joinUrl;
  String? password;
  String? createdAt;

  ZoomData(
      {this.id,
      this.appointmentId,
      this.zoomId,
      this.zoomUuid,
      this.startUrl,
      this.joinUrl,
      this.password,
      this.createdAt});

  ZoomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointment_id'];
    zoomId = json['zoom_id'];
    zoomUuid = json['zoom_uuid'];
    startUrl = json['start_url'];
    joinUrl = json['join_url'];
    password = json['password'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['appointment_id'] = appointmentId;
    data['zoom_id'] = zoomId;
    data['zoom_uuid'] = zoomUuid;
    data['start_url'] = startUrl;
    data['join_url'] = joinUrl;
    data['password'] = password;
    data['created_at'] = createdAt;
    return data;
  }
}
