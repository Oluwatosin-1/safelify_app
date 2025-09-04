import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/conversation.dart';
import '../../utils/global_helpers.dart';

class AdminConversationsController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Conversation> conversations = RxList();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchConversations() async {
    isLoading(true);
    try {
      // Assuming 'admin_conversations' is the document in 'conversations' collection
      DocumentSnapshot<Map<String, dynamic>> response = await _firestore
          .collection('conversations')
          .doc('admin_conversations')
          .get();

      if (response.exists) {
        var conversationsData = response.data()!;
        conversations.value = Conversation.listFromMap(conversationsData['conversations']);
      } else {
        showMightySnackBar(message: 'No conversations found.');
      }
    } catch (e) {
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }
}
