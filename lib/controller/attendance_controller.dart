import 'package:get/get.dart';
import 'package:visoattend/controller/user_database_controller.dart';

import '../models/attendance_model.dart';
import '../models/classroom_model.dart';
import '../models/recognition_model.dart';
import '../models/user_model.dart';
import 'camera_service_controller.dart';
import 'cloud_firestore_controller.dart';
import 'face_detector_controller.dart';
import 'recognition_controller.dart';
import 'timer_controller.dart';

class AttendanceController extends GetxController {
  final _attendances = <AttendanceModel>[].obs;

  List<AttendanceModel> get attendances => _attendances;

  final _classroomData = ClassroomModel.empty().obs;

  ClassroomModel get classroomData => _classroomData.value;

  List<UserModel> studentsData = [];

  final _currentUserRole = ''.obs;

  String get currentUserRole => _currentUserRole.value;

  final _currentUserMissedClasses = 0.obs;

  int get currentUserMissedClasses => _currentUserMissedClasses.value;

  Map<int, RecognitionModel> totalRecognized = {};

  Map<String, RecognitionModel> matchedStudents = {}; // String is user.authUid

  int openAttendanceTimerSec = 300;

  @override
  onInit() {
    ever(_attendances, (_) => calculateMissedClass());
    ever(_selectedAttendance, (_) => fetchStudentsStatus());
    ever(_classroomData, (_) => updateRootClassesValue());
    super.onInit();
  }

  @override
  void dispose() {
    Get.find<TimerController>().cancelAttendanceTimer();
    super.dispose();
  }

  @override
  InternalFinalCallback<void> get onDelete {
    Get.find<TimerController>().cancelAttendanceTimer();
    return super.onDelete;
  }

  void updateRootClassesValue() {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final classIndex = cloudFirestoreController.classrooms.indexWhere(
        (classroom) => classroom.classroomId == classroomData.classroomId);
    cloudFirestoreController.classrooms[classIndex] = classroomData;
    cloudFirestoreController.filterClassesOfToday();
  }

  Future<void> updateValues(ClassroomModel classroom, {bool forLive = false}) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    _classroomData.bindStream(
        cloudFirestoreController.classroomStream(classroom.classroomId));
    // _classroomData.value = classroom;
    _attendances.value = await cloudFirestoreController
        .getClassroomAttendances(classroom.classroomId);
    _currentUserRole.value = cloudFirestoreController
        .currentUser.classrooms[_classroomData.value.classroomId];

    print(
        'The current user is : ${cloudFirestoreController.currentUser.authUid}');
    print('The current user is : $currentUserRole');
    print('The clasroom Data : ${classroomData.openAttendance}');
    if(forLive){
      return;
    }
    if (currentUserRole == 'Student') {
      return;
    }
    //Check for open attendance
    final dbOpenAttendance = _classroomData.value.openAttendance;

