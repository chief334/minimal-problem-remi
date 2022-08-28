import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myshop/auth/controller/auth_controller.dart';
import 'package:myshop/models/status_model.dart';
import 'package:myshop/status/repository/status_repository.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepository = ref.read(statusRepositoryProvider);
  return StatusController(
    statusRepository: statusRepository,
    ref: ref,
  );
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class StatusController {
  final StatusRepository statusRepository;
  final ProviderRef ref;
  StatusController({
    required this.statusRepository,
    required this.ref,
  });

  void addStatus(File file, BuildContext context) async {
    await ref.watch(userDataAuthProvider).whenData((value) {
      statusRepository.uploadStatus(
        username: value!.username!,
        profilePic: value.profilepic!,
        phoneNumber: value.phonenumber!.toString(),
        statusImage: file,
        context: context,
      );
    });
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statuses = await statusRepository.getStatus(context);
    return statuses;
  }

  // Future<UserModel?> getUserData() async {
  //   UserModel? user = await ref.watch(userDataAuthProvider);
  //   return user;
  // }
}
