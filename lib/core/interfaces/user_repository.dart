import '../../model/user_model.dart';

/// Abstract interface for user data operations
/// Implemented by different backend repositories (Firebase, Telehealth, Telelegal)
abstract class UserRepository {
  /// Get user data by user ID
  Future<UserModel?> getUser(String userId);

  /// Update user data
  Future<void> updateUser(UserModel user);

  /// Sync user data across all backends
  Future<void> syncUserData();

  /// Check if user exists in this backend
  Future<bool> userExists(String userId);

  /// Create user in this backend
  Future<void> createUser(UserModel user);

  /// Delete user from this backend
  Future<void> deleteUser(String userId);

  /// Get user profile image URL
  Future<String?> getUserProfileImage(String userId);

  /// Update user profile image
  Future<String?> updateUserProfileImage(String userId, String imagePath);

  /// Get user's clinics (for doctors/receptionists)
  Future<List<String>?> getUserClinics(String userId);

  /// Update user's clinic associations
  Future<void> updateUserClinics(String userId, List<String> clinicIds);
}
