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

  final _archivedClassrooms = <ClassroomModel>[].obs;

  List<ClassroomModel> get archivedClassrooms => _archivedClassrooms;

  final _filteredClassroom = <ClassroomModel>[].obs;

  List<ClassroomModel> get filteredClassroom => _filteredClassroom;

  final _classesOfToday = <ClassroomModel>[].obs;

  List<ClassroomModel> get classesOfToday => _classesOfToday;

  final _timeLeftToStart = [].obs;

  List<dynamic> get timeLeftToStart => _timeLeftToStart;

  final _timeLeftToEnd = [].obs;

  List<dynamic> get timeLeftToEnd => _timeLeftToEnd;

  final _isHoliday = true.obs;

  bool get isHoliday => _isHoliday.value;

  final _isInitialized = false.obs;

  bool get isInitialized => _isInitialized.value;

  set isInitialized(value) => _isInitialized.value = value;

  Future<void> initialize() async {
    await resetValues();
    await setCurrentUser();
    await getUserClassrooms().then((_) => filterClassesOfToday());
  }

  Future<void> resetValues() async {
    _isLoading(false);
    _currentUser(UserModel.empty());
    _classrooms([]);
    _isHoliday(true);
    homeClassId = '';
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
        dev.log('Class not found');
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
      return true;
    } catch (e) {
      dev.log(e.toString());
      return false;
    }
  }

  Future<void> updateClassroom(ClassroomModel classroom) async {
    try {
      await _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroom.classroomId)
          .update(classroom.toJson());
    } catch (e) {
      dev.log(e.toString());
    }
  }

  Future<void> archiveClassroom(ClassroomModel classroom) async {
    try {
      await _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroom.classroomId)
          .update({'isArchived': true});
      await initialize();
    } catch (e) {
      dev.log(e.toString());
    }
  }

  Future<void> leaveClassroom(ClassroomModel classroom) async {
    try {
      classroom.students.removeWhere(
          (students) => students['authUid'] == currentUser.authUid);
      currentUser.classrooms
          .removeWhere((key, value) => key == classroom.classroomId);
      await _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroom.classroomId)
          .update({'students': classroom.students});
      await _firestoreInstance
          .collection(userCollection)
          .doc(currentUser.authUid)
          .update({'classrooms': currentUser.classrooms});
      await initialize();
    } catch (e) {
      dev.log(e.toString());
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
    List<ClassroomModel> archivedClasses = [];
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
          final classroom = ClassroomModel.fromJson(docRef.data());
          if (classroom.isArchived) {
            archivedClasses.add(classroom);
          } else {
            classes.add(classroom);
          }
        }
      } catch (e) {
        dev.log(e.toString());
      }
    }
    _classrooms.value = classes;
    _archivedClassrooms.value = archivedClasses;
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
    // Getting the class
    dev.log('Classes Filtered');
    _classesOfToday.value = [];
    final allClasses = _classrooms;
    if (_classrooms.isEmpty) {
      return;
    }
    final weekDay = DateFormat('EEEE').format(DateTime.now());
    List<ClassroomModel> todayClasses = [];
    for (ClassroomModel classroom in allClasses) {
      if (classroom.weekTimes[weekDay]['startTime'] != 'Off Day') {
        _isHoliday.value = false;
        todayClasses.add(classroom);
      }
    }
    _classesOfToday.value = todayClasses;
    _classesOfToday.sort((a, b) {
      String aData = TimeOfDay.fromDateTime(
              DateTime.parse(a.weekTimes[weekDay]['startTime']))
          .toString();
      String bData = TimeOfDay.fromDateTime(
              DateTime.parse(b.weekTimes[weekDay]['startTime']))
          .toString();
      return aData.compareTo(bData);
    });

    //filtering using time
    int count = 0;
    List<int> tempStartTimes = [];
    List<int> tempEndTimes = [];
    for (ClassroomModel classroom in _classesOfToday) {
      final startTime = TimeOfDay.fromDateTime(
          DateTime.parse(classroom.weekTimes[weekDay]['startTime']));
      final endTime = TimeOfDay.fromDateTime(
          DateTime.parse(classroom.weekTimes[weekDay]['endTime']));
      final now = TimeOfDay.now();
      final startTimeDifferance = (now.hour * 60 + now.minute) -
          (startTime.hour * 60 + startTime.minute);
      final endTimeDifferance =
          (now.hour * 60 + now.minute) - (endTime.hour * 60 + endTime.minute);
      tempStartTimes.add(startTimeDifferance * -1);
      tempEndTimes.add(endTimeDifferance);
      if (startTimeDifferance >= 0) {
        count++;
      }
    }
    _timeLeftToStart.value = tempStartTimes;
    _timeLeftToEnd.value = tempEndTimes;
    if (count > 0) {
      _classesOfToday.removeRange(0, count - 1);
      _timeLeftToStart.removeRange(0, count - 1);
      _timeLeftToEnd.removeRange(0, count - 1);
    }
    if (_classesOfToday.isNotEmpty) {
      if (_timeLeftToEnd.first >= 0) {
        _classesOfToday.removeAt(0);
        _timeLeftToStart.removeAt(0);
        _timeLeftToEnd.removeAt(0);
      }
    }
    if (_classesOfToday.isNotEmpty) {
      calculateHomeClassAttendance(_classesOfToday.first.classroomId);
    }
    if (_timeLeftToEnd.isNotEmpty && _timeLeftToEnd.first < 0) {
      dev.log('Timer Started');
      Get.find<TimerController>().startTimer();
    } else {
      dev.log('Timer Closed');
      Get.find<TimerController>().cancelTimer();
    }
  }

  void updateTimeLeft() {
    print('Running Update');

    if (_timeLeftToStart.isNotEmpty) {
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

  final _homeClassUserRole = 'Student'.obs;

  String get homeClassUserRole => _homeClassUserRole.value;

  String homeClassId = '';

  Stream<List<AttendanceModel>> attendancesStream(String classroomId) {
    return _firestoreInstance
        .collection(classroomsCollection)
        .doc(classroomId)
        .collection(attendanceCollection)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((query) {
      List<AttendanceModel> attendanceList = [];
      for (var element in query.docs) {
        attendanceList.add(AttendanceModel.fromJson(element.data()));
      }
      return attendanceList;
    });
  }

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

  Future<AttendanceModel> saveAttendanceData(
    String classroomId,
    AttendanceModel attendanceData,
  ) async {
    final docRef = _firestoreInstance
        .collection(classroomsCollection)
        .doc(classroomId)
        .collection(attendanceCollection)
        .doc();
    attendanceData.attendanceId = docRef.id;
    await docRef.set(attendanceData.toJson());
    return attendanceData;
  }

  Future<void> calculateHomeClassAttendance(String classroomId) async {
    if (homeClassId == classroomId) {
      return;
    }
    homeClassId = classroomId;
    _homeClassUserRole.value = currentUser.classrooms[classroomId];

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

  Future<void> changeStudentAttendanceStatus({
    required String classroomId,
    required String attendanceId,
    required Map<String, dynamic> studentData,
  }) async {
    try {
      _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroomId)
          .collection(attendanceCollection)
          .doc(attendanceId)
          .update({'studentsData': studentData});
    } catch (e) {
      dev.log(e.toString());
    }
  }

  /// Control selected user role
  final _selectedUserRole = 'Student'.obs;

  String get selectedUserRole => _selectedUserRole.value;

  set selectedUserRole(String value) => _selectedUserRole.value = value;

  Future<void> changeUserRole({
    required Map<String, dynamic> user,
    required ClassroomModel classroom,
    required String currentRole,
  }) async {
    if (selectedUserRole == currentRole) {
      return;
    }

    if (currentRole == 'Teacher') {
      classroom.teachers
          .removeWhere((element) => element['authUid'] == user['authUid']);
    } else if (currentRole == 'CR') {
      classroom.cRs
          .removeWhere((element) => element['authUid'] == user['authUid']);
    } else if (currentRole == 'Student') {
      classroom.students
          .removeWhere((element) => element['authUid'] == user['authUid']);
    }

    if (selectedUserRole == 'Teacher') {
      classroom.teachers.add(user);
    } else if (selectedUserRole == 'CR') {
      classroom.cRs.add(user);
    } else if (selectedUserRole == 'Student') {
      classroom.students.add(user);
    }

    // Updating firestore data
    try {
      final selectedUserDoc = await _firestoreInstance
          .collection(userCollection)
          .doc(user['authUid'])
          .get();
      final selectedUser = UserModel.fromJson(selectedUserDoc.data()!);
      selectedUser.classrooms[classroom.classroomId] = selectedUserRole;
      _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroom.classroomId)
          .update({
        'teachers': classroom.teachers,
        'cRs': classroom.cRs,
        'students': classroom.students,
      });
      _firestoreInstance
          .collection(userCollection)
          .doc(user['authUid'])
          .update({
        'classrooms': selectedUser.classrooms,
      });
    } catch (e) {
      dev.log(e.toString());
    }
  }

  /// Open Attendance
  Future<void> changeOpenAttendance(
      String classroomId, String openAttendance) async {
    try {
      _firestoreInstance
          .collection(classroomsCollection)
          .doc(classroomId)
          .update({'openAttendance': openAttendance});
    } catch (e) {
      dev.log(e.toString());
    }
  }

  Stream<ClassroomModel> classroomStream(String classroomId) {
    return _firestoreInstance
        .collection(classroomsCollection)
        .doc(classroomId)
        .snapshots()
        .map((documentSnapshot) {
      return documentSnapshot.data() != null
          ? ClassroomModel.fromJson(documentSnapshot.data()!)
          : ClassroomModel.empty();
    });
  }
}
