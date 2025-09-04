import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import '../screens/auth/screens/sign_in_screen.dart';
import '../utils/constants.dart';
import '../utils/global_helpers.dart';
import '../main_page.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isRequestingHelp = false.obs;
  Rx<User?> user = Rx<User?>(null);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString userRole = ''.obs; // Add this line
  final GetStorage box = GetStorage();
  RxString firstName = ''.obs;  // To store first name
  RxString lastName = ''.obs;   // To store last name


  @override
  void onInit() async {
    super.onInit();
    user.value = _auth.currentUser;
    if (user.value != null) {
      await fetchUserDetails();
    }
    _auth.authStateChanges().listen((User? user) async {
      this.user.value = user;
      if (user != null) {
        fetchUserDetails();
      }
    });
  }

  // Merged fetchUserRole and fetchUserDetails for efficiency
  Future<void> fetchUserDetails() async {
    try {
      if (user.value != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.value!.uid)
            .get();
        if (doc.exists) {
          userRole.value = doc['role'] ?? ''; // Fetch the role
          firstName.value = doc['first_name'] ?? ''; // Fetch first name
          lastName.value = doc['last_name'] ?? '';   // Fetch last name
        } else {
          log('User document does not exist.');
        }
      } else {
        log('User value is null. Cannot fetch user details.');
      }
    } catch (e) {
      log('Error fetching user details: $e');
    }
  }

  Future<bool> checkFirebaseAuth(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } catch (e) {
      if (kDebugMode) {
        log('Firebase authentication error: $e');
      }
      return false;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading(true);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user.value = userCredential.user;
      await storeAuthData(userCredential.user!.uid);
      Get.offAll(() => MainPage());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showMightySnackBar(message: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showMightySnackBar(message: 'Wrong password provided.');
      } else {
        showMightySnackBar(message: 'Sign-in failed: ${e.message}');
      }
    } catch (e) {
      showMightySnackBar(message: 'Sign-in failed: $e');
    } finally {
      isLoading(false);
    }
  }


  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      isLoading(true);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user.value = userCredential.user;
      await storeAuthData(userCredential.user!.uid);
      Get.offAll(() => MainPage());
    } on FirebaseAuthException catch (e) {
      showMightySnackBar(message: e.message ?? "Registration failed.");
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<String?> getIdToken() async {
    User? currentUser = _auth.currentUser;
    return currentUser?.getIdToken();
  }
  Future<void> signOut(BuildContext context) async {
    try {
      // 1. Sign out from Firebase
      await _auth.signOut();
      if (kDebugMode) {
        log("Firebase sign-out successful.");
      }

      // 2. Clear local storage
      await box.erase();
      if (kDebugMode) {
        log("Local storage cleared.");
      }

      // 3. Clear additional local storage keys if needed
      await removeKey(USER_ID);
      await removeKey(FIRST_NAME);
      await removeKey(LAST_NAME);
      await removeKey(USER_EMAIL);
      await removeKey(USER_DISPLAY_NAME);
      await removeKey(PROFILE_IMAGE);
      await removeKey(USER_MOBILE);
      await removeKey(USER_GENDER);
      await removeKey(USER_ROLE);
      await removeKey(PASSWORD);

      // 4. Update app state
      appStore.setLoggedIn(false);
      appStore.setLoading(false);

      // 5. Redirect to SignInScreen
      Get.offAll(() =>  SignInScreen(), transition: Transition.fade);
      log("Redirected to Sign-In Screen.");

    } catch (e) {
      showMightySnackBar(message: "Sign-out failed: ${e.toString()}");
      if (kDebugMode) {
        log("Sign-out failed: ${e.toString()}");
      }
    }
  }


  Future<void> storeAuthData(String uid) async {
    try {
      var box = GetStorage();
      await box.write('auth_data', {'uid': uid});
    } catch (e) {
      showMightySnackBar(message: "Failed to store auth data: ${e.toString()}");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      Get.to(() =>  SignInScreen());
      showMightySnackBar(message: "Password reset link has been sent to your email.");
    } on FirebaseAuthException catch (e) {
      showMightySnackBar(message: e.message ?? "Password reset failed.");
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading(true);
      await _auth.currentUser?.delete();
      await signOut(getContext);
      showMightySnackBar(message: "Account deleted successfully.");
    } on FirebaseAuthException catch (e) {
      showMightySnackBar(message: e.message ?? "Account deletion failed.");
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
    required Map<String, String> details,
    XFile? image,
  }) async {
    try {
      isLoading(true);

      Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
        'address': address,
        ...details,
      };

      if (image != null) {
        String? imageUrl = await uploadImage(image);
        if (imageUrl != null) {
          data['profile_image'] = imageUrl;
        }
      }

      if (user.value != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.value!.uid)
            .update(data);
        showMightySnackBar(message: "Profile updated successfully.");
      } else {
        showMightySnackBar(message: "User not authenticated.");
      }
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>?> get userDetails async {
    if (user.value != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.value!.uid)
            .get();
        return doc.data() as Map<String, dynamic>?;
      } catch (e) {
        showMightySnackBar(message: "Failed to fetch user details: ${e.toString()}");
        return null;
      }
    }
    return null;
  }

  Future<String?> uploadImage(XFile image) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final ref = storage.ref().child('profile_images/${user.value!.uid}/${DateTime.now().toIso8601String()}_${image.name}');
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      showMightySnackBar(message: "Image upload failed: ${e.toString()}");
      return null;
    }
  }

  Future<void> requestHelp({
    required String requestType,
    required String description,
  }) async {
    try {
      isRequestingHelp(true);
      String uid = user.value!.uid;
      Map<String, dynamic> data = {
        'request_type': requestType,
        'description': description,
        'requested_at': FieldValue.serverTimestamp(),
        'user_id': uid,
      };

      await FirebaseFirestore.instance
          .collection('help_requests')
          .add(data);
      showMightySnackBar(message: "Help request submitted successfully.");
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isRequestingHelp(false);
    }
  }

  Future<void> becomeReporter(String reason, XFile? proofImage) async {
    try {
      isLoading(true);
      String uid = user.value!.uid;
      Map<String, dynamic> data = {
        'reason': reason,
        'requested_at': FieldValue.serverTimestamp(),
        'user_id': uid,
        'status': 'pending',
      };

      if (proofImage != null) {
        String? imageUrl = await uploadImage(proofImage);
        if (imageUrl != null) {
          data['proof_image'] = imageUrl;
        }
      }

      await FirebaseFirestore.instance
          .collection('reporter_requests')
          .add(data);
      showMightySnackBar(message: "Reporter request submitted successfully.");
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateHelpRequestStatus(String requestId, String status) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('help_requests')
          .doc(requestId)
          .update(data);
      showMightySnackBar(message: "Help request status updated successfully.");
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }
}