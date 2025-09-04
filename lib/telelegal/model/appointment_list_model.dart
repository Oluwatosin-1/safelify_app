import 'package:safelify/telelegal/model/upcoming_appointment_model.dart';

class AppointmentListModel {
  List<UpcomingAppointmentModel>? upcomingAppointment;
  int? total;

  AppointmentListModel({this.upcomingAppointment, this.total});

  factory AppointmentListModel.fromJson(Map<String, dynamic> json) {
    return AppointmentListModel(
      upcomingAppointment: json['data'] != null ? (json['data'] as List).map((i) => UpcomingAppointmentModel.fromJson(i)).toList() : null,
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    if (upcomingAppointment != null) {
      data['data'] = upcomingAppointment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
