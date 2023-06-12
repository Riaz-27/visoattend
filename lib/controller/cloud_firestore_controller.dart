import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/auth_controller.dart';

import 'package:visoattend/models/classroom_model.dart';
import 'package:visoattend/models/user_model.dart';

class CloudFirestoreController extends GetxController {
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  final _firestoreInstance = FirebaseFirestore.instance;
  FirebaseFirestore get firestoreInstance => _firestoreInstance;

  UserModel? currentUser;
  final _currentUsername = ''.obs;

  String get currentUsername => _currentUsername.value;

  set currentUsername(String value) => _currentUsername(value);

  @override
  void onInit() {
    setCurrentUser();
    super.onInit();
  }

  /// User data control
  final userCollection = 'UserData';

  Future<UserModel?> getUserDataFromFirestore(String userId) async {
    final userDocument =
        await _firestoreInstance.collection(userCollection).doc(userId).get();
    final userData = userDocument.data();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  void setCurrentUser() async {
    final currentAuthUser = Get.find<AuthController>().currentUser;
    if (currentAuthUser != null) {
      final userDoc = await _firestoreInstance
          .collection(userCollection)
          .where('authUid', isEqualTo: currentAuthUser.uid)
          .get();
      if (userDoc.docs.isNotEmpty) {
        currentUser = UserModel.fromJson(userDoc.docs.first.data());
        _currentUsername(currentUser!.name);
      }
    }
  }

  void addUserDataToFirestore(UserModel user) async {
    final userData = await getUserDataFromFirestore(user.userId);
    if (userData == null) {
      try {
        await _firestoreInstance
            .collection(userCollection)
            .doc(user.userId)
            .set(user.toJson());
      } catch (e) {
        print(e.toString());
      }
    }
  }

  /// Classroom database control
  final classroomsCollection = 'Classrooms';

  Future<void> createClassroom(ClassroomModel classroom) async {
    try {
      _firestoreInstance
          .collection(classroomsCollection)
          .doc()
          .set(classroom.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

  /// Attendance Control
  final attendanceCollection = 'Attendances';
}
