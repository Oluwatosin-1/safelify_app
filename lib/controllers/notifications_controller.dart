import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/notification.dart';
import '../utils/global_helpers.dart';

class NotificationsController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Notification> notifications = RxList();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch notifications from Firestore
  Future<void> fetchNotifications() async {
    isLoading(true);
    try {
      // Assuming your notifications are stored in a collection named 'notifications'
      var snapshot = await _firestore.collection('notifications').get();

      // Handle empty collection case
      if (snapshot.docs.isEmpty) {
        notifications.value = [];
        return;
      }

      notifications.value = snapshot.docs
          .map((doc) => Notification.fromMap(doc.data()))
          .toList();
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }
}
