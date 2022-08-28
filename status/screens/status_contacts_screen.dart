import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myshop/models/status_model.dart';
import 'package:myshop/status/controller/status_controller.dart';
import 'package:myshop/status/screens/confirm_status_screen.dart';
import 'package:myshop/status/screens/status_screen.dart';
import 'package:myshop/widget/loader.dart';

class StatusContactsScreen extends ConsumerStatefulWidget {
  final String? profilePic;
  StatusContactsScreen({Key? key, this.profilePic}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatusContactsScreenState();
}

class _StatusContactsScreenState extends ConsumerState<StatusContactsScreen> {
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickedProfileFile(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      maxWidth: 600,
    );
    if (photo == null) {
      return;
    }
    setState(() {
      _profileImageFile = File(photo.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final data = ref.read(authControllerProvider);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('status')
                    .where(
                      'uid',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .where(
                      'createdAt',
                      isGreaterThan: DateTime.now()
                          .subtract(const Duration(hours: 24))
                          .millisecondsSinceEpoch,
                    )
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.data!.docs.isEmpty || snapshot.data == null) {
                    return SingleChildScrollView(
                      child: InkWell(
                        onTap: () async {
                          await _pickedProfileFile(ImageSource.gallery);
                          // File? pickedImage =
                          //     await pickImageFromGallery(context);
                          if (_profileImageFile != null) {
                            Navigator.pushNamed(
                              context,
                              ConfirmStatusScreen.routeName,
                              arguments: _profileImageFile,
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: widget.profilePic == null
                                  ? AssetImage('assets/images/profilepic.jpg')
                                      as ImageProvider<Object>?
                                  : CachedNetworkImageProvider(
                                      widget.profilePic!,
                                    ),
                              radius: 34,
                            ),
                            Positioned(
                              right: -10,
                              bottom: -5,
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Container(
                    height: 90,
                    width: 80,
                    child: ListView.builder(
                        itemCount: snapshot.requireData.size,
                        itemBuilder: (context, i) {
                          final data = snapshot.requireData.docs[i].data();
                          Status tempStatus = Status.fromMap(data);

                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                StatusScreen.routeName,
                                arguments: tempStatus,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child:
                                  // title: Text(
                                  //   statusData.username,
                                  // ),
                                  CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  tempStatus.profilePic,
                                ),
                                radius: 47,
                              ),
                            ),
                          );
                        }),
                  );
                }),
            Expanded(
              child: FutureBuilder<List<Status>>(
                future: ref.read(statusControllerProvider).getStatus(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  //ignore: unnecessary_null_comparison
                  // if (snapshot.data!.isEmpty || snapshot.data! == null) {
                  //   return const Loader();
                  // }
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        // if (index == 0) {
                        //   return

                        // } else {
                        var statusData = snapshot.data![index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  StatusScreen.routeName,
                                  arguments: statusData,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child:
                                    // title: Text(
                                    //   statusData.username,
                                    // ),
                                    CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    statusData.profilePic,
                                  ),
                                  radius: 47,
                                ),
                              ),
                            ),
                            // const Divider(color: dividerColor, indent: 85),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class StatusContactsScreen extends ConsumerWidget {
//   final String? profilePic;
//    StatusContactsScreen({Key? key, this.profilePic}) : super(key: key);

//  File? _profileImageFile;
//  final ImagePicker _picker = ImagePicker();
//   Future<void> _pickedProfileFile(ImageSource source) async {
//     final XFile? photo = await _picker.pickImage(
//       source: source,
//       maxWidth: 600,
//     );
//     if (photo == null) {
//       return;
//     }
//     setState(() {
//       _profileImageFile = File(photo.path);
//     });
//   }


// }
