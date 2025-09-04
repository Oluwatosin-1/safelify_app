import 'dart:io';

import 'package:safelify/telelegal/model/clinic_list_model.dart';
import 'package:safelify/telelegal/model/encounter_module.dart';
import 'package:safelify/telelegal/model/module_config_model.dart';
import 'package:safelify/telelegal/model/prescription_module.dart';
import 'package:safelify/telelegal/model/qualification_model.dart';
import 'package:safelify/telelegal/model/rating_model.dart';
import 'package:safelify/telelegal/model/restrict_appointment_model.dart';
import 'package:safelify/telelegal/model/service_model.dart';
import 'package:safelify/telelegal/model/speciality_model.dart';
import 'package:nb_utils/nb_utils.dart';

class UserModel {
  // String properties
  String? apiResponseMessage;

  String? consumerKey;

  String? consumerSecretKey;

  String? apiNonce;
  String? doctorId;
  String? firstName;
  String? lastName;

  String? userName;
  String? doctorName;
  String? userDisplayName;
  String? userEmail;
  String? userNiceName;
  String? mobileNumber;

  String? address;
  String? city;
  String? country;
  String? dob;

  String? gender;
  String? isPatientEnable;

  String? noOfExperience;

  String? postalCode;
  String? price;
  String? priceType;
  String? profileImage;
  String? role;
  String? token;

  String? zoomId;
  String? signatureImg;
  String? state;
  String? timeSlot;
  String? userLogin;
  String? bloodGroup;
  String? isUploadFileAppointment;
  String? message;
  String? globalDateFormat;
  String? available;
  String? clinicId;
  String? clinicName;
  String? displayName;
  String? userStatus;
  String? charges;
  String? duration;
  String? serviceImage;
  String? mappingTableId;
  String? status;
  String? utc;
  String? serviceId;
  String? patientAddedBy;
  String? totalEncounter;
  String? userRegistered;

  String? currentMedicalCondition;
  String? patientHeight;
  String? patientWeight;
  String? currentDoctorName;
  String? currentDoctorPhone;
  String? currentDoctorEmail;

  //num
  num? avgRating;

  // Int properties
  int? userId;
  int? iD;

  // Bool properties
  bool isCheck;
  bool? multiple;
  bool? isTelemed;

  // List properties
  List<Clinic>? clinic;
  List<EncounterModule>? encounterModules;
  List<ModuleConfig>? moduleConfig;
  List<Object>? notification;
  List<PrescriptionModule>? prescriptionModule;
  List<Qualification>? qualifications;
  List<SpecialtyModel>? specialties;
  List<RatingData>? ratingList;
  List<ServiceData>? serviceData;

  // File property
  File? imageFile;

  // Object properties
  RestrictAppointmentModel? restrictAppointment;

  UserModel({
    // String properties
    this.address,
    this.apiNonce,
    this.consumerKey,
    this.consumerSecretKey,
    this.firstName,
    this.userName,
    this.city,
    this.country,
    this.dob,
    this.imageFile,
    this.doctorName,
    this.apiResponseMessage,
    this.gender,
    this.isPatientEnable,
    this.lastName,
    this.mobileNumber,
    this.noOfExperience,
    this.notification,
    this.postalCode,
    this.prescriptionModule,
    this.price,
    this.priceType,
    this.profileImage,
    this.qualifications,
    this.role,
    this.specialties,
    this.token,
    this.userDisplayName,
    this.userEmail,
    this.userId,
    this.userNiceName,
    this.zoomId,
    this.utc,
    this.signatureImg,
    this.userLogin,
    this.bloodGroup,
    this.timeSlot,
    this.state,
    this.isUploadFileAppointment,
    this.restrictAppointment,
    this.message,
    this.globalDateFormat,
    this.available,
    this.clinicId,
    this.clinicName,
    this.displayName,
    this.ratingList,
    this.iD,
    this.serviceId,
    this.userStatus,
    this.doctorId,
    this.isCheck = false,
    this.charges,
    this.duration,
    this.serviceImage,
    this.mappingTableId,
    this.multiple,
    this.status,
    this.isTelemed,
    this.serviceData,
    this.clinic,
    this.encounterModules,
    this.moduleConfig,
    this.avgRating,
    this.patientAddedBy,
    this.totalEncounter,
    this.userRegistered,
    this.currentDoctorEmail,
    this.currentDoctorName,
    this.currentDoctorPhone,
    this.currentMedicalCondition,
    this.patientHeight,
    this.patientWeight,
  });

