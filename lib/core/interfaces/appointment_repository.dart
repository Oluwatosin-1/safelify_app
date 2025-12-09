import '../../model/upcoming_appointment_model.dart';

/// Abstract interface for appointment data operations
/// Implemented by different backend repositories
abstract class AppointmentRepository {
  /// Get appointments for a specific user
  Future<List<UpcomingAppointmentModel>> getAppointments(String userId);

  /// Get appointment by ID
  Future<UpcomingAppointmentModel?> getAppointment(String appointmentId);

  /// Create new appointment
  Future<UpcomingAppointmentModel> createAppointment(UpcomingAppointmentModel appointment);

  /// Update existing appointment
  Future<void> updateAppointment(UpcomingAppointmentModel appointment);

  /// Cancel/delete appointment
  Future<void> cancelAppointment(String appointmentId);

  /// Get appointments for a specific clinic
  Future<List<UpcomingAppointmentModel>> getClinicAppointments(String clinicId);

  /// Get appointments for a specific doctor
  Future<List<UpcomingAppointmentModel>> getDoctorAppointments(String doctorId);

  /// Sync appointments across all backends
  Future<void> syncAppointments();

  /// Get appointments within date range
  Future<List<UpcomingAppointmentModel>> getAppointmentsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status);

  /// Get pending appointments count
  Future<int> getPendingAppointmentsCount(String userId);
}
