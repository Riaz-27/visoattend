import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
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


  final _classrooms = <ClassroomModel>[].obs;
  List<ClassroomModel?> get classrooms => _classrooms;


  Stream<List<ClassroomModel>> get getUserClassrooms => _getUserClassrooms();

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

  Future<void> updateUserClassroom(Map<String,String> classroomInfo) async {
    try{
      if(currentUser == null){
        print('User Not Found');
        return;
      }
      currentUser!.classrooms.add(classroomInfo);
      await _firestoreInstance.collection(userCollection).doc(currentUser!.userId).update(
          {'classrooms': currentUser!.classrooms});
    } catch(e) {
      print(e.toString());
    }
  }

  bool isUserAlreadyInThisClassroom(String classroomId){
    currentUser!.classrooms.map((value){
      if(value['id'] == classroomId){
        return true;
      }
    });
    return false;
  }



  /// Classroom database control
  final classroomsCollection = 'Classrooms';

  Future<String?> createClassroom(ClassroomModel classroom) async {
    try {
      final docRef = _firestoreInstance
          .collection(classroomsCollection)
          .doc()
          ..set(classroom.toJson());
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
          .doc(classroomId).get();
      final docData = docRef.data();
      if(docData == null || docData.isEmpty){
        return false;
      }
      docData['students'].add(currentUser!.userId);
      await _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroomId).update(docData['students']);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Stream<List<ClassroomModel>> _getUserClassrooms() {
    try {
      if (currentUser == null) {
        print('No User Found!');
        return const Stream.empty();
      }
      print('User Found : ${currentUser!.userId}');
      final classrooms = currentUser!.classrooms.map((val) => val['id'].toString()).toList();
      if(classrooms.isEmpty){
        return const Stream.empty();
      }
      final result = _firestoreInstance
          .collection(classroomsCollection)
          .where(FieldPath.documentId, whereIn: classrooms)
          .snapshots()
          .map((querySnap) => querySnap.docs
              .map((docSnap) => ClassroomModel.fromJson(docSnap.data()))
              .toList());
      return result;
    } catch (e) {
      print(e.toString());
      return const Stream.empty();
    }
  }

  /// Attendance Control
  final attendanceCollection = 'Attendances';
}
