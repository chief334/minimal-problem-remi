import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myshop/common/repositories/common_firebase_storage_repository.dart';
import 'package:myshop/common/utils/utils.dart';
import 'package:myshop/models/status_model.dart';
import 'package:myshop/models/user.dart';
import 'package:uuid/uuid.dart';

final statusRepositoryProvider = Provider(
  (ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      //  1first we get the status =id
      var statusId = const Uuid().v1();
      // 2 we get the uuid
      String uid = auth.currentUser!.uid;
      // 3 we get the reference of the inage file from firebase
      String imageurl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            '/status/$statusId$uid',
            statusImage,
          );
      List<String> uidWhoCanSee = [];
      // 4 we retrieve our  phone contacts
      //TODO 1  We create a following class model
      List<UserModel> contacts = [];
      //TODO 2 we get our following id from firebase and add it to following class model
      var collection = FirebaseFirestore.instance
          .collection('following')
          .doc(uid)
          .collection('userFollowers');
      var querySnapshots = await collection.get();
      for (var snapshot in querySnapshots.docs) {
        var userDataFirebase = await firestore
            .collection('users')
            .where(
              'uid',
              isEqualTo: snapshot.id,
            )
            .get();
        if (userDataFirebase.docs.isNotEmpty) {
          // we add to userData
          // TODO 7 we store thier data details locally
          var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
          // retrieve the uid and add to the list
          //TODO 8 and add their uid to our list
          uidWhoCanSee.add(userData.uid!);
        }
        var documentID = snapshot.id; // <-- Document ID
      }

      //TODO 9 we create another variable to hold our imageurls
      List<String> statusImageUrls = [];
      // we check if uid is equals to owner uid then get data
      //TODO  10 We search the status for our stored status
      var statusesSnapshot = await firestore
          .collection('status')
          .where(
            'createdAt',
            isGreaterThan: DateTime.now()
                .subtract(const Duration(hours: 24))
                .millisecondsSinceEpoch,
          )
          .where(
            'uid',
            isEqualTo: auth.currentUser!.uid,
          )
          .get();
      // TODO  11 its there we proceed
      if (statusesSnapshot.docs.isNotEmpty) {
        // if user has already add a  status, we update
        //TODO 12 we take the docs and store it locally
        Status status = Status.fromMap(statusesSnapshot.docs[0].data());
        //TODO 13 next we extract our store status photoUrl
        statusImageUrls = status.photoUrl;
        //TODO 14 and add it locally
        statusImageUrls.add(imageurl);
        //TODO 15 We udate our photourl to receive our the newest image taken
        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        // else we add a new status
        // TODO 16 if there are no stored images we store the current image in our local list
        statusImageUrls = [imageurl];
      }
      //  if it all  checks out we  send data to firebase
      // TODO   17 we take all data and store it in status model
      Status status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );
      //TODO We store its  in status collection in doc with v1 id
      await firestore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    //TODO  we create a list that will contain status
    List<Status> statusData = [];
    try {
      //TODO 2 we get our following id from firebase and add it to following class model

      var collection = FirebaseFirestore.instance
          .collection('following')
          .doc(auth.currentUser!.uid)
          .collection('userFollowers');
      var querySnapshots = await collection.get();
      for (var snapshot in querySnapshots.docs) {
        // UserModel userStatus = UserModel.fromMap(snapshot.data());

        var statusSnapshot = await firestore
            .collection('status')
            .where(
              'uid',
              isEqualTo: snapshot.id,
            )
            .where(
              'createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch,
            )
            .get();
        for (var tempData in statusSnapshot.docs) {
          // TODO 7 we store it in our status tempstatus variable
          Status tempStatus = Status.fromMap(tempData.data());
          //TODO 8 we check the field whocansee whether it contains our uid
          // QuerySnapshot<Map<String, dynamic>> mydoc = await firestore
          //     .collection('status')
          //     .where(
          //       'uid',
          //       isEqualTo: auth.currentUser!.uid,
          //     )
          //     .where(
          //       'createdAt',
          //       isGreaterThan: DateTime.now()
          //           .subtract(const Duration(hours: 2))
          //           .millisecondsSinceEpoch,
          //     )
          //     .get();
          // for (var medoc in mydoc.docs) {
          //   Status mytemStatus = Status.fromMap(medoc.data());
          //   statusData.add(mytemStatus);
          // }
          // if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
          //TODO  if yes we add to our list of statusData
          statusData.add(tempStatus);
          debugPrint(statusData.length.toString());
          // }
        }

        var documentID = snapshot.id; // <-- Document ID
      }
    } catch (e) {
      if (kDebugMode) print(e);
      showSnackBar(context: context, content: e.toString());
    }
    //TODO after all the docs have been collected we return statusData
    return statusData;
  }
}
