import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import '../model/report_category.dart';
import '../model/get_community_reports_model.dart';
import '../utils/global_helpers.dart';
import 'auth_controller.dart';

class ReportController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isCorroborating = false.obs;
  RxBool isUploading = false.obs; // Track upload state

  RxList<CommunityReport> communityReports = RxList([]);
  RxList<ReportCategory> categories = RxList([]);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch categories from Firestore with their ID
  Future<void> fetchReportCategories() async {
    if (categories.isNotEmpty) return;
    isLoading(true);
    try {
      var snapshot = await _firestore.collection('reportCategories').get();
      categories.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return ReportCategory(
          id: doc.id, // Assign Firestore document ID to the category ID
          category: data['category'],
        );
      }).toList();

      categories.refresh();
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: 'Failed to fetch categories: $e');
    } finally {
      isLoading(false);
    }
  }

  // Add a new category with ID to Firestore
  Future<void> addCategory(String categoryName) async {
    if (categoryName.trim().isEmpty) {
      showMightySnackBar(message: 'Category name cannot be empty');
      return;
    }
    isLoading(true);
    try {
      DocumentReference newCategoryRef = _firestore.collection('reportCategories').doc();
      await newCategoryRef.set({
        'category': categoryName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchReportCategories(); // Refresh categories
      showMightySnackBar(message: 'Category added successfully');
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: 'Failed to add category: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addReport({
    required File? imageFile,
    required File? videoFile,
    required String title,
    required String token,
    required String catId,
    required String userId,
  }) async {
    if (title.isEmpty || catId.isEmpty || userId.isEmpty) {
      showMightySnackBar(message: 'Title, Category, or User ID is empty');
      return;
    }

    isUploading(true); // Indicate upload has started
    try {
      String reportId = _firestore.collection('reports').doc().id;

      String? imageUrl;
      String? videoUrl;

      // Upload image if provided
      if (imageFile != null) {
        try {
          final storageRef = _storage.ref().child('reportImages').child(reportId);
          final uploadTask = storageRef.putFile(imageFile);
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          throw Exception("Failed to upload image: $e");
        }
      }

      // Upload video if provided
      if (videoFile != null) {
        try {
          final storageRef = _storage.ref().child('reportVideos').child(reportId);
          final uploadTask = storageRef.putFile(videoFile);
          final snapshot = await uploadTask;
          videoUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          throw Exception("Failed to upload video: $e");
        }
      }

      // Add report to Firestore
      await _firestore.collection('reports').doc(reportId).set({
        'id': reportId,
        'title': title,
        'cat_id': catId,
        'image': imageUrl ?? '',
        'video': videoUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'token': token,
        'user_id': userId,
      });

      showMightySnackBar(message: 'Report added successfully');
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: 'Failed to submit report: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch community reports
  Future<void> fetchCommunityReports({
    bool loadMine = false,
    required String city,
    required String catId,
  }) async {
    isLoading(true);
    try {
      Query query = _firestore.collection('reports');

      if (city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (catId.isNotEmpty) {
        query = query.where('cat_id', isEqualTo: catId);
      }

      var snapshot = await query.get();

      communityReports.value = CommunityReport.listFromMap(
        snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>?; // Cast data to Map<String, dynamic>
          if (data != null) {
            data['id'] = doc.id; // Assign Firestore document ID to the 'id' field
          }
          return data ?? {}; // Ensure the return is a non-null map
        }).toList(),
      );

      if (loadMine) {
        AuthController authController = Get.find();
        String currentUserId = authController.user.value?.uid ?? '';
        communityReports.value = communityReports
            .where((element) => element.userId == currentUserId)
            .toList();
      }
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Update the status of a report (e.g., corroborate)
  Future<void> corroborate({required String id, required String status}) async {
    isCorroborating(true);
    try {
      await _firestore.collection('reports').doc(id).update({
        'status': status,
      });
      showMightySnackBar(message: 'Report status updated');
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isCorroborating(false);
    }
  }
}
