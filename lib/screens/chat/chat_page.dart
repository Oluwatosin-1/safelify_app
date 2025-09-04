import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import '../../controllers/chat_controller.dart';
import '../../utils/colors.dart';
import '../../utils/global_helpers.dart';

import '../../model/chat.dart'; 

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.receiverId});

  final String? receiverId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = Get.find();

  @override
  void initState() {
    super.initState();
    _chatController.fetchInitialChat(receiverId: widget.receiverId);
  }

  final GlobalKey<FormState> _key = GlobalKey();
  final TextEditingController _messageEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Image.asset(
            'assets/logo/app_logo.png',
            width: 30,
            height: 30,
            color: primaryColor,
          ),
          iconTheme: const IconThemeData(color: primaryColor),
          actions: [
            IconButton(
              onPressed: (){},// => Get.to(() => VideoCallPage()),
              icon: const Icon(Icons.video_call),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () {
                    return _chatController.isLoading.value
                        ? getLoading()
                        : _chatController.chat.value == null ||
                                _chatController.chat.value!.messages.isEmpty
                            ? const Center(child: Text("No Messages Yet."))
                            : Align(
                                alignment: Alignment.bottomCenter,
                                child: ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 70),
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemCount: _chatController
                                      .chat.value!.messages.length,
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: 10),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return chatBubble(_chatController
                                        .chat.value!.messages.reversed
                                        .elementAt(index));
                                  },
                                ),
                              );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 16,
                right: 16,
              ),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Form(
                    key: _key,
                    child: TextFormField(
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? "Please type something..."
                              : null,
                      cursorColor: primaryColor,
                      controller: _messageEditingController,
                      decoration: InputDecoration(
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        suffixIcon: InkWell(
                          onTap: () async {
                            if (_key.currentState!.validate() &&
                                _chatController.chat.value != null) {
                              await _chatController.sendMessage(
                                  _messageEditingController.text.trim(),
                                  _chatController.chat.value!.userId);
                              _messageEditingController.clear();
                            }
                          },
                          child: Container(
                            width: 20,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        hintText: 'Type here...',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // bottomSheet:
      ),
    );
  }

  Widget chatBubble(Message message) {
    return Row(
      mainAxisAlignment:
          message.isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: message.isOwner ? Colors.grey : primaryColor),
          width: Get.width * 0.8,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: Text(
            message.body,
            style: const TextStyle(
              letterSpacing: 1.1,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
