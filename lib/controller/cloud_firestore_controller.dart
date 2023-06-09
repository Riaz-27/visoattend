import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:visoattend/models/user_model.dart';

class CloudFirestoreController extends GetxController {
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  final firestoreInstance = FirebaseFirestore.instance;

  final userCollection = 'UserData';

  Future<Map<String,dynamic>?> getUserDataFromFirestore(String userId) async {
    final userDocument =
        await firestoreInstance.collection(userCollection).doc(userId).get();
    return userDocument.data();
  }

  void addUserDataToFirestore(UserModel user) async {
    await firestoreInstance.collection(userCollection).doc(user.userId).set(user.toJson());
  }
}
