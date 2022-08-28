import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myshop/common/utils/utils.dart';
import 'package:myshop/status/controller/status_controller.dart';
import 'package:myshop/status/repository/status_repository.dart';
import 'package:myshop/utils/colors.dart';

class ConfirmStatusScreen extends ConsumerStatefulWidget {
  static const String routeName = '/confirm-status-screen';
  final File file;
  const ConfirmStatusScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConfirmStatusScreenState();
}

bool istrue = false;

class _ConfirmStatusScreenState extends ConsumerState<ConfirmStatusScreen> {
  // late NavigatorState _navigator;
  bool isloading = false;

  @override
  void didChangeDependencies() {
    // _navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

  String? result = '';
  Future<void> addStatus(File file, BuildContext context) async {
    setState(() {
      isloading = true;
    });
    await progress(file).then((value) {
      if (value!.isNotEmpty && value == 'Hurray!, file upload completed') {
        Future.delayed(Duration(seconds: 5), () {
          setState(() {
            isloading = false;
          });
          showSnackBar(
              context: context, content: 'Your status has been uploaded');
          Navigator.of(context).pop();
        });
      } else {
        showSnackBar(
            context: context, content: 'Please try again something went wrong');
      }
    }).onError((error, stackTrace) {
      showSnackBar(
          context: context, content: 'Please try again something went wrong');
    });
  }

  Future<String?> progress(File file) async {
    setState(() {
      result = 'Your file has started uploading';
      showSnackBar(
          context: context, content: 'Your file has started uploading');
    });
    final statusRepository = ref.read(statusRepositoryProvider);
    await ref.read(userDataAuthProvider).whenData((value) {
      if(value.toString().isNotEmpty){
        statusRepository.uploadStatus(
        username: value!.username!,
        profilePic: value.profilepic!,
        phoneNumber: value.phonenumber!.toString(),
        statusImage: file,
        context: context,
      );
      }
      else{
        showSnackBar(
          context: context, content: 'Please try again something went wrong');
      }
      
    });
    setState(() {
      result = 'Hurray!, file upload completed';
      showSnackBar(context: context, content: 'Hurray!, file upload completed');
    });
    return result;
  }

  // void addStatus(WidgetRef ref, BuildContext context) async {
  //   await ref.read(statusControllerProvider)
  //     ..addStatus(widget.file, context);

  //   // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   //   Future.delayed(Duration.zero, () {
  //   //     _navigator.pop(context);
  //   //   });
  //   // });
  // }

  @override
  void dispose() {
    // _navigator.deactivate();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(widget.file),
        ),
      ),
      floatingActionButton: isloading
          ? CircularProgressIndicator()
          : FloatingActionButton(
              onPressed: () {
                // setState(() {
                //   isloading = true;
                // });
                addStatus(widget.file, context);
                // setState(() {
                //   isloading = false;
                // });
              },
              backgroundColor: tabColor,
              child: isloading
                  ? CircularProgressIndicator()
                  : const Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
            ),
    );
  }
}


// class ConfirmStatusScreen extends ConsumerWidget {
//   static const String routeName = '/confirm-status-screen';
//   final File file;
//   const ConfirmStatusScreen({
//     Key? key,
//     required this.file,
//   }) : super(key: key);

  

//   void addStatus(WidgetRef ref, BuildContext context) {
//     ref.read(statusControllerProvider).addStatus(file, context);
    
//     Navigator.pop(context);
//   }
//   @override
//   void dispose() {
    
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: 9 / 16,
//           child: Image.file(file),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => addStatus(ref, context),
//         backgroundColor: tabColor,
//         child: const Icon(
//           Icons.done,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
