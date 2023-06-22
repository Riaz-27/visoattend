import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:visoattend/controller/auth_controller.dart';
import 'package:visoattend/models/classroom_model.dart';
import 'package:visoattend/models/user_model.dart';

import '../models/attendance_model.dart';

class CloudFirestoreController extends GetxController {
  final _firestoreInstance = FirebaseFirestore.instance;

  FirebaseFirestore get firestoreInstance => _firestoreInstance;

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  final _currentUser = UserModel.empty().obs;

  UserModel get currentUser => _currentUser.value;

  set currentUser(UserModel user) => _currentUser.value = user;

  final _classrooms = <ClassroomModel>[].obs;

  List<ClassroomModel> get classrooms => _classrooms;

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

  Future<UserModel?> getUserDataFromFirestoreByEmail(String email) async {
    final userDocument = await _firestoreInstance
        .collection(userCollection)
        .where('email', isEqualTo: email)
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
        dev.log(e.toString());
      }
    }
  }

  Future<void> updateUserClassroom(Map<String, String> classroomInfo) async {
    try {
      if (_currentUser.value.authUid == '') {
        dev.log('User Not Found');
        return;
      }
      _currentUser.value.classrooms[classroomInfo.keys.first] = classroomInfo.values.first;
      await _firestoreInstance
          .collection(userCollection)
          .doc(_currentUser.value.authUid)
          .update({'classrooms': _currentUser.value.classrooms});
    } catch (e) {
      dev.log(e.toString());
    }
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
      dev.log(e.toString());
      return null;
    }
  }

  bool isUserAlreadyInThisClassroom(String classroomId) {
    if (_currentUser.value.authUid == '') {
      dev.log('User not found');
      return true;
    }
    for (String value in _currentUser.value.classrooms.keys) {
      if (value == classroomId) {
        return true;
      }
    }
    return false;
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
      dev.log('The Doc Data : $docData');
      await _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroomId)
          .update({'students': docData['students']});
      _classrooms.add(ClassroomModel.fromJson(docData));
      return true;
    } catch (e) {
      dev.log(e.toString());
      return false;
    }
  }

  Future<void> getUserClassrooms() async {
    if (_currentUser.value.authUid == '') {
      dev.log('No User Found!');
      return;
    }
    final classroomList = _currentUser.value.classrooms.keys.toList();
    if (classroomList.isEmpty) {
      dev.log('ClassroomList is empty');
      return;
    }
    dev.log('ClassroomList: $classroomList');
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
        dev.log(e.toString());
      }
    }
  }

  Future<List<UserModel>> getStudentsOfClassroom(
      List<String> studentsUid) async {
    List<UserModel> finalList = [];
    for (int i = 0; i < studentsUid.length; i += 10) {
      try {
        final collectionsRef = await _firestoreInstance
            .collection(userCollection)
            .where(FieldPath.documentId,
                whereIn: studentsUid.sublist(i,
                    i + 10 > studentsUid.length ? studentsUid.length : i + 10))
            .get();
        for (var docRef in collectionsRef.docs) {
          finalList.add(UserModel.fromJson(docRef.data()));
        }
      } catch (e) {
        dev.log(e.toString());
        return [];
      }
    }
    return finalList;
  }

  /// Attendance Control
  final attendanceCollection = 'Attendances';

  Future<List<AttendanceModel>> getClassroomAttendances(
      String classroomId) async {
    final collectionRef = await _firestoreInstance
        .collection(classroomsCollection)
        .doc(classroomId)
        .collection(attendanceCollection)
        .get();
    return collectionRef.docs
        .map((docRef) => AttendanceModel.fromJson(docRef.data()))
        .toList();
  }

  Future<void> saveAttendanceData(
    String classroomId,
    AttendanceModel attendanceData,
  ) async {
    await _firestoreInstance
        .collection(classroomsCollection)
        .doc(classroomId)
        .collection(attendanceCollection)
        .doc()
        .set(attendanceData.toJson());
  }
}
