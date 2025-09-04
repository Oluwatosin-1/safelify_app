import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat.dart';
import '../utils/global_helpers.dart';

class ChatController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<Chat?> chat = Rx(null);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchInitialChat({String? receiverId}) async {
    try {
      isLoading(true);

      DateTime dateTime = DateTime.now();
      String timezone = dateTime.timeZoneName;

      String chatPath = 'messages/${receiverId ?? '1'}';
      DocumentSnapshot<Map<String, dynamic>> response = await _firestore.doc(chatPath).get();
      Map<String, dynamic> chatData = response.data()!;
      chatData['timezone'] = timezone;

      chat.value = Chat.fromMap(chatData);
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshChat({String? receiverId}) async {
    try {
      DateTime dateTime = DateTime.now();
      String timezone = dateTime.timeZoneName;

      String chatPath = 'messages/${receiverId ?? '1'}';
      DocumentSnapshot<Map<String, dynamic>> response = await _firestore.doc(chatPath).get();
      Map<String, dynamic> chatData = response.data()!;
      chatData['timezone'] = timezone;

      chat.value = Chat.fromMap(chatData);
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    }
  }

  Future<void> sendMessage(String message, String receiverId) async {
    try {
      isLoading(true);

      Map<String, dynamic> messageData = {
        'message': message,
        'receiverId': receiverId,
        'sent_at': DateTime.now().toUtc().toString(),
      };

      String chatPath = 'messages/$receiverId';
      await _firestore.collection(chatPath).add(messageData);
      await refreshChat(receiverId: receiverId);
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }
}