    if (dbOpenAttendance != 'off') {
      await checkOpenCloseAttendance(dbOpenAttendance);
    }
  }

  Future<void> checkOpenCloseAttendance(String dbOpenAttendance) async {
    final timerController = Get.find<TimerController>();
    final now = DateTime.now();
    final dbDateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(dbOpenAttendance));
    final dbTimeSeconds =
        (dbDateTime.minute * 60 + dbDateTime.second) + openAttendanceTimerSec;
    final nowTimeSeconds = now.minute * 60 + now.second;
    final timeDiff = dbTimeSeconds - nowTimeSeconds;
    if (timeDiff > 0) {
      timerController.startAttendanceTimer(timeDiff);
    } else {
      timerController.cancelAttendanceTimer();
      await closeAttendance();
    }
  }

  Future<void> getStudentsData() async {
    List<String> allStudentsUid = [];
    for (var student in classroomData.students + classroomData.cRs) {
      allStudentsUid.add(student['authUid']);
    }
    if (allStudentsUid.isEmpty) {
      print('No Students in this class');
      return;
    }
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    studentsData =
        await cloudFirestoreController.getStudentsOfClassroom(allStudentsUid);
  }

  Future<void> setMatchedStudents() async {
    totalRecognized.forEach((key, value) {
      if (value.userOrNot is UserModel) {
        final authUid = value.userOrNot.authUid;
        matchedStudents[authUid] = value;
      }
    });
  }

  Future<void> saveDataToFirestore({int counts = 1}) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final currentUser = cloudFirestoreController.currentUser;
    final takenBy = {
      'authUid': currentUser.authUid,
      'name': currentUser.name,
      'userId': currentUser.userId,
    };
    AttendanceModel attendanceData = AttendanceModel(
      attendanceId: '',
      dateTime: DateTime.now().millisecondsSinceEpoch,
      counts: counts,
      studentsData: {},
      takenBy: takenBy,
    );
    for (var student in studentsData) {
      attendanceData.studentsData[student.authUid] = 'Absent';
      if (matchedStudents.containsKey(student.authUid)) {
        attendanceData.studentsData[student.authUid] = 'Present';
      }
    }

    await cloudFirestoreController
        .saveAttendanceData(classroomData.classroomId, attendanceData)
        .then((attendance) => _attendances.insert(0, attendance));
  }

  void calculateMissedClass() {
    final userAuthUid =
        Get.find<CloudFirestoreController>().currentUser.authUid;
    _currentUserMissedClasses.value = 0;
    for (AttendanceModel attendance in _attendances) {
      if (attendance.studentsData[userAuthUid] == 'Absent' ||
          attendance.studentsData[userAuthUid] == null) {
        _currentUserMissedClasses.value++;
      }
    }
  }

  double getUserAttendancePercent(String userAuthUid) {
    int missedClasses = 0;
    final totalClasses = _attendances.length;
    for (AttendanceModel attendance in _attendances) {
      if (attendance.studentsData[userAuthUid] == 'Absent' ||
          attendance.studentsData[userAuthUid] == null) {
        missedClasses++;
      }
    }
    return totalClasses > 0 ? (totalClasses - missedClasses) / totalClasses : 0;
  }

  Future<void> openAttendance() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await Get.find<CloudFirestoreController>()
          .changeOpenAttendance(classroomData.classroomId, now);
      Get.find<TimerController>().startAttendanceTimer(openAttendanceTimerSec);
    } catch (e) {
      return;
    }
  }

  Future<void> closeAttendance() async {
    const now = 'off';
    try {
      await Get.find<CloudFirestoreController>()
          .changeOpenAttendance(classroomData.classroomId, now);
      Get.find<TimerController>().cancelAttendanceTimer();
    } catch (e) {
      return;
    }
  }

  /// For controlling selected attendance details

  final Rx<AttendanceModel> _selectedAttendance = AttendanceModel.empty().obs;

  AttendanceModel get selectedAttendance => _selectedAttendance.value;

  set selectedAttendance(AttendanceModel value) =>
      _selectedAttendance.value = value;

  final _presentStudents = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get presentStudents => _presentStudents;

  final _absentStudents = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get absentStudents => _absentStudents;

  final _filteredStudents = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get filteredStudents => _filteredStudents;

  final _selectedAttendanceStatus = ''.obs;

  String get selectedAttendanceStatus => _selectedAttendanceStatus.value;

  set selectedAttendanceStatus(String value) =>
      _selectedAttendanceStatus.value = value;

  void fetchStudentsStatus() {
    if (selectedAttendance == AttendanceModel.empty()) {
      return;
    }
    List<Map<String, dynamic>> tempPresents = [];
    List<Map<String, dynamic>> tempAbsent = [];
    for (var student in classroomData.cRs + classroomData.students) {
      if (selectedAttendance.studentsData[student['authUid']] == 'Present') {
        tempPresents.add(student);
      } else {
        tempAbsent.add(student);
      }
    }

    tempPresents.sort((a, b) {
      return a['userId'].compareTo(b['userId']);
    });
    tempAbsent.sort((a, b) {
      return a['userId'].compareTo(b['userId']);
    });

    _presentStudents.value = tempPresents;
    _absentStudents.value = tempAbsent;
  }

  Future<void> changeStudentAttendanceStatus({
    required Map<String, dynamic> student,
  }) async {
    _selectedAttendance.value.studentsData[student['authUid']] =
        selectedAttendanceStatus;

    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.changeStudentAttendanceStatus(
      classroomId: classroomData.classroomId,
      attendanceId: selectedAttendance.attendanceId,
      studentData: selectedAttendance.studentsData,
    );
  }

  //filtering classroom for the search result
  void filterSearchResult(String value, bool isPresent) {
    _filteredStudents.value = [];
    final studentData = isPresent ? presentStudents : absentStudents;

    if (value.isEmpty) {
      _filteredStudents.value = studentData;
    } else {
      value = value.toLowerCase();
      _filteredStudents.value = studentData
          .where((student) =>
              student['name'].toLowerCase().contains(value) ||
              student['userId'].toLowerCase().contains(value))
          .toList();
    }
  }
}
