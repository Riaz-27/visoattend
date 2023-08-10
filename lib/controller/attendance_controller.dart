import 'dart:developer' as dev;

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/leave_request_model.dart';
import '../models/attendance_model.dart';
import '../models/classroom_model.dart';
import '../models/recognition_model.dart';
import '../models/user_model.dart';
import 'cloud_firestore_controller.dart';
import 'leave_request_controller.dart';
import 'timer_controller.dart';

class AttendanceController extends GetxController {
  final _attendances = <AttendanceModel>[].obs;

  List<AttendanceModel> get attendances => _attendances;

  final _filteredAttendances = <AttendanceModel>[].obs;

  List<AttendanceModel> get filteredAttendances => _filteredAttendances;

  final _classroomData = ClassroomModel.empty().obs;

  ClassroomModel get classroomData => _classroomData.value;

  final _teachersData = <UserModel>[].obs;

  List<UserModel> get teachersData => _teachersData;
  final _cRsData = <UserModel>[].obs;

  List<UserModel> get cRsData => _cRsData;
  final _studentsData = <UserModel>[].obs;

  List<UserModel> get studentsData => _studentsData;

  final _currentUserRole = ''.obs;

  String get currentUserRole => _currentUserRole.value;

  final _currentUserMissedClasses = 0.obs;

  int get currentUserMissedClasses => _currentUserMissedClasses.value;

  Map<int, RecognitionModel> totalRecognized = {};

  Map<String, RecognitionModel> matchedStudents = {}; // String is user.authUid

  final _attendanceCount = 1.obs;

  int get attendanceCount => _attendanceCount.value;

  set attendanceCount(int value) => _attendanceCount.value = value;

  final _isAttendanceLoading = false.obs;

  bool get isAttendanceLoading => _isAttendanceLoading.value;

  set isAttendanceLoading(value) => _isAttendanceLoading.value = value;

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

  Future<void> loadDataOfClassroom(ClassroomModel classroom) async {
    await updateValues(classroom);
    await getUsersData();
  }

  void updateRootClassesValue() {
    if (classroomData.isArchived) return;

    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final classIndex = cloudFirestoreController.classrooms.indexWhere(
        (classroom) => classroom.classroomId == classroomData.classroomId);

    if (classIndex < 0) return;

    cloudFirestoreController.classrooms[classIndex] = classroomData;
    cloudFirestoreController.filterClassesOfToday();
  }

  Future<void> updateValues(ClassroomModel classroom,
      {bool forLive = false}) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    _classroomData.bindStream(
        cloudFirestoreController.classroomStream(classroom.classroomId));
    // _classroomData.value = classroom;
    _attendances.value = await cloudFirestoreController
        .getClassroomAttendances(classroom.classroomId);
    _currentUserRole.value = cloudFirestoreController
        .currentUser.classrooms[_classroomData.value.classroomId];

    _filteredAttendances.value = _attendances;

    final classCount = classroom
        .weekTimes[DateFormat('EEEE').format(DateTime.now())]['classCount'];
    _attendanceCount.value =
        classCount == null || classCount == '' ? 1 : int.parse(classCount);

    dev.log(
        'The current user is : ${cloudFirestoreController.currentUser.authUid}');
    dev.log('The current user is : $currentUserRole');
    dev.log('The classroom Data : ${classroomData.openAttendance}');
    if (forLive) {
      return;
    }
    if (currentUserRole == 'Student') {
      return;
    }
    //Check for open attendance
    final dbOpenAttendance = _classroomData.value.openAttendance;