  String get getDoctorSpeciality =>
      specialties.validate().map((e) => e.label.validate()).join(', ');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      apiResponseMessage: json['message'],
      apiNonce: json['nounce'],
      consumerKey: json['consumer_key'],
      consumerSecretKey: json['consumer_secret'],
      role: json['role'],
      firstName: json['first_name'] != null
          ? json['first_name']
          : json['display_name'].toString().split(' ').first,
      lastName: json['last_name'] != null
          ? json['last_name']
          : json['display_name'].toString().split(' ').last,
      userName: json['user_name'],
      userDisplayName: json['display_name'],
      userEmail: json['email'] != null
          ? json['email']
          : json['user_email'] != null
              ? json['user_email']
              : null,
      userId: json['user_id'].runtimeType == String
          ? (json['user_id'] as String).toInt()
          : json['user_id'],
      iD: json['ID'],
      doctorId: json['doctor_id'],
      displayName: json['display_name'],
      doctorName: json['doctor_name'],
      userNiceName: json['user_nicename'],
      userStatus: json['user_status'],
      gender: json['gender'],
      mobileNumber:
          json['mobile_number'] is String ? json['mobile_number'] : '',
      dob: json['dob'],
      city: json['city'],
      country: json['country'],
      address: json['address'],
      clinic: json['clinic'] != null
          ? (json['clinic'] as List).map((i) => Clinic.fromJson(i)).toList()
          : null,
      encounterModules: json['enocunter_modules'] != null
          ? (json['enocunter_modules'] as List)
              .map((i) => EncounterModule.fromJson(i))
              .toList()
          : null,
      isPatientEnable: json['is_patient_enable'],
      moduleConfig: json['module_config'] != null
          ? (json['module_config'] as List)
              .map((i) => ModuleConfig.fromJson(i))
              .toList()
          : null,
      noOfExperience: json['no_of_experience'],
      postalCode: json['postal_code'],
      prescriptionModule: json['prescription_module'] != null
          ? (json['prescription_module'] as List)
              .map((i) => PrescriptionModule.fromJson(i))
              .toList()
          : null,
      price: json['price'],
      priceType: json['price_type'],
      profileImage: json['profile_image'],
      qualifications: json['qualifications'] != null
          ? (json['qualifications'] as List)
              .map((i) => Qualification.fromJson(i))
              .toList()
          : null,
      specialties: json['specialties'] != null
          ? (json['specialities'].runtimeType == String
              ? (json['specialties'])
                  .split(',')
                  .map((e) => SpecialtyModel(label: e))
                  .toList()
              : (json['specialties'] as List)
                  .map((e) => SpecialtyModel.fromJson(e))
                  .toList())
          : json['specialties'],
      zoomId: json['zoom_id'],
      signatureImg: json['signature_img'],
      state: json['state'],
      timeSlot: json['time_slot'],
      userLogin: json['user_login'],
      bloodGroup: json['blood_group'],
      currentMedicalCondition: json['current_medical_condition'],
      patientHeight: json['patient_height'],
      patientWeight: json['patient_weight'],
      currentDoctorName: json['current_doctor_name'],
      currentDoctorPhone: json['current_doctor_phone'],
      currentDoctorEmail: json['current_doctor_email'],
      globalDateFormat: json['global_date_format'],
      isUploadFileAppointment: json['is_uploadfile_appointment'],
      message: json['message'],
      restrictAppointment: json['restrict_appointment'] != null
          ? RestrictAppointmentModel.fromJson(json['restrict_appointment'])
          : null,
      available: json['available'],
      avgRating: json['avgRating'],
      clinicName: json['clinic_name'],
      ratingList: json['review'] != null
          ? (json['review'] as List).map((i) => RatingData.fromJson(i)).toList()
          : json['reviews'] != null
              ? (json['reviews'] as List)
                  .map((i) => RatingData.fromJson(i))
                  .toList()
              : null,
      charges: json['charges'],
      serviceId: json['service_id'],
      duration: json['duration'],
      serviceImage: json['image'],
      isTelemed: json['is_telemed'],
      mappingTableId: json['mapping_table_id'],
      multiple: json['is_multiple_selection'],
      status: json['status'].runtimeType == int
          ? (json['status'] as int).toString()
          : json['status'],
      patientAddedBy: json['patient_added_by'],
      totalEncounter: json['total_encounter'],
      userRegistered: json['user_registered'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['message'] = apiResponseMessage;
    json['consumer_key'] = consumerKey;
    json['consumer_secret'] = consumerSecretKey;
    json['nounce'] = apiNonce;
    json['doctor_id'] = doctorId;
    json['first_name'] = firstName;
    json['last_name'] = lastName;
    json['mobile_number'] = mobileNumber;
    json['address'] = address;
    json['city'] = city;
    json['country'] = country;
    json['dob'] = dob;
    json['gender'] = gender;
    json['is_patient_enable'] = isPatientEnable;
    json['no_of_experience'] = noOfExperience;
    json['postal_code'] = postalCode;
    json['price'] = price;
    json['price_type'] = priceType;
    json['profile_image'] = profileImage;
    json['role'] = role;
    json['token'] = token;
    json['zoom_id'] = zoomId;
    json['signature_img'] = signatureImg;
    json['state'] = state;
    json['time_slot'] = timeSlot;
    json['user_login'] = userLogin;
    json['blood_group'] = bloodGroup;
    json['is_uploadfile_appointment'] = isUploadFileAppointment;
    json['message'] = message;
    json['global_date_format'] = globalDateFormat;
    json['available'] = available;
    json['clinic_id'] = clinicId;
    json['clinic_name'] = clinicName;
    json['display_name'] = displayName;
    json['review'] = ratingList?.map((x) => x.toJson()).toList();
    json['ID'] = iD;
    json['service_id'] = serviceId;
    json['user_status'] = userStatus;
    json['isCheck'] = isCheck;
    json['charges'] = charges;
    json['duration'] = duration;
    json['image'] = serviceImage;
    json['mapping_table_id'] = mappingTableId;
    json['is_multiple_selection'] = multiple;
    json['status'] = status;
    json['is_telemed'] = isTelemed;
    json['service_data'] = serviceData?.map((x) => x.toJson()).toList();
    json['clinic'] = clinic?.map((x) => x.toJson()).toList();
    json['enocunter_modules'] =
        encounterModules?.map((x) => x.toJson()).toList();
    json['module_config'] = moduleConfig?.map((x) => x.toJson()).toList();
    json['avgRating'] = avgRating;
    json['patient_added_by'] = patientAddedBy;
    json['total_encounter'] = totalEncounter;
    json['user_registered'] = userRegistered;
    json['restrict_appointment'] = restrictAppointment?.toJson();
    json['current_medical_condition'] = currentMedicalCondition;
    json['patient_height'] = patientHeight;
    json['patient_weight'] = patientHeight;
    json['current_doctor_name'] = currentDoctorName;
    json['current_doctor_phone'] = currentDoctorPhone;
    json['current_doctor_email'] = currentDoctorEmail;

    return json;
  }
}
