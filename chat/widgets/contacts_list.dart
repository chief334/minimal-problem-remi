import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:myshop/chat/controller/chat_controller.dart';
import 'package:myshop/chat/screens/mobile_chat_screen.dart';
import 'package:myshop/chat/widgets/colors.dart';
import 'package:myshop/models/chat_contact.dart';

class ContactsList extends ConsumerWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(color: Colors.black)),
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: StreamBuilder<List<ChatContact>>(
            stream: ref.watch(chatControllerProvider).chatContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An Error Has Occured'),
                );
              }
              if (snapshot.requireData.isEmpty) {
                return const Center(
                  child: Text('No Chats Available Yet'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var chatContactData = snapshot.data![index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            MobileChatScreen.routeName,
                            arguments: {
                              'name': chatContactData.name,
                              'uid': chatContactData.contactId,
                              // 'isGroupChat': false,
                              // 'profilePic': chatContactData.profilePic,
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(
                              chatContactData.name,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                chatContactData.lastMessage,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                chatContactData.profilePic,
                              ),
                              radius: 30,
                            ),
                            trailing: Text(
                              DateFormat.Hm().format(chatContactData.timeSent),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: dividerColor, indent: 85),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}