    if (dbOpenAttendance != 'off' && dbOpenAttendance != 'always') {
      await checkOpenCloseAttendance(dbOpenAttendance);
    }
  }

  void filterAttendances(String value) {
    _filteredAttendances.value = _attendances.where((attendance) {
      final attendanceDate = DateFormat('dd MMMM y')
          .format(DateTime.fromMillisecondsSinceEpoch(attendance.dateTime));
      return attendanceDate.toLowerCase().contains(value.toLowerCase());
    }).toList();
  }

  Future<void> checkOpenCloseAttendance(String dbOpenAttendance) async {
    final timerController = Get.find<TimerController>();
    final now = DateTime.now();
    final dbDateTime = DateTime.parse(dbOpenAttendance);
    final timeDiff = dbDateTime.difference(now).inSeconds;
    dev.log('Time Diff : $timeDiff');
    if (timeDiff > 0) {
      timerController.startAttendanceTimer(timeDiff);
    } else {
      timerController.cancelAttendanceTimer();
      await closeAttendance();
    }
  }

  Future<void> getUsersData() async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    List<String> allTeachersUid = [];
    List<String> allCRsUid = [];
    List<String> allStudentsUid = [];
    for (var teacher in classroomData.teachers) {
      allTeachersUid.add(teacher['authUid']);
    }

    _teachersData.value =
        await cloudFirestoreController.getUsersOfClassroom(allTeachersUid);

    for (var cr in classroomData.cRs) {
      allCRsUid.add(cr['authUid']);
    }
    for (var student in classroomData.students) {
      allStudentsUid.add(student['authUid']);
    }
    if ((allCRsUid + allStudentsUid).isEmpty) {
      dev.log('No Students in this class');
      return;
    }
    _cRsData.value =
        await cloudFirestoreController.getUsersOfClassroom(allCRsUid);
    _studentsData.value =
        await cloudFirestoreController.getUsersOfClassroom(allStudentsUid);

    // sorting by id
    // _teachersData.sort((a, b) => a.userId.compareTo(b.userId));
    _cRsData.sort((a, b) => a.userId.compareTo(b.userId));
    _studentsData.sort((a, b) => a.userId.compareTo(b.userId));
  }

  Future<void> setMatchedStudents() async {
    matchedStudents.clear();
    totalRecognized.forEach((key, value) {
      if (value.userOrNot is UserModel) {
        final authUid = value.userOrNot.authUid;
        matchedStudents[authUid] = value;
      }
    });
  }

  Future<void> saveDataToFirestore({bool isEmpty = false}) async {
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
      studentsData: {},
      takenBy: takenBy,
    );
    final totalStudents = cRsData.toList() + studentsData.toList();
    for (var student in totalStudents) {
      attendanceData.studentsData[student.authUid] = 'Absent';
      if (!isEmpty && matchedStudents.containsKey(student.authUid)) {
        attendanceData.studentsData[student.authUid] = 'Present';
      }
    }
    if (currentUserRole == 'CR') {
      attendanceData.studentsData[currentUser.authUid] = 'Present';
    }

    //Check for leave request data
    final leaveRequestController = Get.find<LeaveRequestController>();
    for (LeaveRequestModel request
        in leaveRequestController.activeLeaveRequests) {
      final userAuthUid = request.userAuthUid;
      if (attendanceData.studentsData[userAuthUid] == 'Absent') {
        attendanceData.studentsData[userAuthUid] = 'Present(Leave)';
      }
    }

    for (int i = 0; i < attendanceCount; i++) {
      await cloudFirestoreController
          .saveAttendanceData(classroomData.classroomId, attendanceData)
          .then((attendance) => _attendances.insert(0, attendance));
    }
  }

  // Checking and updating previous attendance on leave request approved
  Future<void> updateAttendanceOnApprove(LeaveRequestModel leaveRequest) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final fromDateTime = DateTime.parse(leaveRequest.fromDate);
    final toDateTime = DateTime.parse(leaveRequest.toDate);

    for (int i = 0; i < _attendances.length; i++) {
      final attendanceDateTime =
          DateTime.fromMillisecondsSinceEpoch(_attendances[i].dateTime);
      if (attendanceDateTime.isAfter(fromDateTime) &&
          attendanceDateTime.isBefore(toDateTime)) {
        if (_attendances[i].studentsData[leaveRequest.userAuthUid] ==
            'Absent') {
          _attendances[i].studentsData[leaveRequest.userAuthUid] =
              'Present(Leave)';
          await cloudFirestoreController.changeStudentAttendanceStatus(
            classroomId: classroomData.classroomId,
            attendanceId: _attendances[i].attendanceId,
            studentData: _attendances[i].studentsData,
          );
        }
      }
    }
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

  int getUserMissedClassesCount(String userAuthUid) {
    int missedClasses = 0;
    for (AttendanceModel attendance in _attendances) {
      if (attendance.studentsData[userAuthUid] == 'Absent' ||
          attendance.studentsData[userAuthUid] == null) {
        missedClasses++;
      }
    }
    return missedClasses;
  }

  Future<void> openAttendance(String duration) async {
    if (duration == '') {
      try {
        await Get.find<CloudFirestoreController>()
            .changeOpenAttendance(classroomData.classroomId, 'always');
      } catch (e) {
        return;
      }
    } else {
      final min = int.parse(duration);
      final time = DateTime.now().add(Duration(minutes: min));
      try {
        await Get.find<CloudFirestoreController>()
            .changeOpenAttendance(classroomData.classroomId, time.toString());
        Get.find<TimerController>().startAttendanceTimer(min * 60);
      } catch (e) {
        return;
      }
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

  final _selectedDateTime = DateTime.now().obs;

  DateTime get selectedDateTime => _selectedDateTime.value;

  set selectedDateTime(DateTime dateTime) => _selectedDateTime.value = dateTime;

  final _allStudents = <UserModel>[].obs;

  List<UserModel> get allStudents => _allStudents;

  final _filteredStudents = <UserModel>[].obs;

  List<UserModel> get filteredStudents => _filteredStudents;

  final _selectedAttendanceStatus = ''.obs;

  String get selectedAttendanceStatus => _selectedAttendanceStatus.value;

  set selectedAttendanceStatus(String value) =>
      _selectedAttendanceStatus.value = value;

  final _selectedCategory = ''.obs;

  String get selectedCategory => _selectedCategory.value;

  set selectedCategory(String val) => _selectedCategory.value = val;

  void fetchStudentsStatus() {
    if (selectedAttendance == AttendanceModel.empty()) {
      return;
    }

    List<UserModel> tempStudents = studentsData.toList() + cRsData.toList();

    tempStudents.sort((a, b) => a.userId.compareTo(b.userId));

    _allStudents(tempStudents);
    _filteredStudents(tempStudents);

    // setting attendance current date and time
    _selectedDateTime.value =
        DateTime.fromMillisecondsSinceEpoch(_selectedAttendance.value.dateTime);
  }

  Future<void> changeStudentAttendanceStatus({
    required UserModel student,
  }) async {
    _selectedAttendance.value.studentsData[student.authUid] =
        selectedAttendanceStatus;

    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.changeStudentAttendanceStatus(
      classroomId: classroomData.classroomId,
      attendanceId: selectedAttendance.attendanceId,
      studentData: selectedAttendance.studentsData,
    );

    selectedCategoryResult(forceUpdate: true);
  }

  //filtering classroom for the search result
  String _searchedValue = '';

  void filterSearchResult(String value) {
    _searchedValue = value;
    _filteredStudents.value = _allStudents;
    value = value.toLowerCase();
    _filteredStudents.value = _allStudents
        .where((student) =>
            student.name.toLowerCase().contains(value.toLowerCase()) ||
            student.userId.toLowerCase().contains(value.toLowerCase()))
        .toList();
  }

  void selectedCategoryResult({bool forceUpdate = false}) {
    if (forceUpdate) {
      filterSearchResult(_searchedValue);
    }
    _selectedCategory.listen((_) => filterSearchResult(_searchedValue));
    if (selectedCategory == '') {
      return;
    }
    String finalCategory = _selectedCategory.value;
    if (finalCategory.contains('Leave')) {
      finalCategory = 'Present(Leave)';
    }

    _filteredStudents.value = _filteredStudents
        .where(
          (student) =>
              _selectedAttendance.value.studentsData[student.authUid] ==
              finalCategory,
        )
        .toList();
  }

  Future<void> updateAttendanceDateTime(AttendanceModel attendance) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.updateAttendanceDateTime(
      classroomData.classroomId,
      attendance,
    );
    _attendances.value = await cloudFirestoreController
        .getClassroomAttendances(classroomData.classroomId);
  }

  Future<void> deleteAttendance(AttendanceModel attendance) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.deleteAttendanceData(
      classroomData.classroomId,
      attendance.attendanceId,
    );
    _attendances.remove(attendance);
    _filteredAttendances.remove(attendance);
  }

  void resetAllValues() {
    _selectedAttendance.value = AttendanceModel.empty();
  }
}
