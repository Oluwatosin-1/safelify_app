import '../../model/clinic_list_model.dart';

/// Abstract interface for clinic/doctor data operations
/// Implemented by different backend repositories
abstract class ClinicRepository {
  /// Get all clinics
  Future<List<Clinic>> getClinics({int page = 1, String? searchTerm});

  /// Get clinic by ID
  Future<Clinic?> getClinic(String clinicId);

  /// Get doctors for a specific clinic
  Future<List<dynamic>> getClinicDoctors(String clinicId);

  /// Get services offered by a clinic
  Future<List<dynamic>> getClinicServices(String clinicId);

  /// Search clinics by name/location
  Future<List<Clinic>> searchClinics(String query);

  /// Get clinics near a location (if location services available)
  Future<List<Clinic>> getNearbyClinics(double latitude, double longitude, double radius);

  /// Sync clinic data across backends
  Future<void> syncClinics();

  /// Get clinic availability/status
  Future<bool> isClinicActive(String clinicId);

  /// Get clinic working hours
  Future<Map<String, dynamic>?> getClinicHours(String clinicId);

  /// Update clinic information
  Future<void> updateClinic(Clinic clinic);
}
