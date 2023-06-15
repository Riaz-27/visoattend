import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:visoattend/controller/auth_controller.dart';
import 'package:visoattend/models/classroom_model.dart';
import 'package:visoattend/models/user_model.dart';

class CloudFirestoreController extends GetxController {
  final _firestoreInstance = FirebaseFirestore.instance;
  FirebaseFirestore get firestoreInstance => _firestoreInstance;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _currentUser = UserModel.empty().obs;
  UserModel get currentUser => _currentUser.value;
  set currentUser(UserModel user) => _currentUser.value = user;

  final _classrooms = <ClassroomModel>[].obs;
  List<ClassroomModel?> get classrooms => _classrooms;

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  void initialize() async {
    await setCurrentUser();
    await getUserClassrooms();
  }

  void resetValues() async {
    _isLoading(false);
    _currentUser(UserModel.empty());
    _classrooms([]);
  }

  /// User data control
  final userCollection = 'UserData';

  Future<UserModel?> getUserDataFromFirestore(String userId) async {
    final userDocument = await _firestoreInstance
        .collection(userCollection)
        .where('userId', isEqualTo: userId)
        .get();
    final userDoc = userDocument.docs;
    if (userDoc.isNotEmpty) {
      return UserModel.fromJson(userDoc.first.data());
    }
    return null;
  }

  Future<void> setCurrentUser() async {
    final currentAuthUser = Get.find<AuthController>().currentUser;
    if (currentAuthUser != null) {
      final userDoc = await _firestoreInstance
          .collection(userCollection)
          .doc(currentAuthUser.uid)
          .get();
      if (userDoc.data() != null) {
        _currentUser(UserModel.fromJson(userDoc.data()!));
      }
    }
  }

  void addUserDataToFirestore(UserModel user) async {
    final userData = await getUserDataFromFirestore(user.userId);
    if (userData == null) {
      try {
        await _firestoreInstance
            .collection(userCollection)
            .doc(user.authUid)
            .set(user.toJson());
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<void> updateUserClassroom(Map<String, String> classroomInfo) async {
    try {
      if (_currentUser.value.authUid == '') {
        print('User Not Found');
        return;
      }
      _currentUser.value.classrooms.add(classroomInfo);
      await _firestoreInstance
          .collection(userCollection)
          .doc(_currentUser.value.authUid)
          .update({'classrooms': _currentUser.value.classrooms});
    } catch (e) {
      print(e.toString());
    }
  }

  bool isUserAlreadyInThisClassroom(String classroomId) {
    if (_currentUser.value.authUid == '') {
      print('User not found');
      return true;
    }
    for (var value in _currentUser.value.classrooms) {
      if (value['id'] == classroomId) {
        return true;
      }
    }
    return false;
  }

  /// Classroom database control
  final classroomsCollection = 'Classrooms';

  Future<String?> createClassroom(ClassroomModel classroom) async {
    try {
      final docRef = _firestoreInstance.collection(classroomsCollection).doc();
      classroom.classroomId = docRef.id;
      docRef.set(classroom.toJson());
      return docRef.id;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> joinClassroom(String classroomId) async {
    try {
      final docRef = await _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroomId)
          .get();
      final docData = docRef.data();
      if (docData == null || docData.isEmpty) {
        return false;
      }
      docData['students'].add({
        'name': currentUser.name,
        'userId': currentUser.userId,
        'authUid': currentUser.authUid,
      });
      print('The Doc Data : $docData');
      await _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroomId)
          .update({'students': docData['students']});
      _classrooms.add(ClassroomModel.fromJson(docData));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> getUserClassrooms() async {
    if (_currentUser.value.authUid == '') {
      print('No User Found!');
      return;
    }
    final classroomList = _currentUser.value.classrooms
        .map((val) => val['id'].toString())
        .toList();
    if (classroomList.isEmpty) {
      print('ClassroomList is empty');
      return;
    }
    print('ClassroomList: $classroomList');
    _classrooms.value = [];
    for (int i = 0; i < classroomList.length; i += 10) {
      try {
        final collectionRef = await _firestoreInstance
            .collection(classroomsCollection)
            .where(FieldPath.documentId,
                whereIn: classroomList.sublist(
                    i,
                    i + 10 > classroomList.length
                        ? classroomList.length
                        : i + 10))
            .get();
        for (var docRef in collectionRef.docs) {
          _classrooms.add(ClassroomModel.fromJson(docRef.data()));
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  /// Attendance Control
  final attendanceCollection = 'Attendances';


}
