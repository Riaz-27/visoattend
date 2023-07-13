import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'cloud_firestore_controller.dart';

class ProfilePicController extends GetxController {
  final _firebaseStorage = FirebaseStorage.instance;

  final _profilePicUrl = 'https://firebasestorage.googleapis.com/v0/b/visoattend.appspot.com/o/profile_pics%2Fdefault_profile.jpg?alt=media&token=0ff37477-4ac1-41df-8522-73a5eacceee7'.obs;

  String get profilePicUrl => _profilePicUrl.value;
  set profilePicUrl(String value) => _profilePicUrl.value = value;

  Future<String> uploadDefaultImage(String userAuthUid) async {
    final ref =
        _firebaseStorage.ref().child('/profile_pics').child('$userAuthUid.jpg');

    await ref.putFile(File('assets/default_profile.jpg'));
    final picUrl = await ref.getDownloadURL();
    _profilePicUrl.value = await ref.getDownloadURL();
    return picUrl;
  }

  Future<void> pickUploadImage(ImageSource source) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final userAuthUid = cloudFirestoreController.currentUser.authUid;
    final image = await ImagePicker().pickImage(
      source: source,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );
    if (image != null) {
      final ref = _firebaseStorage
          .ref()
          .child('/profile_pics')
          .child('$userAuthUid.jpg');

      await ref.putFile(File(image.path));
      final picUrl = await ref.getDownloadURL();
      _profilePicUrl.value = picUrl;
      cloudFirestoreController.currentUser.profilePic = picUrl;
      await cloudFirestoreController
          .updateUserData(cloudFirestoreController.currentUser);
    }
  }

  Future<String?> getUserProfilePic({required String userAuthUid}) async {
    try {
      final ref = _firebaseStorage
          .ref()
          .child('/profile_pics')
          .child('$userAuthUid.jpg');
      final picUrl = await ref.getDownloadURL();
      return picUrl;
    } catch (e) {
      return null;
    }
  }
}
