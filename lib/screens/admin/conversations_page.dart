import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin/admin_conversations_controller.dart';
import '../../model/conversation.dart';
import '../../utils/colors.dart';
import '../../utils/global_helpers.dart';
import '../../widgets/app_bar.dart';
import '../auth/screens/sign_in_screen.dart';
import '../chat/chat_page.dart';

class ConversationsPage extends StatelessWidget {
  ConversationsPage({super.key});

  final AdminConversationsController _conversationsController = Get.put(AdminConversationsController())..fetchConversations();

  // Define the signOut method here
  Future<void> signOut(BuildContext context) async {
    try {
      await signOut(context); // Call the logout method you defined earlier
      Get.offAll(() => SignInScreen(), transition: Transition.fade); // Redirect to sign-in screen
    } catch (e) {
      showMightySnackBar(message: "Sign-out failed: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: const Text('Admin Conversations'),
        color: primaryColor,
        iconColor: Colors.white,
        actions: [
          IconButton(onPressed: () => signOut(context), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Obx(() {
        return _conversationsController.isLoading.value
            ? getLoading()
            : ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) {
            Conversation conversation = _conversationsController.conversations[index];
            return ListTile(
              onTap: () => Get.to(() => ChatPage(receiverId: conversation.receiverId)),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: primaryColor,
                backgroundImage: NetworkImage(
                  conversation.avatarReceiver,
                ),
              ),
              title: Text(
                conversation.nameReceiver,
              ),
              subtitle: Text(conversation.message),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 5),
          itemCount: _conversationsController.conversations.length,
        );
      }),
    );
  }
}
