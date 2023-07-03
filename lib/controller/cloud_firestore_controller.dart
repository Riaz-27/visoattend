import 'dart:async';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:visoattend/controller/auth_controller.dart';
import 'package:visoattend/models/classroom_model.dart';
import 'package:visoattend/models/user_model.dart';

import '../models/attendance_model.dart';
import 'timer_controller.dart';

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

  final _filteredClassroom = <ClassroomModel>[].obs;

  List<ClassroomModel> get filteredClassroom => _filteredClassroom;

  final _classesOfToday = <ClassroomModel>[].obs;

  List<ClassroomModel> get classesOfToday => _classesOfToday;

  final _timeLeftOfClasses = [].obs;

  List<dynamic> get timeLeftOfClasses => _timeLeftOfClasses;

  final _isInitialized = false.obs;

  bool get isInitialized => _isInitialized.value;

  set isInitialized(value) => _isInitialized.value = value;

  void initialize() async {
    await resetValues();
    await setCurrentUser();
    await getUserClassrooms().then((_) => filterClassesOfToday());
  }

  Future<void> resetValues() async {
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
    if (currentAuthUser == null) {
      await resetValues();
      return;
    }

    final userDoc = await _firestoreInstance
        .collection(userCollection)
        .doc(currentAuthUser.uid)
        .get();
    if (userDoc.data() != null) {
      _currentUser(UserModel.fromJson(userDoc.data()!));
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
      _currentUser.value.classrooms[classroomInfo.keys.first] =
          classroomInfo.values.first;
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
      _classrooms.add(classroom);
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
    // _classrooms.value = [];
    List<ClassroomModel> classes = [];
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
        dev.log(collectionRef.docs.length.toString());
        for (var docRef in collectionRef.docs) {
          classes.add(ClassroomModel.fromJson(docRef.data()));
        }
      } catch (e) {
        dev.log(e.toString());
      }
    }
    _classrooms.value = classes;
    _isInitialized.value = true;
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

  void filterClassesOfToday() {
    print('Classes Filtered');
    _classesOfToday.value = [];
    final allClasses = _classrooms;
    if (_classrooms.isEmpty) {
      return;
    }
    final weekDay = DateFormat('EEEE').format(DateTime.now());
    List<ClassroomModel> todayClasses =[];
    for (ClassroomModel classroom in allClasses) {
      if (classroom.weekTimes[weekDay]['time'] != 'Off Day') {
        todayClasses.add(classroom);
      }
    }
    _classesOfToday.value = todayClasses;
    _classesOfToday.sort((a, b) {
      String aData =
          TimeOfDay.fromDateTime(DateTime.parse(a.weekTimes[weekDay]['time']))
              .toString();
      String bData =
          TimeOfDay.fromDateTime(DateTime.parse(b.weekTimes[weekDay]['time']))
              .toString();
      return aData.compareTo(bData);
    });
    int count = 0;
    List<int> tempTime = [];
    for (ClassroomModel classroom in _classesOfToday) {
      final startTime =
          TimeOfDay.fromDateTime(DateTime.parse(classroom.weekTimes[weekDay]['time']));
      final now = TimeOfDay.now();
      final timeDifferance = (now.hour * 60 + now.minute) -
          (startTime.hour * 60 + startTime.minute);
      tempTime.add(timeDifferance * -1);
      if (timeDifferance >= 0) {
        count++;
      }
    }
    _timeLeftOfClasses.value = tempTime;
    if (count > 0) {
      _classesOfToday.removeRange(0, count - 1);
      _timeLeftOfClasses.removeRange(0, count - 1);
    }
    if (_classesOfToday.isNotEmpty) {
      calculateHomeClassAttendance(_classesOfToday.first.classroomId);
    }
    if (_timeLeftOfClasses.isNotEmpty &&
        (_timeLeftOfClasses.first > 0 || _timeLeftOfClasses.length > 1)) {
      Get.find<TimerController>().startTimer();
    } else {
      Get.find<TimerController>().cancelTimer();
    }
  }

  void updateTimeLeft() {
    print('Running Update');

    if (_timeLeftOfClasses.isNotEmpty) {
      filterClassesOfToday();
    }
  }

  //filtering classroom for the search result
  void filterSearchResult(String value) {
    _filteredClassroom.value = [];
    if (value.isEmpty) {
      _filteredClassroom.value = _classrooms;
    } else {
      value = value.toLowerCase();
      _filteredClassroom.value = _classrooms
          .where((classroom) =>
              classroom.courseTitle.toLowerCase().contains(value) ||
              classroom.courseCode.toLowerCase().contains(value) ||
              classroom.session.toLowerCase().contains(value) ||
              classroom.section.toLowerCase().contains(value))
          .toList();
    }
  }

  /// Attendance Control
  final attendanceCollection = 'Attendances';

  final _homeMissedClasses = 0.obs;

  int get homeMissedClasses => _homeMissedClasses.value;

  final _homeClassAttendances = 0.obs;

  int get homeClassAttendances => _homeClassAttendances.value;

  String homeClassId = '';

  Future<List<AttendanceModel>> getClassroomAttendances(
      String classroomId) async {
    final collectionRef = await _firestoreInstance
        .collection(classroomsCollection)
        .doc(classroomId)
        .collection(attendanceCollection)
        .orderBy('dateTime', descending: true)
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

  Future<void> calculateHomeClassAttendance(String classroomId) async {
    if(homeClassId == classroomId){
      return;
    }
    homeClassId = classroomId;

    final attendances = await getClassroomAttendances(classroomId);
    _homeClassAttendances.value = attendances.length;

    print('CAL HOME CLASS');

    int missedClass = 0;
    for (AttendanceModel attendance in attendances) {
      if (attendance.studentsData[currentUser.authUid] == 'Absent') {
        missedClass++;
      }
    }
    _homeMissedClasses.value = missedClass;
  }
}
