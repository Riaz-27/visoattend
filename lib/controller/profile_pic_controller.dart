import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicController extends GetxController {
  final _firebaseStorage = FirebaseStorage.instance;

  final _profilePicUrl = 'https://firebasestorage.googleapis.com/v0/b/visoattend.appspot.com/o/profile_pics%2Fdefault_profile.jpg?alt=media&token=0ff37477-4ac1-41df-8522-73a5eacceee7'.obs;
  String get profilePicUrl => _profilePicUrl.value;

  void pickUploadImage(
      {required ImageSource source, required String userAuthUid}) async {
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
      _profilePicUrl.value = await ref.getDownloadURL();
    }
  }

  Future<String?> getUserProfilePic({required String userAuthUid}) async {
    try{
      final ref = _firebaseStorage
          .ref()
          .child('/profile_pics')
          .child('$userAuthUid.jpg');
      final picUrl = await ref.getDownloadURL();
      _profilePicUrl.value = picUrl;
      return picUrl;
    } catch(e){
      return null;
    }
  }
}
