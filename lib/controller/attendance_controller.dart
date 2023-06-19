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

class AttendanceController extends GetxController {
  final _attendances = <AttendanceModel>[].obs;

  List<AttendanceModel> get attendances => _attendances;

  final _classroomData = ClassroomModel.empty().obs;

  ClassroomModel get classroomData => _classroomData.value;

  List<UserModel> studentsData = [];
  final _currentUserRole = 'Student'.obs;
  String get currentUserRole => _currentUserRole.value;

  Map<int, RecognitionModel> totalRecognized = {};

  Map<String, RecognitionModel> matchedStudents = {}; // String is user.authUid

  Future<void> updateValues(ClassroomModel classroom) async {
    _classroomData.value = classroom;
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    _attendances.value = await cloudFirestoreController
        .getClassroomAttendances(classroom.classroomId);
    final currentUser = cloudFirestoreController.currentUser;
    if(_classroomData.value.teachers.any((element) =>
        element['authUid'] == currentUser.authUid)){
      _currentUserRole.value = 'Teacher';
    } else if(_classroomData.value.cRs.any((element) =>
    element['authUid'] == currentUser.authUid)){
      _currentUserRole.value = 'CR';
    }

    print('The current user is : ${currentUser.authUid}');
    print('The current user is : $currentUserRole');
  }

  Future<void> getStudentsData() async {
    List<String> allStudentsUid = [];
    for (var student in classroomData.students + classroomData.cRs) {
      allStudentsUid.add(student['authUid']);
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
        dateTime: DateTime.now().toString(),
        counts: counts,
        studentsData: [],
        takenBy: takenBy);
    for (var student in studentsData) {
      final studentData = {
        'authUid': student.authUid,
        'name': student.name,
        'userId': student.userId,
        'status': 'Absent',
      };
      if (matchedStudents.containsKey(student.authUid)) {
        studentData['status'] = 'Present';
      }
      attendanceData.studentsData.add(studentData);
    }

    await cloudFirestoreController.saveAttendanceData(
        classroomData.classroomId, attendanceData);
  }
}
