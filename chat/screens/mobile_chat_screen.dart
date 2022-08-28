import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myshop/auth/controller/auth_controller.dart';
import 'package:myshop/chat/widgets/bottom_chat_field.dart';
import 'package:myshop/chat/widgets/chat_list.dart';
import 'package:myshop/chat/widgets/colors.dart';
import 'package:myshop/models/user.dart';
import 'package:myshop/widget/loader.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  // final bool isGroupChat;
  // final String profilePic;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    // required this.isGroupChat,
    // required this.profilePic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: StreamBuilder<UserModel>(
            stream: ref.read(authControllerProvider).userDataById(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Column(
                children: [
                  Text(name),
                  Text(
                    snapshot.data!.isOnline ? 'online' : 'offline',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
        centerTitle: false,
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.video_call),
        //   ),
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.call),
        //   ),
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.more_vert),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              recieverUserId: uid,
            ),
          ),
          BottomChatField(
            recieverUserId: uid,
          ),
        ],
      ),
    );
  }
}
